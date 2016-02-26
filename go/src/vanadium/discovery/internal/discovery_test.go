// Copyright 2015 The Vanadium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

package internal

import (
	"fmt"
	"reflect"
	"testing"
	"time"

	mojom "mojom/vanadium/discovery"

	idiscovery "v.io/x/ref/lib/discovery"
	dfactory "v.io/x/ref/lib/discovery/factory"
	"v.io/x/ref/lib/discovery/plugins/mock"
	_ "v.io/x/ref/runtime/factories/generic"
	"v.io/x/ref/test"
)

func TestBasic(t *testing.T) {
	ctx, shutdown := test.V23Init()
	defer shutdown()

	df, _ := idiscovery.NewFactory(ctx, mock.New())
	dfactory.InjectFactory(df)

	ads := []mojom.Advertisement{
		{
			Id:            &[AdIdLen]uint8{1, 2, 3},
			InterfaceName: "v.io/v23/a",
			Addresses:     []string{"/h1:123/x"},
			Attributes:    &map[string]string{"a1": "v1"},
		},
		{
			InterfaceName: "v.io/v23/b",
			Addresses:     []string{"/h1:123/y"},
			Attributes:    &map[string]string{"b1": "v1"},
		},
	}

	d1 := NewDiscovery(ctx)
	defer d1.Close()

	var adClosers []mojom.Closer
	for i, _ := range ads {
		closer, err := d1.(*mdiscovery).doAdvertise(&ads[i], nil)
		if err != nil {
			t.Fatalf("ad[%d]: failed to advertise: %v", i, err)
		}
		if ads[i].Id == nil {
			t.Errorf("ad[%d]: got nil id", i)
		}
		adClosers = append(adClosers, closer)
	}

	// Make sure none of advertisements are discoverable by the same discovery instance.
	if err := scanAndMatch(d1, ""); err != nil {
		t.Error(err)
	}

	// Create a new discovery instance. All advertisements should be discovered with that.
	d2 := NewDiscovery(ctx)
	defer d2.Close()

	if err := scanAndMatch(d2, `v.InterfaceName="v.io/v23/a"`, ads[0]); err != nil {
		t.Error(err)
	}

	if err := scanAndMatch(d2, `v.InterfaceName="v.io/v23/b"`, ads[1]); err != nil {
		t.Error(err)
	}
	if err := scanAndMatch(d2, ``, ads...); err != nil {
		t.Error(err)
	}

	// Open a new scan channel and consume expected advertisements first.
	scanCh, scanCloser, err := scan(d2, `v.InterfaceName="v.io/v23/a"`)
	if err != nil {
		t.Fatal(err)
	}
	defer scanCloser.Close()
	update := <-scanCh
	if !matchFound([]mojom.Update{update}, ads[0]) {
		t.Errorf("unexpected scan: %v", update)
	}

	// Make sure scan returns the lost advertisement when advertising is stopped.
	adClosers[0].Close()

	update = <-scanCh
	if !matchLost([]mojom.Update{update}, ads[0]) {
		t.Errorf("unexpected scan: %v", update)
	}

	// Also it shouldn't affect the other.
	if err := scanAndMatch(d2, `v.InterfaceName="v.io/v23/b"`, ads[1]); err != nil {
		t.Error(err)
	}

	// Stop advertising the remaining one; Shouldn't discover any advertisements.
	adClosers[1].Close()
	if err := scanAndMatch(d2, ""); err != nil {
		t.Error(err)
	}
}

type mockScanHandler struct {
	ch chan mojom.Update
}

func (m *mockScanHandler) Close_Proxy() { close(m.ch) }
func (m *mockScanHandler) passUpdate(u mojom.Update) error {
	m.ch <- u
	return nil
}

func scan(d mojom.Discovery, query string) (<-chan mojom.Update, mojom.Closer, error) {
	ch := make(chan mojom.Update)
	closer, err := d.(*mdiscovery).doScan(query, &mockScanHandler{ch})
	if err != nil {
		return nil, nil, err
	}
	return ch, closer, nil
}

func scanAndMatch(d mojom.Discovery, query string, wants ...mojom.Advertisement) error {
	const timeout = 10 * time.Second

	var updates []mojom.Update
	for now := time.Now(); time.Since(now) < timeout; {
		var err error
		updates, err = doScan(d, query, len(wants))
		if err != nil {
			return err
		}
		if matchFound(updates, wants...) {
			return nil
		}
	}
	return fmt.Errorf("Match failed; got %v, but wanted %v", updates, wants)
}

func doScan(d mojom.Discovery, query string, expectedUpdates int) ([]mojom.Update, error) {
	scanCh, closer, err := scan(d, query)
	if err != nil {
		return nil, err
	}
	defer closer.Close()

	updates := make([]mojom.Update, 0, expectedUpdates)
	for {
		timeout := 5 * time.Millisecond
		if len(updates) < expectedUpdates {
			// Increase the timeout if we do not receive enough updates
			// to avoid flakiness in unit tests.
			timeout = 5 * time.Second
		}

		select {
		case update := <-scanCh:
			updates = append(updates, update)
		case <-time.After(timeout):
			return updates, nil
		}
	}
}

func matchFound(updates []mojom.Update, wants ...mojom.Advertisement) bool {
	return match(updates, false, wants...)
}

func matchLost(updates []mojom.Update, wants ...mojom.Advertisement) bool {
	return match(updates, true, wants...)
}

func match(updates []mojom.Update, lost bool, wants ...mojom.Advertisement) bool {
	updateMap := make(map[[AdIdLen]uint8]mojom.Update)
	for _, update := range updates {
		id, _ := update.GetId()
		updateMap[id] = update
	}

	for _, want := range wants {
		update := updateMap[*want.Id]
		if update == nil {
			return false
		}
		if got, _ := update.IsLost(); got != lost {
			return false
		}
		if got, _ := update.GetAdvertisement(); !reflect.DeepEqual(got, want) {
			return false
		}
		delete(updateMap, *want.Id)
	}
	return len(updateMap) == 0
}
