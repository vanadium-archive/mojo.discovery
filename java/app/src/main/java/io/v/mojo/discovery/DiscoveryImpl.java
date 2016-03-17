// Copyright 2016 The Vanadium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

package io.v.mojo.discovery;

import com.google.common.util.concurrent.ListenableFuture;
import com.google.common.util.concurrent.MoreExecutors;

import java.util.List;

import org.chromium.mojo.system.Core;
import org.chromium.mojo.system.MojoException;
import org.chromium.mojo.system.RunLoop;

import io.v.android.v23.V;
import io.v.v23.InputChannelCallback;
import io.v.v23.InputChannels;
import io.v.v23.context.VContext;
import io.v.v23.security.BlessingPattern;
import io.v.v23.verror.VException;

class DiscoveryImpl implements Discovery {
    private final Core mCore;
    private final VContext mContext;
    private final io.v.v23.discovery.Discovery mDiscovery;

    DiscoveryImpl(Core core, VContext context) throws VException {
        mCore = core;
        mContext = context.withCancel();
        mDiscovery = V.newDiscovery(mContext);
    }

    private static class CloserImpl implements Closer {
        private final Core mCore;
        private final VContext mContext;
        private final ListenableFuture<Void> mDone;

        CloserImpl(Core core, VContext context, ListenableFuture<Void> done) {
            mCore = core;
            mContext = context;
            mDone = done;
        }

        @Override
        public void close(final CloseResponse callback) {
            // The bindings are not thread safe. We cannot call an interface
            // or a callback in another thread automatically. So we need to
            // them in the original thread using RunLoop.
            final RunLoop runLoop = mCore.getCurrentRunLoop();

            mContext.cancel();
            mDone.addListener(
                    new Runnable() {
                        @Override
                        public void run() {
                            runLoop.postDelayedTask(
                                    new Runnable() {
                                        @Override
                                        public void run() {
                                            callback.call();
                                        }
                                    },
                                    0);
                        }
                    },
                    MoreExecutors.directExecutor());
        }

        @Override
        public void close() {
            mContext.cancel();
        }

        @Override
        public void onConnectionError(MojoException e) {}
    }

    @Override
    public void advertise(Advertisement ad, String[] visibility, AdvertiseResponse callback) {
        try {
            io.v.v23.discovery.Advertisement vAd = Util.m2vAd(ad);
            List<BlessingPattern> vVisibility = Util.m2vVisibility(visibility);

            VContext context = mContext.withCancel();
            ListenableFuture<Void> done = mDiscovery.advertise(context, vAd, vVisibility);
            callback.call(
                    vAd.getId().toPrimitiveArray(), new CloserImpl(mCore, context, done), null);
        } catch (VException e) {
            callback.call(null, null, Util.v2mError(e));
        }
    }

    @Override
    public void scan(String query, final ScanHandler handler, final ScanResponse callback) {
        try {
            // The bindings are not thread safe. We cannot call an interface
            // or a callback in another thread automatically. So we need to
            // them in the original thread using RunLoop.
            final RunLoop runLoop = mCore.getCurrentRunLoop();

            final VContext context = mContext.withCancel();
            ListenableFuture<Void> done =
                    InputChannels.withCallback(
                            mDiscovery.scan(context, query),
                            new InputChannelCallback<io.v.v23.discovery.Update>() {
                                @Override
                                public ListenableFuture<Void> onNext(
                                        final io.v.v23.discovery.Update update) {
                                    runLoop.postDelayedTask(
                                            new Runnable() {
                                                @Override
                                                public void run() {
                                                    handler.onUpdate(
                                                            new UpdateImpl(mCore, context, update));
                                                }
                                            },
                                            0);
                                    return null;
                                }
                            });
            done.addListener(
                    new Runnable() {
                        @Override
                        public void run() {
                            runLoop.postDelayedTask(
                                    new Runnable() {
                                        @Override
                                        public void run() {
                                            handler.close();
                                        }
                                    },
                                    0);
                        }
                    },
                    MoreExecutors.directExecutor());
            callback.call(new CloserImpl(mCore, context, done), null);
        } catch (VException e) {
            callback.call(null, Util.v2mError(e));
        }
    }

    @Override
    public void close() {
        mContext.cancel();
    }

    @Override
    public void onConnectionError(MojoException e) {}
}
