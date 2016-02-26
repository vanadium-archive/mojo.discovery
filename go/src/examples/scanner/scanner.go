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

type scanHandler struct{}

func (*scanHandler) OnUpdate(ptr discovery.Update_Pointer) error {
	uProxy := discovery.NewUpdateProxy(ptr, bindings.GetAsyncWaiter())
	defer uProxy.Close_Proxy()

	tag := "Found"
	if lost, _ := uProxy.IsLost(); lost {
		tag = "Lost"
	}
	id, _ := uProxy.GetId()
	interfaceName, _ := uProxy.GetInterfaceName()
	addresses, _ := uProxy.GetAddresses()
	attribute, _ := uProxy.GetAttribute("foo")
	attachmentHandle, _ := uProxy.GetAttachment("bar")
	_, attachment := attachmentHandle.ReadData(system.MOJO_READ_DATA_FLAG_NONE)
	attachmentHandle.Close()

	log.Printf("%s %x: {InterfaceName: %q, Addresses: %q, Attribute[\"foo\"]: %q, Attachment[\"bar\"]: 0x%x}", tag, id, interfaceName, addresses, attribute, attachment)
	return nil
}

type delegate struct {
	stop func()
}

func (d *delegate) Initialize(ctx application.Context) {
	req, ptr := discovery.CreateMessagePipeForDiscovery()
	ctx.ConnectToApplication("https://mojo.v.io/discovery.mojo").ConnectToService(&req)

	scanHandlerReq, scanHandlerPtr := discovery.CreateMessagePipeForScanHandler()
	scanHandlerStub := discovery.NewScanHandlerStub(scanHandlerReq, &scanHandler{}, bindings.GetAsyncWaiter())

	dProxy := discovery.NewDiscoveryProxy(ptr, bindings.GetAsyncWaiter())
	closerPtr, e1, e2 := dProxy.Scan(`v.InterfaceName="v.io/discovery.T"`, scanHandlerPtr)
	if e1 != nil || e2 != nil {
		log.Printf("Failed to scan: %v, %v", e1, e2)
		scanHandlerStub.Close()
		dProxy.Close_Proxy()
		return
	}

	go func() {
		for {
			if err := scanHandlerStub.ServeRequest(); err != nil {
				connErr, ok := err.(*bindings.ConnectionError)
				if !ok || !connErr.Closed() {
					log.Println(err)
				}
				break
			}
		}
	}()

	d.stop = func() {
		cProxy := discovery.NewCloserProxy(*closerPtr, bindings.GetAsyncWaiter())
		cProxy.Close()
		cProxy.Close_Proxy()

		scanHandlerStub.Close()
		dProxy.Close_Proxy()
	}
}

func (*delegate) AcceptConnection(connection *application.Connection) {
	connection.Close()
}

func (d *delegate) Quit() {
	d.stop()
}

//export MojoMain
func MojoMain(handle C.MojoHandle) C.MojoResult {
	application.Run(&delegate{}, system.MojoHandle(handle))
	return C.MOJO_RESULT_OK
}

func main() {}
