// Copyright 2015 The Vanadium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
library discovery;

import 'dart:async';
import 'dart:typed_data';

import 'package:mojo/bindings.dart' as bindings;
import 'package:mojo/core.dart' as mojo_core;

import './gen/dart-gen/mojom/lib/discovery/discovery.mojom.dart' as mojom;

part 'client_impl.dart';

typedef void ConnectToServiceFunction(String url, bindings.ProxyBase proxy);

abstract class Client {
  factory Client(ConnectToServiceFunction cts, String url) {
    return new _Client(cts, url);
  }

  /// Scan scans advertisements that match the query and returns a scanner handle that
  /// includes streams of found and lost advertisements.
  /// Scanning will continue until [stop] is called on the [Scanner] handle.
  ///
  /// For example, the following code waits until finding the first advertisement that matches the
  /// query and then stops scanning.
  ///
  ///     Scanner scanner = client.scan('v.InterfaceName = "v.io/i" AND v.Attrs["a"] = "v"');
  ///     Update firstFound = await scanner.onUpdate.firstWhere((update) => update.updateType == UpdateTypes.found);
  ///     scanner.stop();
  ///
  /// The query is a WHERE expression of a syncQL query against advertisements, where
  /// keys are Ids and values are Advertisement.
  ///
  /// SyncQL tutorial at:
  ///    https://github.com/vanadium/docs/blob/master/tutorials/syncql-tutorial.md
  Future<Scanner> scan(String query);

  /// Advertise the [Advertisement] to be discovered by [scan].
  /// [visibility] is used to limit the principals that can see the advertisement.
  /// An empty or null [visibility] means that there are no restrictions on visibility.
  /// Advertising will continue until [stop] is called on the [Advertiser] handle.
  ///
  /// If advertisement.id is not specified, a random unique identifier will be
  /// assigned to it. Any change to advertisement will not be applied after advertising starts.
  ///
  /// It is an error to have simultaneously active advertisements for two identical
  /// instances (advertisement.id).
  ///
  /// For example, the following code advertises an advertisement for 10 seconds.
  ///
  ///     Advertisement ad = new Advertisement('v.io/interfaceName', ['v.io/address']);
  ///     ad.attributes['a'] = 'v';
  ///     Advertiser advertiser = client.advertise(ad);
  ///     new Timer(const Duration(seconds: 10), () => advertiser.stop());
  Future<Advertiser> advertise(Advertisement advertisement,
      {List<String> visibility: null});
}

/// Handle to a scan call.
abstract class Scanner {
  /// A stream of [Update] objects as advertisements are found or lost by the scanner.
  Stream<Update> get onUpdate;

  /// Stops scanning.
  Future stop();
}

/// Handle to an advertise call.
abstract class Advertiser {
  /// Stops the advertisement.
  Future stop();
}

/// Advertisement represents a feed into advertiser to broadcast its contents
/// to scanners.
///
/// A large advertisement may require additional RPC calls causing delay in
/// discovery. We limit the maximum size of an advertisement to 512 bytes
/// excluding id and attachments.
class Advertisement {
  /// Universal unique identifier of the advertisement.
  /// If this is not specified, a random unique identifier will be assigned.
  List<int> id = null;

  /// Interface name that the advertised service implements.
  /// E.g., 'v.io/v23/services/vtrace.Store'.
  String interfaceName = null;

  /// Addresses (vanadium object names) that the advertised service is served on.
  /// E.g., '/host:port/a/b/c', '/ns.dev.v.io:8101/blah/blah'.
  List<String> addresses = null;

  /// Attributes as a key/value pair.
  /// E.g., {'resolution': '1024x768'}.
  ///
  /// The key must be US-ASCII printable characters, excluding the '=' character
  /// and should not start with '_' character.
  Map<String, String> attributes = new Map<String, String>();

  /// Attachments as a key/value pair.
  /// E.g., {'thumbnail': binary_data }.
  ///
  /// Unlike attributes, attachments are for binary data and they are not queryable.
  /// We limit the maximum size of a single attachment to 4K bytes.
  ///
  /// The key must be US-ASCII printable characters, excluding the '=' character
  /// and should not start with '_' character.
  Map<String, List<int>> attachments = new Map<String, List<int>>();

  Advertisement(this.interfaceName, this.addresses);
}

/// Enum for different types of updates.
enum UpdateTypes { found, lost }

/// Update represents a discovery update.
class Update {
  // The update type.
  UpdateTypes updateType;

  // The universal unique identifier of the advertisement.
  List<int> id = null;

  // The interface name that the service implements.
  String interfaceName = null;

  // The addresses (vanadium object names) that the service
  // is served on.
  List<String> addresses = new List<String>();

  // Returns the named attribute. An empty string is returned if
  // not found.
  Map<String, String> attributes = new Map<String, String>();

  Map<String, List<int>> _attachments = new Map<String, List<int>>();
  Function _attachmentFetcher;

  /// Fetches an attachment on-demand from its source.
  /// ArgumentError is thrown if not found.
  ///
  /// This may do RPC calls if the attachment is not fetched yet.
  ///
  /// Attachments may not be available when this update is for lost advertisement.
  Future<List<int>> fetchAttachment(String key) async {
    if (_attachments.containsKey(key)) {
      return _attachments[key];
    }

    return _attachmentFetcher(key);
  }

  Update._internal(
      this.updateType, this._attachmentFetcher, this.id, this.interfaceName);
}
