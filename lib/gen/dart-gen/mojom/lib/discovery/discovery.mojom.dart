// Copyright 2014 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

library discovery_mojom;
import 'dart:async';
import 'package:mojo/bindings.dart' as bindings;
import 'package:mojo/core.dart' as core;
import 'package:mojo/mojo/bindings/types/service_describer.mojom.dart' as service_describer;
const String queryGlobal = "global";
const String queryMountTtl = "mount_ttl";
const String queryScanInterval = "scan_interval";



class Advertisement extends bindings.Struct {
  static const List<bindings.StructDataHeader> kVersions = const [
    const bindings.StructDataHeader(48, 0)
  ];
  static const int idLen = 16;
  List<int> id = null;
  String interfaceName = null;
  List<String> addresses = null;
  Map<String, String> attributes = null;
  Map<String, List<int>> attachments = null;

  Advertisement() : super(kVersions.last.size);

  static Advertisement deserialize(bindings.Message message) {
    var decoder = new bindings.Decoder(message);
    var result = decode(decoder);
    if (decoder.excessHandles != null) {
      decoder.excessHandles.forEach((h) => h.close());
    }
    return result;
  }

  static Advertisement decode(bindings.Decoder decoder0) {
    if (decoder0 == null) {
      return null;
    }
    Advertisement result = new Advertisement();

    var mainDataHeader = decoder0.decodeStructDataHeader();
    if (mainDataHeader.version <= kVersions.last.version) {
      // Scan in reverse order to optimize for more recent versions.
      for (int i = kVersions.length - 1; i >= 0; --i) {
        if (mainDataHeader.version >= kVersions[i].version) {
          if (mainDataHeader.size == kVersions[i].size) {
            // Found a match.
            break;
          }
          throw new bindings.MojoCodecError(
              'Header size doesn\'t correspond to known version size.');
        }
      }
    } else if (mainDataHeader.size < kVersions.last.size) {
      throw new bindings.MojoCodecError(
        'Message newer than the last known version cannot be shorter than '
        'required by the last known version.');
    }
    if (mainDataHeader.version >= 0) {
      
      result.id = decoder0.decodeUint8Array(8, bindings.kArrayNullable, 16);
    }
    if (mainDataHeader.version >= 0) {
      
      result.interfaceName = decoder0.decodeString(16, false);
    }
    if (mainDataHeader.version >= 0) {
      
      var decoder1 = decoder0.decodePointer(24, false);
      {
        var si1 = decoder1.decodeDataHeaderForPointerArray(bindings.kUnspecifiedArrayLength);
        result.addresses = new List<String>(si1.numElements);
        for (int i1 = 0; i1 < si1.numElements; ++i1) {
          
          result.addresses[i1] = decoder1.decodeString(bindings.ArrayDataHeader.kHeaderSize + bindings.kPointerSize * i1, false);
        }
      }
    }
    if (mainDataHeader.version >= 0) {
      
      var decoder1 = decoder0.decodePointer(32, true);
      if (decoder1 == null) {
        result.attributes = null;
      } else {
        decoder1.decodeDataHeaderForMap();
        List<String> keys0;
        List<String> values0;
        {
          
          var decoder2 = decoder1.decodePointer(bindings.ArrayDataHeader.kHeaderSize, false);
          {
            var si2 = decoder2.decodeDataHeaderForPointerArray(bindings.kUnspecifiedArrayLength);
            keys0 = new List<String>(si2.numElements);
            for (int i2 = 0; i2 < si2.numElements; ++i2) {
              
              keys0[i2] = decoder2.decodeString(bindings.ArrayDataHeader.kHeaderSize + bindings.kPointerSize * i2, false);
            }
          }
        }
        {
          
          var decoder2 = decoder1.decodePointer(bindings.ArrayDataHeader.kHeaderSize + bindings.kPointerSize, false);
          {
            var si2 = decoder2.decodeDataHeaderForPointerArray(keys0.length);
            values0 = new List<String>(si2.numElements);
            for (int i2 = 0; i2 < si2.numElements; ++i2) {
              
              values0[i2] = decoder2.decodeString(bindings.ArrayDataHeader.kHeaderSize + bindings.kPointerSize * i2, false);
            }
          }
        }
        result.attributes = new Map<String, String>.fromIterables(
            keys0, values0);
      }
    }
    if (mainDataHeader.version >= 0) {
      
      var decoder1 = decoder0.decodePointer(40, true);
      if (decoder1 == null) {
        result.attachments = null;
      } else {
        decoder1.decodeDataHeaderForMap();
        List<String> keys0;
        List<List<int>> values0;
        {
          
          var decoder2 = decoder1.decodePointer(bindings.ArrayDataHeader.kHeaderSize, false);
          {
            var si2 = decoder2.decodeDataHeaderForPointerArray(bindings.kUnspecifiedArrayLength);
            keys0 = new List<String>(si2.numElements);
            for (int i2 = 0; i2 < si2.numElements; ++i2) {
              
              keys0[i2] = decoder2.decodeString(bindings.ArrayDataHeader.kHeaderSize + bindings.kPointerSize * i2, false);
            }
          }
        }
        {
          
          var decoder2 = decoder1.decodePointer(bindings.ArrayDataHeader.kHeaderSize + bindings.kPointerSize, false);
          {
            var si2 = decoder2.decodeDataHeaderForPointerArray(keys0.length);
            values0 = new List<List<int>>(si2.numElements);
            for (int i2 = 0; i2 < si2.numElements; ++i2) {
              
              values0[i2] = decoder2.decodeUint8Array(bindings.ArrayDataHeader.kHeaderSize + bindings.kPointerSize * i2, bindings.kNothingNullable, bindings.kUnspecifiedArrayLength);
            }
          }
        }
        result.attachments = new Map<String, List<int>>.fromIterables(
            keys0, values0);
      }
    }
    return result;
  }

  void encode(bindings.Encoder encoder) {
    var encoder0 = encoder.getStructEncoderAtOffset(kVersions.last);
    try {
      encoder0.encodeUint8Array(id, 8, bindings.kArrayNullable, 16);
    } on bindings.MojoCodecError catch(e) {
      e.message = "Error encountered while encoding field "
          "id of struct Advertisement: $e";
      rethrow;
    }
    try {
      encoder0.encodeString(interfaceName, 16, false);
    } on bindings.MojoCodecError catch(e) {
      e.message = "Error encountered while encoding field "
          "interfaceName of struct Advertisement: $e";
      rethrow;
    }
    try {
      if (addresses == null) {
        encoder0.encodeNullPointer(24, false);
      } else {
        var encoder1 = encoder0.encodePointerArray(addresses.length, 24, bindings.kUnspecifiedArrayLength);
        for (int i0 = 0; i0 < addresses.length; ++i0) {
          encoder1.encodeString(addresses[i0], bindings.ArrayDataHeader.kHeaderSize + bindings.kPointerSize * i0, false);
        }
      }
    } on bindings.MojoCodecError catch(e) {
      e.message = "Error encountered while encoding field "
          "addresses of struct Advertisement: $e";
      rethrow;
    }
    try {
      if (attributes == null) {
        encoder0.encodeNullPointer(32, true);
      } else {
        var encoder1 = encoder0.encoderForMap(32);
        var keys0 = attributes.keys.toList();
        var values0 = attributes.values.toList();
        
        {
          var encoder2 = encoder1.encodePointerArray(keys0.length, bindings.ArrayDataHeader.kHeaderSize, bindings.kUnspecifiedArrayLength);
          for (int i1 = 0; i1 < keys0.length; ++i1) {
            encoder2.encodeString(keys0[i1], bindings.ArrayDataHeader.kHeaderSize + bindings.kPointerSize * i1, false);
          }
        }
        
        {
          var encoder2 = encoder1.encodePointerArray(values0.length, bindings.ArrayDataHeader.kHeaderSize + bindings.kPointerSize, bindings.kUnspecifiedArrayLength);
          for (int i1 = 0; i1 < values0.length; ++i1) {
            encoder2.encodeString(values0[i1], bindings.ArrayDataHeader.kHeaderSize + bindings.kPointerSize * i1, false);
          }
        }
      }
    } on bindings.MojoCodecError catch(e) {
      e.message = "Error encountered while encoding field "
          "attributes of struct Advertisement: $e";
      rethrow;
    }
    try {
      if (attachments == null) {
        encoder0.encodeNullPointer(40, true);
      } else {
        var encoder1 = encoder0.encoderForMap(40);
        var keys0 = attachments.keys.toList();
        var values0 = attachments.values.toList();
        
        {
          var encoder2 = encoder1.encodePointerArray(keys0.length, bindings.ArrayDataHeader.kHeaderSize, bindings.kUnspecifiedArrayLength);
          for (int i1 = 0; i1 < keys0.length; ++i1) {
            encoder2.encodeString(keys0[i1], bindings.ArrayDataHeader.kHeaderSize + bindings.kPointerSize * i1, false);
          }
        }
        
        {
          var encoder2 = encoder1.encodePointerArray(values0.length, bindings.ArrayDataHeader.kHeaderSize + bindings.kPointerSize, bindings.kUnspecifiedArrayLength);
          for (int i1 = 0; i1 < values0.length; ++i1) {
            encoder2.encodeUint8Array(values0[i1], bindings.ArrayDataHeader.kHeaderSize + bindings.kPointerSize * i1, bindings.kNothingNullable, bindings.kUnspecifiedArrayLength);
          }
        }
      }
    } on bindings.MojoCodecError catch(e) {
      e.message = "Error encountered while encoding field "
          "attachments of struct Advertisement: $e";
      rethrow;
    }
  }

  String toString() {
    return "Advertisement("
           "id: $id" ", "
           "interfaceName: $interfaceName" ", "
           "addresses: $addresses" ", "
           "attributes: $attributes" ", "
           "attachments: $attachments" ")";
  }

  Map toJson() {
    Map map = new Map();
    map["id"] = id;
    map["interfaceName"] = interfaceName;
    map["addresses"] = addresses;
    map["attributes"] = attributes;
    map["attachments"] = attachments;
    return map;
  }
}


class Error extends bindings.Struct {
  static const List<bindings.StructDataHeader> kVersions = const [
    const bindings.StructDataHeader(32, 0)
  ];
  String id = null;
  int actionCode = 0;
  String msg = null;

  Error() : super(kVersions.last.size);

  static Error deserialize(bindings.Message message) {
    var decoder = new bindings.Decoder(message);
    var result = decode(decoder);
    if (decoder.excessHandles != null) {
      decoder.excessHandles.forEach((h) => h.close());
    }
    return result;
  }

  static Error decode(bindings.Decoder decoder0) {
    if (decoder0 == null) {
      return null;
    }
    Error result = new Error();

    var mainDataHeader = decoder0.decodeStructDataHeader();
    if (mainDataHeader.version <= kVersions.last.version) {
      // Scan in reverse order to optimize for more recent versions.
      for (int i = kVersions.length - 1; i >= 0; --i) {
        if (mainDataHeader.version >= kVersions[i].version) {
          if (mainDataHeader.size == kVersions[i].size) {
            // Found a match.
            break;
          }
          throw new bindings.MojoCodecError(
              'Header size doesn\'t correspond to known version size.');
        }
      }
    } else if (mainDataHeader.size < kVersions.last.size) {
      throw new bindings.MojoCodecError(
        'Message newer than the last known version cannot be shorter than '
        'required by the last known version.');
    }
    if (mainDataHeader.version >= 0) {
      
      result.id = decoder0.decodeString(8, false);
    }
    if (mainDataHeader.version >= 0) {
      
      result.actionCode = decoder0.decodeUint32(16);
    }
    if (mainDataHeader.version >= 0) {
      
      result.msg = decoder0.decodeString(24, false);
    }
    return result;
  }

  void encode(bindings.Encoder encoder) {
    var encoder0 = encoder.getStructEncoderAtOffset(kVersions.last);
    try {
      encoder0.encodeString(id, 8, false);
    } on bindings.MojoCodecError catch(e) {
      e.message = "Error encountered while encoding field "
          "id of struct Error: $e";
      rethrow;
    }
    try {
      encoder0.encodeUint32(actionCode, 16);
    } on bindings.MojoCodecError catch(e) {
      e.message = "Error encountered while encoding field "
          "actionCode of struct Error: $e";
      rethrow;
    }
    try {
      encoder0.encodeString(msg, 24, false);
    } on bindings.MojoCodecError catch(e) {
      e.message = "Error encountered while encoding field "
          "msg of struct Error: $e";
      rethrow;
    }
  }

  String toString() {
    return "Error("
           "id: $id" ", "
           "actionCode: $actionCode" ", "
           "msg: $msg" ")";
  }

