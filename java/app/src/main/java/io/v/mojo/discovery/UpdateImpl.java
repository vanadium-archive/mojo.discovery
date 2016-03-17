// Copyright 2016 The Vanadium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

package io.v.mojo.discovery;

import android.util.Log;

import com.google.common.util.concurrent.FutureCallback;
import com.google.common.util.concurrent.Futures;

import java.nio.ByteBuffer;
import java.util.List;

import org.chromium.mojo.system.Core;
import org.chromium.mojo.system.DataPipe;
import org.chromium.mojo.system.DataPipe.ConsumerHandle;
import org.chromium.mojo.system.DataPipe.ProducerHandle;
import org.chromium.mojo.system.Pair;
import org.chromium.mojo.system.MojoException;

import io.v.v23.context.VContext;
import io.v.v23.verror.VException;

class UpdateImpl implements Update {
    private static final DataPipe.WriteFlags WRITE_FLAG =
            DataPipe.WriteFlags.none().setAllOrNone(true);

    private final Core mCore;
    private final VContext mContext;
    private final io.v.v23.discovery.Update mUpdate;

    UpdateImpl(Core core, VContext context, io.v.v23.discovery.Update update) {
        mCore = core;
        mContext = context;
        mUpdate = update;
    }

    @Override
    public void isLost(IsLostResponse callback) {
        callback.call(new Boolean(mUpdate.isLost()));
    }

    @Override
    public void getId(GetIdResponse callback) {
        callback.call(mUpdate.getId().toPrimitiveArray());
    }

    @Override
    public void getInterfaceName(GetInterfaceNameResponse callback) {
        callback.call(mUpdate.getInterfaceName());
    }

    @Override
    public void getAddresses(GetAddressesResponse callback) {
        List<String> addresses = mUpdate.getAddresses();
        callback.call(addresses.toArray(new String[addresses.size()]));
    }

    @Override
    public void getAttribute(String name, GetAttributeResponse callback) {
        callback.call(mUpdate.getAttribute(name));
    }

    @Override
    public void getAttachment(String name, GetAttachmentResponse callback) {
        Pair<DataPipe.ProducerHandle, DataPipe.ConsumerHandle> handles = mCore.createDataPipe(null);
        callback.call(handles.second);

        final DataPipe.ProducerHandle producer = handles.first;
        try {
            Futures.addCallback(
                    mUpdate.getAttachment(mContext, name),
                    new FutureCallback<byte[]>() {
                        @Override
                        public void onSuccess(byte[] attachment) {
                            try {
                                ByteBuffer buf = ByteBuffer.allocateDirect(attachment.length);
                                buf.put(attachment);
                                producer.writeData(buf, WRITE_FLAG);
                            } catch (MojoException e) {
                                Log.e(DiscoveryApp.TAG, e.toString());
                            } finally {
                                producer.close();
                            }
                        }

                        @Override
                        public void onFailure(Throwable t) {
                            // TODO(jhahn): Any way to notify an error to the requester?
                            Log.e(DiscoveryApp.TAG, t.toString());
                            producer.close();
                        }
                    });
        } catch (VException e) {
            Log.e(DiscoveryApp.TAG, e.toString());
            producer.close();
        }
    }

    @Override
    public void getAdvertisement(GetAdvertisementResponse callback) {
        callback.call(Util.v2mAd(mUpdate.getAdvertisement()));
    }

    @Override
    public void close() {}

    @Override
    public void onConnectionError(MojoException e) {}
}
