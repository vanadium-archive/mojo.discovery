// Copyright 2015 The Vanadium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

package io.v.mojo.discovery;

import com.google.common.util.concurrent.FutureCallback;
import com.google.common.util.concurrent.ListenableFuture;

import org.chromium.mojo.system.MojoException;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;

import io.v.v23.InputChannels;
import io.v.v23.context.CancelableVContext;
import io.v.v23.context.VContext;
import io.v.v23.discovery.Update;
import io.v.v23.discovery.VDiscovery;
import io.v.v23.rpc.Callback;
import io.v.v23.verror.VException;

class ScannerImpl implements Scanner{
    private final VDiscovery discovery;
    private final VContext rootCtx;


    private final Map<Integer, CancelableVContext> contextMap  = new HashMap<>();

    private final AtomicInteger nextScanner = new AtomicInteger(0);

    public ScannerImpl(VDiscovery discovery, VContext rootCtx) {
        this.discovery = discovery;
        this.rootCtx = rootCtx;
    }
    @Override
    public void scan(String query, final ScanHandler scanHandler, ScanResponse callback) {
        synchronized (this) {
            System.out.println("Got a scan call");
            int handle = nextScanner.getAndAdd(1);
            CancelableVContext ctx = rootCtx.withCancel();
            contextMap.put(handle, ctx);
            ListenableFuture<Void> done = InputChannels.withCallback(discovery.scan(ctx, query),
                    new Callback<Update>() {
                        @Override
                        public void onSuccess(Update update) {
                            if (update instanceof Update.Found) {
                                Update.Found found = (Update.Found) update;
                                io.v.v23.discovery.Service vService = found.getElem().getService();
                                Service mService = new Service();
                                mService.instanceId = vService.getInstanceId();
                                mService.instanceName = vService.getInstanceName();
                                mService.interfaceName = vService.getInterfaceName();
                                mService.addrs = new String[vService.getAddrs().size()];
                                mService.addrs = vService.getAddrs().toArray(mService.addrs);
                                mService.attrs = vService.getAttrs();
                                scanHandler.found(mService);
                            } else {
                                Update.Lost lost = (Update.Lost) update;
                                scanHandler.lost(lost.getElem().getInstanceId());
                            }
                        }

                        @Override
                        public void onFailure(VException t) {

                        }
                    });
            System.out.println("Returning a scan call");
            callback.call(handle, null);
        }
    }

    @Override
    public void stop(int h, StopResponse response) {
        synchronized (this) {
            CancelableVContext ctx = contextMap.get(h);
            if (ctx != null) {
                contextMap.remove(h);
                ctx.cancel();
            }
            response.call(null);
        }
    }

    @Override
    public void close() {}

    @Override
    public void onConnectionError(MojoException e) {}
}
