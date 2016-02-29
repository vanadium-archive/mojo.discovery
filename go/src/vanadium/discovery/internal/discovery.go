// Copyright 2015 The Vanadium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

package internal

import (
	"sync"

	"mojo/public/go/bindings"

	mojom "mojom/vanadium/discovery"

	"v.io/v23"
	"v.io/v23/context"
	"v.io/v23/discovery"
)

// TODO(jhahn): Mojom 'const' is ignored in mojom.go.
// See https://github.com/domokit/mojo/issues/685.
const AdIdLen = 16

// closer implements the mojom.Closer.
type closer struct {
	cancel func()
}

func (c *closer) Close() error {
	c.cancel()
	return nil
}

type discoveryCloser interface {
	mojom.Discovery

	// Close closes all active tasks.
	Close()
}

// mdiscovery is a thin wrapper around the Vanadium discovery.
type mdiscovery struct {
	ctx *context.T
	d   discovery.T

	mu    sync.Mutex
	stubs map[*bindings.Stub]struct{} // GUARDED_BY(mu)
}

func (d *mdiscovery) Advertise(ad mojom.Advertisement, visibility *[]string) (*[AdIdLen]uint8, *mojom.Closer_Pointer, *mojom.Error, error) {
	ctx, cancel := context.WithCancel(d.ctx)

	vAd := m2vAd(&ad)
	vVisibility := m2vVisibility(visibility)
	done, err := d.d.Advertise(ctx, &vAd, vVisibility)
	if err != nil {
		cancel()
		return nil, nil, v2mError(err), nil
	}

	stop := func() {
		cancel()
		<-done
	}
	req, ptr := mojom.CreateMessagePipeForCloser()
	stub := mojom.NewCloserStub(req, &closer{stop}, bindings.GetAsyncWaiter())
	d.serveStub(stub, stop)

	var id [AdIdLen]uint8
	id = vAd.Id
	return &id, &ptr, nil, nil
}

func (d *mdiscovery) Scan(query string, handlerPtr mojom.ScanHandler_Pointer) (*mojom.Closer_Pointer, *mojom.Error, error) {
	ctx, cancel := context.WithCancel(d.ctx)

	scanCh, err := d.d.Scan(ctx, query)
	if err != nil {
		cancel()
		return nil, v2mError(err), nil
	}

	handler := mojom.NewScanHandlerProxy(handlerPtr, bindings.GetAsyncWaiter())
	go func() {
		defer handler.Close_Proxy()

		for update := range scanCh {
			mUpdate := newMojoUpdate(d.ctx, update)

			req, ptr := mojom.CreateMessagePipeForUpdate()
			stub := mojom.NewUpdateStub(req, mUpdate, bindings.GetAsyncWaiter())
			if err := handler.OnUpdate(ptr); err != nil {
				stub.Close()
				cancel()
				return
			}
			d.serveStub(stub, nil)
		}
	}()

	req, ptr := mojom.CreateMessagePipeForCloser()
	stub := mojom.NewCloserStub(req, &closer{cancel}, bindings.GetAsyncWaiter())
	d.serveStub(stub, cancel)
	return &ptr, nil, nil
}

func (d *mdiscovery) serveStub(stub *bindings.Stub, cleanup func()) {
	d.mu.Lock()
	d.stubs[stub] = struct{}{}
	d.mu.Unlock()

	go func() {
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

		if cleanup != nil {
			cleanup()
		}
	}()
}

func (d *mdiscovery) Close() {
	d.mu.Lock()
	defer d.mu.Unlock()

	for stub := range d.stubs {
		stub.Close()
	}
}

// ediscovery always returns the given error.
type ediscovery struct{ err error }

func (d *ediscovery) Advertise(mojom.Advertisement, *[]string) (*[AdIdLen]uint8, *mojom.Closer_Pointer, *mojom.Error, error) {
	return nil, nil, v2mError(d.err), nil
}
func (d *ediscovery) Scan(string, mojom.ScanHandler_Pointer) (*mojom.Closer_Pointer, *mojom.Error, error) {
	return nil, v2mError(d.err), nil
}
func (d *ediscovery) Close() {}

// NewDiscovery returns a new Vanadium discovery instance.
func NewDiscovery(ctx *context.T) discoveryCloser {
	d, err := v23.NewDiscovery(ctx)
	if err != nil {
		return &ediscovery{err}
	}

	return &mdiscovery{
		ctx:   ctx,
		d:     d,
		stubs: make(map[*bindings.Stub]struct{}),
	}
}
