// Copyright 2015 The Vanadium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

package io.v.mojo.discovery;

import com.google.common.util.concurrent.FutureCallback;
import com.google.common.util.concurrent.Futures;
import com.google.common.util.concurrent.ListenableFuture;

import io.v.v23.InputChannelCallback;
import org.chromium.mojo.system.MojoException;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;

import io.v.v23.InputChannels;
import io.v.v23.context.VContext;
import io.v.v23.discovery.Attachments;
import io.v.v23.discovery.Attributes;
import io.v.v23.discovery.VDiscovery;
import io.v.v23.rpc.Callback;
import io.v.v23.security.BlessingPattern;
import io.v.v23.verror.VException;

class DiscoveryImpl implements Discovery {
    private final VDiscovery discovery;
    private final VContext rootCtx;

    private final Map<Integer, VContext> contextMap  = new HashMap<>();
    private final Map<String, VContext> advertiserContextMap = new HashMap<>();

    private final AtomicInteger nextScanner = new AtomicInteger(0);

    public DiscoveryImpl(VDiscovery discovery, VContext rootCtx) {
        this.discovery = discovery;
        this.rootCtx = rootCtx;
    }
    @Override
    public void startScan(String query, final ScanHandler scanHandler, StartScanResponse callback) {
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
                                ScanUpdate mUpdate = new ScanUpdate();
                                mUpdate.service = mService;
                                mUpdate.updateType = UpdateType.FOUND;
                                scanHandler.update(mUpdate);
                            } else {
                                io.v.v23.discovery.Update.Lost lost = (io.v.v23.discovery.Update.Lost) update;
                                Service mService = toMojoService(lost.getElem().getService());
                                ScanUpdate mUpdate = new ScanUpdate();
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
    public void stopScan(int h, StopScanResponse response) {
        synchronized (this) {
            VContext ctx = contextMap.get(h);
            if (ctx != null) {
                contextMap.remove(h);
                ctx.cancel();
            }
            response.call(null);
        }
    }

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

    @Override
    public void startAdvertising(Service service, String[] visibility, final StartAdvertisingResponse callback) {
        synchronized (this) {
            final VContext ctx = rootCtx.withCancel();
            Attributes attrs = null;
            final io.v.v23.discovery.Service vService = new io.v.v23.discovery.Service(
                    service.instanceId, service.instanceName, service.interfaceName,
                    new Attributes(service.attrs), Arrays.asList(service.addrs), new Attachments());
            if (service.attrs == null) {
                vService.setAttrs(new Attributes(new HashMap<String, String>()));
            }
            List<BlessingPattern> patterns;
            if (visibility != null) {
                patterns = new ArrayList<>(visibility.length);
                for (String pattern : visibility) {
                    patterns.add(new BlessingPattern(pattern));
                }
            } else {
                patterns = new ArrayList<>(0);
            }
            ListenableFuture<ListenableFuture<Void>> done = discovery.advertise(ctx, vService, patterns);
            Futures.addCallback(done, new FutureCallback<ListenableFuture<Void>>() {
                @Override
                public void onSuccess(ListenableFuture<Void> result) {
                    String instanceId = vService.getInstanceId();
                    callback.call(instanceId, null);
                    advertiserContextMap.put(instanceId, ctx);
                }

                @Override
                public void onFailure(Throwable t) {
                    System.out.println("Failed with " + t.toString());
                    Error e = new Error();
                    e.msg = t.toString();
                    e.id = "unknown";
                    callback.call("", e);
                }
            });
        }
    }

    @Override
    public void stopAdvertising(String instanceId, StopAdvertisingResponse response) {
        synchronized (this) {
            VContext ctx = advertiserContextMap.get(instanceId);
            if (ctx != null) {
                advertiserContextMap.remove(instanceId);
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
