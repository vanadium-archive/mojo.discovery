// Copyright 2014 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

library discovery_mojom;

import 'dart:async';

import 'package:mojo/bindings.dart' as bindings;
import 'package:mojo/core.dart' as core;



class Service extends bindings.Struct {
  static const List<bindings.StructDataHeader> kVersions = const [
    const bindings.StructDataHeader(48, 0)
  ];
  List<int> instanceUuid = null;
  String instanceName = null;
  String interfaceName = null;
  Map<String, String> attrs = null;
  List<String> addrs = null;

  Service() : super(kVersions.last.size);

  static Service deserialize(bindings.Message message) {
    var decoder = new bindings.Decoder(message);
    var result = decode(decoder);
    decoder.excessHandles.forEach((h) => h.close());
    return result;
  }

  static Service decode(bindings.Decoder decoder0) {
    if (decoder0 == null) {
      return null;
    }
    Service result = new Service();

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
      
      result.instanceUuid = decoder0.decodeUint8Array(8, bindings.kNothingNullable, bindings.kUnspecifiedArrayLength);
    }
    if (mainDataHeader.version >= 0) {
      
      result.instanceName = decoder0.decodeString(16, false);
    }
    if (mainDataHeader.version >= 0) {
      
      result.interfaceName = decoder0.decodeString(24, false);
    }
    if (mainDataHeader.version >= 0) {
      
      var decoder1 = decoder0.decodePointer(32, false);
      {
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
        result.attrs = new Map<String, String>.fromIterables(
            keys0, values0);
      }
    }
    if (mainDataHeader.version >= 0) {
      
      var decoder1 = decoder0.decodePointer(40, false);
      {
        var si1 = decoder1.decodeDataHeaderForPointerArray(bindings.kUnspecifiedArrayLength);
        result.addrs = new List<String>(si1.numElements);
        for (int i1 = 0; i1 < si1.numElements; ++i1) {
          
          result.addrs[i1] = decoder1.decodeString(bindings.ArrayDataHeader.kHeaderSize + bindings.kPointerSize * i1, false);
        }
      }
    }
    return result;
  }

  void encode(bindings.Encoder encoder) {
    var encoder0 = encoder.getStructEncoderAtOffset(kVersions.last);
    
    encoder0.encodeUint8Array(instanceUuid, 8, bindings.kNothingNullable, bindings.kUnspecifiedArrayLength);
    
    encoder0.encodeString(instanceName, 16, false);
    
    encoder0.encodeString(interfaceName, 24, false);
    
    if (attrs == null) {
      encoder0.encodeNullPointer(32, false);
    } else {
      var encoder1 = encoder0.encoderForMap(32);
      int size0 = attrs.length;
      var keys0 = attrs.keys.toList();
      var values0 = attrs.values.toList();
      
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
    
    if (addrs == null) {
      encoder0.encodeNullPointer(40, false);
    } else {
      var encoder1 = encoder0.encodePointerArray(addrs.length, 40, bindings.kUnspecifiedArrayLength);
      for (int i0 = 0; i0 < addrs.length; ++i0) {
        
        encoder1.encodeString(addrs[i0], bindings.ArrayDataHeader.kHeaderSize + bindings.kPointerSize * i0, false);
      }
    }
  }

  String toString() {
    return "Service("
           "instanceUuid: $instanceUuid" ", "
           "instanceName: $instanceName" ", "
           "interfaceName: $interfaceName" ", "
           "attrs: $attrs" ", "
           "addrs: $addrs" ")";
  }

  Map toJson() {
    Map map = new Map();
    map["instanceUuid"] = instanceUuid;
    map["instanceName"] = instanceName;
    map["interfaceName"] = interfaceName;
    map["attrs"] = attrs;
    map["addrs"] = addrs;
    return map;
  }
}


class Error extends bindings.Struct {
  static const List<bindings.StructDataHeader> kVersions = const [
    const bindings.StructDataHeader(32, 0)
  ];
  String id = null;
  int action = 0;
  String msg = null;

  Error() : super(kVersions.last.size);

