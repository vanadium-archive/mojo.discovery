// Copyright 2015 The Vanadium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

package io.v.mojo.discovery;

import android.app.admin.SystemUpdatePolicy;
import android.util.Log;

import com.google.common.util.concurrent.FutureCallback;
import com.google.common.util.concurrent.Futures;
import com.google.common.util.concurrent.ListenableFuture;

import io.v.v23.discovery.Attachments;
import org.chromium.mojo.system.MojoException;

import java.lang.Override;
import java.lang.String;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;

import io.v.v23.context.VContext;
import io.v.v23.discovery.Attributes;
import io.v.v23.discovery.VDiscovery;
import io.v.v23.security.BlessingPattern;

class AdvertiserImpl implements Advertiser {

    private VDiscovery discovery;
    private VContext rootCtx;

    private final AtomicInteger nextAdvertiser = new AtomicInteger(0);

    private final Map<Integer, VContext> contextMap = new HashMap<>();

    public AdvertiserImpl(VDiscovery discovery, VContext rootCtx) {
        this.discovery = discovery;
        this.rootCtx = rootCtx;
    }
    @Override
    public void advertise(Service service, String[] visibility, final AdvertiseResponse callback) {
        synchronized (this) {
            final Integer nextValue = nextAdvertiser.getAndAdd(1);
            VContext ctx = rootCtx.withCancel();
            contextMap.put(nextValue, ctx);
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
                    callback.call(nextValue, vService.getInstanceId(), null);
                }

                @Override
                public void onFailure(Throwable t) {
                    System.out.println("Failed with " + t.toString());
                    Error e = new Error();
                    e.msg = t.toString();
                    e.id = "unknown";
                    callback.call(0, "", e);
                }
            });
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

}
