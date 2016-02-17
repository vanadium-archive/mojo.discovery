// Copyright 2015 The Vanadium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
part of discovery;

typedef Future _StopFunction();

class _Client implements Client {
  final DiscoveryProxy _discoveryProxy = new DiscoveryProxy.unbound();

  _Client(ConnectToServiceFunction cts, String url) {
    cts(url, _discoveryProxy);
  }

  Future<Scanner> scan(String query) async {
    StreamController<ScanUpdate> onUpdate = new StreamController<ScanUpdate>();
    ScanHandlerStub handlerStub = new ScanHandlerStub.unbound();
    handlerStub.impl = new _ScanHandler(onUpdate);

    DiscoveryStartScanResponseParams scanResponse =
        await _discoveryProxy.ptr.startScan(query, handlerStub);
    if (scanResponse.err != null) {
      throw scanResponse.err;
    }

    Future stop() {
      return _discoveryProxy.ptr.stopScan(scanResponse.scanId);
    }
    return new _Scanner(stop, onUpdate.stream);
  }

  Future<Advertiser> advertise(Service service,
      {List<String> visibility: null}) async {
    DiscoveryStartAdvertisingResponseParams advertiseResponse =
        await _discoveryProxy.ptr.startAdvertising(service, visibility);

    if (advertiseResponse.err != null) {
      throw advertiseResponse.err;
    }

    Future stop() {
      return _discoveryProxy.ptr.stopAdvertising(advertiseResponse.instanceId);
    }
    return new _Advertiser(stop);
  }
}

class _Scanner implements Scanner {
  final Stream<ScanUpdate> onUpdate;

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
  StreamController<ScanUpdate> _onUpdate;

  _ScanHandler(this._onUpdate);

  update(ScanUpdate update) {
    _onUpdate.add(update);
  }
}
