// Copyright 2015 The Vanadium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

package main

import (
	"log"

	"mojo/public/go/application"
	"mojo/public/go/bindings"
	"mojo/public/go/system"

	"mojom/vanadium/discovery"
)

//#include "mojo/public/c/system/types.h"
import "C"

type delegate struct {
	stop func()
}

func (d *delegate) Initialize(ctx application.Context) {
	req, ptr := discovery.CreateMessagePipeForDiscovery()
	ctx.ConnectToApplication("https://mojo.v.io/discovery.mojo").ConnectToService(&req)

	service := discovery.Service{
		InterfaceName: "v.io/discovery.T",
		Addrs:         []string{"localhost:1000", "localhost:2000"},
		Attrs:         &map[string]string{"foo": "bar"},
	}
	proxy := discovery.NewDiscoveryProxy(ptr, bindings.GetAsyncWaiter())
	instanceId, e1, e2 := proxy.StartAdvertising(service, nil)
	if e1 != nil || e2 != nil {
		log.Println("Error occurred", e1, e2)
		return
	}

	d.stop = func() {
		proxy.StopAdvertising(instanceId)
		proxy.Close_Proxy()
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
