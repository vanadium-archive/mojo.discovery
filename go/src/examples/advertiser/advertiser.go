// Copyright 2015 The Vanadium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

package main

import (
	"log"

	"mojo/public/go/application"
	"mojo/public/go/bindings"
	"mojo/public/go/system"

	"mojom/v.io/discovery"
)

//#include "mojo/public/c/system/types.h"
import "C"

type delegate struct {
	stop func()
}

func (d *delegate) Initialize(ctx application.Context) {
	req, ptr := discovery.CreateMessagePipeForDiscovery()
	ctx.ConnectToApplication("https://mojo.v.io/discovery.mojo").ConnectToService(&req)

	ad := discovery.Advertisement{
		InterfaceName: "v.io/discovery.T",
		Addresses:     []string{"localhost:1000"},
		Attributes:    &map[string]string{"foo": "abc"},
		Attachments:   &map[string][]byte{"bar": []byte{1, 2, 3}},
	}
	dProxy := discovery.NewDiscoveryProxy(ptr, bindings.GetAsyncWaiter())
	id, closerPtr, e1, e2 := dProxy.Advertise(ad, nil)
	if e1 != nil || e2 != nil {
		log.Printf("Failed to advertise: %v, %v", e1, e2)
		return
	}
	log.Printf("Advertising %x...", *id)

	d.stop = func() {
		cProxy := discovery.NewCloserProxy(*closerPtr, bindings.GetAsyncWaiter())
		cProxy.Close()
		cProxy.Close_Proxy()

		dProxy.Close_Proxy()
	}
}

func (*delegate) AcceptConnection(connection *application.Connection) {
	connection.Close()
}

func (d *delegate) Quit() {
	if d.stop != nil {
		d.stop()
	}
}

//export MojoMain
func MojoMain(handle C.MojoHandle) C.MojoResult {
	application.Run(&delegate{}, system.MojoHandle(handle))
	return C.MOJO_RESULT_OK
}

func main() {}
