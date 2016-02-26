// Copyright 2016 The Vanadium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

package internal

import (
	"math/rand"
	"reflect"
	"testing"
	"testing/quick"

	"v.io/v23/discovery"
)

func TestConvAd(t *testing.T) {
	rand := rand.New(rand.NewSource(0))
	for i := 0; i < 10; i++ {
		v, ok := quick.Value(reflect.TypeOf(discovery.Advertisement{}), rand)
		if !ok {
			t.Fatal("failed to populate value")
		}
		ad := v.Interface().(discovery.Advertisement)
		// Make reflect.DeepEqual happy in comparing nil and empty.
		if len(ad.Attributes) == 0 {
			ad.Attributes = nil
		}
		if len(ad.Attachments) == 0 {
			ad.Attachments = nil
		}

		mAd := v2mAd(&ad)
		vAd := m2vAd(&mAd)
		if !reflect.DeepEqual(vAd, ad) {
			t.Errorf("Convert: got %v, but want %v", vAd, ad)
		}
	}
}
