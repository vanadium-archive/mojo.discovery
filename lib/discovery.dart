// Copyright 2015 The Vanadium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
library discovery;

import 'dart:async';

import 'package:mojo/bindings.dart' as bindings;
import 'gen/dart-gen/mojom/lib/discovery/discovery.mojom.dart';

export 'gen/dart-gen/mojom/lib/discovery/discovery.mojom.dart' show Service;

part 'client_impl.dart';

typedef void ConnectToServiceFunction(String url, bindings.ProxyBase proxy);

abstract class Client {
  factory Client(ConnectToServiceFunction cts, String url) {
    return new _Client(cts, url);
  }

  /// Scan scans services that match the query and returns a scanner handle that
  /// includes streams of found and lost services.
  /// Scanning will continue until [stop] is called on the [Scanner] handle.
  ///
  /// For example, the following code waits until finding the first service that matches the
  /// query and then stops scanning.
  ///
  ///    Scanner scanner = client.scan('v.InterfaceName = "v.io/i" AND v.Attrs["a"] = "v"');
  ///    Service firstFoundService = await scanner.onFound.first;
  ///    scanner.stop();
  ///
  /// The query is a WHERE expression of a syncQL query against advertised services, where
  /// keys are InstanceIds and values are Services.
  ///
  /// SyncQL tutorial at:
  ///    https://github.com/vanadium/docs/blob/master/tutorials/syncql-tutorial.md
  Future<Scanner> scan(String query);

  /// Advertise advertises the [Service] to be discovered by [scan].
  /// [visibility] is used to limit the principals that can see the advertisement.
  /// An empty or null [visibility] means that there are no restrictions on visibility.
  /// Advertising will continue until [stop] is called on the [Advertiser] handle.
  ///
  /// If service.InstanceId is not specified, a random unique identifier be
  /// assigned to it. Any change to service will not be applied after advertising starts.
  ///
  /// It is an error to have simultaneously active advertisements for two identical
  /// instances (service.InstanceId).
  ///
  /// For example, the following code advertises a service for 10 seconds.
  ///
  ///   Service service = new Service()
  ///     ..interfaceName = 'v.io/i'
  ///     ..attrs = {'a', 'v'};
  ///   Advertiser advertiser = client.advertise(service);
  ///   new Timer(const Duration(seconds: 10), () => advertiser.stop());
  Future<Advertiser> advertise(Service service,
      {List<String> visibility: null});
}

/// Handle to a scan call.
abstract class Scanner {
  /// A stream of [Service] objects as they are discovered by the scanner.
  Stream<Service> get onFound;

  /// A stream of instanceIds for services that are no longer advertised.
  Stream<String> get onLost;

  /// Stops scanning.
  Future stop();
}

/// Handle to an advertise call.
abstract class Advertiser {
  /// Stops the advertisement.
  Future stop();
}
