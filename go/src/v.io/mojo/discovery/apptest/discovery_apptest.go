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
	"strings"
	"testing"
	"time"

	"mojo/public/go/application"
	"mojo/public/go/bindings"
	"mojo/public/go/system"

	mojom "mojom/v.io/discovery"

	_ "v.io/x/ref/runtime/factories/generic"

	"v.io/mojo/discovery/internal"
)

func newDiscovery(mctx application.Context) *mojom.Discovery_Proxy {
	req, ptr := mojom.CreateMessagePipeForDiscovery()
	mctx.ConnectToApplication("https://mojo.v.io/discovery.mojo").ConnectToService(&req)
	return mojom.NewDiscoveryProxy(ptr, bindings.GetAsyncWaiter())
}

func AppTestBasic(t *testing.T, mctx application.Context) {
	ads := []mojom.Advertisement{
		{
			Id:            &[internal.AdIdLen]uint8{1, 2, 3},
			InterfaceName: "v.io/v23/a",
			Addresses:     []string{"/h1:123/x"},
			Attributes:    &map[string]string{"a1": "v"},
			Attachments:   &map[string][]byte{"a2": []byte{1}},
		},
		{
			InterfaceName: "v.io/v23/b",
			Addresses:     []string{"/h1:123/y"},
			Attributes:    &map[string]string{"b1": "w"},
			Attachments:   &map[string][]byte{"b2": []byte{2}},
		},
	}

	d1 := newDiscovery(mctx)
	defer d1.Close_Proxy()

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
			p := mojom.NewCloserProxy(*closer, bindings.GetAsyncWaiter())
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
	d2 := newDiscovery(mctx)
	defer d2.Close_Proxy()

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
	if err := matchFound([]mojom.Update_Pointer{update}, ads[0]); err != nil {
		t.Error(err)
	}

	// Make sure scan returns the lost advertisement when advertising is stopped.
	stops[0]()

	update = <-scanCh
	if err := matchLost([]mojom.Update_Pointer{update}, ads[0]); err != nil {
		t.Error(err)
	}

	// Also it shouldn't affect the other.
	if err := scanAndMatch(d2, `v.InterfaceName="v.io/v23/b"`, ads[1]); err != nil {
		t.Error(err)
	}

	// Stop advertising the remaining one; Shouldn't discover any advertisements.
	stops[1]()
	if err := scanAndMatch(d2, ``); err != nil {
		t.Error(err)
	}
}

type mockScanHandler struct {
	ch chan mojom.Update_Pointer
}

func (h *mockScanHandler) OnUpdate(ptr mojom.Update_Pointer) error {
	h.ch <- ptr
	return nil
}

func scan(d mojom.Discovery, query string) (<-chan mojom.Update_Pointer, func(), error) {
	ch := make(chan mojom.Update_Pointer)
	handler := &mockScanHandler{ch}
	req, ptr := mojom.CreateMessagePipeForScanHandler()
	stub := mojom.NewScanHandlerStub(req, handler, bindings.GetAsyncWaiter())

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
		p := mojom.NewCloserProxy(*closer, bindings.GetAsyncWaiter())
		p.Close()
		p.Close_Proxy()
		stub.Close()
		close(ch)
	}
	return ch, stop, nil
}

func scanAndMatch(d mojom.Discovery, query string, wants ...mojom.Advertisement) error {
	const timeout = 10 * time.Second

	var err error
	for now := time.Now(); time.Since(now) < timeout; {
		var updatePtrs []mojom.Update_Pointer
		updatePtrs, err = doScan(d, query, len(wants))
		if err != nil {
			return err
		}
		err = matchFound(updatePtrs, wants...)
		if err == nil {
			return nil
		}
	}
	return err
}

func doScan(d mojom.Discovery, query string, expectedUpdates int) ([]mojom.Update_Pointer, error) {
	scanCh, stop, err := scan(d, query)
	if err != nil {
		return nil, err
	}
	defer func() {
		stop()
		for range scanCh {
		}
	}()

	updatePtrs := make([]mojom.Update_Pointer, 0, expectedUpdates)
	for {
		var timer <-chan time.Time
		if len(updatePtrs) >= expectedUpdates {
			timer = time.After(5 * time.Millisecond)
		}

		select {
		case ptr := <-scanCh:
			updatePtrs = append(updatePtrs, ptr)
		case <-timer:
			return updatePtrs, nil
		}
	}
}

func matchFound(updatePtrs []mojom.Update_Pointer, wants ...mojom.Advertisement) error {
	return match(updatePtrs, false, wants...)
}

func matchLost(updatePtrs []mojom.Update_Pointer, wants ...mojom.Advertisement) error {
	return match(updatePtrs, true, wants...)
}

func match(updatePtrs []mojom.Update_Pointer, lost bool, wants ...mojom.Advertisement) error {
	updateMap := make(map[[internal.AdIdLen]uint8]mojom.Update)
	updates := make([]mojom.Update, 0)
	for _, ptr := range updatePtrs {
		update := mojom.NewUpdateProxy(ptr, bindings.GetAsyncWaiter())
		defer update.Close_Proxy()

		id, _ := update.GetId()
		updateMap[id] = update
		updates = append(updates, update)
	}
	for _, want := range wants {
		update := updateMap[*want.Id]
		if update == nil {
			break
		}
		if got, _ := update.IsLost(); got != lost {
			break
		}
		if !updateEqual(update, want) {
			break
		}
		delete(updateMap, *want.Id)
	}
	if len(updateMap) == 0 {
		return nil
	}

	return fmt.Errorf("Match failed; got %v, but wanted %v", updatesToDebugString(updates), adsToDebugString(wants))
}

func updateEqual(update mojom.Update, ad mojom.Advertisement) bool {
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
			h.Wait(system.MOJO_HANDLE_SIGNAL_READABLE, system.MOJO_DEADLINE_INDEFINITE)
			r, got := h.ReadData(system.MOJO_READ_DATA_FLAG_ALL_OR_NONE)
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

func adsToDebugString(ads []mojom.Advertisement) string {
	var strs []string
	for _, ad := range ads {
		strs = append(strs, adToDebugString(ad))
	}
	return "[]" + strings.Join(strs, ", ") + "]"
}

func adToDebugString(ad mojom.Advertisement) string {
	return "{" + strings.Join(dumpFields(ad), ", ") + "}"
}

func updatesToDebugString(updates []mojom.Update) string {
	var strs []string
	for _, u := range updates {
		strs = append(strs, updateToDebugString(u))
	}
	return "[]" + strings.Join(strs, ", ") + "]"
}

func updateToDebugString(update mojom.Update) string {
	lost, _ := update.IsLost()
	ad, _ := update.GetAdvertisement()
	return fmt.Sprintf("{%v, %v}", lost, strings.Join(dumpFields(ad), ", "))
}

func dumpFields(i interface{}) []string {
	var fields []string
	for rv, i := reflect.ValueOf(i), 0; i < rv.NumField(); i++ {
		fields = append(fields, fmt.Sprint(rv.Field(i)))
	}
	return fields
}
