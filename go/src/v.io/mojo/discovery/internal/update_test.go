// Copyright 2016 The Vanadium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

package internal

import (
	"math/rand"
	"reflect"
	"testing"
	"testing/quick"

	"v.io/v23/context"
	"v.io/v23/discovery"
)

type mockUpdate struct {
	lost bool
	ad   discovery.Advertisement
}

func (u *mockUpdate) IsLost() bool                                                        { return u.lost }
func (u *mockUpdate) Id() discovery.AdId                                                  { return u.ad.Id }
func (u *mockUpdate) InterfaceName() string                                               { return u.ad.InterfaceName }
func (u *mockUpdate) Addresses() []string                                                 { return u.ad.Addresses }
func (u *mockUpdate) Attribute(name string) string                                        { return u.ad.Attributes[name] }
func (u *mockUpdate) Attachment(ctx *context.T, name string) <-chan discovery.DataOrError { return nil }
func (u *mockUpdate) Advertisement() discovery.Advertisement                              { return u.ad }

func TestUpdate(t *testing.T) {
	rand := rand.New(rand.NewSource(0))
	for i := 0; i < 10; i++ {
		v, ok := quick.Value(reflect.TypeOf(discovery.Advertisement{}), rand)
		if !ok {
			t.Fatal("failed to populate value")
		}

		lost := rand.Int()%2 == 0
		ad := v.Interface().(discovery.Advertisement)

		mUpdate := newMojoUpdate(nil, &mockUpdate{lost, ad})

		if got, _ := mUpdate.IsLost(); got != lost {
			t.Errorf("IsLost: got %v, but want %v", got, lost)
		}
		if got, _ := mUpdate.GetId(); got != ad.Id {
			t.Errorf("Id: got %v, but want %v", got, ad.Id)
		}
		if got, _ := mUpdate.GetInterfaceName(); got != ad.InterfaceName {
			t.Errorf("InterfaceName: got %v, but want %v", got, ad.InterfaceName)
		}
		if got, _ := mUpdate.GetAddresses(); !reflect.DeepEqual(got, ad.Addresses) {
			t.Errorf("Addresses: got %v, but want %v", got, ad.Addresses)
		}
		for k, v := range ad.Attributes {
			if got, _ := mUpdate.GetAttribute(k); got != v {
				t.Errorf("Attributes[%s]: got %v, but want %v", got, v)
			}
		}

		// Note that we cannot test attachments in this unit test since it is
		// using mojo data handle. This test is covered by apptest.

		mAd := v2mAd(&ad)
		if got, _ := mUpdate.GetAdvertisement(); !reflect.DeepEqual(got, mAd) {
			t.Errorf("Advertisement: got %v, but want %v", got, mAd)
		}
	}
}