  Map toJson() {
    Map map = new Map();
    map["id"] = id;
    map["actionCode"] = actionCode;
    map["msg"] = msg;
    return map;
  }
}


class _DiscoveryAdvertiseParams extends bindings.Struct {
  static const List<bindings.StructDataHeader> kVersions = const [
    const bindings.StructDataHeader(24, 0)
  ];
  Advertisement ad = null;
  List<String> visibility = null;

  _DiscoveryAdvertiseParams() : super(kVersions.last.size);

  static _DiscoveryAdvertiseParams deserialize(bindings.Message message) {
    var decoder = new bindings.Decoder(message);
    var result = decode(decoder);
    if (decoder.excessHandles != null) {
      decoder.excessHandles.forEach((h) => h.close());
    }
    return result;
  }

  static _DiscoveryAdvertiseParams decode(bindings.Decoder decoder0) {
    if (decoder0 == null) {
      return null;
    }
    _DiscoveryAdvertiseParams result = new _DiscoveryAdvertiseParams();

    var mainDataHeader = decoder0.decodeStructDataHeader();
    if (mainDataHeader.version <= kVersions.last.version) {
      // Scan in reverse order to optimize for more recent versions.
      for (int i = kVersions.length - 1; i >= 0; --i) {
        if (mainDataHeader.version >= kVersions[i].version) {
          if (mainDataHeader.size == kVersions[i].size) {
            // Found a match.
            break;
          }
          throw new bindings.MojoCodecError(
              'Header size doesn\'t correspond to known version size.');
        }
      }
    } else if (mainDataHeader.size < kVersions.last.size) {
      throw new bindings.MojoCodecError(
        'Message newer than the last known version cannot be shorter than '
        'required by the last known version.');
    }
    if (mainDataHeader.version >= 0) {
      
      var decoder1 = decoder0.decodePointer(8, false);
      result.ad = Advertisement.decode(decoder1);
    }
    if (mainDataHeader.version >= 0) {
      
      var decoder1 = decoder0.decodePointer(16, true);
      if (decoder1 == null) {
        result.visibility = null;
      } else {
        var si1 = decoder1.decodeDataHeaderForPointerArray(bindings.kUnspecifiedArrayLength);
        result.visibility = new List<String>(si1.numElements);
        for (int i1 = 0; i1 < si1.numElements; ++i1) {
          
          result.visibility[i1] = decoder1.decodeString(bindings.ArrayDataHeader.kHeaderSize + bindings.kPointerSize * i1, false);
        }
      }
    }
    return result;
  }

  void encode(bindings.Encoder encoder) {
    var encoder0 = encoder.getStructEncoderAtOffset(kVersions.last);
    try {
      encoder0.encodeStruct(ad, 8, false);
    } on bindings.MojoCodecError catch(e) {
      e.message = "Error encountered while encoding field "
          "ad of struct _DiscoveryAdvertiseParams: $e";
      rethrow;
    }
    try {
      if (visibility == null) {
        encoder0.encodeNullPointer(16, true);
      } else {
        var encoder1 = encoder0.encodePointerArray(visibility.length, 16, bindings.kUnspecifiedArrayLength);
        for (int i0 = 0; i0 < visibility.length; ++i0) {
          encoder1.encodeString(visibility[i0], bindings.ArrayDataHeader.kHeaderSize + bindings.kPointerSize * i0, false);
        }
      }
    } on bindings.MojoCodecError catch(e) {
      e.message = "Error encountered while encoding field "
          "visibility of struct _DiscoveryAdvertiseParams: $e";
      rethrow;
    }
  }

  String toString() {
    return "_DiscoveryAdvertiseParams("
           "ad: $ad" ", "
           "visibility: $visibility" ")";
  }

  Map toJson() {
    Map map = new Map();
    map["ad"] = ad;
    map["visibility"] = visibility;
    return map;
  }
}


class DiscoveryAdvertiseResponseParams extends bindings.Struct {
  static const List<bindings.StructDataHeader> kVersions = const [
    const bindings.StructDataHeader(32, 0)
  ];
  List<int> instanceId = null;
  Object closer = null;
  Error err = null;

  DiscoveryAdvertiseResponseParams() : super(kVersions.last.size);

  static DiscoveryAdvertiseResponseParams deserialize(bindings.Message message) {
    var decoder = new bindings.Decoder(message);
    var result = decode(decoder);
    if (decoder.excessHandles != null) {
      decoder.excessHandles.forEach((h) => h.close());
    }
    return result;
  }

  static DiscoveryAdvertiseResponseParams decode(bindings.Decoder decoder0) {
    if (decoder0 == null) {
      return null;
    }
    DiscoveryAdvertiseResponseParams result = new DiscoveryAdvertiseResponseParams();

    var mainDataHeader = decoder0.decodeStructDataHeader();
    if (mainDataHeader.version <= kVersions.last.version) {
      // Scan in reverse order to optimize for more recent versions.
      for (int i = kVersions.length - 1; i >= 0; --i) {
        if (mainDataHeader.version >= kVersions[i].version) {
          if (mainDataHeader.size == kVersions[i].size) {
            // Found a match.
            break;
          }
          throw new bindings.MojoCodecError(
              'Header size doesn\'t correspond to known version size.');
        }
      }
    } else if (mainDataHeader.size < kVersions.last.size) {
      throw new bindings.MojoCodecError(
        'Message newer than the last known version cannot be shorter than '
        'required by the last known version.');
    }
    if (mainDataHeader.version >= 0) {
      
      result.instanceId = decoder0.decodeUint8Array(8, bindings.kArrayNullable, 16);
    }
    if (mainDataHeader.version >= 0) {
      
      result.closer = decoder0.decodeServiceInterface(16, true, CloserProxy.newFromEndpoint);
    }
    if (mainDataHeader.version >= 0) {
      
      var decoder1 = decoder0.decodePointer(24, true);
      result.err = Error.decode(decoder1);
    }
    return result;
  }

  void encode(bindings.Encoder encoder) {
    var encoder0 = encoder.getStructEncoderAtOffset(kVersions.last);
    try {
      encoder0.encodeUint8Array(instanceId, 8, bindings.kArrayNullable, 16);
    } on bindings.MojoCodecError catch(e) {
      e.message = "Error encountered while encoding field "
          "instanceId of struct DiscoveryAdvertiseResponseParams: $e";
      rethrow;
    }
    try {
      encoder0.encodeInterface(closer, 16, true);
    } on bindings.MojoCodecError catch(e) {
      e.message = "Error encountered while encoding field "
          "closer of struct DiscoveryAdvertiseResponseParams: $e";
      rethrow;
    }
    try {
      encoder0.encodeStruct(err, 24, true);
    } on bindings.MojoCodecError catch(e) {
      e.message = "Error encountered while encoding field "
          "err of struct DiscoveryAdvertiseResponseParams: $e";
      rethrow;
    }
  }

  String toString() {
    return "DiscoveryAdvertiseResponseParams("
           "instanceId: $instanceId" ", "
           "closer: $closer" ", "
           "err: $err" ")";
  }

  Map toJson() {
    throw new bindings.MojoCodecError(
        'Object containing handles cannot be encoded to JSON.');
  }
}


class _DiscoveryScanParams extends bindings.Struct {
  static const List<bindings.StructDataHeader> kVersions = const [
    const bindings.StructDataHeader(24, 0)
  ];
  String query = null;
  Object handler = null;

  _DiscoveryScanParams() : super(kVersions.last.size);

  static _DiscoveryScanParams deserialize(bindings.Message message) {
    var decoder = new bindings.Decoder(message);
    var result = decode(decoder);
    if (decoder.excessHandles != null) {
      decoder.excessHandles.forEach((h) => h.close());
    }
    return result;
  }

  static _DiscoveryScanParams decode(bindings.Decoder decoder0) {
    if (decoder0 == null) {
      return null;
    }
    _DiscoveryScanParams result = new _DiscoveryScanParams();

    var mainDataHeader = decoder0.decodeStructDataHeader();
    if (mainDataHeader.version <= kVersions.last.version) {
      // Scan in reverse order to optimize for more recent versions.
      for (int i = kVersions.length - 1; i >= 0; --i) {
        if (mainDataHeader.version >= kVersions[i].version) {
          if (mainDataHeader.size == kVersions[i].size) {
            // Found a match.
            break;
          }
          throw new bindings.MojoCodecError(
              'Header size doesn\'t correspond to known version size.');
        }
      }
    } else if (mainDataHeader.size < kVersions.last.size) {
      throw new bindings.MojoCodecError(
        'Message newer than the last known version cannot be shorter than '
        'required by the last known version.');
    }
    if (mainDataHeader.version >= 0) {
      
      result.query = decoder0.decodeString(8, false);
    }
    if (mainDataHeader.version >= 0) {
      
      result.handler = decoder0.decodeServiceInterface(16, false, ScanHandlerProxy.newFromEndpoint);
    }
    return result;
  }

  void encode(bindings.Encoder encoder) {
    var encoder0 = encoder.getStructEncoderAtOffset(kVersions.last);
    try {
      encoder0.encodeString(query, 8, false);
    } on bindings.MojoCodecError catch(e) {
      e.message = "Error encountered while encoding field "
          "query of struct _DiscoveryScanParams: $e";
      rethrow;
    }
    try {
      encoder0.encodeInterface(handler, 16, false);
    } on bindings.MojoCodecError catch(e) {
      e.message = "Error encountered while encoding field "
          "handler of struct _DiscoveryScanParams: $e";
      rethrow;
    }
  }

  String toString() {
    return "_DiscoveryScanParams("
           "query: $query" ", "
           "handler: $handler" ")";
  }

  Map toJson() {
    throw new bindings.MojoCodecError(
        'Object containing handles cannot be encoded to JSON.');
  }
}


class DiscoveryScanResponseParams extends bindings.Struct {
  static const List<bindings.StructDataHeader> kVersions = const [
    const bindings.StructDataHeader(24, 0)
  ];
  Object closer = null;
  Error err = null;

  DiscoveryScanResponseParams() : super(kVersions.last.size);

  static DiscoveryScanResponseParams deserialize(bindings.Message message) {
    var decoder = new bindings.Decoder(message);
    var result = decode(decoder);
    if (decoder.excessHandles != null) {
      decoder.excessHandles.forEach((h) => h.close());
    }
    return result;
  }

  static DiscoveryScanResponseParams decode(bindings.Decoder decoder0) {
    if (decoder0 == null) {
      return null;
    }
    DiscoveryScanResponseParams result = new DiscoveryScanResponseParams();

    var mainDataHeader = decoder0.decodeStructDataHeader();
    if (mainDataHeader.version <= kVersions.last.version) {
      // Scan in reverse order to optimize for more recent versions.
      for (int i = kVersions.length - 1; i >= 0; --i) {
        if (mainDataHeader.version >= kVersions[i].version) {
          if (mainDataHeader.size == kVersions[i].size) {
            // Found a match.
            break;
          }
          throw new bindings.MojoCodecError(
              'Header size doesn\'t correspond to known version size.');
        }
      }
    } else if (mainDataHeader.size < kVersions.last.size) {
      throw new bindings.MojoCodecError(
        'Message newer than the last known version cannot be shorter than '
        'required by the last known version.');
    }
    if (mainDataHeader.version >= 0) {
      
      result.closer = decoder0.decodeServiceInterface(8, true, CloserProxy.newFromEndpoint);
    }
    if (mainDataHeader.version >= 0) {
      
      var decoder1 = decoder0.decodePointer(16, true);
      result.err = Error.decode(decoder1);
    }
    return result;
  }

  void encode(bindings.Encoder encoder) {
    var encoder0 = encoder.getStructEncoderAtOffset(kVersions.last);
    try {
      encoder0.encodeInterface(closer, 8, true);
    } on bindings.MojoCodecError catch(e) {
      e.message = "Error encountered while encoding field "
          "closer of struct DiscoveryScanResponseParams: $e";
      rethrow;
    }
    try {
      encoder0.encodeStruct(err, 16, true);
    } on bindings.MojoCodecError catch(e) {
      e.message = "Error encountered while encoding field "
          "err of struct DiscoveryScanResponseParams: $e";
      rethrow;
    }
  }

  String toString() {
    return "DiscoveryScanResponseParams("
           "closer: $closer" ", "
           "err: $err" ")";
  }

  Map toJson() {
    throw new bindings.MojoCodecError(
        'Object containing handles cannot be encoded to JSON.');
  }
}


class _CloserCloseParams extends bindings.Struct {
  static const List<bindings.StructDataHeader> kVersions = const [
    const bindings.StructDataHeader(8, 0)
  ];

  _CloserCloseParams() : super(kVersions.last.size);

  static _CloserCloseParams deserialize(bindings.Message message) {
    var decoder = new bindings.Decoder(message);
    var result = decode(decoder);
    if (decoder.excessHandles != null) {
      decoder.excessHandles.forEach((h) => h.close());
    }
    return result;
  }

