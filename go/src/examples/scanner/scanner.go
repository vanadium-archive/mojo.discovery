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

func (*scanHandler) Update(update discovery.ScanUpdate) error {
	var tag string
	switch update.UpdateType {
	case discovery.UpdateType_Found:
		tag = "Found"
	case discovery.UpdateType_Lost:
		tag = "Lost"
	}
	log.Printf("%s service: %v", tag, update.Service)
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

	proxy := discovery.NewDiscoveryProxy(ptr, bindings.GetAsyncWaiter())
	scanId, e1, e2 := proxy.StartScan(`v.InterfaceName="v.io/discovery.T"`, scanHandlerPtr)
	if e1 != nil || e2 != nil {
		log.Println("Error occurred", e1, e2)
		scanHandlerStub.Close()
		return
	}

	d.stop = func() {
		proxy.StopScan(scanId)
		scanHandlerStub.Close()
		proxy.Close_Proxy()
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