  static Error deserialize(bindings.Message message) {
    var decoder = new bindings.Decoder(message);
    var result = decode(decoder);
    decoder.excessHandles.forEach((h) => h.close());
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
      
      result.action = decoder0.decodeInt32(16);
    }
    if (mainDataHeader.version >= 0) {
      
      result.msg = decoder0.decodeString(24, false);
    }
    return result;
  }

  void encode(bindings.Encoder encoder) {
    var encoder0 = encoder.getStructEncoderAtOffset(kVersions.last);
    
    encoder0.encodeString(id, 8, false);
    
    encoder0.encodeInt32(action, 16);
    
    encoder0.encodeString(msg, 24, false);
  }

  String toString() {
    return "Error("
           "id: $id" ", "
           "action: $action" ", "
           "msg: $msg" ")";
  }

  Map toJson() {
    Map map = new Map();
    map["id"] = id;
    map["action"] = action;
    map["msg"] = msg;
    return map;
  }
}


class AdvertiserAdvertiseParams extends bindings.Struct {
  static const List<bindings.StructDataHeader> kVersions = const [
    const bindings.StructDataHeader(24, 0)
  ];
  Service s = null;
  List<String> visibility = null;

  AdvertiserAdvertiseParams() : super(kVersions.last.size);

  static AdvertiserAdvertiseParams deserialize(bindings.Message message) {
    var decoder = new bindings.Decoder(message);
    var result = decode(decoder);
    decoder.excessHandles.forEach((h) => h.close());
    return result;
  }

  static AdvertiserAdvertiseParams decode(bindings.Decoder decoder0) {
    if (decoder0 == null) {
      return null;
    }
    AdvertiserAdvertiseParams result = new AdvertiserAdvertiseParams();

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
      result.s = Service.decode(decoder1);
    }
    if (mainDataHeader.version >= 0) {
      
      var decoder1 = decoder0.decodePointer(16, false);
      {
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
    
    encoder0.encodeStruct(s, 8, false);
    
    if (visibility == null) {
      encoder0.encodeNullPointer(16, false);
    } else {
      var encoder1 = encoder0.encodePointerArray(visibility.length, 16, bindings.kUnspecifiedArrayLength);
      for (int i0 = 0; i0 < visibility.length; ++i0) {
        
        encoder1.encodeString(visibility[i0], bindings.ArrayDataHeader.kHeaderSize + bindings.kPointerSize * i0, false);
      }
    }
  }

  String toString() {
    return "AdvertiserAdvertiseParams("
           "s: $s" ", "
           "visibility: $visibility" ")";
  }

  Map toJson() {
    Map map = new Map();
    map["s"] = s;
    map["visibility"] = visibility;
    return map;
  }
}


class AdvertiserAdvertiseResponseParams extends bindings.Struct {
  static const List<bindings.StructDataHeader> kVersions = const [
    const bindings.StructDataHeader(24, 0)
  ];
  int handle = 0;
  Error err = null;

  AdvertiserAdvertiseResponseParams() : super(kVersions.last.size);

  static AdvertiserAdvertiseResponseParams deserialize(bindings.Message message) {
    var decoder = new bindings.Decoder(message);
    var result = decode(decoder);
    decoder.excessHandles.forEach((h) => h.close());
    return result;
  }

  static AdvertiserAdvertiseResponseParams decode(bindings.Decoder decoder0) {
    if (decoder0 == null) {
      return null;
    }
    AdvertiserAdvertiseResponseParams result = new AdvertiserAdvertiseResponseParams();

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
      
      result.handle = decoder0.decodeUint32(8);
    }
    if (mainDataHeader.version >= 0) {
      
      var decoder1 = decoder0.decodePointer(16, true);
      result.err = Error.decode(decoder1);
    }
    return result;
  }

  void encode(bindings.Encoder encoder) {
    var encoder0 = encoder.getStructEncoderAtOffset(kVersions.last);
    
    encoder0.encodeUint32(handle, 8);
    
    encoder0.encodeStruct(err, 16, true);
  }

  String toString() {
    return "AdvertiserAdvertiseResponseParams("
           "handle: $handle" ", "
           "err: $err" ")";
  }

  Map toJson() {
    Map map = new Map();
    map["handle"] = handle;
    map["err"] = err;
    return map;
  }
}


class AdvertiserStopParams extends bindings.Struct {
  static const List<bindings.StructDataHeader> kVersions = const [
    const bindings.StructDataHeader(16, 0)
  ];
  int h = 0;

  AdvertiserStopParams() : super(kVersions.last.size);

