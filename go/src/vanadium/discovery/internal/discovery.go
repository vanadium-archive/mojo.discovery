// Copyright 2015 The Vanadium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

package internal

import (
	"sync"

	"v.io/v23/context"
	"v.io/v23/discovery"
	"v.io/v23/verror"

	"mojo/public/go/bindings"
	mojom "mojom/vanadium/discovery"
	"v.io/v23/security"
)

type id uint32

// DiscoveryService implements the mojom interface mojom/vanadium/discovery.DiscoveryService.  It
// is basically a thin wrapper around the Vanadium Discovery API.
type DiscoveryService struct {
	ctx *context.T
	s   discovery.T

	// mu protects pending* and next*
	mu sync.Mutex

	// The id to assign the next advertisement.
	nextAdv id
	// A map of advertisement ids to the cancellation function.
	activeAdvs map[id]func()
	// The id to assign to the next scan.
	nextScan id
	// A map of scan id to the cancellataion func()
	activeScans map[id]func()
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
func NewDiscoveryService(ctx *context.T, vDiscovery discovery.T) *DiscoveryService {
	return &DiscoveryService{
		ctx:         ctx,
		s:           vDiscovery,
		nextAdv:     1,
		activeAdvs:  map[id]func(){},
		activeScans: map[id]func(){},
	}
}

// Advertise advertises the mojom service passed only to the giveen blessing patterns. Returns the
// handle to this Advertise call.
func (d *DiscoveryService) Advertise(s mojom.Service, patterns []string) (uint32, *mojom.Error, error) {
	vService := discovery.Service{
		InstanceUuid:  s.InstanceUuid,
		InterfaceName: s.InterfaceName,
		InstanceName:  s.InstanceName,
		Attrs:         discovery.Attributes(s.Attrs),
		Addrs:         s.Addrs,
	}

	ctx, cancel := context.WithCancel(d.ctx)

	perms := make([]security.BlessingPattern, len(patterns))
	for i, pattern := range patterns {
		perms[i] = security.BlessingPattern(pattern)
	}
	err := d.s.Advertise(ctx, vService, perms)
	if err != nil {
		cancel()
		return 0, v2mError(err), nil
	}
	d.mu.Lock()
	currId := d.nextAdv
	d.activeAdvs[currId] = cancel
	d.nextAdv += 2
	d.mu.Unlock()
	return uint32(currId), nil, nil
}

func (d *DiscoveryService) stopAdvertising(handle uint32) error {
	d.mu.Lock()
	cancel := d.activeAdvs[id(handle)]
	delete(d.activeAdvs, id(handle))
	d.mu.Unlock()
	if cancel != nil {
		cancel()
	}
	return nil
}

func v2mService(s discovery.Service) mojom.Service {
	return mojom.Service{
		InstanceUuid:  s.InstanceUuid,
		InterfaceName: s.InterfaceName,
		InstanceName:  s.InstanceName,
		Attrs:         s.Attrs,
		Addrs:         s.Addrs,
	}
}

// Scan scans for all services that match the query string passed in and calls scanHandler with updates.
// Returns the handle to this Scan.
func (d *DiscoveryService) Scan(query string, scanHandler mojom.ScanHandler_Pointer) (uint32, *mojom.Error, error) {
	ctx, cancel := context.WithCancel(d.ctx)
	scanCh, err := d.s.Scan(ctx, query)
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
				proxy.Lost(value.Value.InstanceUuid)
			}
		}
	}()
	return uint32(currId), nil, nil
}

// Stop stops the scan.
func (d *DiscoveryService) Stop(handle uint32) error {
	if handle%2 == 0 {
		return d.stopScan(handle)
	}
	return d.stopAdvertising(handle)
}

func (d *DiscoveryService) stopScan(handle uint32) error {
	d.mu.Lock()
	cancel := d.activeScans[id(handle)]
	delete(d.activeScans, id(handle))
	d.mu.Unlock()
	if cancel != nil {
		cancel()
	}
	return nil
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
	d.s.Close()
	d.mu.Unlock()
}