  static _CloserCloseParams decode(bindings.Decoder decoder0) {
    if (decoder0 == null) {
      return null;
    }
    _CloserCloseParams result = new _CloserCloseParams();

    var mainDataHeader = decoder0.decodeStructDataHeader();
    if (mainDataHeader.version <= kVersions.last.version) {
      // Scan in reverse order to optimize for more recent versions.
      for (int i = kVersions.length - 1; i >= 0; --i) {
        if (mainDataHeader.version >= kVersions[i].version) {
          if (mainDataHeader.size == kVersions[i].size) {
            // Found a match.
            break;
          }
          throw new bindings.MojoCodecError(
              'Header size doesn\'t correspond to known version size.');
        }
      }
    } else if (mainDataHeader.size < kVersions.last.size) {
      throw new bindings.MojoCodecError(
        'Message newer than the last known version cannot be shorter than '
        'required by the last known version.');
    }
    return result;
  }

  void encode(bindings.Encoder encoder) {
    encoder.getStructEncoderAtOffset(kVersions.last);
  }

  String toString() {
    return "_CloserCloseParams("")";
  }

  Map toJson() {
    Map map = new Map();
    return map;
  }
}


class CloserCloseResponseParams extends bindings.Struct {
  static const List<bindings.StructDataHeader> kVersions = const [
    const bindings.StructDataHeader(8, 0)
  ];

  CloserCloseResponseParams() : super(kVersions.last.size);

  static CloserCloseResponseParams deserialize(bindings.Message message) {
    var decoder = new bindings.Decoder(message);
    var result = decode(decoder);
    if (decoder.excessHandles != null) {
      decoder.excessHandles.forEach((h) => h.close());
    }
    return result;
  }

  static CloserCloseResponseParams decode(bindings.Decoder decoder0) {
    if (decoder0 == null) {
      return null;
    }
    CloserCloseResponseParams result = new CloserCloseResponseParams();

    var mainDataHeader = decoder0.decodeStructDataHeader();
    if (mainDataHeader.version <= kVersions.last.version) {
      // Scan in reverse order to optimize for more recent versions.
      for (int i = kVersions.length - 1; i >= 0; --i) {
        if (mainDataHeader.version >= kVersions[i].version) {
          if (mainDataHeader.size == kVersions[i].size) {
            // Found a match.
            break;
          }
          throw new bindings.MojoCodecError(
              'Header size doesn\'t correspond to known version size.');
        }
      }
    } else if (mainDataHeader.size < kVersions.last.size) {
      throw new bindings.MojoCodecError(
        'Message newer than the last known version cannot be shorter than '
        'required by the last known version.');
    }
    return result;
  }

  void encode(bindings.Encoder encoder) {
    encoder.getStructEncoderAtOffset(kVersions.last);
  }

  String toString() {
    return "CloserCloseResponseParams("")";
  }

  Map toJson() {
    Map map = new Map();
    return map;
  }
}


class _ScanHandlerOnUpdateParams extends bindings.Struct {
  static const List<bindings.StructDataHeader> kVersions = const [
    const bindings.StructDataHeader(16, 0)
  ];
  Object update = null;

  _ScanHandlerOnUpdateParams() : super(kVersions.last.size);

  static _ScanHandlerOnUpdateParams deserialize(bindings.Message message) {
    var decoder = new bindings.Decoder(message);
    var result = decode(decoder);
    if (decoder.excessHandles != null) {
      decoder.excessHandles.forEach((h) => h.close());
    }
    return result;
  }

  static _ScanHandlerOnUpdateParams decode(bindings.Decoder decoder0) {
    if (decoder0 == null) {
      return null;
    }
    _ScanHandlerOnUpdateParams result = new _ScanHandlerOnUpdateParams();

    var mainDataHeader = decoder0.decodeStructDataHeader();
    if (mainDataHeader.version <= kVersions.last.version) {
      // Scan in reverse order to optimize for more recent versions.
      for (int i = kVersions.length - 1; i >= 0; --i) {
        if (mainDataHeader.version >= kVersions[i].version) {
          if (mainDataHeader.size == kVersions[i].size) {
            // Found a match.
            break;
          }
          throw new bindings.MojoCodecError(
              'Header size doesn\'t correspond to known version size.');
        }
      }
    } else if (mainDataHeader.size < kVersions.last.size) {
      throw new bindings.MojoCodecError(
        'Message newer than the last known version cannot be shorter than '
        'required by the last known version.');
    }
    if (mainDataHeader.version >= 0) {
      
      result.update = decoder0.decodeServiceInterface(8, false, UpdateProxy.newFromEndpoint);
    }
    return result;
  }

  void encode(bindings.Encoder encoder) {
    var encoder0 = encoder.getStructEncoderAtOffset(kVersions.last);
    try {
      encoder0.encodeInterface(update, 8, false);
    } on bindings.MojoCodecError catch(e) {
      e.message = "Error encountered while encoding field "
          "update of struct _ScanHandlerOnUpdateParams: $e";
      rethrow;
    }
  }

  String toString() {
    return "_ScanHandlerOnUpdateParams("
           "update: $update" ")";
  }

  Map toJson() {
    throw new bindings.MojoCodecError(
        'Object containing handles cannot be encoded to JSON.');
  }
}


class _UpdateIsLostParams extends bindings.Struct {
  static const List<bindings.StructDataHeader> kVersions = const [
    const bindings.StructDataHeader(8, 0)
  ];

  _UpdateIsLostParams() : super(kVersions.last.size);

  static _UpdateIsLostParams deserialize(bindings.Message message) {
    var decoder = new bindings.Decoder(message);
    var result = decode(decoder);
    if (decoder.excessHandles != null) {
      decoder.excessHandles.forEach((h) => h.close());
    }
    return result;
  }

  static _UpdateIsLostParams decode(bindings.Decoder decoder0) {
    if (decoder0 == null) {
      return null;
    }
    _UpdateIsLostParams result = new _UpdateIsLostParams();

    var mainDataHeader = decoder0.decodeStructDataHeader();
    if (mainDataHeader.version <= kVersions.last.version) {
      // Scan in reverse order to optimize for more recent versions.
      for (int i = kVersions.length - 1; i >= 0; --i) {
        if (mainDataHeader.version >= kVersions[i].version) {
          if (mainDataHeader.size == kVersions[i].size) {
            // Found a match.
            break;
          }
          throw new bindings.MojoCodecError(
              'Header size doesn\'t correspond to known version size.');
        }
      }
    } else if (mainDataHeader.size < kVersions.last.size) {
      throw new bindings.MojoCodecError(
        'Message newer than the last known version cannot be shorter than '
        'required by the last known version.');
    }
    return result;
  }

  void encode(bindings.Encoder encoder) {
    encoder.getStructEncoderAtOffset(kVersions.last);
  }

  String toString() {
    return "_UpdateIsLostParams("")";
  }

  Map toJson() {
    Map map = new Map();
    return map;
  }
}


class UpdateIsLostResponseParams extends bindings.Struct {
  static const List<bindings.StructDataHeader> kVersions = const [
    const bindings.StructDataHeader(16, 0)
  ];
  bool lost = false;

  UpdateIsLostResponseParams() : super(kVersions.last.size);

  static UpdateIsLostResponseParams deserialize(bindings.Message message) {
    var decoder = new bindings.Decoder(message);
    var result = decode(decoder);
    if (decoder.excessHandles != null) {
      decoder.excessHandles.forEach((h) => h.close());
    }
    return result;
  }

  static UpdateIsLostResponseParams decode(bindings.Decoder decoder0) {
    if (decoder0 == null) {
      return null;
    }
    UpdateIsLostResponseParams result = new UpdateIsLostResponseParams();

    var mainDataHeader = decoder0.decodeStructDataHeader();
    if (mainDataHeader.version <= kVersions.last.version) {
      // Scan in reverse order to optimize for more recent versions.
      for (int i = kVersions.length - 1; i >= 0; --i) {
        if (mainDataHeader.version >= kVersions[i].version) {
          if (mainDataHeader.size == kVersions[i].size) {
            // Found a match.
            break;
          }
          throw new bindings.MojoCodecError(
              'Header size doesn\'t correspond to known version size.');
        }
      }
    } else if (mainDataHeader.size < kVersions.last.size) {
      throw new bindings.MojoCodecError(
        'Message newer than the last known version cannot be shorter than '
        'required by the last known version.');
    }
    if (mainDataHeader.version >= 0) {
      
      result.lost = decoder0.decodeBool(8, 0);
    }
    return result;
  }

  void encode(bindings.Encoder encoder) {
    var encoder0 = encoder.getStructEncoderAtOffset(kVersions.last);
    try {
      encoder0.encodeBool(lost, 8, 0);
    } on bindings.MojoCodecError catch(e) {
      e.message = "Error encountered while encoding field "
          "lost of struct UpdateIsLostResponseParams: $e";
      rethrow;
    }
  }

  String toString() {
    return "UpdateIsLostResponseParams("
           "lost: $lost" ")";
  }

  Map toJson() {
    Map map = new Map();
    map["lost"] = lost;
    return map;
  }
}


class _UpdateGetIdParams extends bindings.Struct {
  static const List<bindings.StructDataHeader> kVersions = const [
    const bindings.StructDataHeader(8, 0)
  ];

  _UpdateGetIdParams() : super(kVersions.last.size);

  static _UpdateGetIdParams deserialize(bindings.Message message) {
    var decoder = new bindings.Decoder(message);
    var result = decode(decoder);
    if (decoder.excessHandles != null) {
      decoder.excessHandles.forEach((h) => h.close());
    }
    return result;
  }

  static _UpdateGetIdParams decode(bindings.Decoder decoder0) {
    if (decoder0 == null) {
      return null;
    }
    _UpdateGetIdParams result = new _UpdateGetIdParams();

    var mainDataHeader = decoder0.decodeStructDataHeader();
    if (mainDataHeader.version <= kVersions.last.version) {
      // Scan in reverse order to optimize for more recent versions.
      for (int i = kVersions.length - 1; i >= 0; --i) {
        if (mainDataHeader.version >= kVersions[i].version) {
          if (mainDataHeader.size == kVersions[i].size) {
            // Found a match.
            break;
          }
          throw new bindings.MojoCodecError(
              'Header size doesn\'t correspond to known version size.');
        }
      }
    } else if (mainDataHeader.size < kVersions.last.size) {
      throw new bindings.MojoCodecError(
        'Message newer than the last known version cannot be shorter than '
        'required by the last known version.');
    }
    return result;
  }

  void encode(bindings.Encoder encoder) {
    encoder.getStructEncoderAtOffset(kVersions.last);
  }

  String toString() {
    return "_UpdateGetIdParams("")";
  }

  Map toJson() {
    Map map = new Map();
    return map;
  }
}


class UpdateGetIdResponseParams extends bindings.Struct {
  static const List<bindings.StructDataHeader> kVersions = const [
    const bindings.StructDataHeader(16, 0)
  ];
  List<int> id = null;

  UpdateGetIdResponseParams() : super(kVersions.last.size);

  static UpdateGetIdResponseParams deserialize(bindings.Message message) {
    var decoder = new bindings.Decoder(message);
    var result = decode(decoder);
    if (decoder.excessHandles != null) {
      decoder.excessHandles.forEach((h) => h.close());
    }
    return result;
  }

  static UpdateGetIdResponseParams decode(bindings.Decoder decoder0) {
    if (decoder0 == null) {
      return null;
    }
    UpdateGetIdResponseParams result = new UpdateGetIdResponseParams();

    var mainDataHeader = decoder0.decodeStructDataHeader();
    if (mainDataHeader.version <= kVersions.last.version) {
      // Scan in reverse order to optimize for more recent versions.
      for (int i = kVersions.length - 1; i >= 0; --i) {
        if (mainDataHeader.version >= kVersions[i].version) {
          if (mainDataHeader.size == kVersions[i].size) {
            // Found a match.
            break;
          }
          throw new bindings.MojoCodecError(
              'Header size doesn\'t correspond to known version size.');
        }
      }
    } else if (mainDataHeader.size < kVersions.last.size) {
      throw new bindings.MojoCodecError(
        'Message newer than the last known version cannot be shorter than '
        'required by the last known version.');
    }
    if (mainDataHeader.version >= 0) {
      
      result.id = decoder0.decodeUint8Array(8, bindings.kNothingNullable, 16);
    }
    return result;
  }

  void encode(bindings.Encoder encoder) {
    var encoder0 = encoder.getStructEncoderAtOffset(kVersions.last);
    try {
      encoder0.encodeUint8Array(id, 8, bindings.kNothingNullable, 16);
    } on bindings.MojoCodecError catch(e) {
      e.message = "Error encountered while encoding field "
          "id of struct UpdateGetIdResponseParams: $e";
      rethrow;
    }
  }