  static AdvertiserStopParams deserialize(bindings.Message message) {
    var decoder = new bindings.Decoder(message);
    var result = decode(decoder);
    decoder.excessHandles.forEach((h) => h.close());
    return result;
  }

  static AdvertiserStopParams decode(bindings.Decoder decoder0) {
    if (decoder0 == null) {
      return null;
    }
    AdvertiserStopParams result = new AdvertiserStopParams();

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
      
      result.h = decoder0.decodeUint32(8);
    }
    return result;
  }

  void encode(bindings.Encoder encoder) {
    var encoder0 = encoder.getStructEncoderAtOffset(kVersions.last);
    
    encoder0.encodeUint32(h, 8);
  }

  String toString() {
    return "AdvertiserStopParams("
           "h: $h" ")";
  }

  Map toJson() {
    Map map = new Map();
    map["h"] = h;
    return map;
  }
}


class ScannerScanParams extends bindings.Struct {
  static const List<bindings.StructDataHeader> kVersions = const [
    const bindings.StructDataHeader(24, 0)
  ];
  String query = null;
  Object scanHandler = null;

  ScannerScanParams() : super(kVersions.last.size);

  static ScannerScanParams deserialize(bindings.Message message) {
    var decoder = new bindings.Decoder(message);
    var result = decode(decoder);
    decoder.excessHandles.forEach((h) => h.close());
    return result;
  }

  static ScannerScanParams decode(bindings.Decoder decoder0) {
    if (decoder0 == null) {
      return null;
    }
    ScannerScanParams result = new ScannerScanParams();

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
      
      result.scanHandler = decoder0.decodeServiceInterface(16, false, ScanHandlerProxy.newFromEndpoint);
    }
    return result;
  }

  void encode(bindings.Encoder encoder) {
    var encoder0 = encoder.getStructEncoderAtOffset(kVersions.last);
    
    encoder0.encodeString(query, 8, false);
    
    encoder0.encodeInterface(scanHandler, 16, false);
  }

  String toString() {
    return "ScannerScanParams("
           "query: $query" ", "
           "scanHandler: $scanHandler" ")";
  }

  Map toJson() {
    throw new bindings.MojoCodecError(
        'Object containing handles cannot be encoded to JSON.');
  }
}


class ScannerScanResponseParams extends bindings.Struct {
  static const List<bindings.StructDataHeader> kVersions = const [
    const bindings.StructDataHeader(24, 0)
  ];
  int handle = 0;
  Error err = null;

  ScannerScanResponseParams() : super(kVersions.last.size);

  static ScannerScanResponseParams deserialize(bindings.Message message) {
    var decoder = new bindings.Decoder(message);
    var result = decode(decoder);
    decoder.excessHandles.forEach((h) => h.close());
    return result;
  }

  static ScannerScanResponseParams decode(bindings.Decoder decoder0) {
    if (decoder0 == null) {
      return null;
    }
    ScannerScanResponseParams result = new ScannerScanResponseParams();

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
      
      result.handle = decoder0.decodeUint32(8);
    }
    if (mainDataHeader.version >= 0) {
      
      var decoder1 = decoder0.decodePointer(16, true);
      result.err = Error.decode(decoder1);
    }
    return result;
  }

  void encode(bindings.Encoder encoder) {
    var encoder0 = encoder.getStructEncoderAtOffset(kVersions.last);
    
    encoder0.encodeUint32(handle, 8);
    
    encoder0.encodeStruct(err, 16, true);
  }

  String toString() {
    return "ScannerScanResponseParams("
           "handle: $handle" ", "
           "err: $err" ")";
  }

  Map toJson() {
    Map map = new Map();
    map["handle"] = handle;
    map["err"] = err;
    return map;
  }
}


class ScannerStopParams extends bindings.Struct {
  static const List<bindings.StructDataHeader> kVersions = const [
    const bindings.StructDataHeader(16, 0)
  ];
  int h = 0;

  ScannerStopParams() : super(kVersions.last.size);

  static ScannerStopParams deserialize(bindings.Message message) {
    var decoder = new bindings.Decoder(message);
    var result = decode(decoder);
    decoder.excessHandles.forEach((h) => h.close());
    return result;
  }

