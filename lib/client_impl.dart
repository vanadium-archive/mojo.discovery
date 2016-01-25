// Copyright 2015 The Vanadium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
part of discovery;

typedef Future _StopFunction();

class _Client implements Client {
  final AdvertiserProxy _advertiserProxy = new AdvertiserProxy.unbound();
  final ScannerProxy _scannerProxy = new ScannerProxy.unbound();

  _Client(ConnectToServiceFunction cts, String url) {
    cts(url, _advertiserProxy);
    cts(url, _scannerProxy);
  }

  Future<Scanner> scan(String query) async {
    StreamController<Update> onUpdate = new StreamController<Update>();
    ScanHandlerStub handlerStub = new ScanHandlerStub.unbound();
    handlerStub.impl = new _ScanHandler(onUpdate);

    ScannerScanResponseParams scanResponse =
        await _scannerProxy.ptr.scan(query, handlerStub);
    if (scanResponse.err != null) {
      throw scanResponse.err;
    }

    Future stop() {
      return _scannerProxy.ptr.stop(scanResponse.handle);
    }
    return new _Scanner(stop, onUpdate.stream);
  }

  Future<Advertiser> advertise(Service service,
      {List<String> visibility: null}) async {
    AdvertiserAdvertiseResponseParams advertiseResponse =
        await _advertiserProxy.ptr.advertise(service, visibility);

    if (advertiseResponse.err != null) {
      throw advertiseResponse.err;
    }

    Future stop() {
      return _advertiserProxy.ptr.stop(advertiseResponse.handle);
    }
    return new _Advertiser(stop);
  }
}

class _Scanner implements Scanner {
  final Stream<Update> onUpdate;

  final _StopFunction _stop;
  _Scanner(this._stop, this.onUpdate) {}

  Future stop() {
    return _stop();
  }
}

class _Advertiser implements Advertiser {
  final _StopFunction _stop;
  _Advertiser(this._stop) {}

  Future stop() {
    return _stop();
  }
}

class _ScanHandler extends ScanHandler {
  StreamController<Update> _onUpdate;

  _ScanHandler(this._onUpdate);

  update(Update update) {
    _onUpdate.add(update);
  }
}
