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
	errInvalidHandle = verror.Register(pkgPath+".errInvalidHandle", verror.NoRetry, "{1:}{2:} handle not valid")
)

type handleT uint32

// DiscoveryService implements the mojom interface mojom/vanadium/discovery.DiscoveryService.  It
// is basically a thin wrapper around the Vanadium Discovery API.
type DiscoveryService struct {
	ctx       *context.T
	discovery discovery.T

	// mu protects pending* and next*
	mu sync.Mutex

	// The id to assign the next advertisement.
	nextAdv handleT
	// A map of advertisement ids to the cancellation function.
	activeAdvs map[handleT]func()
	// The id to assign to the next scan.
	nextScan handleT
	// A map of scan id to the cancellataion func()
	activeScans map[handleT]func()
}

func v2mError(err error) *mojom.Error {
	return &mojom.Error{
		Id:     string(verror.ErrorID(err)),
		Action: int32(verror.Action(err)),
		Msg:    err.Error(),
	}
}

// NewDiscoveryService returns a new DiscoveryService bound to the context and the Vanadium
// Discovery implementation passed in.
func NewDiscoveryService(ctx *context.T) *DiscoveryService {
	return &DiscoveryService{
		ctx:         ctx,
		discovery:   v23.GetDiscovery(ctx),
		nextAdv:     1,
		activeAdvs:  map[handleT]func(){},
		activeScans: map[handleT]func(){},
	}
}

func (d *DiscoveryService) Advertise(service mojom.Service, visibility *[]string) (uint32, string, *mojom.Error, error) {
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
	var vVisibility []security.BlessingPattern
	if visibility != nil {
		vVisibility := make([]security.BlessingPattern, len(*visibility))
		for i, p := range *visibility {
			vVisibility[i] = security.BlessingPattern(p)
		}
	}

	ctx, cancel := context.WithCancel(d.ctx)
	done, err := d.discovery.Advertise(ctx, &vService, vVisibility)
	if err != nil {
		cancel()
		return 0, "", v2mError(err), nil
	}
	d.mu.Lock()
	currId := d.nextAdv
	d.activeAdvs[currId] = func() {
		cancel()
		<-done
	}
	d.nextAdv += 2
	d.mu.Unlock()
	return uint32(currId), vService.InstanceId, nil, nil
}

func (d *DiscoveryService) stopAdvertising(handle uint32) (*mojom.Error, error) {
	d.mu.Lock()
	stop := d.activeAdvs[handleT(handle)]
	if stop == nil {
		d.mu.Unlock()
		return v2mError(verror.New(errInvalidHandle, d.ctx)), nil
	}
	delete(d.activeAdvs, handleT(handle))
	d.mu.Unlock()
	stop()
	return nil, nil
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
		attr := map[string]string(s.Attrs)
		mService.Attrs = &attr
	}
	return mService
}

func (d *DiscoveryService) Scan(query string, scanHandler mojom.ScanHandler_Pointer) (uint32, *mojom.Error, error) {
	ctx, cancel := context.WithCancel(d.ctx)
	scanCh, err := d.discovery.Scan(ctx, query)
	if err != nil {
		cancel()
		return 0, v2mError(err), nil
	}
	d.mu.Lock()
	currId := d.nextScan
	d.activeScans[currId] = cancel
	d.nextScan += 2
	d.mu.Unlock()

	go func() {
		proxy := mojom.NewScanHandlerProxy(scanHandler, bindings.GetAsyncWaiter())
		for v := range scanCh {
			switch value := v.(type) {
			case discovery.UpdateFound:
				proxy.Found(v2mService(value.Value.Service))
			case discovery.UpdateLost:
				proxy.Lost(value.Value.InstanceId)
			}
		}
	}()
	return uint32(currId), nil, nil
}

// Stop stops the scan.
func (d *DiscoveryService) Stop(handle uint32) (*mojom.Error, error) {
	if handle%2 == 0 {
		return d.stopScan(handle)
	}
	return d.stopAdvertising(handle)
}

func (d *DiscoveryService) stopScan(handle uint32) (*mojom.Error, error) {
	d.mu.Lock()
	cancel := d.activeScans[handleT(handle)]
	if cancel == nil {
		d.mu.Unlock()
		return v2mError(verror.New(errInvalidHandle, d.ctx)), nil
	}
	delete(d.activeScans, handleT(handle))
	d.mu.Unlock()
	cancel()
	return nil, nil
}

// Stop Stops all scans and advertisements.
func (d *DiscoveryService) StopAll() {
	d.mu.Lock()
	for _, cancel := range d.activeScans {
		cancel()
	}

	for _, cancel := range d.activeAdvs {
		cancel()
	}
	d.discovery.Close()
	d.mu.Unlock()
}