  String toString() {
    return "UpdateGetIdResponseParams("
           "id: $id" ")";
  }

  Map toJson() {
    Map map = new Map();
    map["id"] = id;
    return map;
  }
}


class _UpdateGetInterfaceNameParams extends bindings.Struct {
  static const List<bindings.StructDataHeader> kVersions = const [
    const bindings.StructDataHeader(8, 0)
  ];

  _UpdateGetInterfaceNameParams() : super(kVersions.last.size);

  static _UpdateGetInterfaceNameParams deserialize(bindings.Message message) {
    var decoder = new bindings.Decoder(message);
    var result = decode(decoder);
    if (decoder.excessHandles != null) {
      decoder.excessHandles.forEach((h) => h.close());
    }
    return result;
  }

  static _UpdateGetInterfaceNameParams decode(bindings.Decoder decoder0) {
    if (decoder0 == null) {
      return null;
    }
    _UpdateGetInterfaceNameParams result = new _UpdateGetInterfaceNameParams();

    var mainDataHeader = decoder0.decodeStructDataHeader();
    if (mainDataHeader.version <= kVersions.last.version) {
      // Scan in reverse order to optimize for more recent versions.
      for (int i = kVersions.length - 1; i >= 0; --i) {
        if (mainDataHeader.version >= kVersions[i].version) {
          if (mainDataHeader.size == kVersions[i].size) {
            // Found a match.
            break;
          }
          throw new bindings.MojoCodecError(
              'Header size doesn\'t correspond to known version size.');
        }
      }
    } else if (mainDataHeader.size < kVersions.last.size) {
      throw new bindings.MojoCodecError(
        'Message newer than the last known version cannot be shorter than '
        'required by the last known version.');
    }
    return result;
  }

  void encode(bindings.Encoder encoder) {
    encoder.getStructEncoderAtOffset(kVersions.last);
  }

  String toString() {
    return "_UpdateGetInterfaceNameParams("")";
  }

  Map toJson() {
    Map map = new Map();
    return map;
  }
}


class UpdateGetInterfaceNameResponseParams extends bindings.Struct {
  static const List<bindings.StructDataHeader> kVersions = const [
    const bindings.StructDataHeader(16, 0)
  ];
  String interfaceName = null;

  UpdateGetInterfaceNameResponseParams() : super(kVersions.last.size);

  static UpdateGetInterfaceNameResponseParams deserialize(bindings.Message message) {
    var decoder = new bindings.Decoder(message);
    var result = decode(decoder);
    if (decoder.excessHandles != null) {
      decoder.excessHandles.forEach((h) => h.close());
    }
    return result;
  }

  static UpdateGetInterfaceNameResponseParams decode(bindings.Decoder decoder0) {
    if (decoder0 == null) {
      return null;
    }
    UpdateGetInterfaceNameResponseParams result = new UpdateGetInterfaceNameResponseParams();

    var mainDataHeader = decoder0.decodeStructDataHeader();
    if (mainDataHeader.version <= kVersions.last.version) {
      // Scan in reverse order to optimize for more recent versions.
      for (int i = kVersions.length - 1; i >= 0; --i) {
        if (mainDataHeader.version >= kVersions[i].version) {
          if (mainDataHeader.size == kVersions[i].size) {
            // Found a match.
            break;
          }
          throw new bindings.MojoCodecError(
              'Header size doesn\'t correspond to known version size.');
        }
      }
    } else if (mainDataHeader.size < kVersions.last.size) {
      throw new bindings.MojoCodecError(
        'Message newer than the last known version cannot be shorter than '
        'required by the last known version.');
    }
    if (mainDataHeader.version >= 0) {
      
      result.interfaceName = decoder0.decodeString(8, false);
    }
    return result;
  }

  void encode(bindings.Encoder encoder) {
    var encoder0 = encoder.getStructEncoderAtOffset(kVersions.last);
    try {
      encoder0.encodeString(interfaceName, 8, false);
    } on bindings.MojoCodecError catch(e) {
      e.message = "Error encountered while encoding field "
          "interfaceName of struct UpdateGetInterfaceNameResponseParams: $e";
      rethrow;
    }
  }

  String toString() {
    return "UpdateGetInterfaceNameResponseParams("
           "interfaceName: $interfaceName" ")";
  }

  Map toJson() {
    Map map = new Map();
    map["interfaceName"] = interfaceName;
    return map;
  }
}


class _UpdateGetAddressesParams extends bindings.Struct {
  static const List<bindings.StructDataHeader> kVersions = const [
    const bindings.StructDataHeader(8, 0)
  ];

  _UpdateGetAddressesParams() : super(kVersions.last.size);

  static _UpdateGetAddressesParams deserialize(bindings.Message message) {
    var decoder = new bindings.Decoder(message);
    var result = decode(decoder);
    if (decoder.excessHandles != null) {
      decoder.excessHandles.forEach((h) => h.close());
    }
    return result;
  }

  static _UpdateGetAddressesParams decode(bindings.Decoder decoder0) {
    if (decoder0 == null) {
      return null;
    }
    _UpdateGetAddressesParams result = new _UpdateGetAddressesParams();

    var mainDataHeader = decoder0.decodeStructDataHeader();
    if (mainDataHeader.version <= kVersions.last.version) {
      // Scan in reverse order to optimize for more recent versions.
      for (int i = kVersions.length - 1; i >= 0; --i) {
        if (mainDataHeader.version >= kVersions[i].version) {
          if (mainDataHeader.size == kVersions[i].size) {
            // Found a match.
            break;
          }
          throw new bindings.MojoCodecError(
              'Header size doesn\'t correspond to known version size.');
        }
      }
    } else if (mainDataHeader.size < kVersions.last.size) {
      throw new bindings.MojoCodecError(
        'Message newer than the last known version cannot be shorter than '
        'required by the last known version.');
    }
    return result;
  }

  void encode(bindings.Encoder encoder) {
    encoder.getStructEncoderAtOffset(kVersions.last);
  }

  String toString() {
    return "_UpdateGetAddressesParams("")";
  }

  Map toJson() {
    Map map = new Map();
    return map;
  }
}


class UpdateGetAddressesResponseParams extends bindings.Struct {
  static const List<bindings.StructDataHeader> kVersions = const [
    const bindings.StructDataHeader(16, 0)
  ];
  List<String> addresses = null;

  UpdateGetAddressesResponseParams() : super(kVersions.last.size);

  static UpdateGetAddressesResponseParams deserialize(bindings.Message message) {
    var decoder = new bindings.Decoder(message);
    var result = decode(decoder);
    if (decoder.excessHandles != null) {
      decoder.excessHandles.forEach((h) => h.close());
    }
    return result;
  }

  static UpdateGetAddressesResponseParams decode(bindings.Decoder decoder0) {
    if (decoder0 == null) {
      return null;
    }
    UpdateGetAddressesResponseParams result = new UpdateGetAddressesResponseParams();

    var mainDataHeader = decoder0.decodeStructDataHeader();
    if (mainDataHeader.version <= kVersions.last.version) {
      // Scan in reverse order to optimize for more recent versions.
      for (int i = kVersions.length - 1; i >= 0; --i) {
        if (mainDataHeader.version >= kVersions[i].version) {
          if (mainDataHeader.size == kVersions[i].size) {
            // Found a match.
            break;
          }
          throw new bindings.MojoCodecError(
              'Header size doesn\'t correspond to known version size.');
        }
      }
    } else if (mainDataHeader.size < kVersions.last.size) {
      throw new bindings.MojoCodecError(
        'Message newer than the last known version cannot be shorter than '
        'required by the last known version.');
    }
    if (mainDataHeader.version >= 0) {
      
      var decoder1 = decoder0.decodePointer(8, false);
      {
        var si1 = decoder1.decodeDataHeaderForPointerArray(bindings.kUnspecifiedArrayLength);
        result.addresses = new List<String>(si1.numElements);
        for (int i1 = 0; i1 < si1.numElements; ++i1) {
          
          result.addresses[i1] = decoder1.decodeString(bindings.ArrayDataHeader.kHeaderSize + bindings.kPointerSize * i1, false);
        }
      }
    }
    return result;
  }

  void encode(bindings.Encoder encoder) {
    var encoder0 = encoder.getStructEncoderAtOffset(kVersions.last);
    try {
      if (addresses == null) {
        encoder0.encodeNullPointer(8, false);
      } else {
        var encoder1 = encoder0.encodePointerArray(addresses.length, 8, bindings.kUnspecifiedArrayLength);
        for (int i0 = 0; i0 < addresses.length; ++i0) {
          encoder1.encodeString(addresses[i0], bindings.ArrayDataHeader.kHeaderSize + bindings.kPointerSize * i0, false);
        }
      }
    } on bindings.MojoCodecError catch(e) {
      e.message = "Error encountered while encoding field "
          "addresses of struct UpdateGetAddressesResponseParams: $e";
      rethrow;
    }
  }

  String toString() {
    return "UpdateGetAddressesResponseParams("
           "addresses: $addresses" ")";
  }

  Map toJson() {
    Map map = new Map();
    map["addresses"] = addresses;
    return map;
  }
}


class _UpdateGetAttributeParams extends bindings.Struct {
  static const List<bindings.StructDataHeader> kVersions = const [
    const bindings.StructDataHeader(16, 0)
  ];
  String name = null;

  _UpdateGetAttributeParams() : super(kVersions.last.size);

  static _UpdateGetAttributeParams deserialize(bindings.Message message) {
    var decoder = new bindings.Decoder(message);
    var result = decode(decoder);
    if (decoder.excessHandles != null) {
      decoder.excessHandles.forEach((h) => h.close());
    }
    return result;
  }

  static _UpdateGetAttributeParams decode(bindings.Decoder decoder0) {
    if (decoder0 == null) {
      return null;
    }
    _UpdateGetAttributeParams result = new _UpdateGetAttributeParams();

    var mainDataHeader = decoder0.decodeStructDataHeader();
    if (mainDataHeader.version <= kVersions.last.version) {
      // Scan in reverse order to optimize for more recent versions.
      for (int i = kVersions.length - 1; i >= 0; --i) {
        if (mainDataHeader.version >= kVersions[i].version) {
          if (mainDataHeader.size == kVersions[i].size) {
            // Found a match.
            break;
          }
          throw new bindings.MojoCodecError(
              'Header size doesn\'t correspond to known version size.');
        }
      }
    } else if (mainDataHeader.size < kVersions.last.size) {
      throw new bindings.MojoCodecError(
        'Message newer than the last known version cannot be shorter than '
        'required by the last known version.');
    }
    if (mainDataHeader.version >= 0) {
      
      result.name = decoder0.decodeString(8, false);
    }
    return result;
  }

  void encode(bindings.Encoder encoder) {
    var encoder0 = encoder.getStructEncoderAtOffset(kVersions.last);
    try {
      encoder0.encodeString(name, 8, false);
    } on bindings.MojoCodecError catch(e) {
      e.message = "Error encountered while encoding field "
          "name of struct _UpdateGetAttributeParams: $e";
      rethrow;
    }
  }

  String toString() {
    return "_UpdateGetAttributeParams("
           "name: $name" ")";
  }

  Map toJson() {
    Map map = new Map();
    map["name"] = name;
    return map;
  }
}


class UpdateGetAttributeResponseParams extends bindings.Struct {
  static const List<bindings.StructDataHeader> kVersions = const [
    const bindings.StructDataHeader(16, 0)
  ];
  String attribute = null;

  UpdateGetAttributeResponseParams() : super(kVersions.last.size);

  static UpdateGetAttributeResponseParams deserialize(bindings.Message message) {
    var decoder = new bindings.Decoder(message);
    var result = decode(decoder);
    if (decoder.excessHandles != null) {
      decoder.excessHandles.forEach((h) => h.close());
    }
    return result;
  }

  static UpdateGetAttributeResponseParams decode(bindings.Decoder decoder0) {
    if (decoder0 == null) {
      return null;
    }
    UpdateGetAttributeResponseParams result = new UpdateGetAttributeResponseParams();

    var mainDataHeader = decoder0.decodeStructDataHeader();
    if (mainDataHeader.version <= kVersions.last.version) {
      // Scan in reverse order to optimize for more recent versions.
      for (int i = kVersions.length - 1; i >= 0; --i) {
        if (mainDataHeader.version >= kVersions[i].version) {
          if (mainDataHeader.size == kVersions[i].size) {
            // Found a match.
            break;
          }
          throw new bindings.MojoCodecError(
              'Header size doesn\'t correspond to known version size.');
        }
      }
    } else if (mainDataHeader.size < kVersions.last.size) {
      throw new bindings.MojoCodecError(
        'Message newer than the last known version cannot be shorter than '
        'required by the last known version.');
    }
    if (mainDataHeader.version >= 0) {
      
      result.attribute = decoder0.decodeString(8, false);
    }
    return result;
  }

