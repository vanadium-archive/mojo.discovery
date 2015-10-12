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

type advDelegate struct {
	id    uint32
	proxy *discovery.Advertiser_Proxy
}

func (a *advDelegate) Initialize(ctx application.Context) {
	req, ptr := discovery.CreateMessagePipeForAdvertiser()
	ctx.ConnectToApplication("https://mojo.v.io/discovery.mojo").ConnectToService(&req)
	a.proxy = discovery.NewAdvertiserProxy(ptr, bindings.GetAsyncWaiter())
	s := discovery.Service{
		InterfaceName: "v.io/discovery.T",
		Addrs:         []string{"localhost:1000", "localhost:2000"},
		Attrs:         map[string]string{"foo": "bar"},
	}
	id, e1, e2 := a.proxy.Advertise(s, nil)
	if e1 != nil || e2 != nil {
		log.Println("Error occurred", e1, e2)
		return
	}

	a.id = id
}

func (*advDelegate) AcceptConnection(connection *application.Connection) {
	connection.Close()
}

func (s *advDelegate) Quit() {
	s.proxy.Stop(s.id)
}

//export MojoMain
func MojoMain(handle C.MojoHandle) C.MojoResult {
	application.Run(&advDelegate{}, system.MojoHandle(handle))
	return C.MOJO_RESULT_OK
}

func main() {
}
