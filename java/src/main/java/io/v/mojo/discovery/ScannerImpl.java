// Copyright 2015 The Vanadium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

package io.v.mojo.discovery;

import com.google.common.util.concurrent.FutureCallback;
import com.google.common.util.concurrent.Futures;
import com.google.common.util.concurrent.ListenableFuture;

import io.v.v23.InputChannelCallback;
import org.chromium.mojo.system.MojoException;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;

import io.v.v23.InputChannels;
import io.v.v23.context.VContext;
import io.v.v23.discovery.VDiscovery;
import io.v.v23.rpc.Callback;
import io.v.v23.verror.VException;

class ScannerImpl implements Scanner{
    private final VDiscovery discovery;
    private final VContext rootCtx;


    private final Map<Integer, VContext> contextMap  = new HashMap<>();

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
            VContext ctx = rootCtx.withCancel();
            contextMap.put(handle, ctx);
            ListenableFuture<Void> done = InputChannels.withCallback(discovery.scan(ctx, query),
                    new InputChannelCallback<io.v.v23.discovery.Update>() {
                        @Override
                        public ListenableFuture<Void> onNext(io.v.v23.discovery.Update update) {
                            if (update instanceof io.v.v23.discovery.Update.Found) {
                                io.v.v23.discovery.Update.Found found = (io.v.v23.discovery.Update.Found) update;
                                Service mService = toMojoService(found.getElem().getService());
                                Update mUpdate = new Update();
                                mUpdate.service = mService;
                                mUpdate.updateType = UpdateType.FOUND;
                                scanHandler.update(mUpdate);
                            } else {
                                io.v.v23.discovery.Update.Lost lost = (io.v.v23.discovery.Update.Lost) update;
                                Service mService = toMojoService(lost.getElem().getService());
                                Update mUpdate = new Update();
                                mUpdate.service = mService;
                                mUpdate.updateType = UpdateType.LOST;
                                scanHandler.update(mUpdate);
                            }

                            return Futures.immediateFuture(null);
                        }

                    });
            System.out.println("Returning a scan call");
            callback.call(handle, null);
        }
    }

    @Override
    public void stop(int h, StopResponse response) {
        synchronized (this) {
            VContext ctx = contextMap.get(h);
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

    private static Service toMojoService(io.v.v23.discovery.Service vService) {
      Service mService = new Service();
      mService.instanceId = vService.getInstanceId();
      mService.instanceName = vService.getInstanceName();
      mService.interfaceName = vService.getInterfaceName();
      mService.addrs = new String[vService.getAddrs().size()];
      mService.addrs = vService.getAddrs().toArray(mService.addrs);
      mService.attrs = vService.getAttrs();
      return mService;
    }
}
