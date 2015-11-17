// Copyright 2015 The Vanadium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

package internal

import (
	"fmt"
	"math/rand"
	"reflect"
	"strconv"
	"sync"
	"testing"

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

func (d *mockDiscovery) Advertise(ctx *context.T, s *discovery.Service, perms []security.BlessingPattern) (<-chan struct{}, error) {
	if len(s.InstanceId) == 0 {
		s.InstanceId = strconv.Itoa(rand.Int())
	}
	d.mu.Lock()
	currId := d.id
	d.services[currId] = *s
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

func mkMojomService(instanceId, interfaceName string, attrs map[string]string, addrs []string) mojom.Service {
	return mojom.Service{
		InstanceId:    &instanceId,
		InterfaceName: interfaceName,
		Attrs:         &attrs,
		Addrs:         addrs,
	}
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

	ds := NewDiscoveryService(ctx)

	s1 := mkMojomService("s1", "v.io/discovery", map[string]string{"k1": "v1", "k2": "v2"}, []string{"addr1", "addr2"})
	h1, id1, e1, e2 := ds.Advertise(s1, nil)
	if e1 != nil || e2 != nil {
		t.Fatalf("failed to start service: %v, %v", e1, e2)
	}
	if got, want := id1, "s1"; got != want {
		t.Errorf("got instance id %s, but want %s", got, want)
	}
	if len(mock.services) != 1 {
		t.Errorf("service missing in mock")
	}

	for _, service := range mock.services {
		if err := compare(service, s1); err != nil {
			t.Error(err)
		}
	}

	s2 := mkMojomService("", "v.io/naming", map[string]string{"k1": "v1", "k2": "v2"}, []string{"addr3", "addr4"})
	_, id2, e1, e2 := ds.Advertise(s2, nil)
	if e1 != nil || e2 != nil {
		t.Fatalf("failed to start service: %v, %v", e1, e2)
	}
	if len(id2) == 0 {
		t.Error("empty instance id returned")
	}
	s2.InstanceId = &id2

	ds.Stop(h1)
	// Wait for the deletion to finish.
	<-mock.deleteCh
	if len(mock.services) != 1 {
		t.Errorf("service should have been removed")
	}

	for _, service := range mock.services {
		if err := compare(service, s2); err != nil {
			t.Error(err)
		}
	}

	ds.StopAll()
	<-mock.deleteCh
	if len(mock.services) != 0 {
		t.Errorf("service should have been removed")
	}
}