  static ScannerStopParams decode(bindings.Decoder decoder0) {
    if (decoder0 == null) {
      return null;
    }
    ScannerStopParams result = new ScannerStopParams();

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
      
      result.h = decoder0.decodeUint32(8);
    }
    return result;
  }

  void encode(bindings.Encoder encoder) {
    var encoder0 = encoder.getStructEncoderAtOffset(kVersions.last);
    
    encoder0.encodeUint32(h, 8);
  }

  String toString() {
    return "ScannerStopParams("
           "h: $h" ")";
  }

  Map toJson() {
    Map map = new Map();
    map["h"] = h;
    return map;
  }
}


class ScanHandlerFoundParams extends bindings.Struct {
  static const List<bindings.StructDataHeader> kVersions = const [
    const bindings.StructDataHeader(16, 0)
  ];
  Service s = null;

  ScanHandlerFoundParams() : super(kVersions.last.size);

  static ScanHandlerFoundParams deserialize(bindings.Message message) {
    var decoder = new bindings.Decoder(message);
    var result = decode(decoder);
    decoder.excessHandles.forEach((h) => h.close());
    return result;
  }

  static ScanHandlerFoundParams decode(bindings.Decoder decoder0) {
    if (decoder0 == null) {
      return null;
    }
    ScanHandlerFoundParams result = new ScanHandlerFoundParams();

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
      result.s = Service.decode(decoder1);
    }
    return result;
  }

  void encode(bindings.Encoder encoder) {
    var encoder0 = encoder.getStructEncoderAtOffset(kVersions.last);
    
    encoder0.encodeStruct(s, 8, false);
  }

  String toString() {
    return "ScanHandlerFoundParams("
           "s: $s" ")";
  }

  Map toJson() {
    Map map = new Map();
    map["s"] = s;
    return map;
  }
}


class ScanHandlerLostParams extends bindings.Struct {
  static const List<bindings.StructDataHeader> kVersions = const [
    const bindings.StructDataHeader(16, 0)
  ];
  List<int> instanceId = null;

  ScanHandlerLostParams() : super(kVersions.last.size);

  static ScanHandlerLostParams deserialize(bindings.Message message) {
    var decoder = new bindings.Decoder(message);
    var result = decode(decoder);
    decoder.excessHandles.forEach((h) => h.close());
    return result;
  }

  static ScanHandlerLostParams decode(bindings.Decoder decoder0) {
    if (decoder0 == null) {
      return null;
    }
    ScanHandlerLostParams result = new ScanHandlerLostParams();

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
      
      result.instanceId = decoder0.decodeUint8Array(8, bindings.kNothingNullable, bindings.kUnspecifiedArrayLength);
    }
    return result;
  }

  void encode(bindings.Encoder encoder) {
    var encoder0 = encoder.getStructEncoderAtOffset(kVersions.last);
    
    encoder0.encodeUint8Array(instanceId, 8, bindings.kNothingNullable, bindings.kUnspecifiedArrayLength);
  }

  String toString() {
    return "ScanHandlerLostParams("
           "instanceId: $instanceId" ")";
  }

  Map toJson() {
    Map map = new Map();
    map["instanceId"] = instanceId;
    return map;
  }
}

const int kAdvertiser_advertise_name = 0;
const int kAdvertiser_stop_name = 1;

const String AdvertiserName =
      'discovery::Advertiser';

abstract class Advertiser {
  dynamic advertise(Service s,List<String> visibility,[Function responseFactory = null]);
  void stop(int h);

}


class AdvertiserProxyImpl extends bindings.Proxy {
  AdvertiserProxyImpl.fromEndpoint(
      core.MojoMessagePipeEndpoint endpoint) : super.fromEndpoint(endpoint);

  AdvertiserProxyImpl.fromHandle(core.MojoHandle handle) :
      super.fromHandle(handle);

  AdvertiserProxyImpl.unbound() : super.unbound();

  static AdvertiserProxyImpl newFromEndpoint(
      core.MojoMessagePipeEndpoint endpoint) {
    assert(endpoint.setDescription("For AdvertiserProxyImpl"));
    return new AdvertiserProxyImpl.fromEndpoint(endpoint);
  }

  String get name => AdvertiserName;