  void encode(bindings.Encoder encoder) {
    var encoder0 = encoder.getStructEncoderAtOffset(kVersions.last);
    try {
      encoder0.encodeString(attribute, 8, false);
    } on bindings.MojoCodecError catch(e) {
      e.message = "Error encountered while encoding field "
          "attribute of struct UpdateGetAttributeResponseParams: $e";
      rethrow;
    }
  }

  String toString() {
    return "UpdateGetAttributeResponseParams("
           "attribute: $attribute" ")";
  }

  Map toJson() {
    Map map = new Map();
    map["attribute"] = attribute;
    return map;
  }
}


class _UpdateGetAttachmentParams extends bindings.Struct {
  static const List<bindings.StructDataHeader> kVersions = const [
    const bindings.StructDataHeader(16, 0)
  ];
  String name = null;

  _UpdateGetAttachmentParams() : super(kVersions.last.size);

  static _UpdateGetAttachmentParams deserialize(bindings.Message message) {
    var decoder = new bindings.Decoder(message);
    var result = decode(decoder);
    if (decoder.excessHandles != null) {
      decoder.excessHandles.forEach((h) => h.close());
    }
    return result;
  }

  static _UpdateGetAttachmentParams decode(bindings.Decoder decoder0) {
    if (decoder0 == null) {
      return null;
    }
    _UpdateGetAttachmentParams result = new _UpdateGetAttachmentParams();

    var mainDataHeader = decoder0.decodeStructDataHeader();
    if (mainDataHeader.version <= kVersions.last.version) {
      // Scan in reverse order to optimize for more recent versions.
      for (int i = kVersions.length - 1; i >= 0; --i) {
        if (mainDataHeader.version >= kVersions[i].version) {
          if (mainDataHeader.size == kVersions[i].size) {
            // Found a match.
            break;
          }
          throw new bindings.MojoCodecError(
              'Header size doesn\'t correspond to known version size.');
        }
      }
    } else if (mainDataHeader.size < kVersions.last.size) {
      throw new bindings.MojoCodecError(
        'Message newer than the last known version cannot be shorter than '
        'required by the last known version.');
    }
    if (mainDataHeader.version >= 0) {
      
      result.name = decoder0.decodeString(8, false);
    }
    return result;
  }

  void encode(bindings.Encoder encoder) {
    var encoder0 = encoder.getStructEncoderAtOffset(kVersions.last);
    try {
      encoder0.encodeString(name, 8, false);
    } on bindings.MojoCodecError catch(e) {
      e.message = "Error encountered while encoding field "
          "name of struct _UpdateGetAttachmentParams: $e";
      rethrow;
    }
  }

  String toString() {
    return "_UpdateGetAttachmentParams("
           "name: $name" ")";
  }

  Map toJson() {
    Map map = new Map();
    map["name"] = name;
    return map;
  }
}


class UpdateGetAttachmentResponseParams extends bindings.Struct {
  static const List<bindings.StructDataHeader> kVersions = const [
    const bindings.StructDataHeader(16, 0)
  ];
  core.MojoDataPipeConsumer data = null;

  UpdateGetAttachmentResponseParams() : super(kVersions.last.size);

  static UpdateGetAttachmentResponseParams deserialize(bindings.Message message) {
    var decoder = new bindings.Decoder(message);
    var result = decode(decoder);
    if (decoder.excessHandles != null) {
      decoder.excessHandles.forEach((h) => h.close());
    }
    return result;
  }

  static UpdateGetAttachmentResponseParams decode(bindings.Decoder decoder0) {
    if (decoder0 == null) {
      return null;
    }
    UpdateGetAttachmentResponseParams result = new UpdateGetAttachmentResponseParams();

    var mainDataHeader = decoder0.decodeStructDataHeader();
    if (mainDataHeader.version <= kVersions.last.version) {
      // Scan in reverse order to optimize for more recent versions.
      for (int i = kVersions.length - 1; i >= 0; --i) {
        if (mainDataHeader.version >= kVersions[i].version) {
          if (mainDataHeader.size == kVersions[i].size) {
            // Found a match.
            break;
          }
          throw new bindings.MojoCodecError(
              'Header size doesn\'t correspond to known version size.');
        }
      }
    } else if (mainDataHeader.size < kVersions.last.size) {
      throw new bindings.MojoCodecError(
        'Message newer than the last known version cannot be shorter than '
        'required by the last known version.');
    }
    if (mainDataHeader.version >= 0) {
      
      result.data = decoder0.decodeConsumerHandle(8, false);
    }
    return result;
  }

  void encode(bindings.Encoder encoder) {
    var encoder0 = encoder.getStructEncoderAtOffset(kVersions.last);
    try {
      encoder0.encodeConsumerHandle(data, 8, false);
    } on bindings.MojoCodecError catch(e) {
      e.message = "Error encountered while encoding field "
          "data of struct UpdateGetAttachmentResponseParams: $e";
      rethrow;
    }
  }

  String toString() {
    return "UpdateGetAttachmentResponseParams("
           "data: $data" ")";
  }

  Map toJson() {
    throw new bindings.MojoCodecError(
        'Object containing handles cannot be encoded to JSON.');
  }
}


class _UpdateGetAdvertisementParams extends bindings.Struct {
  static const List<bindings.StructDataHeader> kVersions = const [
    const bindings.StructDataHeader(8, 0)
  ];

  _UpdateGetAdvertisementParams() : super(kVersions.last.size);

  static _UpdateGetAdvertisementParams deserialize(bindings.Message message) {
    var decoder = new bindings.Decoder(message);
    var result = decode(decoder);
    if (decoder.excessHandles != null) {
      decoder.excessHandles.forEach((h) => h.close());
    }
    return result;
  }

  static _UpdateGetAdvertisementParams decode(bindings.Decoder decoder0) {
    if (decoder0 == null) {
      return null;
    }
    _UpdateGetAdvertisementParams result = new _UpdateGetAdvertisementParams();

    var mainDataHeader = decoder0.decodeStructDataHeader();
    if (mainDataHeader.version <= kVersions.last.version) {
      // Scan in reverse order to optimize for more recent versions.
      for (int i = kVersions.length - 1; i >= 0; --i) {
        if (mainDataHeader.version >= kVersions[i].version) {
          if (mainDataHeader.size == kVersions[i].size) {
            // Found a match.
            break;
          }
          throw new bindings.MojoCodecError(
              'Header size doesn\'t correspond to known version size.');
        }
      }
    } else if (mainDataHeader.size < kVersions.last.size) {
      throw new bindings.MojoCodecError(
        'Message newer than the last known version cannot be shorter than '
        'required by the last known version.');
    }
    return result;
  }

  void encode(bindings.Encoder encoder) {
    encoder.getStructEncoderAtOffset(kVersions.last);
  }

  String toString() {
    return "_UpdateGetAdvertisementParams("")";
  }

  Map toJson() {
    Map map = new Map();
    return map;
  }
}


class UpdateGetAdvertisementResponseParams extends bindings.Struct {
  static const List<bindings.StructDataHeader> kVersions = const [
    const bindings.StructDataHeader(16, 0)
  ];
  Advertisement ad = null;

  UpdateGetAdvertisementResponseParams() : super(kVersions.last.size);

  static UpdateGetAdvertisementResponseParams deserialize(bindings.Message message) {
    var decoder = new bindings.Decoder(message);
    var result = decode(decoder);
    if (decoder.excessHandles != null) {
      decoder.excessHandles.forEach((h) => h.close());
    }
    return result;
  }

  static UpdateGetAdvertisementResponseParams decode(bindings.Decoder decoder0) {
    if (decoder0 == null) {
      return null;
    }
    UpdateGetAdvertisementResponseParams result = new UpdateGetAdvertisementResponseParams();

    var mainDataHeader = decoder0.decodeStructDataHeader();
    if (mainDataHeader.version <= kVersions.last.version) {
      // Scan in reverse order to optimize for more recent versions.
      for (int i = kVersions.length - 1; i >= 0; --i) {
        if (mainDataHeader.version >= kVersions[i].version) {
          if (mainDataHeader.size == kVersions[i].size) {
            // Found a match.
            break;
          }
          throw new bindings.MojoCodecError(
              'Header size doesn\'t correspond to known version size.');
        }
      }
    } else if (mainDataHeader.size < kVersions.last.size) {
      throw new bindings.MojoCodecError(
        'Message newer than the last known version cannot be shorter than '
        'required by the last known version.');
    }
    if (mainDataHeader.version >= 0) {
      
      var decoder1 = decoder0.decodePointer(8, false);
      result.ad = Advertisement.decode(decoder1);
    }
    return result;
  }

  void encode(bindings.Encoder encoder) {
    var encoder0 = encoder.getStructEncoderAtOffset(kVersions.last);
    try {
      encoder0.encodeStruct(ad, 8, false);
    } on bindings.MojoCodecError catch(e) {
      e.message = "Error encountered while encoding field "
          "ad of struct UpdateGetAdvertisementResponseParams: $e";
      rethrow;
    }
  }

  String toString() {
    return "UpdateGetAdvertisementResponseParams("
           "ad: $ad" ")";
  }

  Map toJson() {
    Map map = new Map();
    map["ad"] = ad;
    return map;
  }
}

const int _discoveryMethodAdvertiseName = 0;
const int _discoveryMethodScanName = 1;

class _DiscoveryServiceDescription implements service_describer.ServiceDescription {
  dynamic getTopLevelInterface([Function responseFactory]) =>
      responseFactory(null);

  dynamic getTypeDefinition(String typeKey, [Function responseFactory]) =>
      responseFactory(null);

  dynamic getAllTypeDefinitions([Function responseFactory]) =>
      responseFactory(null);
}

abstract class Discovery {
  static const String serviceName = "v23::discovery::Discovery";
  dynamic advertise(Advertisement ad,List<String> visibility,[Function responseFactory = null]);
  dynamic scan(String query,Object handler,[Function responseFactory = null]);
}


class _DiscoveryProxyImpl extends bindings.Proxy {
  _DiscoveryProxyImpl.fromEndpoint(
      core.MojoMessagePipeEndpoint endpoint) : super.fromEndpoint(endpoint);

  _DiscoveryProxyImpl.fromHandle(core.MojoHandle handle) :
      super.fromHandle(handle);

  _DiscoveryProxyImpl.unbound() : super.unbound();

  static _DiscoveryProxyImpl newFromEndpoint(
      core.MojoMessagePipeEndpoint endpoint) {
    assert(endpoint.setDescription("For _DiscoveryProxyImpl"));
    return new _DiscoveryProxyImpl.fromEndpoint(endpoint);
  }

  service_describer.ServiceDescription get serviceDescription =>
    new _DiscoveryServiceDescription();

  void handleResponse(bindings.ServiceMessage message) {
    switch (message.header.type) {
      case _discoveryMethodAdvertiseName:
        var r = DiscoveryAdvertiseResponseParams.deserialize(
            message.payload);
        if (!message.header.hasRequestId) {
          proxyError("Expected a message with a valid request Id.");
          return;
        }
        Completer c = completerMap[message.header.requestId];
        if (c == null) {
          proxyError(
              "Message had unknown request Id: ${message.header.requestId}");
          return;
        }
        completerMap.remove(message.header.requestId);
        if (c.isCompleted) {
          proxyError("Response completer already completed");
          return;
        }
        c.complete(r);
        break;
      case _discoveryMethodScanName:
        var r = DiscoveryScanResponseParams.deserialize(
            message.payload);
        if (!message.header.hasRequestId) {
          proxyError("Expected a message with a valid request Id.");
          return;
        }
        Completer c = completerMap[message.header.requestId];
        if (c == null) {
          proxyError(
              "Message had unknown request Id: ${message.header.requestId}");
          return;
        }
        completerMap.remove(message.header.requestId);
        if (c.isCompleted) {
          proxyError("Response completer already completed");
          return;
        }
        c.complete(r);
        break;
      default:
        proxyError("Unexpected message type: ${message.header.type}");
        close(immediate: true);
        break;
    }
  }

  String toString() {
    var superString = super.toString();
    return "_DiscoveryProxyImpl($superString)";
  }
}


class _DiscoveryProxyCalls implements Discovery {
  _DiscoveryProxyImpl _proxyImpl;

