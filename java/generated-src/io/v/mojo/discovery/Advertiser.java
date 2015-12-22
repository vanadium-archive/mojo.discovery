// Copyright 2015 The Vanadium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

// Copyright 2014 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This file is autogenerated by:
//     mojo/public/tools/bindings/mojom_bindings_generator.py
// For:
//     mojom/vanadium/discovery.mojom
//

package io.v.mojo.discovery;

public interface Advertiser extends org.chromium.mojo.bindings.Interface {

    public interface Proxy extends Advertiser, org.chromium.mojo.bindings.Interface.Proxy {
    }

    NamedManager<Advertiser, Advertiser.Proxy> MANAGER = Advertiser_Internal.MANAGER;

    void advertise(Service service, String[] visibility, AdvertiseResponse callback);
    interface AdvertiseResponse extends org.chromium.mojo.bindings.Callbacks.Callback3<Integer, String, Error> { }

    void stop(int h, StopResponse callback);
    interface StopResponse extends org.chromium.mojo.bindings.Callbacks.Callback1<Error> { }
}