  void handleResponse(bindings.ServiceMessage message) {
    switch (message.header.type) {
      case kAdvertiser_advertise_name:
        var r = AdvertiserAdvertiseResponseParams.deserialize(
            message.payload);
        if (!message.header.hasRequestId) {
          throw 'Expected a message with a valid request Id.';
        }
        Completer c = completerMap[message.header.requestId];
        if (c == null) {
          throw 'Message had unknown request Id: ${message.header.requestId}';
        }
        completerMap.remove(message.header.requestId);
        assert(!c.isCompleted);
        c.complete(r);
        break;
      default:
        throw new bindings.MojoCodecError("Unexpected message name");
        break;
    }
  }

  String toString() {
    var superString = super.toString();
    return "AdvertiserProxyImpl($superString)";
  }
}


class _AdvertiserProxyCalls implements Advertiser {
  AdvertiserProxyImpl _proxyImpl;

  _AdvertiserProxyCalls(this._proxyImpl);
    dynamic advertise(Service s,List<String> visibility,[Function responseFactory = null]) {
      assert(_proxyImpl.isBound);
      var params = new AdvertiserAdvertiseParams();
      params.s = s;
      params.visibility = visibility;
      return _proxyImpl.sendMessageWithRequestId(
          params,
          kAdvertiser_advertise_name,
          -1,
          bindings.MessageHeader.kMessageExpectsResponse);
    }
    void stop(int h) {
      assert(_proxyImpl.isBound);
      var params = new AdvertiserStopParams();
      params.h = h;
      _proxyImpl.sendMessage(params, kAdvertiser_stop_name);
    }
  
}


class AdvertiserProxy implements bindings.ProxyBase {
  final bindings.Proxy impl;
  Advertiser ptr;
  final String name = AdvertiserName;

  AdvertiserProxy(AdvertiserProxyImpl proxyImpl) :
      impl = proxyImpl,
      ptr = new _AdvertiserProxyCalls(proxyImpl);

  AdvertiserProxy.fromEndpoint(
      core.MojoMessagePipeEndpoint endpoint) :
      impl = new AdvertiserProxyImpl.fromEndpoint(endpoint) {
    ptr = new _AdvertiserProxyCalls(impl);
  }

  AdvertiserProxy.fromHandle(core.MojoHandle handle) :
      impl = new AdvertiserProxyImpl.fromHandle(handle) {
    ptr = new _AdvertiserProxyCalls(impl);
  }

  AdvertiserProxy.unbound() :
      impl = new AdvertiserProxyImpl.unbound() {
    ptr = new _AdvertiserProxyCalls(impl);
  }

  factory AdvertiserProxy.connectToService(
      bindings.ServiceConnector s, String url) {
    AdvertiserProxy p = new AdvertiserProxy.unbound();
    s.connectToService(url, p);
    return p;
  }

  static AdvertiserProxy newFromEndpoint(
      core.MojoMessagePipeEndpoint endpoint) {
    assert(endpoint.setDescription("For AdvertiserProxy"));
    return new AdvertiserProxy.fromEndpoint(endpoint);
  }

  Future close({bool immediate: false}) => impl.close(immediate: immediate);

  int get version => impl.version;

  Future<int> queryVersion() => impl.queryVersion();

  void requireVersion(int requiredVersion) {
    impl.requireVersion(requiredVersion);
  }

  String toString() {
    return "AdvertiserProxy($impl)";
  }
}


class AdvertiserStub extends bindings.Stub {
  Advertiser _impl = null;

  AdvertiserStub.fromEndpoint(
      core.MojoMessagePipeEndpoint endpoint, [this._impl])
      : super.fromEndpoint(endpoint);

  AdvertiserStub.fromHandle(core.MojoHandle handle, [this._impl])
      : super.fromHandle(handle);

  AdvertiserStub.unbound() : super.unbound();

  static AdvertiserStub newFromEndpoint(
      core.MojoMessagePipeEndpoint endpoint) {
    assert(endpoint.setDescription("For AdvertiserStub"));
    return new AdvertiserStub.fromEndpoint(endpoint);
  }

  static const String name = AdvertiserName;


  AdvertiserAdvertiseResponseParams _AdvertiserAdvertiseResponseParamsFactory(int handle, Error err) {
    var result = new AdvertiserAdvertiseResponseParams();
    result.handle = handle;
    result.err = err;
    return result;
  }

