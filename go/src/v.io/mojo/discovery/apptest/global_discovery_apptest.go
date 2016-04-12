// Copyright 2016 The Vanadium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

// +build mojo

package apptest

import (
	"encoding/hex"
	"fmt"
	"net/url"
	"testing"
	"time"

	"mojo/public/go/application"
	"mojo/public/go/bindings"

	mojom "mojom/v.io/discovery"

	_ "v.io/x/ref/runtime/factories/generic"

	"v.io/mojo/discovery/internal"
)

// TODO(jhahn): Mojom 'const' is ignored in mojom.go.
// See https://github.com/domokit/mojo/issues/685.
const (
	QueryGlobal       = "global"
	QueryMountTTL     = "mount_ttl"
	QueryScanInterval = "scan_interval"
)

func newGlobalDiscovery(mctx application.Context, scanInterval time.Duration) *mojom.Discovery_Proxy {
	u, _ := url.Parse("https://mojo.v.io/discovery.mojo")
	q := u.Query()
	q.Set(QueryGlobal, "a/b/c")
	q.Set(QueryScanInterval, fmt.Sprintf("%.3fs", scanInterval.Seconds()))
	u.RawQuery = q.Encode()

	req, ptr := mojom.CreateMessagePipeForDiscovery()
	mctx.ConnectToApplication(u.String()).ConnectToService(&req)
	return mojom.NewDiscoveryProxy(ptr, bindings.GetAsyncWaiter())
}

func AppTestGlobalDiscoveryBasic(t *testing.T, mctx application.Context) {
	ads := []mojom.Advertisement{
		{
			Id:        &[internal.AdIdLen]uint8{1, 2, 3},
			Addresses: []string{"/h1:123/x"},
		},
		{
			Addresses: []string{"/h1:123/y"},
		},
	}

	d1 := newGlobalDiscovery(mctx, 0)
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
	if err := scanAndMatch(d1, ``); err != nil {
		t.Error(err)
	}

	// Create a new discovery instance. All advertisements should be discovered with that.
	d2 := newGlobalDiscovery(mctx, 1*time.Millisecond)
	defer d2.Close_Proxy()

	if err := scanAndMatch(d2, `k="01020300000000000000000000000000"`, ads[0]); err != nil {
		t.Error(err)
	}
	if err := scanAndMatch(d2, ``, ads...); err != nil {
		t.Error(err)
	}

	// Open a new scan channel and consume expected advertisements first.
	scanCh, scanStop, err := scan(d2, `k="01020300000000000000000000000000"`)
	if err != nil {
		t.Fatal(err)
	}
	defer scanStop()

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
	if err := scanAndMatch(d2, fmt.Sprintf(`k="%s"`, hex.EncodeToString(ads[1].Id[:])), ads[1]); err != nil {
		t.Error(err)
	}

	// Stop advertising the remaining one; Shouldn't discover any advertisements.
	stops[1]()
	if err := scanAndMatch(d2, ``); err != nil {
		t.Error(err)
	}
}