  _DiscoveryProxyCalls(this._proxyImpl);
    dynamic advertise(Advertisement ad,List<String> visibility,[Function responseFactory = null]) {
      var params = new _DiscoveryAdvertiseParams();
      params.ad = ad;
      params.visibility = visibility;
      return _proxyImpl.sendMessageWithRequestId(
          params,
          _discoveryMethodAdvertiseName,
          -1,
          bindings.MessageHeader.kMessageExpectsResponse);
    }
    dynamic scan(String query,Object handler,[Function responseFactory = null]) {
      var params = new _DiscoveryScanParams();
      params.query = query;
      params.handler = handler;
      return _proxyImpl.sendMessageWithRequestId(
          params,
          _discoveryMethodScanName,
          -1,
          bindings.MessageHeader.kMessageExpectsResponse);
    }
}


class DiscoveryProxy implements bindings.ProxyBase {
  final bindings.Proxy impl;
  Discovery ptr;

  DiscoveryProxy(_DiscoveryProxyImpl proxyImpl) :
      impl = proxyImpl,
      ptr = new _DiscoveryProxyCalls(proxyImpl);

  DiscoveryProxy.fromEndpoint(
      core.MojoMessagePipeEndpoint endpoint) :
      impl = new _DiscoveryProxyImpl.fromEndpoint(endpoint) {
    ptr = new _DiscoveryProxyCalls(impl);
  }

  DiscoveryProxy.fromHandle(core.MojoHandle handle) :
      impl = new _DiscoveryProxyImpl.fromHandle(handle) {
    ptr = new _DiscoveryProxyCalls(impl);
  }

  DiscoveryProxy.unbound() :
      impl = new _DiscoveryProxyImpl.unbound() {
    ptr = new _DiscoveryProxyCalls(impl);
  }

  factory DiscoveryProxy.connectToService(
      bindings.ServiceConnector s, String url, [String serviceName]) {
    DiscoveryProxy p = new DiscoveryProxy.unbound();
    s.connectToService(url, p, serviceName);
    return p;
  }

  static DiscoveryProxy newFromEndpoint(
      core.MojoMessagePipeEndpoint endpoint) {
    assert(endpoint.setDescription("For DiscoveryProxy"));
    return new DiscoveryProxy.fromEndpoint(endpoint);
  }

  String get serviceName => Discovery.serviceName;

  Future close({bool immediate: false}) => impl.close(immediate: immediate);

  Future responseOrError(Future f) => impl.responseOrError(f);

  Future get errorFuture => impl.errorFuture;

  int get version => impl.version;

  Future<int> queryVersion() => impl.queryVersion();

  void requireVersion(int requiredVersion) {
    impl.requireVersion(requiredVersion);
  }

  String toString() {
    return "DiscoveryProxy($impl)";
  }
}


class DiscoveryStub extends bindings.Stub {
  Discovery _impl;

  DiscoveryStub.fromEndpoint(
      core.MojoMessagePipeEndpoint endpoint, [Discovery impl])
      : super.fromEndpoint(endpoint, autoBegin: impl != null) {
    _impl = impl;
  }

  DiscoveryStub.fromHandle(
      core.MojoHandle handle, [Discovery impl])
      : super.fromHandle(handle, autoBegin: impl != null) {
    _impl = impl;
  }

  DiscoveryStub.unbound([this._impl]) : super.unbound();

  static DiscoveryStub newFromEndpoint(
      core.MojoMessagePipeEndpoint endpoint) {
    assert(endpoint.setDescription("For DiscoveryStub"));
    return new DiscoveryStub.fromEndpoint(endpoint);
  }


  DiscoveryAdvertiseResponseParams _discoveryAdvertiseResponseParamsFactory(List<int> instanceId, Object closer, Error err) {
    var result = new DiscoveryAdvertiseResponseParams();
    result.instanceId = instanceId;
    result.closer = closer;
    result.err = err;
    return result;
  }
  DiscoveryScanResponseParams _discoveryScanResponseParamsFactory(Object closer, Error err) {
    var result = new DiscoveryScanResponseParams();
    result.closer = closer;
    result.err = err;
    return result;
  }

  dynamic handleMessage(bindings.ServiceMessage message) {
    if (bindings.ControlMessageHandler.isControlMessage(message)) {
      return bindings.ControlMessageHandler.handleMessage(this,
                                                          0,
                                                          message);
    }
    if (_impl == null) {
      throw new core.MojoApiError("$this has no implementation set");
    }
    switch (message.header.type) {
      case _discoveryMethodAdvertiseName:
        var params = _DiscoveryAdvertiseParams.deserialize(
            message.payload);
        var response = _impl.advertise(params.ad,params.visibility,_discoveryAdvertiseResponseParamsFactory);
        if (response is Future) {
          return response.then((response) {
            if (response != null) {
              return buildResponseWithId(
                  response,
                  _discoveryMethodAdvertiseName,
                  message.header.requestId,
                  bindings.MessageHeader.kMessageIsResponse);
            }
          });
        } else if (response != null) {
          return buildResponseWithId(
              response,
              _discoveryMethodAdvertiseName,
              message.header.requestId,
              bindings.MessageHeader.kMessageIsResponse);
        }
        break;
      case _discoveryMethodScanName:
        var params = _DiscoveryScanParams.deserialize(
            message.payload);
        var response = _impl.scan(params.query,params.handler,_discoveryScanResponseParamsFactory);
        if (response is Future) {
          return response.then((response) {
            if (response != null) {
              return buildResponseWithId(
                  response,
                  _discoveryMethodScanName,
                  message.header.requestId,
                  bindings.MessageHeader.kMessageIsResponse);
            }
          });
        } else if (response != null) {
          return buildResponseWithId(
              response,
              _discoveryMethodScanName,
              message.header.requestId,
              bindings.MessageHeader.kMessageIsResponse);
        }
        break;
      default:
        throw new bindings.MojoCodecError("Unexpected message name");
        break;
    }
    return null;
  }

  Discovery get impl => _impl;
  set impl(Discovery d) {
    if (d == null) {
      throw new core.MojoApiError("$this: Cannot set a null implementation");
    }
    if (isBound && (_impl == null)) {
      beginHandlingEvents();
    }
    _impl = d;
  }

  @override
  void bind(core.MojoMessagePipeEndpoint endpoint) {
    super.bind(endpoint);
    if (!isOpen && (_impl != null)) {
      beginHandlingEvents();
    }
  }

  String toString() {
    var superString = super.toString();
    return "DiscoveryStub($superString)";
  }

  int get version => 0;

  static service_describer.ServiceDescription _cachedServiceDescription;
  static service_describer.ServiceDescription get serviceDescription {
    if (_cachedServiceDescription == null) {
      _cachedServiceDescription = new _DiscoveryServiceDescription();
    }
    return _cachedServiceDescription;
  }
}

const int _closerMethodCloseName = 0;

class _CloserServiceDescription implements service_describer.ServiceDescription {
  dynamic getTopLevelInterface([Function responseFactory]) =>
      responseFactory(null);

  dynamic getTypeDefinition(String typeKey, [Function responseFactory]) =>
      responseFactory(null);

  dynamic getAllTypeDefinitions([Function responseFactory]) =>
      responseFactory(null);
}

abstract class Closer {
  static const String serviceName = null;
  dynamic close([Function responseFactory = null]);
}


class _CloserProxyImpl extends bindings.Proxy {
  _CloserProxyImpl.fromEndpoint(
      core.MojoMessagePipeEndpoint endpoint) : super.fromEndpoint(endpoint);

  _CloserProxyImpl.fromHandle(core.MojoHandle handle) :
      super.fromHandle(handle);

  _CloserProxyImpl.unbound() : super.unbound();

  static _CloserProxyImpl newFromEndpoint(
      core.MojoMessagePipeEndpoint endpoint) {
    assert(endpoint.setDescription("For _CloserProxyImpl"));
    return new _CloserProxyImpl.fromEndpoint(endpoint);
  }

  service_describer.ServiceDescription get serviceDescription =>
    new _CloserServiceDescription();

  void handleResponse(bindings.ServiceMessage message) {
    switch (message.header.type) {
      case _closerMethodCloseName:
        var r = CloserCloseResponseParams.deserialize(
            message.payload);
        if (!message.header.hasRequestId) {
          proxyError("Expected a message with a valid request Id.");
          return;
        }
        Completer c = completerMap[message.header.requestId];
        if (c == null) {
          proxyError(
              "Message had unknown request Id: ${message.header.requestId}");
          return;
        }
        completerMap.remove(message.header.requestId);
        if (c.isCompleted) {
          proxyError("Response completer already completed");
          return;
        }
        c.complete(r);
        break;
      default:
        proxyError("Unexpected message type: ${message.header.type}");
        close(immediate: true);
        break;
    }
  }

  String toString() {
    var superString = super.toString();
    return "_CloserProxyImpl($superString)";
  }
}


class _CloserProxyCalls implements Closer {
  _CloserProxyImpl _proxyImpl;

  _CloserProxyCalls(this._proxyImpl);
    dynamic close([Function responseFactory = null]) {
      var params = new _CloserCloseParams();
      return _proxyImpl.sendMessageWithRequestId(
          params,
          _closerMethodCloseName,
          -1,
          bindings.MessageHeader.kMessageExpectsResponse);
    }
}


class CloserProxy implements bindings.ProxyBase {
  final bindings.Proxy impl;
  Closer ptr;

  CloserProxy(_CloserProxyImpl proxyImpl) :
      impl = proxyImpl,
      ptr = new _CloserProxyCalls(proxyImpl);

  CloserProxy.fromEndpoint(
      core.MojoMessagePipeEndpoint endpoint) :
      impl = new _CloserProxyImpl.fromEndpoint(endpoint) {
    ptr = new _CloserProxyCalls(impl);
  }

  CloserProxy.fromHandle(core.MojoHandle handle) :
      impl = new _CloserProxyImpl.fromHandle(handle) {
    ptr = new _CloserProxyCalls(impl);
  }

  CloserProxy.unbound() :
      impl = new _CloserProxyImpl.unbound() {
    ptr = new _CloserProxyCalls(impl);
  }

  factory CloserProxy.connectToService(
      bindings.ServiceConnector s, String url, [String serviceName]) {
    CloserProxy p = new CloserProxy.unbound();
    s.connectToService(url, p, serviceName);
    return p;
  }

  static CloserProxy newFromEndpoint(
      core.MojoMessagePipeEndpoint endpoint) {
    assert(endpoint.setDescription("For CloserProxy"));
    return new CloserProxy.fromEndpoint(endpoint);
  }

  String get serviceName => Closer.serviceName;

  Future close({bool immediate: false}) => impl.close(immediate: immediate);

  Future responseOrError(Future f) => impl.responseOrError(f);

  Future get errorFuture => impl.errorFuture;

  int get version => impl.version;

  Future<int> queryVersion() => impl.queryVersion();

  void requireVersion(int requiredVersion) {
    impl.requireVersion(requiredVersion);
  }

  String toString() {
    return "CloserProxy($impl)";
  }
}


class CloserStub extends bindings.Stub {
  Closer _impl;

  CloserStub.fromEndpoint(
      core.MojoMessagePipeEndpoint endpoint, [Closer impl])
      : super.fromEndpoint(endpoint, autoBegin: impl != null) {
    _impl = impl;
  }

  CloserStub.fromHandle(
      core.MojoHandle handle, [Closer impl])
      : super.fromHandle(handle, autoBegin: impl != null) {
    _impl = impl;
  }

  CloserStub.unbound([this._impl]) : super.unbound();

  static CloserStub newFromEndpoint(
      core.MojoMessagePipeEndpoint endpoint) {
    assert(endpoint.setDescription("For CloserStub"));
    return new CloserStub.fromEndpoint(endpoint);
  }


  CloserCloseResponseParams _closerCloseResponseParamsFactory() {
    var result = new CloserCloseResponseParams();
    return result;
  }

  dynamic handleMessage(bindings.ServiceMessage message) {
    if (bindings.ControlMessageHandler.isControlMessage(message)) {
      return bindings.ControlMessageHandler.handleMessage(this,
                                                          0,
                                                          message);
    }
    if (_impl == null) {
      throw new core.MojoApiError("$this has no implementation set");
    }
    switch (message.header.type) {
      case _closerMethodCloseName:
        var response = _impl.close(_closerCloseResponseParamsFactory);
        if (response is Future) {
          return response.then((response) {
            if (response != null) {
              return buildResponseWithId(
                  response,
                  _closerMethodCloseName,
                  message.header.requestId,
                  bindings.MessageHeader.kMessageIsResponse);
            }
          });
        } else if (response != null) {
          return buildResponseWithId(
              response,
              _closerMethodCloseName,
              message.header.requestId,
              bindings.MessageHeader.kMessageIsResponse);
        }
        break;
      default:
        throw new bindings.MojoCodecError("Unexpected message name");
        break;
    }
    return null;
  }