  dynamic handleMessage(bindings.ServiceMessage message) {
    if (bindings.ControlMessageHandler.isControlMessage(message)) {
      return bindings.ControlMessageHandler.handleMessage(this,
                                                          0,
                                                          message);
    }
    assert(_impl != null);
    switch (message.header.type) {
      case kAdvertiser_advertise_name:
        var params = AdvertiserAdvertiseParams.deserialize(
            message.payload);
        var response = _impl.advertise(params.s,params.visibility,_AdvertiserAdvertiseResponseParamsFactory);
        if (response is Future) {
          return response.then((response) {
            if (response != null) {
              return buildResponseWithId(
                  response,
                  kAdvertiser_advertise_name,
                  message.header.requestId,
                  bindings.MessageHeader.kMessageIsResponse);
            }
          });
        } else if (response != null) {
          return buildResponseWithId(
              response,
              kAdvertiser_advertise_name,
              message.header.requestId,
              bindings.MessageHeader.kMessageIsResponse);
        }
        break;
      case kAdvertiser_stop_name:
        var params = AdvertiserStopParams.deserialize(
            message.payload);
        _impl.stop(params.h);
        break;
      default:
        throw new bindings.MojoCodecError("Unexpected message name");
        break;
    }
    return null;
  }

  Advertiser get impl => _impl;
  set impl(Advertiser d) {
    assert(_impl == null);
    _impl = d;
  }

  String toString() {
    var superString = super.toString();
    return "AdvertiserStub($superString)";
  }

  int get version => 0;
}

const int kScanner_scan_name = 0;
const int kScanner_stop_name = 1;

const String ScannerName =
      'discovery::Scanner';

abstract class Scanner {
  dynamic scan(String query,Object scanHandler,[Function responseFactory = null]);
  void stop(int h);

}


class ScannerProxyImpl extends bindings.Proxy {
  ScannerProxyImpl.fromEndpoint(
      core.MojoMessagePipeEndpoint endpoint) : super.fromEndpoint(endpoint);

  ScannerProxyImpl.fromHandle(core.MojoHandle handle) :
      super.fromHandle(handle);

  ScannerProxyImpl.unbound() : super.unbound();

  static ScannerProxyImpl newFromEndpoint(
      core.MojoMessagePipeEndpoint endpoint) {
    assert(endpoint.setDescription("For ScannerProxyImpl"));
    return new ScannerProxyImpl.fromEndpoint(endpoint);
  }

  String get name => ScannerName;

  void handleResponse(bindings.ServiceMessage message) {
    switch (message.header.type) {
      case kScanner_scan_name:
        var r = ScannerScanResponseParams.deserialize(
            message.payload);
        if (!message.header.hasRequestId) {
          throw 'Expected a message with a valid request Id.';
        }
        Completer c = completerMap[message.header.requestId];
        if (c == null) {
          throw 'Message had unknown request Id: ${message.header.requestId}';
        }
        completerMap.remove(message.header.requestId);
        assert(!c.isCompleted);
        c.complete(r);
        break;
      default:
        throw new bindings.MojoCodecError("Unexpected message name");
        break;
    }
  }

  String toString() {
    var superString = super.toString();
    return "ScannerProxyImpl($superString)";
  }
}


class _ScannerProxyCalls implements Scanner {
  ScannerProxyImpl _proxyImpl;

  _ScannerProxyCalls(this._proxyImpl);
    dynamic scan(String query,Object scanHandler,[Function responseFactory = null]) {
      assert(_proxyImpl.isBound);
      var params = new ScannerScanParams();
      params.query = query;
      params.scanHandler = scanHandler;
      return _proxyImpl.sendMessageWithRequestId(
          params,
          kScanner_scan_name,
          -1,
          bindings.MessageHeader.kMessageExpectsResponse);
    }
    void stop(int h) {
      assert(_proxyImpl.isBound);
      var params = new ScannerStopParams();
      params.h = h;
      _proxyImpl.sendMessage(params, kScanner_stop_name);
    }
  
}


class ScannerProxy implements bindings.ProxyBase {
  final bindings.Proxy impl;
  Scanner ptr;
  final String name = ScannerName;

  ScannerProxy(ScannerProxyImpl proxyImpl) :
      impl = proxyImpl,
      ptr = new _ScannerProxyCalls(proxyImpl);

  ScannerProxy.fromEndpoint(
      core.MojoMessagePipeEndpoint endpoint) :
      impl = new ScannerProxyImpl.fromEndpoint(endpoint) {
    ptr = new _ScannerProxyCalls(impl);
  }

