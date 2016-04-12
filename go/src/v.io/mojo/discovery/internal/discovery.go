// Copyright 2015 The Vanadium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

package internal

import (
	"net/url"
	"sync"
	"time"

	"mojo/public/go/bindings"

	mojom "mojom/v.io/discovery"

	"v.io/v23"
	"v.io/v23/context"
	"v.io/v23/discovery"

	"v.io/x/ref/lib/discovery/global"
)

// TODO(jhahn): Mojom 'const' is ignored in mojom.go.
// See https://github.com/domokit/mojo/issues/685.
const (
	AdIdLen = 16

	QueryGlobal       = "global"
	QueryMountTTL     = "mount_ttl"
	QueryScanInterval = "scan_interval"
)

// closer implements the mojom.Closer.
type closer struct {
	cancel func()
}

func (c *closer) Close() error {
	c.cancel()
	return nil
}

type DiscoveryCloser interface {
	mojom.Discovery

	// Close closes all active tasks.
	Close()
}

// mdiscovery is a thin wrapper around the Vanadium discovery.
type mdiscovery struct {
	ctx    *context.T
	cancel func()

	d discovery.T

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

	d.cancel()
	for stub := range d.stubs {
		stub.Close()
	}
}

// NewDiscovery returns a new Vanadium discovery instance.
func NewDiscovery(ctx *context.T, connectionUrl string) (DiscoveryCloser, error) {
	d, err := newDiscovery(ctx, connectionUrl)
	if err != nil {
		return nil, err
	}

	ctx, cancel := context.WithCancel(ctx)
	md := &mdiscovery{
		ctx:    ctx,
		cancel: cancel,
		d:      d,
		stubs:  make(map[*bindings.Stub]struct{}),
	}
	return md, nil
}

func newDiscovery(ctx *context.T, connectionUrl string) (discovery.T, error) {
	u, err := url.ParseRequestURI(connectionUrl)
	if err != nil {
		return nil, err
	}

	q := u.Query()
	if _, ok := q[QueryGlobal]; ok {
		mountTTL, err := parseDuration(q.Get(QueryMountTTL))
		if err != nil {
			return nil, err
		}
		scanInterval, err := parseDuration(q.Get(QueryScanInterval))
		if err != nil {
			return nil, err
		}
		return global.NewWithTTL(ctx, q.Get(QueryGlobal), mountTTL, scanInterval)
	}
	return v23.NewDiscovery(ctx)
}

func parseDuration(s string) (time.Duration, error) {
	if len(s) == 0 {
		return 0, nil
	}
	return time.ParseDuration(s)
}
