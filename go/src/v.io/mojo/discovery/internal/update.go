// Copyright 2016 The Vanadium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

package internal

import (
	"fmt"

	"mojo/public/go/system"

	mojom "mojom/v.io/discovery"

	"v.io/v23/context"
	"v.io/v23/discovery"
)

type mupdate struct {
	ctx *context.T
	u   discovery.Update
}

func (u *mupdate) IsLost() (bool, error)                    { return u.u.IsLost(), nil }
func (u *mupdate) GetId() ([AdIdLen]uint8, error)           { return u.u.Id(), nil }
func (u *mupdate) GetInterfaceName() (string, error)        { return u.u.InterfaceName(), nil }
func (u *mupdate) GetAddresses() ([]string, error)          { return u.u.Addresses(), nil }
func (u *mupdate) GetAttribute(name string) (string, error) { return u.u.Attribute(name), nil }

func (u *mupdate) GetAttachment(name string) (system.ConsumerHandle, error) {
	r, producer, consumer := system.GetCore().CreateDataPipe(nil)
	if r != system.MOJO_RESULT_OK {
		return nil, fmt.Errorf("can't create data pipe: %v", r)
	}
	go func() {
		defer producer.Close()

		dataOrErr := <-u.u.Attachment(u.ctx, name)
		if dataOrErr.Error != nil {
			u.ctx.Error(dataOrErr.Error)
		} else {
			producer.WriteData([]byte(dataOrErr.Data), system.MOJO_WRITE_DATA_FLAG_ALL_OR_NONE)
		}
	}()
	return consumer, nil
}

func (u *mupdate) GetAdvertisement() (mojom.Advertisement, error) {
	ad := u.u.Advertisement()
	return v2mAd(&ad), nil
}

func newMojoUpdate(ctx *context.T, update discovery.Update) mojom.Update {
	return &mupdate{ctx, update}
}