  ScannerProxy.fromHandle(core.MojoHandle handle) :
      impl = new ScannerProxyImpl.fromHandle(handle) {
    ptr = new _ScannerProxyCalls(impl);
  }

  ScannerProxy.unbound() :
      impl = new ScannerProxyImpl.unbound() {
    ptr = new _ScannerProxyCalls(impl);
  }

  factory ScannerProxy.connectToService(
      bindings.ServiceConnector s, String url) {
    ScannerProxy p = new ScannerProxy.unbound();
    s.connectToService(url, p);
    return p;
  }

  static ScannerProxy newFromEndpoint(
      core.MojoMessagePipeEndpoint endpoint) {
    assert(endpoint.setDescription("For ScannerProxy"));
    return new ScannerProxy.fromEndpoint(endpoint);
  }

  Future close({bool immediate: false}) => impl.close(immediate: immediate);

  int get version => impl.version;

  Future<int> queryVersion() => impl.queryVersion();

  void requireVersion(int requiredVersion) {
    impl.requireVersion(requiredVersion);
  }

  String toString() {
    return "ScannerProxy($impl)";
  }
}


class ScannerStub extends bindings.Stub {
  Scanner _impl = null;

  ScannerStub.fromEndpoint(
      core.MojoMessagePipeEndpoint endpoint, [this._impl])
      : super.fromEndpoint(endpoint);

  ScannerStub.fromHandle(core.MojoHandle handle, [this._impl])
      : super.fromHandle(handle);

  ScannerStub.unbound() : super.unbound();

  static ScannerStub newFromEndpoint(
      core.MojoMessagePipeEndpoint endpoint) {
    assert(endpoint.setDescription("For ScannerStub"));
    return new ScannerStub.fromEndpoint(endpoint);
  }

  static const String name = ScannerName;


  ScannerScanResponseParams _ScannerScanResponseParamsFactory(int handle, Error err) {
    var result = new ScannerScanResponseParams();
    result.handle = handle;
    result.err = err;
    return result;
  }

  dynamic handleMessage(bindings.ServiceMessage message) {
    if (bindings.ControlMessageHandler.isControlMessage(message)) {
      return bindings.ControlMessageHandler.handleMessage(this,
                                                          0,
                                                          message);
    }
    assert(_impl != null);
    switch (message.header.type) {
      case kScanner_scan_name:
        var params = ScannerScanParams.deserialize(
            message.payload);
        var response = _impl.scan(params.query,params.scanHandler,_ScannerScanResponseParamsFactory);
        if (response is Future) {
          return response.then((response) {
            if (response != null) {
              return buildResponseWithId(
                  response,
                  kScanner_scan_name,
                  message.header.requestId,
                  bindings.MessageHeader.kMessageIsResponse);
            }
          });
        } else if (response != null) {
          return buildResponseWithId(
              response,
              kScanner_scan_name,
              message.header.requestId,
              bindings.MessageHeader.kMessageIsResponse);
        }
        break;
      case kScanner_stop_name:
        var params = ScannerStopParams.deserialize(
            message.payload);
        _impl.stop(params.h);
        break;
      default:
        throw new bindings.MojoCodecError("Unexpected message name");
        break;
    }
    return null;
  }

  Scanner get impl => _impl;
  set impl(Scanner d) {
    assert(_impl == null);
    _impl = d;
  }

  String toString() {
    var superString = super.toString();
    return "ScannerStub($superString)";
  }

  int get version => 0;
}

const int kScanHandler_found_name = 0;
const int kScanHandler_lost_name = 1;

const String ScanHandlerName =
      'discovery::ScanHandler';

abstract class ScanHandler {
  void found(Service s);
  void lost(List<int> instanceId);

}


class ScanHandlerProxyImpl extends bindings.Proxy {
  ScanHandlerProxyImpl.fromEndpoint(
      core.MojoMessagePipeEndpoint endpoint) : super.fromEndpoint(endpoint);

  ScanHandlerProxyImpl.fromHandle(core.MojoHandle handle) :
      super.fromHandle(handle);

  ScanHandlerProxyImpl.unbound() : super.unbound();

  static ScanHandlerProxyImpl newFromEndpoint(
      core.MojoMessagePipeEndpoint endpoint) {
    assert(endpoint.setDescription("For ScanHandlerProxyImpl"));
    return new ScanHandlerProxyImpl.fromEndpoint(endpoint);
  }

