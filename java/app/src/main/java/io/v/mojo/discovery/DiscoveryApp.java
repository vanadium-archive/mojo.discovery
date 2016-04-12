// Copyright 2016 The Vanadium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

package io.v.mojo.discovery;

import android.content.Context;
import android.util.Log;

import com.google.common.collect.ImmutableList;

import java.io.File;

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

import io.v.impl.google.lib.discovery.FactoryUtil;
import io.v.impl.google.services.mounttable.MountTableServer;

/**
 * Android mojo application providing the vanadium discovery service.
 */
public class DiscoveryApp implements ApplicationDelegate {
    static final String TAG = "DiscoveryApp";

    private final Core mCore;
    private VContext mContext;

    private File mCacheDir;

    DiscoveryApp(Core core, Context context) {
        mCore = core;
        mContext = V.init(context);

        // TODO(jhahn): MountTableServer always requires a storage directory for now.
        // Remove this once this bug is fixed.
        mCacheDir = context.getCacheDir();
    }

    @Override
    public void initialize(Shell shell, String[] args, String url) {
        for (String arg : args) {
            if (arg.matches("-{1,2}test-mode")) {
                try {
                    // Inject a mock plugin.
                    FactoryUtil.injectMockPlugin(mContext);

                    // Start a mounttable and set the namespace roots.
                    File storageRoot = new File(mCacheDir, "mounttable");
                    storageRoot.mkdirs();
                    mContext =
                            MountTableServer.withNewServer(
                                    mContext,
                                    new MountTableServer.Params()
                                            .withStatsPrefix("mounttable")
                                            .withStorageRootDir(storageRoot.getAbsolutePath()));
                    String name = V.getServer(mContext).getStatus().getEndpoints()[0].name();
                    V.getNamespace(mContext).setRoots(ImmutableList.of(name));
                } catch (Exception e) {
                    Log.e(TAG, e.toString());
                }
                break;
            }
        }
    }

    @Override
    public boolean configureIncomingConnection(final ApplicationConnection applicationConnection) {
        applicationConnection.addService(
                new ServiceFactoryBinder<Discovery>() {
                    @Override
                    public void bind(InterfaceRequest<Discovery> request) {
                        try {
                            Discovery.MANAGER.bind(
                                    new DiscoveryImpl(
                                            mCore, mContext, applicationConnection.connectionUrl()),
                                    request);
                        } catch (Exception e) {
                            Log.e(TAG, e.toString());
                            request.close();
                        }
                    }

                    @Override
                    public String getInterfaceName() {
                        return Discovery.MANAGER.getName();
                    }
                });
        return true;
    }

    @Override
    public void quit() {
        mContext.cancel();
    }

    public static void mojoMain(
            Context context, Core core, MessagePipeHandle applicationRequestHandle) {
        ApplicationRunner.run(new DiscoveryApp(core, context), core, applicationRequestHandle);
    }
}
