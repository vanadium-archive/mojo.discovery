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

// TODO(jhahn): Mojom 'const' is ignored in mojom.go. Remove this once it is fixed.
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
	// There is no way to mock _Pointer or _Request types. So we put Advertise()
	// logic into a separate function doAdvertise() for unit testing.
	closer, err := d.doAdvertise(&ad, visibility)
	if err != nil {
		return nil, nil, v2mError(err), nil
	}

	req, ptr := mojom.CreateMessagePipeForCloser()
	stub := mojom.NewCloserStub(req, closer, bindings.GetAsyncWaiter())
	d.serveStub(stub, closer.cancel)
	return ad.Id, &ptr, nil, nil
}

func (d *mdiscovery) doAdvertise(ad *mojom.Advertisement, visibility *[]string) (*closer, error) {
	vAd := m2vAd(ad)
	vVisibility := m2vVisibility(visibility)

	ctx, cancel := context.WithCancel(d.ctx)
	done, err := d.d.Advertise(ctx, &vAd, vVisibility)
	if err != nil {
		cancel()
		return nil, err
	}
	if ad.Id == nil {
		ad.Id = new([AdIdLen]uint8)
	}
	*ad.Id = vAd.Id
	stop := func() {
		cancel()
		<-done
	}
	return &closer{stop}, nil
}

type scanHandlerProxy interface {
	passUpdate(update mojom.Update) error
	Close_Proxy()
}

type scanHandlerProxyImpl struct {
	*mojom.ScanHandler_Proxy

	d *mdiscovery
}

func (p *scanHandlerProxyImpl) passUpdate(update mojom.Update) error {
	req, ptr := mojom.CreateMessagePipeForUpdate()
	stub := mojom.NewUpdateStub(req, update, bindings.GetAsyncWaiter())
	p.d.serveStub(stub, nil)
	return p.OnUpdate(ptr)
}

func (d *mdiscovery) Scan(query string, handlerPtr mojom.ScanHandler_Pointer) (*mojom.Closer_Pointer, *mojom.Error, error) {
	// There is no way to mock _Pointer or _Request types. So we put Scan()
	// logic into a separate function doScan() for unit testing.
	proxy := mojom.NewScanHandlerProxy(handlerPtr, bindings.GetAsyncWaiter())
	closer, err := d.doScan(query, &scanHandlerProxyImpl{proxy, d})
	if err != nil {
		return nil, v2mError(err), nil
	}

	req, ptr := mojom.CreateMessagePipeForCloser()
	stub := mojom.NewCloserStub(req, closer, bindings.GetAsyncWaiter())
	d.serveStub(stub, closer.cancel)
	return &ptr, nil, nil
}

func (d *mdiscovery) doScan(query string, proxy scanHandlerProxy) (*closer, error) {
	ctx, cancel := context.WithCancel(d.ctx)
	scanCh, err := d.d.Scan(ctx, query)
	if err != nil {
		cancel()
		proxy.Close_Proxy()
		return nil, err
	}

	go func() {
		defer proxy.Close_Proxy()

		for update := range scanCh {
			mUpdate := newMojoUpdate(ctx, update)
			if err := proxy.passUpdate(mUpdate); err != nil {
				return
			}
		}
	}()
	return &closer{cancel}, nil
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