  String get name => ScanHandlerName;

  void handleResponse(bindings.ServiceMessage message) {
    switch (message.header.type) {
      default:
        throw new bindings.MojoCodecError("Unexpected message name");
        break;
    }
  }

  String toString() {
    var superString = super.toString();
    return "ScanHandlerProxyImpl($superString)";
  }
}


class _ScanHandlerProxyCalls implements ScanHandler {
  ScanHandlerProxyImpl _proxyImpl;

  _ScanHandlerProxyCalls(this._proxyImpl);
    void found(Service s) {
      assert(_proxyImpl.isBound);
      var params = new ScanHandlerFoundParams();
      params.s = s;
      _proxyImpl.sendMessage(params, kScanHandler_found_name);
    }
  
    void lost(List<int> instanceId) {
      assert(_proxyImpl.isBound);
      var params = new ScanHandlerLostParams();
      params.instanceId = instanceId;
      _proxyImpl.sendMessage(params, kScanHandler_lost_name);
    }
  
}


class ScanHandlerProxy implements bindings.ProxyBase {
  final bindings.Proxy impl;
  ScanHandler ptr;
  final String name = ScanHandlerName;

  ScanHandlerProxy(ScanHandlerProxyImpl proxyImpl) :
      impl = proxyImpl,
      ptr = new _ScanHandlerProxyCalls(proxyImpl);

  ScanHandlerProxy.fromEndpoint(
      core.MojoMessagePipeEndpoint endpoint) :
      impl = new ScanHandlerProxyImpl.fromEndpoint(endpoint) {
    ptr = new _ScanHandlerProxyCalls(impl);
  }

  ScanHandlerProxy.fromHandle(core.MojoHandle handle) :
      impl = new ScanHandlerProxyImpl.fromHandle(handle) {
    ptr = new _ScanHandlerProxyCalls(impl);
  }

  ScanHandlerProxy.unbound() :
      impl = new ScanHandlerProxyImpl.unbound() {
    ptr = new _ScanHandlerProxyCalls(impl);
  }

  factory ScanHandlerProxy.connectToService(
      bindings.ServiceConnector s, String url) {
    ScanHandlerProxy p = new ScanHandlerProxy.unbound();
    s.connectToService(url, p);
    return p;
  }

  static ScanHandlerProxy newFromEndpoint(
      core.MojoMessagePipeEndpoint endpoint) {
    assert(endpoint.setDescription("For ScanHandlerProxy"));
    return new ScanHandlerProxy.fromEndpoint(endpoint);
  }

  Future close({bool immediate: false}) => impl.close(immediate: immediate);

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
  ScanHandler _impl = null;

  ScanHandlerStub.fromEndpoint(
      core.MojoMessagePipeEndpoint endpoint, [this._impl])
      : super.fromEndpoint(endpoint);

  ScanHandlerStub.fromHandle(core.MojoHandle handle, [this._impl])
      : super.fromHandle(handle);

  ScanHandlerStub.unbound() : super.unbound();

  static ScanHandlerStub newFromEndpoint(
      core.MojoMessagePipeEndpoint endpoint) {
    assert(endpoint.setDescription("For ScanHandlerStub"));
    return new ScanHandlerStub.fromEndpoint(endpoint);
  }

  static const String name = ScanHandlerName;



  dynamic handleMessage(bindings.ServiceMessage message) {
    if (bindings.ControlMessageHandler.isControlMessage(message)) {
      return bindings.ControlMessageHandler.handleMessage(this,
                                                          0,
                                                          message);
    }
    assert(_impl != null);
    switch (message.header.type) {
      case kScanHandler_found_name:
        var params = ScanHandlerFoundParams.deserialize(
            message.payload);
        _impl.found(params.s);
        break;
      case kScanHandler_lost_name:
        var params = ScanHandlerLostParams.deserialize(
            message.payload);
        _impl.lost(params.instanceId);
        break;
      default:
        throw new bindings.MojoCodecError("Unexpected message name");
        break;
    }
    return null;
  }

  ScanHandler get impl => _impl;
  set impl(ScanHandler d) {
    assert(_impl == null);
    _impl = d;
  }

  String toString() {
    var superString = super.toString();
    return "ScanHandlerStub($superString)";
  }

  int get version => 0;
}


