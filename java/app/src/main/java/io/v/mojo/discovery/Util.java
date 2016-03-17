// Copyright 2016 The Vanadium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

package io.v.mojo.discovery;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import io.v.v23.discovery.AdId;
import io.v.v23.discovery.Attachments;
import io.v.v23.discovery.Attributes;
import io.v.v23.security.BlessingPattern;
import io.v.v23.verror.VException;

class Util {
    static Error v2mError(VException e) {
        Error err = new Error();
        err.id = e.getID();
        err.actionCode = e.getAction().getValue();
        err.msg = e.toString();
        return err;
    }

    static io.v.v23.discovery.Advertisement m2vAd(Advertisement ad) {
        return new io.v.v23.discovery.Advertisement(
                (ad.id == null) ? new AdId() : new AdId(ad.id),
                ad.interfaceName,
                Arrays.asList(ad.addresses),
                (ad.attributes == null) ? new Attributes() : new Attributes(ad.attributes),
                (ad.attachments == null) ? new Attachments() : new Attachments(ad.attachments));
    }

    static List<BlessingPattern> m2vVisibility(String[] visibility) {
        if (visibility == null) {
            return null;
        }
        List<BlessingPattern> patterns = new ArrayList<>(visibility.length);
        for (String pattern : visibility) {
            patterns.add(new BlessingPattern(pattern));
        }
        return patterns;
    }

    static Advertisement v2mAd(io.v.v23.discovery.Advertisement ad) {
        Advertisement mAd = new Advertisement();
        mAd.id = ad.getId().toPrimitiveArray();
        mAd.interfaceName = ad.getInterfaceName();
        List<String> addresses = ad.getAddresses();
        mAd.addresses = addresses.toArray(new String[addresses.size()]);
        mAd.attributes = ad.getAttributes();
        mAd.attachments = ad.getAttachments();
        return mAd;
    }
}
