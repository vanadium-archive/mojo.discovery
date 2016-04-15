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
	"v.io/v23/rpc"

	idiscovery "v.io/x/ref/lib/discovery"
	fdiscovery "v.io/x/ref/lib/discovery/factory"
	"v.io/x/ref/lib/discovery/plugins/mock"
	"v.io/x/ref/runtime/factories/roaming"
	"v.io/x/ref/services/mounttable/mounttablelib"

	"v.io/mojo/discovery/internal"
)

//#include "mojo/public/c/system/handle.h"
import "C"

var (
	flagTestMode = flag.Bool("test-mode", false, "should only be true for apptests.")
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

	if *flagTestMode {
		// Inject a mock plugin.
		df, _ := idiscovery.NewFactory(d.ctx, mock.New())
		fdiscovery.InjectFactory(df)

		// Start a mounttable and set the namespace roots.
		//
		// Note that we need to listen on a local IP address in order to
		// accept connections within a GCE instance.
		d.ctx = v23.WithListenSpec(d.ctx, rpc.ListenSpec{Addrs: rpc.ListenAddrs{{Protocol: "tcp", Address: "127.0.0.1:0"}}})
		name, _, err := mounttablelib.StartServers(d.ctx, v23.GetListenSpec(d.ctx), "", "", "", "", "mounttable")
		if err != nil {
			panic(err)
		}
		ns := v23.GetNamespace(d.ctx)
		ns.SetRoots(name)
	}
}

func (d *delegate) AcceptConnection(connection *application.Connection) {
	f := &factory{d, connection.ConnectionURL()}
	connection.ProvideServices(&mojom.Discovery_ServiceFactory{f})
}

func (d *delegate) run(stub *bindings.Stub, done func()) {
	d.mu.Lock()
	d.stubs[stub] = struct{}{}
	d.mu.Unlock()

	go func() {
		defer done()

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

func (d *delegate) Quit() {
	d.mu.Lock()
	for stub := range d.stubs {
		stub.Close()
	}
	d.mu.Unlock()
	d.shutdown()
}

type factory struct {
	d   *delegate
	url string
}

func (f *factory) Create(request mojom.Discovery_Request) {
	discovery, err := internal.NewDiscovery(f.d.ctx, f.url)
	if err != nil {
		f.d.ctx.Error(err)
		request.Close()
		return
	}
	stub := mojom.NewDiscoveryStub(request, discovery, bindings.GetAsyncWaiter())
	f.d.run(stub, discovery.Close)
}

//export MojoMain
func MojoMain(handle C.MojoHandle) C.MojoResult {
	application.Run(&delegate{stubs: map[*bindings.Stub]struct{}{}}, system.MojoHandle(handle))
	return C.MOJO_RESULT_OK
}

func main() {}
