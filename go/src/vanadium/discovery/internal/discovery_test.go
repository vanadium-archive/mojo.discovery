// Copyright 2015 The Vanadium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

package internal

import (
	"errors"
	"fmt"
	"reflect"
	"runtime"
	"testing"
	"time"

	mojom "mojom/vanadium/discovery"

	"v.io/v23/discovery"

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

	services := []discovery.Service{
		{
			InstanceId:    "123",
			InterfaceName: "v.io/v23/a",
			Attrs:         discovery.Attributes{"a1": "v1"},
			Addrs:         []string{"/h1:123/x"},
		},
		{
			InterfaceName: "v.io/v23/b",
			Attrs:         discovery.Attributes{"b1": "v1"},
			Addrs:         []string{"/h1:123/y"},
		},
	}

	d1 := NewDiscovery(ctx)

	for i, service := range services {
		instanceId, merr, err := d1.StartAdvertising(mkMojomService(service), nil)
		if merr != nil || err != nil {
			t.Fatalf("failed to advertise service: %v, %v", merr, err)
		}
		if len(instanceId) == 0 {
			t.Errorf("service[%d]: got empty instance id", i)
		}

		if len(service.InstanceId) == 0 {
			services[i].InstanceId = instanceId
		} else if instanceId != service.InstanceId {
			t.Errorf("service[%d]: got instance id %v, but wanted %v", i, instanceId, service.InstanceId)
		}
	}

	// Make sure none of advertisements are discoverable by the same discovery instance.
	if err := scanAndMatch(d1, ""); err != nil {
		t.Error(err)
	}

	// Create a new discovery instance. All advertisements should be discovered with that.
	d2 := NewDiscovery(ctx)

	if err := scanAndMatch(d2, `v.InterfaceName="v.io/v23/a"`, services[0]); err != nil {
		t.Error(err)
	}
	if err := scanAndMatch(d2, `v.InterfaceName="v.io/v23/b"`, services[1]); err != nil {
		t.Error(err)
	}
	if err := scanAndMatch(d2, "", services...); err != nil {
		t.Error(err)
	}

	// Open a new scan channel and consume expected advertisements first.
	scanCh, scanStop, err := startScan(d2, `v.InterfaceName="v.io/v23/a"`)
	if err != nil {
		t.Fatal(err)
	}
	defer scanStop()
	update := <-scanCh
	if !matchFound([]mojom.Update{update}, services[0]) {
		t.Errorf("unexpected scan: %v", update)
	}

	// Make sure scan returns the lost advertisement when advertising is stopped.
	d1.StopAdvertising(services[0].InstanceId)

	update = <-scanCh
	if !matchLost([]mojom.Update{update}, services[0]) {
		t.Errorf("unexpected scan: %v", update)
	}

	// Also it shouldn't affect the other.
	if err := scanAndMatch(d2, `v.InterfaceName="v.io/v23/b"`, services[1]); err != nil {
		t.Error(err)
	}

	// Stop advertising the remaining one; Shouldn't discover any service.
	d1.StopAdvertising(services[1].InstanceId)
	if err := scanAndMatch(d2, ""); err != nil {
		t.Error(err)
	}
}

type mockScanHandler struct {
	ch chan mojom.Update
}

func (m *mockScanHandler) Update(u mojom.Update) error {
	m.ch <- u
	return nil
}
func (m *mockScanHandler) Close_Proxy() { close(m.ch) }

func startScan(d mojom.Discovery, query string) (<-chan mojom.Update, func(), error) {
	ch := make(chan mojom.Update)
	scanId, merr, err := d.(*mdiscovery).startScan(query, &mockScanHandler{ch})
	if merr != nil {
		return nil, nil, errors.New(merr.Msg)
	}
	if err != nil {
		return nil, nil, err
	}

	stop := func() { d.StopScan(scanId) }
	return ch, stop, nil
}

func scan(d mojom.Discovery, query string) ([]mojom.Update, error) {
	ch, stop, err := startScan(d, query)
	if err != nil {
		return nil, err
	}
	defer stop()

	var updates []mojom.Update
	for {
		select {
		case update := <-ch:
			updates = append(updates, update)
		case <-time.After(5 * time.Millisecond):
			return updates, nil
		}
	}
}

func scanAndMatch(d mojom.Discovery, query string, wants ...discovery.Service) error {
	const timeout = 3 * time.Second

	var updates []mojom.Update
	for now := time.Now(); time.Since(now) < timeout; {
		runtime.Gosched()

		var err error
		updates, err = scan(d, query)
		if err != nil {
			return err
		}
		if matchFound(updates, wants...) {
			return nil
		}
	}
	return fmt.Errorf("Match failed; got %v, but wanted %v", updates, wants)
}

func match(updates []mojom.Update, updateType mojom.UpdateType, wants ...discovery.Service) bool {
	for _, want := range wants {
		matched := false
		for i, update := range updates {
			if update.UpdateType == updateType && reflect.DeepEqual(update.Service, mkMojomService(want)) {
				updates = append(updates[:i], updates[i+1:]...)
				matched = true
				break
			}
		}
		if !matched {
			return false
		}
	}
	return len(updates) == 0
}

func matchFound(updates []mojom.Update, wants ...discovery.Service) bool {
	return match(updates, mojom.UpdateType_Found, wants...)
}

func matchLost(updates []mojom.Update, wants ...discovery.Service) bool {
	return match(updates, mojom.UpdateType_Lost, wants...)
}

func mkMojomService(service discovery.Service) mojom.Service {
	mservice := mojom.Service{
		InstanceId:    &service.InstanceId,
		InterfaceName: service.InterfaceName,
		Addrs:         service.Addrs,
	}
	if len(service.InstanceName) > 0 {
		mservice.InstanceName = &service.InstanceName
	}
	if len(service.Attrs) > 0 {
		attrs := map[string]string(service.Attrs)
		mservice.Attrs = &attrs
	}
	if len(service.Attachments) > 0 {
		attachments := map[string][]byte(service.Attachments)
		mservice.Attachments = &attachments
	}
	return mservice
}
