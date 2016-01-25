// Copyright 2015 The Vanadium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

package io.v.mojo.discovery;

import android.content.Context;

import org.chromium.mojo.application.ApplicationConnection;
import org.chromium.mojo.application.ApplicationDelegate;
import org.chromium.mojo.application.ApplicationRunner;
import org.chromium.mojo.application.ServiceFactoryBinder;
import org.chromium.mojo.bindings.InterfaceRequest;
import org.chromium.mojo.system.Core;
import org.chromium.mojo.system.MessagePipeHandle;
import org.chromium.mojom.mojo.Shell;

import io.v.android.v23.V;
import io.v.v23.context.VContext;

/**
 * A mojo app that eposes  the v23 discovery api through the i.v.mojo.discovery interface.
 */
public class VDiscoveryApp implements ApplicationDelegate {

    private final VContext rootCtx;

    VDiscoveryApp(Context context) {
        rootCtx = V.init(context);
    }

    @Override
    public void initialize(Shell shell, String[] strings, String s) {}

    @Override
    public boolean configureIncomingConnection(ApplicationConnection applicationConnection) {
        applicationConnection.addService(new ServiceFactoryBinder<Advertiser>() {
            @Override
            public void bind(InterfaceRequest<Advertiser> request) {
                Advertiser.MANAGER.bind(new AdvertiserImpl(V.getDiscovery(rootCtx), rootCtx),
                        request);
            }

            @Override
            public String getInterfaceName() {
                return Advertiser.MANAGER.getName();
            }
        });

        applicationConnection.addService(new ServiceFactoryBinder<Scanner>() {
            @Override
            public void bind(InterfaceRequest<Scanner> request) {
                Scanner.MANAGER.bind(new ScannerImpl(V.getDiscovery(rootCtx), rootCtx),
                        request);

            }

            @Override
            public String getInterfaceName() {
                return Scanner.MANAGER.getName();
            }
        });
        return true;
    }

    @Override
    public void quit() {
        rootCtx.cancel();
    }

    public static void mojoMain(Context context, Core core,
                                MessagePipeHandle applicationRequestHandle) {
        ApplicationRunner.run(new VDiscoveryApp(context), core, applicationRequestHandle);
    }
}
