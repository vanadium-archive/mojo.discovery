// Copyright 2015 The Vanadium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

// +build mojo

package main

import (
	"flag"
	"sync"

	"mojo/public/go/application"
	"mojo/public/go/bindings"
	"mojo/public/go/system"

	mojom "mojom/v.io/discovery"

	"v.io/v23"
	"v.io/v23/context"

	idiscovery "v.io/x/ref/lib/discovery"
	fdiscovery "v.io/x/ref/lib/discovery/factory"
	"v.io/x/ref/lib/discovery/plugins/mock"
	"v.io/x/ref/runtime/factories/roaming"

	"v.io/mojo/discovery/internal"
)

//#include "mojo/public/c/system/handle.h"
import "C"

var (
	flagUseMock = flag.Bool("use-mock", false, "Use a mock plugin for mojo apptests.")
)

type delegate struct {
	ctx      *context.T
	shutdown v23.Shutdown

	mu    sync.Mutex
	stubs map[*bindings.Stub]struct{} // GUARDED_BY(mu)
}

func (d *delegate) Initialize(mctx application.Context) {
	// TODO(bjornick): Calling init multiple times in the same process
	// will be bad.  For now, this is ok because this is the only
	// vanadium service that will be used in the demos and each go library
	// will be in its own process.
	roaming.SetArgs(mctx)
	d.ctx, d.shutdown = v23.Init()

	if *flagUseMock {
		df, _ := idiscovery.NewFactory(d.ctx, mock.New())
		fdiscovery.InjectFactory(df)
	}
}

func (d *delegate) Create(request mojom.Discovery_Request) {
	discovery := internal.NewDiscovery(d.ctx)
	stub := mojom.NewDiscoveryStub(request, discovery, bindings.GetAsyncWaiter())
	d.mu.Lock()
	d.stubs[stub] = struct{}{}
	d.mu.Unlock()

	go func() {
		defer discovery.Close()

		for {
			if err := stub.ServeRequest(); err != nil {
				connErr, ok := err.(*bindings.ConnectionError)
				if !ok || !connErr.Closed() {
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

func (d *delegate) AcceptConnection(connection *application.Connection) {
	connection.ProvideServices(&mojom.Discovery_ServiceFactory{d})
}

func (d *delegate) Quit() {
	d.mu.Lock()
	for stub := range d.stubs {
		stub.Close()
	}
	d.mu.Unlock()
	d.shutdown()
}

//export MojoMain
func MojoMain(handle C.MojoHandle) C.MojoResult {
	application.Run(&delegate{stubs: map[*bindings.Stub]struct{}{}}, system.MojoHandle(handle))
	return C.MOJO_RESULT_OK
}

func main() {}