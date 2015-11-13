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

type handler struct{}

func (*handler) Found(s discovery.Service) error {
	log.Println("Found a new service", s)
	return nil
}

func (*handler) Lost(s []uint8) error {
	log.Println("Lost a new service", s)
	return nil
}

type scannerDelegate struct {
	id    uint32
	proxy *discovery.Scanner_Proxy
	stub  *bindings.Stub
}

func (s *scannerDelegate) Initialize(ctx application.Context) {
	req, ptr := discovery.CreateMessagePipeForScanner()
	ctx.ConnectToApplication("https://mojo.v.io/discovery.mojo").ConnectToService(&req)
	s.proxy = discovery.NewScannerProxy(ptr, bindings.GetAsyncWaiter())
	scanReq, scanPtr := discovery.CreateMessagePipeForScanHandler()
	s.stub = discovery.NewScanHandlerStub(scanReq, &handler{}, bindings.GetAsyncWaiter())
	id, e1, e2 := s.proxy.Scan(`v.InterfaceName="v.io/discovery.T"`, scanPtr)
	if e1 != nil || e2 != nil {
		log.Println("Error occurred", e1, e2)
		return
	}

	s.id = id
	go func() {
		for {
			if err := s.stub.ServeRequest(); err != nil {
				connectionError, ok := err.(*bindings.ConnectionError)
				if !ok || !connectionError.Closed() {
					log.Println(err)
				}
				break
			}
		}
	}()
}

func (*scannerDelegate) AcceptConnection(connection *application.Connection) {
	connection.Close()
}

func (s *scannerDelegate) Quit() {
	s.proxy.Stop(s.id)
	s.stub.Close()
}

//export MojoMain
func MojoMain(handle C.MojoHandle) C.MojoResult {
	application.Run(&scannerDelegate{}, system.MojoHandle(handle))
	return C.MOJO_RESULT_OK
}

func main() {
}
