// Copyright 2015 The Vanadium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
part of discovery;

class _Client implements Client {
  final mojom.DiscoveryProxy _discoveryProxy =
      new mojom.DiscoveryProxy.unbound();

  _Client(ConnectToServiceFunction cts, String url) {
    cts(url, _discoveryProxy);
  }

  Future<Scanner> scan(String query) async {
    StreamController<Update> onUpdate = new StreamController<Update>();

    mojom.ScanHandlerStub handlerStub = new mojom.ScanHandlerStub.unbound();
    handlerStub.impl = new _ScanHandler(onUpdate);

    mojom.DiscoveryScanResponseParams scanResponse =
        await _discoveryProxy.ptr.scan(query, handlerStub);

    if (scanResponse.err != null) {
      throw scanResponse.err;
    }

    return new _Scanner(scanResponse.closer, onUpdate.stream);
  }

  Future<Advertiser> advertise(Advertisement advertisement,
      {List<String> visibility: null}) async {
    mojom.Advertisement mAdvertisement = new mojom.Advertisement()
      ..id = advertisement.id
      ..interfaceName = advertisement.interfaceName
      ..attributes = advertisement.attributes
      ..attachments = advertisement.attachments
      ..addresses = advertisement.addresses;

    mojom.DiscoveryAdvertiseResponseParams advertiseResponse =
        await _discoveryProxy.ptr.advertise(mAdvertisement, visibility);

    if (advertiseResponse.err != null) {
      throw advertiseResponse.err;
    }

    return new _Advertiser(advertiseResponse.closer);
  }
}

class _Scanner implements Scanner {
  final Stream<Update> onUpdate;

  final mojom.CloserProxy _closer;
  _Scanner(this._closer, this.onUpdate) {}

  Future stop() {
    return _closer.close();
  }
}

class _Advertiser implements Advertiser {
  final mojom.CloserProxy _closer;
  _Advertiser(this._closer) {}

  Future stop() {
    return _closer.close();
  }
}

class _ScanHandler extends mojom.ScanHandler {
  StreamController<Update> _onUpdate;

  _ScanHandler(this._onUpdate);

  onUpdate(mojom.UpdateProxy mUpdate) async {
    mojom.UpdateIsLostResponseParams isLostParams = await mUpdate.ptr.isLost();
    bool isLost = isLostParams.lost;

    mojom.UpdateGetAdvertisementResponseParams advertisementParams =
        await mUpdate.ptr.getAdvertisement();

    Future<List<int>> attachmentFetcher(String key) async {
      var attachmentResponse = mUpdate.ptr.getAttachment(key);

      if (!(attachmentResponse is mojom.UpdateGetAttachmentResponseParams)) {
        throw new ArgumentError.value(key, 'key', 'Attachment does not exist');
      }

      ByteData data =
          await mojo_core.DataPipeDrainer.drainHandle(attachmentResponse.data);
      return data.buffer.asUint8List().toList();
    }

    mojom.Advertisement mAdvertisement = advertisementParams.ad;

    Update update = new Update._internal(
        isLost ? UpdateTypes.lost : UpdateTypes.found,
        attachmentFetcher,
        mAdvertisement.id,
        mAdvertisement.interfaceName);

    if (mAdvertisement.attributes != null) {
      update.attributes = mAdvertisement.attributes;
    }
    if (mAdvertisement.addresses != null) {
      update.addresses = mAdvertisement.addresses;
    }
    if (mAdvertisement.attachments != null) {
      update._attachments = mAdvertisement.attachments;
    }
    _onUpdate.add(update);
  }
}
