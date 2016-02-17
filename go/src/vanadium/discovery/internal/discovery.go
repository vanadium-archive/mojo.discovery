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
	"v.io/v23/security"
	"v.io/v23/verror"
)

const pkgPath = "mojo/vanadium/discovery/vanadium/discovery"

var (
	errInvalidInstanceId = verror.Register(pkgPath+".errInvalidInstanceId", verror.NoRetry, "{1:}{2:} instance id not valid")
	errInvalidScanId     = verror.Register(pkgPath+".errInvalidScanId", verror.NoRetry, "{1:}{2:} scan id not valid")
)

type DiscoveryCloser interface {
	mojom.Discovery

	// Close closes all active tasks.
	Close()
}

// mdiscovery is basically a thin wrapper around the Vanadium discovery API.
type mdiscovery struct {
	ctx *context.T
	d   discovery.T

	mu          sync.Mutex
	activeAdvs  map[string]func() // GUARDED_BY(mu)
	activeScans map[uint32]func() // GUARDED_BY(mu)
	nextScanId  uint32            // GUARDED_BY(mu)
}

func v2mError(err error) *mojom.Error {
	return &mojom.Error{
		Id:     string(verror.ErrorID(err)),
		Action: int32(verror.Action(err)),
		Msg:    err.Error(),
	}
}

func v2mService(s discovery.Service) mojom.Service {
	mService := mojom.Service{
		InterfaceName: s.InterfaceName,
		Addrs:         s.Addrs,
	}
	if len(s.InstanceId) > 0 {
		mService.InstanceId = &s.InstanceId
	}
	if len(s.InstanceName) > 0 {
		mService.InstanceName = &s.InstanceName
	}
	if len(s.Attrs) > 0 {
		attrs := map[string]string(s.Attrs)
		mService.Attrs = &attrs
	}
	if len(s.Attachments) > 0 {
		attachments := map[string][]byte(s.Attachments)
		mService.Attachments = &attachments
	}
	return mService
}

func (d *mdiscovery) StartAdvertising(service mojom.Service, visibility *[]string) (string, *mojom.Error, error) {
	vService := discovery.Service{
		InterfaceName: service.InterfaceName,
		Addrs:         service.Addrs,
	}
	if service.InstanceId != nil {
		vService.InstanceId = *service.InstanceId
	}
	if service.InstanceName != nil {
		vService.InstanceName = *service.InstanceName
	}
	if service.Attrs != nil {
		vService.Attrs = *service.Attrs
	}
	if service.Attachments != nil {
		vService.Attachments = *service.Attachments
	}
	var vVisibility []security.BlessingPattern
	if visibility != nil {
		vVisibility := make([]security.BlessingPattern, len(*visibility))
		for i, p := range *visibility {
			vVisibility[i] = security.BlessingPattern(p)
		}
	}

	ctx, cancel := context.WithCancel(d.ctx)
	done, err := d.d.Advertise(ctx, &vService, vVisibility)
	if err != nil {
		cancel()
		return "", v2mError(err), nil
	}
	stop := func() {
		cancel()
		<-done
	}

	d.mu.Lock()
	d.activeAdvs[vService.InstanceId] = stop
	d.mu.Unlock()
	return vService.InstanceId, nil, nil
}

func (d *mdiscovery) StopAdvertising(instanceId string) (*mojom.Error, error) {
	d.mu.Lock()
	stop := d.activeAdvs[instanceId]
	delete(d.activeAdvs, instanceId)
	d.mu.Unlock()
	if stop == nil {
		return v2mError(verror.New(errInvalidInstanceId, d.ctx)), nil
	}
	stop()
	return nil, nil
}

func (d *mdiscovery) StartScan(query string, handlerPtr mojom.ScanHandler_Pointer) (uint32, *mojom.Error, error) {
	// There is no way to mock _Pointer or _Request types. So we put StartScan()
	// logic into a separate function startScan() for unit testing.
	proxy := mojom.NewScanHandlerProxy(handlerPtr, bindings.GetAsyncWaiter())
	return d.startScan(query, proxy)
}

type scanHandlerProxy interface {
	mojom.ScanHandler
	Close_Proxy()
}

func (d *mdiscovery) startScan(query string, proxy scanHandlerProxy) (uint32, *mojom.Error, error) {
	ctx, cancel := context.WithCancel(d.ctx)
	scanCh, err := d.d.Scan(ctx, query)
	if err != nil {
		cancel()
		proxy.Close_Proxy()
		return 0, v2mError(err), nil
	}

	d.mu.Lock()
	scanId := d.nextScanId
	d.activeScans[scanId] = cancel
	d.nextScanId++
	d.mu.Unlock()

	go func() {
		defer proxy.Close_Proxy()

		for update := range scanCh {
			var mupdate mojom.ScanUpdate
			switch u := update.(type) {
			case discovery.UpdateFound:
				mupdate = mojom.ScanUpdate{
					Service:    v2mService(u.Value.Service),
					UpdateType: mojom.UpdateType_Found,
				}
			case discovery.UpdateLost:
				mupdate = mojom.ScanUpdate{
					Service:    v2mService(u.Value.Service),
					UpdateType: mojom.UpdateType_Lost,
				}
			}
			if err := proxy.Update(mupdate); err != nil {
				return
			}
		}
	}()

	return scanId, nil, nil
}

func (d *mdiscovery) StopScan(scanId uint32) (*mojom.Error, error) {
	d.mu.Lock()
	stop := d.activeScans[scanId]
	delete(d.activeScans, scanId)
	d.mu.Unlock()
	if stop == nil {
		return v2mError(verror.New(errInvalidScanId, d.ctx)), nil
	}
	stop()
	return nil, nil
}

func (d *mdiscovery) Close() {
	d.mu.Lock()
	defer d.mu.Unlock()

	for _, stop := range d.activeAdvs {
		stop()
	}
	for _, stop := range d.activeScans {
		stop()
	}
}

// ediscovery always returns the given error.
type ediscovery struct{ err error }

func (d *ediscovery) StartAdvertising(mojom.Service, *[]string) (string, *mojom.Error, error) {
	return "", v2mError(d.err), nil
}
func (d *ediscovery) StopAdvertising(string) (*mojom.Error, error) { return v2mError(d.err), nil }
func (d *ediscovery) StartScan(string, mojom.ScanHandler_Pointer) (uint32, *mojom.Error, error) {
	return 0, v2mError(d.err), nil
}
func (d *ediscovery) StopScan(uint32) (*mojom.Error, error) { return v2mError(d.err), nil }
func (d *ediscovery) Close()                                {}

// NewDiscovery returns a new Vanadium discovery instance.
func NewDiscovery(ctx *context.T) DiscoveryCloser {
	d, err := v23.NewDiscovery(ctx)
	if err != nil {
		return &ediscovery{err}
	}

	return &mdiscovery{
		ctx:         ctx,
		d:           d,
		activeAdvs:  make(map[string]func()),
		activeScans: make(map[uint32]func()),
	}
}
