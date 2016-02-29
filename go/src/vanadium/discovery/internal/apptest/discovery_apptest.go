// Copyright 2016 The Vanadium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

// +build mojo

package apptest

import (
	"bytes"
	"errors"
	"fmt"
	"log"
	"reflect"
	"testing"
	"time"

	"mojo/public/go/application"
	"mojo/public/go/bindings"
	"mojo/public/go/system"

	"mojom/vanadium/discovery"

	idiscovery "v.io/x/ref/lib/discovery"
	dfactory "v.io/x/ref/lib/discovery/factory"
	"v.io/x/ref/lib/discovery/plugins/mock"
	_ "v.io/x/ref/runtime/factories/generic"
	"v.io/x/ref/test"

	"vanadium/discovery/internal"
)

func AppTestBasic(t *testing.T, mctx application.Context) {
	ctx, shutdown := test.V23Init(mctx)
	defer shutdown()

	df, _ := idiscovery.NewFactory(ctx, mock.New())
	dfactory.InjectFactory(df)

	ads := []discovery.Advertisement{
		{
			Id:            &[internal.AdIdLen]uint8{1, 2, 3},
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

	d1 := internal.NewDiscovery(ctx)
	defer d1.Close()

	var stops []func()
	for i, ad := range ads {
		id, closer, e1, e2 := d1.Advertise(ad, nil)
		if e1 != nil || e2 != nil {
			t.Fatalf("ad[%d]: failed to advertise: %v, %v", i, e1, e2)
		}
		if id == nil {
			t.Errorf("ad[%d]: got nil id", i)
			continue
		}
		if ad.Id == nil {
			ads[i].Id = id
		} else if *id != *ad.Id {
			t.Errorf("ad[%d]: got ad id %v, but wanted %v", i, *id, *ad.Id)
		}

		stop := func() {
			p := discovery.NewCloserProxy(*closer, bindings.GetAsyncWaiter())
			p.Close()
			p.Close_Proxy()
		}
		stops = append(stops, stop)
	}

	// Make sure none of advertisements are discoverable by the same discovery instance.
	if err := scanAndMatch(d1, ""); err != nil {
		t.Error(err)
	}

	// Create a new discovery instance. All advertisements should be discovered with that.
	d2 := internal.NewDiscovery(ctx)
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
	scanCh, stop, err := scan(d2, `v.InterfaceName="v.io/v23/a"`)
	if err != nil {
		t.Fatal(err)
	}
	defer stop()
	update := <-scanCh
	if !matchFound([]*discovery.Update_Proxy{update}, ads[0]) {
		t.Errorf("unexpected scan: %v", update)
	}

	// Make sure scan returns the lost advertisement when advertising is stopped.
	stops[0]()

	update = <-scanCh
	if !matchLost([]*discovery.Update_Proxy{update}, ads[0]) {
		t.Errorf("unexpected scan: %v", update)
	}

	// Also it shouldn't affect the other.
	if err := scanAndMatch(d2, `v.InterfaceName="v.io/v23/b"`, ads[1]); err != nil {
		t.Error(err)
	}

	// Stop advertising the remaining one; Shouldn't discover any advertisements.
	stops[1]()
	if err := scanAndMatch(d2, ""); err != nil {
		t.Error(err)
	}
}

type mockScanHandler struct {
	ch chan *discovery.Update_Proxy
}

func (h *mockScanHandler) OnUpdate(ptr discovery.Update_Pointer) error {
	h.ch <- discovery.NewUpdateProxy(ptr, bindings.GetAsyncWaiter())
	return nil
}

func scan(d discovery.Discovery, query string) (<-chan *discovery.Update_Proxy, func(), error) {
	ch := make(chan *discovery.Update_Proxy)
	handler := &mockScanHandler{ch}
	req, ptr := discovery.CreateMessagePipeForScanHandler()
	stub := discovery.NewScanHandlerStub(req, handler, bindings.GetAsyncWaiter())

	closer, e1, e2 := d.Scan(query, ptr)
	if e1 != nil {
		close(ch)
		return nil, nil, errors.New(e1.Msg)
	}
	if e2 != nil {
		close(ch)
		return nil, nil, e2
	}

	go func() {
		for {
			if err := stub.ServeRequest(); err != nil {
				connErr, ok := err.(*bindings.ConnectionError)
				if !ok || !connErr.Closed() {
					log.Println(err)
				}
				break
			}
		}
	}()

	stop := func() {
		p := discovery.NewCloserProxy(*closer, bindings.GetAsyncWaiter())
		p.Close()
		p.Close_Proxy()
		close(ch)
	}
	return ch, stop, nil
}

func scanAndMatch(d discovery.Discovery, query string, wants ...discovery.Advertisement) error {
	const timeout = 3 * time.Second

	var updates []*discovery.Update_Proxy
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

func doScan(d discovery.Discovery, query string, expectedUpdates int) ([]*discovery.Update_Proxy, error) {
	scanCh, stop, err := scan(d, query)
	if err != nil {
		return nil, err
	}
	defer stop()

	updates := make([]*discovery.Update_Proxy, 0, expectedUpdates)
	for {
		timeout := 5 * time.Millisecond
		if len(updates) < expectedUpdates {
			// Increase the timeout if we do not receive enough updates
			// to avoid flakiness in unit tests.
			timeout = 1 * time.Second
		}

		select {
		case update := <-scanCh:
			updates = append(updates, update)
		case <-time.After(timeout):
			return updates, nil
		}
	}
}

func matchFound(updates []*discovery.Update_Proxy, wants ...discovery.Advertisement) bool {
	return match(updates, false, wants...)
}

func matchLost(updates []*discovery.Update_Proxy, wants ...discovery.Advertisement) bool {
	return match(updates, true, wants...)
}

func match(updates []*discovery.Update_Proxy, lost bool, wants ...discovery.Advertisement) bool {
	updateMap := make(map[[internal.AdIdLen]uint8]discovery.Update)
	for _, update := range updates {
		defer update.Close_Proxy()
		id, _ := update.GetId()
		updateMap[id] = update
	}

	for _, want := range wants {
		update := updateMap[*want.Id]
		if update == nil {
			return false
		}
		if !updateEqual(update, want) {
			return false
		}
		delete(updateMap, *want.Id)
	}
	return len(updateMap) == 0
}

func updateEqual(update discovery.Update, ad discovery.Advertisement) bool {
	if got, _ := update.GetId(); got != *ad.Id {
		return false
	}
	if got, _ := update.GetInterfaceName(); got != ad.InterfaceName {
		return false
	}
	if got, _ := update.GetAddresses(); !reflect.DeepEqual(got, ad.Addresses) {
		return false
	}
	if ad.Attributes != nil {
		for k, v := range *ad.Attributes {
			if got, _ := update.GetAttribute(k); got != v {
				return false
			}
		}
	}
	if ad.Attachments != nil {
		for k, v := range *ad.Attachments {
			h, err := update.GetAttachment(k)
			if err != nil {
				return false
			}
			defer h.Close()
			r, got := h.ReadData(system.MOJO_READ_DATA_FLAG_NONE)
			if r != system.MOJO_RESULT_OK {
				return false
			}
			if !bytes.Equal(got, v) {
				return false
			}
		}
	}
	if got, _ := update.GetAdvertisement(); !reflect.DeepEqual(got, ad) {
		return false
	}
	return true
}