  Closer get impl => _impl;
  set impl(Closer d) {
    if (d == null) {
      throw new core.MojoApiError("$this: Cannot set a null implementation");
    }
    if (isBound && (_impl == null)) {
      beginHandlingEvents();
    }
    _impl = d;
  }

  @override
  void bind(core.MojoMessagePipeEndpoint endpoint) {
    super.bind(endpoint);
    if (!isOpen && (_impl != null)) {
      beginHandlingEvents();
    }
  }

  String toString() {
    var superString = super.toString();
    return "CloserStub($superString)";
  }

  int get version => 0;

  static service_describer.ServiceDescription _cachedServiceDescription;
  static service_describer.ServiceDescription get serviceDescription {
    if (_cachedServiceDescription == null) {
      _cachedServiceDescription = new _CloserServiceDescription();
    }
    return _cachedServiceDescription;
  }
}

const int _scanHandlerMethodOnUpdateName = 0;

class _ScanHandlerServiceDescription implements service_describer.ServiceDescription {
  dynamic getTopLevelInterface([Function responseFactory]) =>
      responseFactory(null);

  dynamic getTypeDefinition(String typeKey, [Function responseFactory]) =>
      responseFactory(null);

  dynamic getAllTypeDefinitions([Function responseFactory]) =>
      responseFactory(null);
}

abstract class ScanHandler {
  static const String serviceName = null;
  void onUpdate(Object update);
}


class _ScanHandlerProxyImpl extends bindings.Proxy {
  _ScanHandlerProxyImpl.fromEndpoint(
      core.MojoMessagePipeEndpoint endpoint) : super.fromEndpoint(endpoint);

  _ScanHandlerProxyImpl.fromHandle(core.MojoHandle handle) :
      super.fromHandle(handle);

  _ScanHandlerProxyImpl.unbound() : super.unbound();

  static _ScanHandlerProxyImpl newFromEndpoint(
      core.MojoMessagePipeEndpoint endpoint) {
    assert(endpoint.setDescription("For _ScanHandlerProxyImpl"));
    return new _ScanHandlerProxyImpl.fromEndpoint(endpoint);
  }

  service_describer.ServiceDescription get serviceDescription =>
    new _ScanHandlerServiceDescription();

  void handleResponse(bindings.ServiceMessage message) {
    switch (message.header.type) {
      default:
        proxyError("Unexpected message type: ${message.header.type}");
        close(immediate: true);
        break;
    }
  }

  String toString() {
    var superString = super.toString();
    return "_ScanHandlerProxyImpl($superString)";
  }
}


class _ScanHandlerProxyCalls implements ScanHandler {
  _ScanHandlerProxyImpl _proxyImpl;

  _ScanHandlerProxyCalls(this._proxyImpl);
    void onUpdate(Object update) {
      if (!_proxyImpl.isBound) {
        _proxyImpl.proxyError("The Proxy is closed.");
        return;
      }
      var params = new _ScanHandlerOnUpdateParams();
      params.update = update;
      _proxyImpl.sendMessage(params, _scanHandlerMethodOnUpdateName);
    }
}


class ScanHandlerProxy implements bindings.ProxyBase {
  final bindings.Proxy impl;
  ScanHandler ptr;

  ScanHandlerProxy(_ScanHandlerProxyImpl proxyImpl) :
      impl = proxyImpl,
      ptr = new _ScanHandlerProxyCalls(proxyImpl);

  ScanHandlerProxy.fromEndpoint(
      core.MojoMessagePipeEndpoint endpoint) :
      impl = new _ScanHandlerProxyImpl.fromEndpoint(endpoint) {
    ptr = new _ScanHandlerProxyCalls(impl);
  }

  ScanHandlerProxy.fromHandle(core.MojoHandle handle) :
      impl = new _ScanHandlerProxyImpl.fromHandle(handle) {
    ptr = new _ScanHandlerProxyCalls(impl);
  }

  ScanHandlerProxy.unbound() :
      impl = new _ScanHandlerProxyImpl.unbound() {
    ptr = new _ScanHandlerProxyCalls(impl);
  }

  factory ScanHandlerProxy.connectToService(
      bindings.ServiceConnector s, String url, [String serviceName]) {
    ScanHandlerProxy p = new ScanHandlerProxy.unbound();
    s.connectToService(url, p, serviceName);
    return p;
  }

  static ScanHandlerProxy newFromEndpoint(
      core.MojoMessagePipeEndpoint endpoint) {
    assert(endpoint.setDescription("For ScanHandlerProxy"));
    return new ScanHandlerProxy.fromEndpoint(endpoint);
  }

  String get serviceName => ScanHandler.serviceName;

  Future close({bool immediate: false}) => impl.close(immediate: immediate);

  Future responseOrError(Future f) => impl.responseOrError(f);

  Future get errorFuture => impl.errorFuture;

  int get version => impl.version;

  Future<int> queryVersion() => impl.queryVersion();

  void requireVersion(int requiredVersion) {
    impl.requireVersion(requiredVersion);
  }

  String toString() {
    return "ScanHandlerProxy($impl)";
  }
}


class ScanHandlerStub extends bindings.Stub {
  ScanHandler _impl;

  ScanHandlerStub.fromEndpoint(
      core.MojoMessagePipeEndpoint endpoint, [ScanHandler impl])
      : super.fromEndpoint(endpoint, autoBegin: impl != null) {
    _impl = impl;
  }

  ScanHandlerStub.fromHandle(
      core.MojoHandle handle, [ScanHandler impl])
      : super.fromHandle(handle, autoBegin: impl != null) {
    _impl = impl;
  }

  ScanHandlerStub.unbound([this._impl]) : super.unbound();

  static ScanHandlerStub newFromEndpoint(
      core.MojoMessagePipeEndpoint endpoint) {
    assert(endpoint.setDescription("For ScanHandlerStub"));
    return new ScanHandlerStub.fromEndpoint(endpoint);
  }



  dynamic handleMessage(bindings.ServiceMessage message) {
    if (bindings.ControlMessageHandler.isControlMessage(message)) {
      return bindings.ControlMessageHandler.handleMessage(this,
                                                          0,
                                                          message);
    }
    if (_impl == null) {
      throw new core.MojoApiError("$this has no implementation set");
    }
    switch (message.header.type) {
      case _scanHandlerMethodOnUpdateName:
        var params = _ScanHandlerOnUpdateParams.deserialize(
            message.payload);
        _impl.onUpdate(params.update);
        break;
      default:
        throw new bindings.MojoCodecError("Unexpected message name");
        break;
    }
    return null;
  }

  ScanHandler get impl => _impl;
  set impl(ScanHandler d) {
    if (d == null) {
      throw new core.MojoApiError("$this: Cannot set a null implementation");
    }
    if (isBound && (_impl == null)) {
      beginHandlingEvents();
    }
    _impl = d;
  }

  @override
  void bind(core.MojoMessagePipeEndpoint endpoint) {
    super.bind(endpoint);
    if (!isOpen && (_impl != null)) {
      beginHandlingEvents();
    }
  }

  String toString() {
    var superString = super.toString();
    return "ScanHandlerStub($superString)";
  }

  int get version => 0;

  static service_describer.ServiceDescription _cachedServiceDescription;
  static service_describer.ServiceDescription get serviceDescription {
    if (_cachedServiceDescription == null) {
      _cachedServiceDescription = new _ScanHandlerServiceDescription();
    }
    return _cachedServiceDescription;
  }
}

const int _updateMethodIsLostName = 0;
const int _updateMethodGetIdName = 1;
const int _updateMethodGetInterfaceNameName = 2;
const int _updateMethodGetAddressesName = 3;
const int _updateMethodGetAttributeName = 4;
const int _updateMethodGetAttachmentName = 5;
const int _updateMethodGetAdvertisementName = 6;

class _UpdateServiceDescription implements service_describer.ServiceDescription {
  dynamic getTopLevelInterface([Function responseFactory]) =>
      responseFactory(null);

  dynamic getTypeDefinition(String typeKey, [Function responseFactory]) =>
      responseFactory(null);

  dynamic getAllTypeDefinitions([Function responseFactory]) =>
      responseFactory(null);
}

abstract class Update {
  static const String serviceName = null;
  dynamic isLost([Function responseFactory = null]);
  dynamic getId([Function responseFactory = null]);
  dynamic getInterfaceName([Function responseFactory = null]);
  dynamic getAddresses([Function responseFactory = null]);
  dynamic getAttribute(String name,[Function responseFactory = null]);
  dynamic getAttachment(String name,[Function responseFactory = null]);
  dynamic getAdvertisement([Function responseFactory = null]);
}


class _UpdateProxyImpl extends bindings.Proxy {
  _UpdateProxyImpl.fromEndpoint(
      core.MojoMessagePipeEndpoint endpoint) : super.fromEndpoint(endpoint);

  _UpdateProxyImpl.fromHandle(core.MojoHandle handle) :
      super.fromHandle(handle);

  _UpdateProxyImpl.unbound() : super.unbound();

  static _UpdateProxyImpl newFromEndpoint(
      core.MojoMessagePipeEndpoint endpoint) {
    assert(endpoint.setDescription("For _UpdateProxyImpl"));
    return new _UpdateProxyImpl.fromEndpoint(endpoint);
  }

  service_describer.ServiceDescription get serviceDescription =>
    new _UpdateServiceDescription();

  void handleResponse(bindings.ServiceMessage message) {
    switch (message.header.type) {
      case _updateMethodIsLostName:
        var r = UpdateIsLostResponseParams.deserialize(
            message.payload);
        if (!message.header.hasRequestId) {
          proxyError("Expected a message with a valid request Id.");
          return;
        }
        Completer c = completerMap[message.header.requestId];
        if (c == null) {
          proxyError(
              "Message had unknown request Id: ${message.header.requestId}");
          return;
        }
        completerMap.remove(message.header.requestId);
        if (c.isCompleted) {
          proxyError("Response completer already completed");
          return;
        }
        c.complete(r);
        break;
      case _updateMethodGetIdName:
        var r = UpdateGetIdResponseParams.deserialize(
            message.payload);
        if (!message.header.hasRequestId) {
          proxyError("Expected a message with a valid request Id.");
          return;
        }
        Completer c = completerMap[message.header.requestId];
        if (c == null) {
          proxyError(
              "Message had unknown request Id: ${message.header.requestId}");
          return;
        }
        completerMap.remove(message.header.requestId);
        if (c.isCompleted) {
          proxyError("Response completer already completed");
          return;
        }
        c.complete(r);
        break;
      case _updateMethodGetInterfaceNameName:
        var r = UpdateGetInterfaceNameResponseParams.deserialize(
            message.payload);
        if (!message.header.hasRequestId) {
          proxyError("Expected a message with a valid request Id.");
          return;
        }
        Completer c = completerMap[message.header.requestId];
        if (c == null) {
          proxyError(
              "Message had unknown request Id: ${message.header.requestId}");
          return;
        }
        completerMap.remove(message.header.requestId);
        if (c.isCompleted) {
          proxyError("Response completer already completed");
          return;
        }
        c.complete(r);
        break;
      case _updateMethodGetAddressesName:
        var r = UpdateGetAddressesResponseParams.deserialize(
            message.payload);
        if (!message.header.hasRequestId) {
          proxyError("Expected a message with a valid request Id.");
          return;
        }
        Completer c = completerMap[message.header.requestId];
        if (c == null) {
          proxyError(
              "Message had unknown request Id: ${message.header.requestId}");
          return;
        }
        completerMap.remove(message.header.requestId);
        if (c.isCompleted) {
          proxyError("Response completer already completed");
          return;
        }
        c.complete(r);
        break;
      case _updateMethodGetAttributeName:
        var r = UpdateGetAttributeResponseParams.deserialize(
            message.payload);
        if (!message.header.hasRequestId) {
          proxyError("Expected a message with a valid request Id.");
          return;
        }
        Completer c = completerMap[message.header.requestId];
        if (c == null) {
          proxyError(
              "Message had unknown request Id: ${message.header.requestId}");
          return;
        }
        completerMap.remove(message.header.requestId);
        if (c.isCompleted) {
          proxyError("Response completer already completed");
          return;
        }
        c.complete(r);
        break;
      case _updateMethodGetAttachmentName:
        var r = UpdateGetAttachmentResponseParams.deserialize(
            message.payload);
        if (!message.header.hasRequestId) {
          proxyError("Expected a message with a valid request Id.");
          return;
        }
        Completer c = completerMap[message.header.requestId];
        if (c == null) {
          proxyError(
              "Message had unknown request Id: ${message.header.requestId}");
          return;
        }
        completerMap.remove(message.header.requestId);
        if (c.isCompleted) {
          proxyError("Response completer already completed");
          return;
        }
        c.complete(r);
        break;
      case _updateMethodGetAdvertisementName:
        var r = UpdateGetAdvertisementResponseParams.deserialize(
            message.payload);
        if (!message.header.hasRequestId) {
          proxyError("Expected a message with a valid request Id.");
          return;
        }
        Completer c = completerMap[message.header.requestId];
        if (c == null) {
          proxyError(
              "Message had unknown request Id: ${message.header.requestId}");
          return;
        }
        completerMap.remove(message.header.requestId);
        if (c.isCompleted) {
          proxyError("Response completer already completed");
          return;
        }
        c.complete(r);
        break;
      default:
        proxyError("Unexpected message type: ${message.header.type}");
        close(immediate: true);
        break;
    }
  }

