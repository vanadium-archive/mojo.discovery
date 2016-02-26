// Copyright 2016 The Vanadium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

package internal

import (
	mojom "mojom/vanadium/discovery"

	"v.io/v23/discovery"
	"v.io/v23/security"
	"v.io/v23/verror"
)

func v2mError(err error) *mojom.Error {
	return &mojom.Error{
		Id:         string(verror.ErrorID(err)),
		ActionCode: uint32(verror.Action(err)),
		Msg:        err.Error(),
	}
}

func v2mAd(ad *discovery.Advertisement) mojom.Advertisement {
	mAd := mojom.Advertisement{
		InterfaceName: ad.InterfaceName,
		Addresses:     ad.Addresses,
	}
	if ad.Id.IsValid() {
		mAd.Id = new([AdIdLen]uint8)
		*mAd.Id = ad.Id
	}
	if len(ad.Attributes) > 0 {
		attributes := map[string]string(ad.Attributes)
		mAd.Attributes = &attributes
	}
	if len(ad.Attachments) > 0 {
		attachments := map[string][]byte(ad.Attachments)
		mAd.Attachments = &attachments
	}
	return mAd
}

func m2vAd(ad *mojom.Advertisement) discovery.Advertisement {
	vAd := discovery.Advertisement{
		InterfaceName: ad.InterfaceName,
		Addresses:     ad.Addresses,
	}
	if ad.Id != nil {
		vAd.Id = *ad.Id
	}
	if ad.Attributes != nil {
		vAd.Attributes = *ad.Attributes
	}
	if ad.Attachments != nil {
		vAd.Attachments = *ad.Attachments
	}
	return vAd
}

func m2vVisibility(visibility *[]string) []security.BlessingPattern {
	if visibility == nil {
		return nil
	}
	vVisibility := make([]security.BlessingPattern, len(*visibility))
	for i, p := range *visibility {
		vVisibility[i] = security.BlessingPattern(p)
	}
	return vVisibility
}
