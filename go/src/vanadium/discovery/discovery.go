// Copyright 2015 The Vanadium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

package main

import (
	"v.io/v23"
	discovery_factory "v.io/x/ref/lib/discovery/factory"

	_ "v.io/x/ref/runtime/factories/generic"

	mojom "mojom/vanadium/discovery"
	"vanadium/discovery/internal"

	"mojo/public/go/application"
	"mojo/public/go/bindings"
	"mojo/public/go/system"
	"sync"
	"v.io/v23/context"
)

//#include "mojo/public/c/system/types.h"
import "C"

type discoveryDelegate struct {
	// mu protects stubs.  All calls to methods on the delegate by
	// mojo will be done in the same goroutine.  We need mu so
	// we can clean up stubs that fail because of pipe errors because
	// each stub serves all its requests in its own goroutine.
	mu    sync.Mutex
	stubs map[*bindings.Stub]struct{}

	ctx      *context.T
	impl     *internal.DiscoveryService
	shutdown v23.Shutdown
}

func (d *discoveryDelegate) Initialize(c application.Context) {
	// TODO(bjornick): Calling init multiple times in the same process
	// will be bad.  For now, this is ok because this is the only
	// vanadium service that will be used in the demos and each go library
	// will be in its own process.
	ctx, shutdown := v23.Init()

	if len(c.Args() <= 2) {
		ctx.Fatalf("Not enough arguments passed to discovery.mojo. Given: %v. Pass a name to advertise, followed by 1+ discovery protocols.", c)
	}
	// TODO(bjornick): Change this to use the factory to determine which protocols to use.
	inst, err := discovery_factory.New(c.Args()[2:]...)
	if err != nil {
		ctx.Fatalf("failed to initalize discovery: %v", err)
	}

	d.impl = internal.NewDiscoveryService(ctx, inst)
	d.shutdown = shutdown
}

func (d *discoveryDelegate) addAndServeStub(stub *bindings.Stub) {
	d.mu.Lock()
	d.stubs[stub] = struct{}{}
	d.mu.Unlock()
	go func() {
		for {
			if err := stub.ServeRequest(); err != nil {
				connectionErr, ok := err.(*bindings.ConnectionError)
				if !ok || !connectionErr.Closed() {
					d.ctx.Error(err)
				}
				break
			}
		}
		d.mu.Lock()
		delete(d.stubs, stub)
		d.mu.Unlock()
	}()
}

type advertiseFactory struct {
	d *discoveryDelegate
}

func (a *advertiseFactory) Create(request mojom.Advertiser_Request) {
	stub := mojom.NewAdvertiserStub(request, a.d.impl, bindings.GetAsyncWaiter())
	a.d.addAndServeStub(stub)
}

type scannerFactory struct {
	d *discoveryDelegate
}

func (s *scannerFactory) Create(request mojom.Scanner_Request) {
	stub := mojom.NewScannerStub(request, s.d.impl, bindings.GetAsyncWaiter())
	s.d.addAndServeStub(stub)
}

func (d *discoveryDelegate) AcceptConnection(connection *application.Connection) {
	advFactory := &advertiseFactory{d: d}
	scanFactory := &scannerFactory{d: d}
	connection.ProvideServices(&mojom.Advertiser_ServiceFactory{advFactory}, &mojom.Scanner_ServiceFactory{scanFactory})
}

func (d *discoveryDelegate) Quit() {
	d.impl.StopAll()
	d.shutdown()
	d.mu.Lock()
	for stub := range d.stubs {
		stub.Close()
	}
	d.mu.Unlock()
}

//export MojoMain
func MojoMain(handle C.MojoHandle) C.MojoResult {
	application.Run(&discoveryDelegate{stubs: map[*bindings.Stub]struct{}{}}, system.MojoHandle(handle))
	return C.MOJO_RESULT_OK
}

func main() {
}