  String toString() {
    var superString = super.toString();
    return "_UpdateProxyImpl($superString)";
  }
}


class _UpdateProxyCalls implements Update {
  _UpdateProxyImpl _proxyImpl;

  _UpdateProxyCalls(this._proxyImpl);
    dynamic isLost([Function responseFactory = null]) {
      var params = new _UpdateIsLostParams();
      return _proxyImpl.sendMessageWithRequestId(
          params,
          _updateMethodIsLostName,
          -1,
          bindings.MessageHeader.kMessageExpectsResponse);
    }
    dynamic getId([Function responseFactory = null]) {
      var params = new _UpdateGetIdParams();
      return _proxyImpl.sendMessageWithRequestId(
          params,
          _updateMethodGetIdName,
          -1,
          bindings.MessageHeader.kMessageExpectsResponse);
    }
    dynamic getInterfaceName([Function responseFactory = null]) {
      var params = new _UpdateGetInterfaceNameParams();
      return _proxyImpl.sendMessageWithRequestId(
          params,
          _updateMethodGetInterfaceNameName,
          -1,
          bindings.MessageHeader.kMessageExpectsResponse);
    }
    dynamic getAddresses([Function responseFactory = null]) {
      var params = new _UpdateGetAddressesParams();
      return _proxyImpl.sendMessageWithRequestId(
          params,
          _updateMethodGetAddressesName,
          -1,
          bindings.MessageHeader.kMessageExpectsResponse);
    }
    dynamic getAttribute(String name,[Function responseFactory = null]) {
      var params = new _UpdateGetAttributeParams();
      params.name = name;
      return _proxyImpl.sendMessageWithRequestId(
          params,
          _updateMethodGetAttributeName,
          -1,
          bindings.MessageHeader.kMessageExpectsResponse);
    }
    dynamic getAttachment(String name,[Function responseFactory = null]) {
      var params = new _UpdateGetAttachmentParams();
      params.name = name;
      return _proxyImpl.sendMessageWithRequestId(
          params,
          _updateMethodGetAttachmentName,
          -1,
          bindings.MessageHeader.kMessageExpectsResponse);
    }
    dynamic getAdvertisement([Function responseFactory = null]) {
      var params = new _UpdateGetAdvertisementParams();
      return _proxyImpl.sendMessageWithRequestId(
          params,
          _updateMethodGetAdvertisementName,
          -1,
          bindings.MessageHeader.kMessageExpectsResponse);
    }
}


class UpdateProxy implements bindings.ProxyBase {
  final bindings.Proxy impl;
  Update ptr;

  UpdateProxy(_UpdateProxyImpl proxyImpl) :
      impl = proxyImpl,
      ptr = new _UpdateProxyCalls(proxyImpl);

  UpdateProxy.fromEndpoint(
      core.MojoMessagePipeEndpoint endpoint) :
      impl = new _UpdateProxyImpl.fromEndpoint(endpoint) {
    ptr = new _UpdateProxyCalls(impl);
  }

  UpdateProxy.fromHandle(core.MojoHandle handle) :
      impl = new _UpdateProxyImpl.fromHandle(handle) {
    ptr = new _UpdateProxyCalls(impl);
  }

  UpdateProxy.unbound() :
      impl = new _UpdateProxyImpl.unbound() {
    ptr = new _UpdateProxyCalls(impl);
  }

  factory UpdateProxy.connectToService(
      bindings.ServiceConnector s, String url, [String serviceName]) {
    UpdateProxy p = new UpdateProxy.unbound();
    s.connectToService(url, p, serviceName);
    return p;
  }

  static UpdateProxy newFromEndpoint(
      core.MojoMessagePipeEndpoint endpoint) {
    assert(endpoint.setDescription("For UpdateProxy"));
    return new UpdateProxy.fromEndpoint(endpoint);
  }

  String get serviceName => Update.serviceName;

  Future close({bool immediate: false}) => impl.close(immediate: immediate);

  Future responseOrError(Future f) => impl.responseOrError(f);

  Future get errorFuture => impl.errorFuture;

  int get version => impl.version;

  Future<int> queryVersion() => impl.queryVersion();

  void requireVersion(int requiredVersion) {
    impl.requireVersion(requiredVersion);
  }

  String toString() {
    return "UpdateProxy($impl)";
  }
}


class UpdateStub extends bindings.Stub {
  Update _impl;

  UpdateStub.fromEndpoint(
      core.MojoMessagePipeEndpoint endpoint, [Update impl])
      : super.fromEndpoint(endpoint, autoBegin: impl != null) {
    _impl = impl;
  }

  UpdateStub.fromHandle(
      core.MojoHandle handle, [Update impl])
      : super.fromHandle(handle, autoBegin: impl != null) {
    _impl = impl;
  }

  UpdateStub.unbound([this._impl]) : super.unbound();

  static UpdateStub newFromEndpoint(
      core.MojoMessagePipeEndpoint endpoint) {
    assert(endpoint.setDescription("For UpdateStub"));
    return new UpdateStub.fromEndpoint(endpoint);
  }


  UpdateIsLostResponseParams _updateIsLostResponseParamsFactory(bool lost) {
    var result = new UpdateIsLostResponseParams();
    result.lost = lost;
    return result;
  }
  UpdateGetIdResponseParams _updateGetIdResponseParamsFactory(List<int> id) {
    var result = new UpdateGetIdResponseParams();
    result.id = id;
    return result;
  }
  UpdateGetInterfaceNameResponseParams _updateGetInterfaceNameResponseParamsFactory(String interfaceName) {
    var result = new UpdateGetInterfaceNameResponseParams();
    result.interfaceName = interfaceName;
    return result;
  }
  UpdateGetAddressesResponseParams _updateGetAddressesResponseParamsFactory(List<String> addresses) {
    var result = new UpdateGetAddressesResponseParams();
    result.addresses = addresses;
    return result;
  }
  UpdateGetAttributeResponseParams _updateGetAttributeResponseParamsFactory(String attribute) {
    var result = new UpdateGetAttributeResponseParams();
    result.attribute = attribute;
    return result;
  }
  UpdateGetAttachmentResponseParams _updateGetAttachmentResponseParamsFactory(core.MojoDataPipeConsumer data) {
    var result = new UpdateGetAttachmentResponseParams();
    result.data = data;
    return result;
  }
  UpdateGetAdvertisementResponseParams _updateGetAdvertisementResponseParamsFactory(Advertisement ad) {
    var result = new UpdateGetAdvertisementResponseParams();
    result.ad = ad;
    return result;
  }

  dynamic handleMessage(bindings.ServiceMessage message) {
    if (bindings.ControlMessageHandler.isControlMessage(message)) {
      return bindings.ControlMessageHandler.handleMessage(this,
                                                          0,
                                                          message);
    }
    if (_impl == null) {
      throw new core.MojoApiError("$this has no implementation set");
    }
    switch (message.header.type) {
      case _updateMethodIsLostName:
        var response = _impl.isLost(_updateIsLostResponseParamsFactory);
        if (response is Future) {
          return response.then((response) {
            if (response != null) {
              return buildResponseWithId(
                  response,
                  _updateMethodIsLostName,
                  message.header.requestId,
                  bindings.MessageHeader.kMessageIsResponse);
            }
          });
        } else if (response != null) {
          return buildResponseWithId(
              response,
              _updateMethodIsLostName,
              message.header.requestId,
              bindings.MessageHeader.kMessageIsResponse);
        }
        break;
      case _updateMethodGetIdName:
        var response = _impl.getId(_updateGetIdResponseParamsFactory);
        if (response is Future) {
          return response.then((response) {
            if (response != null) {
              return buildResponseWithId(
                  response,
                  _updateMethodGetIdName,
                  message.header.requestId,
                  bindings.MessageHeader.kMessageIsResponse);
            }
          });
        } else if (response != null) {
          return buildResponseWithId(
              response,
              _updateMethodGetIdName,
              message.header.requestId,
              bindings.MessageHeader.kMessageIsResponse);
        }
        break;
      case _updateMethodGetInterfaceNameName:
        var response = _impl.getInterfaceName(_updateGetInterfaceNameResponseParamsFactory);
        if (response is Future) {
          return response.then((response) {
            if (response != null) {
              return buildResponseWithId(
                  response,
                  _updateMethodGetInterfaceNameName,
                  message.header.requestId,
                  bindings.MessageHeader.kMessageIsResponse);
            }
          });
        } else if (response != null) {
          return buildResponseWithId(
              response,
              _updateMethodGetInterfaceNameName,
              message.header.requestId,
              bindings.MessageHeader.kMessageIsResponse);
        }
        break;
      case _updateMethodGetAddressesName:
        var response = _impl.getAddresses(_updateGetAddressesResponseParamsFactory);
        if (response is Future) {
          return response.then((response) {
            if (response != null) {
              return buildResponseWithId(
                  response,
                  _updateMethodGetAddressesName,
                  message.header.requestId,
                  bindings.MessageHeader.kMessageIsResponse);
            }
          });
        } else if (response != null) {
          return buildResponseWithId(
              response,
              _updateMethodGetAddressesName,
              message.header.requestId,
              bindings.MessageHeader.kMessageIsResponse);
        }
        break;
      case _updateMethodGetAttributeName:
        var params = _UpdateGetAttributeParams.deserialize(
            message.payload);
        var response = _impl.getAttribute(params.name,_updateGetAttributeResponseParamsFactory);
        if (response is Future) {
          return response.then((response) {
            if (response != null) {
              return buildResponseWithId(
                  response,
                  _updateMethodGetAttributeName,
                  message.header.requestId,
                  bindings.MessageHeader.kMessageIsResponse);
            }
          });
        } else if (response != null) {
          return buildResponseWithId(
              response,
              _updateMethodGetAttributeName,
              message.header.requestId,
              bindings.MessageHeader.kMessageIsResponse);
        }
        break;
      case _updateMethodGetAttachmentName:
        var params = _UpdateGetAttachmentParams.deserialize(
            message.payload);
        var response = _impl.getAttachment(params.name,_updateGetAttachmentResponseParamsFactory);
        if (response is Future) {
          return response.then((response) {
            if (response != null) {
              return buildResponseWithId(
                  response,
                  _updateMethodGetAttachmentName,
                  message.header.requestId,
                  bindings.MessageHeader.kMessageIsResponse);
            }
          });
        } else if (response != null) {
          return buildResponseWithId(
              response,
              _updateMethodGetAttachmentName,
              message.header.requestId,
              bindings.MessageHeader.kMessageIsResponse);
        }
        break;
      case _updateMethodGetAdvertisementName:
        var response = _impl.getAdvertisement(_updateGetAdvertisementResponseParamsFactory);
        if (response is Future) {
          return response.then((response) {
            if (response != null) {
              return buildResponseWithId(
                  response,
                  _updateMethodGetAdvertisementName,
                  message.header.requestId,
                  bindings.MessageHeader.kMessageIsResponse);
            }
          });
        } else if (response != null) {
          return buildResponseWithId(
              response,
              _updateMethodGetAdvertisementName,
              message.header.requestId,
              bindings.MessageHeader.kMessageIsResponse);
        }
        break;
      default:
        throw new bindings.MojoCodecError("Unexpected message name");
        break;
    }
    return null;
  }

  Update get impl => _impl;
  set impl(Update d) {
    if (d == null) {
      throw new core.MojoApiError("$this: Cannot set a null implementation");
    }
    if (isBound && (_impl == null)) {
      beginHandlingEvents();
    }
    _impl = d;
  }

  @override
  void bind(core.MojoMessagePipeEndpoint endpoint) {
    super.bind(endpoint);
    if (!isOpen && (_impl != null)) {
      beginHandlingEvents();
    }
  }

  String toString() {
    var superString = super.toString();
    return "UpdateStub($superString)";
  }

  int get version => 0;

  static service_describer.ServiceDescription _cachedServiceDescription;
  static service_describer.ServiceDescription get serviceDescription {
    if (_cachedServiceDescription == null) {
      _cachedServiceDescription = new _UpdateServiceDescription();
    }
    return _cachedServiceDescription;
  }
}



