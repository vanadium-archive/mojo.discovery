// Copyright 2015 The Vanadium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

package internal

import (
	"reflect"
	"sync"
	"testing"

	"third_party/go/tool/android_arm/src/fmt"

	mojom "mojom/vanadium/discovery"

	"v.io/v23/context"
	"v.io/v23/discovery"
	"v.io/v23/security"

	idiscovery "v.io/x/ref/lib/discovery"
	dfactory "v.io/x/ref/lib/discovery/factory"
	_ "v.io/x/ref/runtime/factories/generic"
	vtest "v.io/x/ref/test"
)

type mockDiscovery struct {
	mu       sync.Mutex
	trigger  *idiscovery.Trigger
	id       int64
	services map[int64]discovery.Service
	// An item will be put in deleteCh when something has been deleted.
	deleteCh chan struct{}
}

func (d *mockDiscovery) Advertise(ctx *context.T, s discovery.Service, perms []security.BlessingPattern) (<-chan struct{}, error) {
	d.mu.Lock()
	currId := d.id
	d.services[currId] = s
	d.id++
	d.mu.Unlock()
	done := make(chan struct{})
	stop := func() {
		d.mu.Lock()
		delete(d.services, currId)
		d.mu.Unlock()
		close(done)

		go func() { d.deleteCh <- struct{}{} }()
	}
	d.trigger.Add(stop, ctx.Done())
	return done, nil
}

func (*mockDiscovery) Scan(ctx *context.T, query string) (<-chan discovery.Update, error) {
	return nil, nil
}

func (*mockDiscovery) Close() {}

func compare(want discovery.Service, got mojom.Service) error {
	mwant := v2mService(want)
	if !reflect.DeepEqual(mwant, got) {
		return fmt.Errorf("Got %#v want %#v", got, want)
	}
	return nil
}

func TestAdvertising(t *testing.T) {
	mock := &mockDiscovery{
		trigger:  idiscovery.NewTrigger(),
		services: map[int64]discovery.Service{},
		deleteCh: make(chan struct{}),
	}
	dfactory.InjectDiscovery(mock)

	ctx, shutdown := vtest.V23Init()
	defer shutdown()

	s := NewDiscoveryService(ctx)
	testService := mojom.Service{
		InterfaceName: "v.io/v23/discovery.T",
		Attrs: map[string]string{
			"key1": "value1",
			"key2": "value2",
		},
		InstanceName: "service1",
		Addrs:        []string{"addr1", "addr2"},
	}
	id, e1, e2 := s.Advertise(testService, nil)

	if e1 != nil || e2 != nil {
		t.Fatalf("Failed to start service: %v, %v", e1, e2)
	}
	if len(mock.services) != 1 {
		t.Errorf("service missing in mock")
	}

	for _, service := range mock.services {
		if err := compare(service, testService); err != nil {
			t.Error(err)
		}

	}

	testService2 := mojom.Service{
		InterfaceName: "v.io/v23/naming.T",
		Attrs: map[string]string{
			"key1": "value1",
			"key2": "value2",
		},
		InstanceName: "service2",
		Addrs:        []string{"addr1", "addr2"},
	}

	_, e1, e2 = s.Advertise(testService2, nil)
	if e1 != nil || e2 != nil {
		t.Fatalf("Failed to start service: %v, %v", e1, e2)
	}

	s.Stop(id)
	// Wait for the deletion to finish.
	<-mock.deleteCh
	if len(mock.services) != 1 {
		t.Errorf("service should have been removed")
	}

	for _, service := range mock.services {
		if err := compare(service, testService2); err != nil {
			t.Error(err)
		}

	}

	s.StopAll()
	<-mock.deleteCh
	if len(mock.services) != 0 {
		t.Errorf("service should have been removed")
	}
}
