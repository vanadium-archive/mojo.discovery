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
	"sync"
	"time"

	"mojo/public/go/bindings"
	"mojo/public/go/system"

	mojom "mojom/v.io/discovery"

	_ "v.io/x/ref/runtime/factories/generic"

	"v.io/mojo/discovery/internal"
)

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

	wg := new(sync.WaitGroup)
	wg.Add(1)
	go func() {
		defer wg.Done()
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
		wg.Wait()
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
