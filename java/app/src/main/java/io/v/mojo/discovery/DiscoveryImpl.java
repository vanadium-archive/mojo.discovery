// Copyright 2016 The Vanadium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

package io.v.mojo.discovery;

import android.net.Uri;

import com.google.common.util.concurrent.ListenableFuture;
import com.google.common.util.concurrent.MoreExecutors;

import java.util.List;

import org.chromium.mojo.system.Core;
import org.chromium.mojo.system.MojoException;
import org.chromium.mojo.system.RunLoop;
import org.joda.time.DateTimeZone;
import org.joda.time.Duration;
import org.joda.time.format.PeriodFormatter;
import org.joda.time.format.PeriodFormatterBuilder;
import org.joda.time.tz.UTCProvider;

import io.v.android.v23.V;
import io.v.v23.InputChannelCallback;
import io.v.v23.InputChannels;
import io.v.v23.context.VContext;
import io.v.v23.security.BlessingPattern;
import io.v.v23.verror.VException;

import io.v.impl.google.lib.discovery.GlobalDiscovery;

class DiscoveryImpl implements Discovery {
    private final Core mCore;
    private final VContext mContext;
    private final io.v.v23.discovery.Discovery mDiscovery;

    static {
        // TODO(jhahn): To avoid IOException: 'Resource not found: "org/joda/time/tz/data/ZoneInfoMap"'
        // Load resources or find other way to parse duration strings.
        DateTimeZone.setProvider(new UTCProvider());
    }

    DiscoveryImpl(Core core, VContext context, String connectionUrl) throws Exception {
        mCore = core;
        mContext = context.withCancel();

        Uri uri = Uri.parse(connectionUrl);
        String global = uri.getQueryParameter(DiscoveryConstants.QUERY_GLOBAL);
        if (global != null) {
            Duration mountTTL =
                    parseDuration(uri.getQueryParameter(DiscoveryConstants.QUERY_MOUNT_TTL));
            Duration scanInterval =
                    parseDuration(uri.getQueryParameter(DiscoveryConstants.QUERY_SCAN_INTERVAL));
            mDiscovery = GlobalDiscovery.newDiscovery(mContext, global, mountTTL, scanInterval);
        } else {
            mDiscovery = V.newDiscovery(mContext);
        }
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

    private static Duration parseDuration(String duration) {
        if (duration == null || duration.equals("0")) {
            return Duration.ZERO;
        }
        PeriodFormatter formatter =
                new PeriodFormatterBuilder()
                        .appendHours()
                        .appendSuffix("h")
                        .appendMinutes()
                        .appendSuffix("m")
                        .appendSecondsWithOptionalMillis()
                        .appendSuffix("s")
                        .toFormatter();
        return formatter.parsePeriod(duration).toStandardDuration();
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
