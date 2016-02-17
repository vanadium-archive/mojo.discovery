// Copyright 2014 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

library discovery_mojom;

import 'dart:async';

import 'package:mojo/bindings.dart' as bindings;
import 'package:mojo/core.dart' as core;
import 'package:mojo/mojo/bindings/types/mojom_types.mojom.dart' as mojom_types;
import 'package:mojo/mojo/bindings/types/service_describer.mojom.dart' as service_describer;

class UpdateType extends bindings.MojoEnum {
  static const UpdateType found = const UpdateType._(1);
  static const UpdateType lost = const UpdateType._(2);

  const UpdateType._(int v) : super(v);

  static const Map<String, UpdateType> valuesMap = const {
    "found": found,
    "lost": lost,
  };
  static const List<UpdateType> values = const [
    found,
    lost,
  ];

  static UpdateType valueOf(String name) => valuesMap[name];

  factory UpdateType(int v) {
    switch (v) {
      case 1:
        return found;
      case 2:
        return lost;
      default:
        return null;
    }
  }

  static UpdateType decode(bindings.Decoder decoder0, int offset) {
    int v = decoder0.decodeUint32(offset);
    UpdateType result = new UpdateType(v);
    if (result == null) {
      throw new bindings.MojoCodecError(
          'Bad value $v for enum UpdateType.');
    }
    return result;
  }

  String toString() {
    switch(this) {
      case found:
        return 'UpdateType.found';
      case lost:
        return 'UpdateType.lost';
      default:
        return null;
    }
  }

  int toJson() => mojoEnumValue;
}





class Service extends bindings.Struct {
  static const List<bindings.StructDataHeader> kVersions = const [
    const bindings.StructDataHeader(56, 0)
  ];
  String instanceId = null;
  String instanceName = null;
  String interfaceName = null;
  Map<String, String> attrs = null;
  List<String> addrs = null;
  Map<String, List<int>> attachments = null;

  Service() : super(kVersions.last.size);

  static Service deserialize(bindings.Message message) {
    var decoder = new bindings.Decoder(message);
    var result = decode(decoder);
    if (decoder.excessHandles != null) {
      decoder.excessHandles.forEach((h) => h.close());
    }
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
      
      result.instanceId = decoder0.decodeString(8, true);
    }
    if (mainDataHeader.version >= 0) {
      
      result.instanceName = decoder0.decodeString(16, true);
    }
    if (mainDataHeader.version >= 0) {
      
      result.interfaceName = decoder0.decodeString(24, false);
    }
    if (mainDataHeader.version >= 0) {
      
      var decoder1 = decoder0.decodePointer(32, true);
      if (decoder1 == null) {
        result.attrs = null;
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
    if (mainDataHeader.version >= 0) {
      
      var decoder1 = decoder0.decodePointer(48, true);
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
    
    encoder0.encodeString(instanceId, 8, true);
    
    encoder0.encodeString(instanceName, 16, true);
    
    encoder0.encodeString(interfaceName, 24, false);
    
    if (attrs == null) {
      encoder0.encodeNullPointer(32, true);
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
    
    if (attachments == null) {
      encoder0.encodeNullPointer(48, true);
    } else {
      var encoder1 = encoder0.encoderForMap(48);
      int size0 = attachments.length;
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
  }

  String toString() {
    return "Service("
           "instanceId: $instanceId" ", "
           "instanceName: $instanceName" ", "
           "interfaceName: $interfaceName" ", "
           "attrs: $attrs" ", "
           "addrs: $addrs" ", "
           "attachments: $attachments" ")";
  }

  Map toJson() {
    Map map = new Map();
    map["instanceId"] = instanceId;
    map["instanceName"] = instanceName;
    map["interfaceName"] = interfaceName;
    map["attrs"] = attrs;
    map["addrs"] = addrs;
    map["attachments"] = attachments;
    return map;
  }
}




class ScanUpdate extends bindings.Struct {
  static const List<bindings.StructDataHeader> kVersions = const [
    const bindings.StructDataHeader(24, 0)
  ];
  Service service = null;
  UpdateType updateType = null;

  ScanUpdate() : super(kVersions.last.size);

  static ScanUpdate deserialize(bindings.Message message) {
    var decoder = new bindings.Decoder(message);
    var result = decode(decoder);
    if (decoder.excessHandles != null) {
      decoder.excessHandles.forEach((h) => h.close());
    }
    return result;
  }

  static ScanUpdate decode(bindings.Decoder decoder0) {
    if (decoder0 == null) {
      return null;
    }
    ScanUpdate result = new ScanUpdate();

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
      result.service = Service.decode(decoder1);
    }
    if (mainDataHeader.version >= 0) {
      
        result.updateType = UpdateType.decode(decoder0, 16);
        if (result.updateType == null) {
          throw new bindings.MojoCodecError(
            'Trying to decode null union for non-nullable UpdateType.');
        }
    }
    return result;
  }

  void encode(bindings.Encoder encoder) {
    var encoder0 = encoder.getStructEncoderAtOffset(kVersions.last);
    
    encoder0.encodeStruct(service, 8, false);
    
    encoder0.encodeEnum(updateType, 16);
  }

  String toString() {
    return "ScanUpdate("
           "service: $service" ", "
           "updateType: $updateType" ")";
  }

  Map toJson() {
    Map map = new Map();
    map["service"] = service;
    map["updateType"] = updateType;
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




class _DiscoveryStartAdvertisingParams extends bindings.Struct {
  static const List<bindings.StructDataHeader> kVersions = const [
    const bindings.StructDataHeader(24, 0)
  ];
  Service service = null;
  List<String> visibility = null;

  _DiscoveryStartAdvertisingParams() : super(kVersions.last.size);

  static _DiscoveryStartAdvertisingParams deserialize(bindings.Message message) {
    var decoder = new bindings.Decoder(message);
    var result = decode(decoder);
    if (decoder.excessHandles != null) {
      decoder.excessHandles.forEach((h) => h.close());
    }
    return result;
  }

  static _DiscoveryStartAdvertisingParams decode(bindings.Decoder decoder0) {
    if (decoder0 == null) {
      return null;
    }
    _DiscoveryStartAdvertisingParams result = new _DiscoveryStartAdvertisingParams();

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
      result.service = Service.decode(decoder1);
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
    
    encoder0.encodeStruct(service, 8, false);
    
    if (visibility == null) {
      encoder0.encodeNullPointer(16, true);
    } else {
      var encoder1 = encoder0.encodePointerArray(visibility.length, 16, bindings.kUnspecifiedArrayLength);
      for (int i0 = 0; i0 < visibility.length; ++i0) {
        
        encoder1.encodeString(visibility[i0], bindings.ArrayDataHeader.kHeaderSize + bindings.kPointerSize * i0, false);
      }
    }
  }

  String toString() {
    return "_DiscoveryStartAdvertisingParams("
           "service: $service" ", "
           "visibility: $visibility" ")";
  }

  Map toJson() {
    Map map = new Map();
    map["service"] = service;
    map["visibility"] = visibility;
    return map;
  }
}




class DiscoveryStartAdvertisingResponseParams extends bindings.Struct {
  static const List<bindings.StructDataHeader> kVersions = const [
    const bindings.StructDataHeader(24, 0)
  ];
  String instanceId = null;
  Error err = null;

  DiscoveryStartAdvertisingResponseParams() : super(kVersions.last.size);

  static DiscoveryStartAdvertisingResponseParams deserialize(bindings.Message message) {
    var decoder = new bindings.Decoder(message);
    var result = decode(decoder);
    if (decoder.excessHandles != null) {
      decoder.excessHandles.forEach((h) => h.close());
    }
    return result;
  }

  static DiscoveryStartAdvertisingResponseParams decode(bindings.Decoder decoder0) {
    if (decoder0 == null) {
      return null;
    }
    DiscoveryStartAdvertisingResponseParams result = new DiscoveryStartAdvertisingResponseParams();

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
      
      result.instanceId = decoder0.decodeString(8, false);
    }
    if (mainDataHeader.version >= 0) {
      
      var decoder1 = decoder0.decodePointer(16, true);
      result.err = Error.decode(decoder1);
    }
    return result;
  }

  void encode(bindings.Encoder encoder) {
    var encoder0 = encoder.getStructEncoderAtOffset(kVersions.last);
    
    encoder0.encodeString(instanceId, 8, false);
    
    encoder0.encodeStruct(err, 16, true);
  }

  String toString() {
    return "DiscoveryStartAdvertisingResponseParams("
           "instanceId: $instanceId" ", "
           "err: $err" ")";
  }

  Map toJson() {
    Map map = new Map();
    map["instanceId"] = instanceId;
    map["err"] = err;
    return map;
  }
}




class _DiscoveryStopAdvertisingParams extends bindings.Struct {
  static const List<bindings.StructDataHeader> kVersions = const [
    const bindings.StructDataHeader(16, 0)
  ];
  String instanceId = null;

  _DiscoveryStopAdvertisingParams() : super(kVersions.last.size);

  static _DiscoveryStopAdvertisingParams deserialize(bindings.Message message) {
    var decoder = new bindings.Decoder(message);
    var result = decode(decoder);
    if (decoder.excessHandles != null) {
      decoder.excessHandles.forEach((h) => h.close());
    }
    return result;
  }

  static _DiscoveryStopAdvertisingParams decode(bindings.Decoder decoder0) {
    if (decoder0 == null) {
      return null;
    }
    _DiscoveryStopAdvertisingParams result = new _DiscoveryStopAdvertisingParams();

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
      
      result.instanceId = decoder0.decodeString(8, false);
    }
    return result;
  }

  void encode(bindings.Encoder encoder) {
    var encoder0 = encoder.getStructEncoderAtOffset(kVersions.last);
    
    encoder0.encodeString(instanceId, 8, false);
  }

  String toString() {
    return "_DiscoveryStopAdvertisingParams("
           "instanceId: $instanceId" ")";
  }

  Map toJson() {
    Map map = new Map();
    map["instanceId"] = instanceId;
    return map;
  }
}




class DiscoveryStopAdvertisingResponseParams extends bindings.Struct {
  static const List<bindings.StructDataHeader> kVersions = const [
    const bindings.StructDataHeader(16, 0)
  ];
  Error err = null;

  DiscoveryStopAdvertisingResponseParams() : super(kVersions.last.size);

  static DiscoveryStopAdvertisingResponseParams deserialize(bindings.Message message) {
    var decoder = new bindings.Decoder(message);
    var result = decode(decoder);
    if (decoder.excessHandles != null) {
      decoder.excessHandles.forEach((h) => h.close());
    }
    return result;
  }

  static DiscoveryStopAdvertisingResponseParams decode(bindings.Decoder decoder0) {
    if (decoder0 == null) {
      return null;
    }
    DiscoveryStopAdvertisingResponseParams result = new DiscoveryStopAdvertisingResponseParams();

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
      
      var decoder1 = decoder0.decodePointer(8, true);
      result.err = Error.decode(decoder1);
    }
    return result;
  }

  void encode(bindings.Encoder encoder) {
    var encoder0 = encoder.getStructEncoderAtOffset(kVersions.last);
    
    encoder0.encodeStruct(err, 8, true);
  }

  String toString() {
    return "DiscoveryStopAdvertisingResponseParams("
           "err: $err" ")";
  }

  Map toJson() {
    Map map = new Map();
    map["err"] = err;
    return map;
  }
}




class _DiscoveryStartScanParams extends bindings.Struct {
  static const List<bindings.StructDataHeader> kVersions = const [
    const bindings.StructDataHeader(24, 0)
  ];
  String query = null;
  Object handler = null;

  _DiscoveryStartScanParams() : super(kVersions.last.size);

  static _DiscoveryStartScanParams deserialize(bindings.Message message) {
    var decoder = new bindings.Decoder(message);
    var result = decode(decoder);
    if (decoder.excessHandles != null) {
      decoder.excessHandles.forEach((h) => h.close());
    }
    return result;
  }

  static _DiscoveryStartScanParams decode(bindings.Decoder decoder0) {
    if (decoder0 == null) {
      return null;
    }
    _DiscoveryStartScanParams result = new _DiscoveryStartScanParams();

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
    
    encoder0.encodeString(query, 8, false);
    
    encoder0.encodeInterface(handler, 16, false);
  }

  String toString() {
    return "_DiscoveryStartScanParams("
           "query: $query" ", "
           "handler: $handler" ")";
  }

  Map toJson() {
    throw new bindings.MojoCodecError(
        'Object containing handles cannot be encoded to JSON.');
  }
}




class DiscoveryStartScanResponseParams extends bindings.Struct {
  static const List<bindings.StructDataHeader> kVersions = const [
    const bindings.StructDataHeader(24, 0)
  ];
  int scanId = 0;
  Error err = null;

  DiscoveryStartScanResponseParams() : super(kVersions.last.size);

  static DiscoveryStartScanResponseParams deserialize(bindings.Message message) {
    var decoder = new bindings.Decoder(message);
    var result = decode(decoder);
    if (decoder.excessHandles != null) {
      decoder.excessHandles.forEach((h) => h.close());
    }
    return result;
  }

  static DiscoveryStartScanResponseParams decode(bindings.Decoder decoder0) {
    if (decoder0 == null) {
      return null;
    }
    DiscoveryStartScanResponseParams result = new DiscoveryStartScanResponseParams();

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
      
      result.scanId = decoder0.decodeUint32(8);
    }
    if (mainDataHeader.version >= 0) {
      
      var decoder1 = decoder0.decodePointer(16, true);
      result.err = Error.decode(decoder1);
    }
    return result;
  }

  void encode(bindings.Encoder encoder) {
    var encoder0 = encoder.getStructEncoderAtOffset(kVersions.last);
    
    encoder0.encodeUint32(scanId, 8);
    
    encoder0.encodeStruct(err, 16, true);
  }

  String toString() {
    return "DiscoveryStartScanResponseParams("
           "scanId: $scanId" ", "
           "err: $err" ")";
  }

  Map toJson() {
    Map map = new Map();
    map["scanId"] = scanId;
    map["err"] = err;
    return map;
  }
}




class _DiscoveryStopScanParams extends bindings.Struct {
  static const List<bindings.StructDataHeader> kVersions = const [
    const bindings.StructDataHeader(16, 0)
  ];
  int scanId = 0;

  _DiscoveryStopScanParams() : super(kVersions.last.size);

  static _DiscoveryStopScanParams deserialize(bindings.Message message) {
    var decoder = new bindings.Decoder(message);
    var result = decode(decoder);
    if (decoder.excessHandles != null) {
      decoder.excessHandles.forEach((h) => h.close());
    }
    return result;
  }

  static _DiscoveryStopScanParams decode(bindings.Decoder decoder0) {
    if (decoder0 == null) {
      return null;
    }
    _DiscoveryStopScanParams result = new _DiscoveryStopScanParams();

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
      
      result.scanId = decoder0.decodeUint32(8);
    }
    return result;
  }

  void encode(bindings.Encoder encoder) {
    var encoder0 = encoder.getStructEncoderAtOffset(kVersions.last);
    
    encoder0.encodeUint32(scanId, 8);
  }

  String toString() {
    return "_DiscoveryStopScanParams("
           "scanId: $scanId" ")";
  }

  Map toJson() {
    Map map = new Map();
    map["scanId"] = scanId;
    return map;
  }
}




class DiscoveryStopScanResponseParams extends bindings.Struct {
  static const List<bindings.StructDataHeader> kVersions = const [
    const bindings.StructDataHeader(16, 0)
  ];
  Error err = null;

  DiscoveryStopScanResponseParams() : super(kVersions.last.size);

  static DiscoveryStopScanResponseParams deserialize(bindings.Message message) {
    var decoder = new bindings.Decoder(message);
    var result = decode(decoder);
    if (decoder.excessHandles != null) {
      decoder.excessHandles.forEach((h) => h.close());
    }
    return result;
  }

  static DiscoveryStopScanResponseParams decode(bindings.Decoder decoder0) {
    if (decoder0 == null) {
      return null;
    }
    DiscoveryStopScanResponseParams result = new DiscoveryStopScanResponseParams();

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
      
      var decoder1 = decoder0.decodePointer(8, true);
      result.err = Error.decode(decoder1);
    }
    return result;
  }

  void encode(bindings.Encoder encoder) {
    var encoder0 = encoder.getStructEncoderAtOffset(kVersions.last);
    
    encoder0.encodeStruct(err, 8, true);
  }

  String toString() {
    return "DiscoveryStopScanResponseParams("
           "err: $err" ")";
  }

  Map toJson() {
    Map map = new Map();
    map["err"] = err;
    return map;
  }
}




class _ScanHandlerUpdateParams extends bindings.Struct {
  static const List<bindings.StructDataHeader> kVersions = const [
    const bindings.StructDataHeader(16, 0)
  ];
  ScanUpdate update = null;

  _ScanHandlerUpdateParams() : super(kVersions.last.size);

  static _ScanHandlerUpdateParams deserialize(bindings.Message message) {
    var decoder = new bindings.Decoder(message);
    var result = decode(decoder);
    if (decoder.excessHandles != null) {
      decoder.excessHandles.forEach((h) => h.close());
    }
    return result;
  }

  static _ScanHandlerUpdateParams decode(bindings.Decoder decoder0) {
    if (decoder0 == null) {
      return null;
    }
    _ScanHandlerUpdateParams result = new _ScanHandlerUpdateParams();

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
      result.update = ScanUpdate.decode(decoder1);
    }
    return result;
  }

  void encode(bindings.Encoder encoder) {
    var encoder0 = encoder.getStructEncoderAtOffset(kVersions.last);
    
    encoder0.encodeStruct(update, 8, false);
  }

  String toString() {
    return "_ScanHandlerUpdateParams("
           "update: $update" ")";
  }

  Map toJson() {
    Map map = new Map();
    map["update"] = update;
    return map;
  }
}




const int _Discovery_startAdvertisingName = 0;
const int _Discovery_stopAdvertisingName = 1;
const int _Discovery_startScanName = 2;
const int _Discovery_stopScanName = 3;



class _DiscoveryServiceDescription implements service_describer.ServiceDescription {
  dynamic getTopLevelInterface([Function responseFactory]) => null;

  dynamic getTypeDefinition(String typeKey, [Function responseFactory]) => null;

  dynamic getAllTypeDefinitions([Function responseFactory]) => null;
}

abstract class Discovery {
  static const String serviceName = "v23::discovery::Discovery";
  dynamic startAdvertising(Service service,List<String> visibility,[Function responseFactory = null]);
  dynamic stopAdvertising(String instanceId,[Function responseFactory = null]);
  dynamic startScan(String query,Object handler,[Function responseFactory = null]);
  dynamic stopScan(int scanId,[Function responseFactory = null]);
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
      case _Discovery_startAdvertisingName:
        var r = DiscoveryStartAdvertisingResponseParams.deserialize(
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
      case _Discovery_stopAdvertisingName:
        var r = DiscoveryStopAdvertisingResponseParams.deserialize(
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
      case _Discovery_startScanName:
        var r = DiscoveryStartScanResponseParams.deserialize(
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
      case _Discovery_stopScanName:
        var r = DiscoveryStopScanResponseParams.deserialize(
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
    dynamic startAdvertising(Service service,List<String> visibility,[Function responseFactory = null]) {
      var params = new _DiscoveryStartAdvertisingParams();
      params.service = service;
      params.visibility = visibility;
      return _proxyImpl.sendMessageWithRequestId(
          params,
          _Discovery_startAdvertisingName,
          -1,
          bindings.MessageHeader.kMessageExpectsResponse);
    }
    dynamic stopAdvertising(String instanceId,[Function responseFactory = null]) {
      var params = new _DiscoveryStopAdvertisingParams();
      params.instanceId = instanceId;
      return _proxyImpl.sendMessageWithRequestId(
          params,
          _Discovery_stopAdvertisingName,
          -1,
          bindings.MessageHeader.kMessageExpectsResponse);
    }
    dynamic startScan(String query,Object handler,[Function responseFactory = null]) {
      var params = new _DiscoveryStartScanParams();
      params.query = query;
      params.handler = handler;
      return _proxyImpl.sendMessageWithRequestId(
          params,
          _Discovery_startScanName,
          -1,
          bindings.MessageHeader.kMessageExpectsResponse);
    }
    dynamic stopScan(int scanId,[Function responseFactory = null]) {
      var params = new _DiscoveryStopScanParams();
      params.scanId = scanId;
      return _proxyImpl.sendMessageWithRequestId(
          params,
          _Discovery_stopScanName,
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
  Discovery _impl = null;

  DiscoveryStub.fromEndpoint(
      core.MojoMessagePipeEndpoint endpoint, [this._impl])
      : super.fromEndpoint(endpoint);

  DiscoveryStub.fromHandle(core.MojoHandle handle, [this._impl])
      : super.fromHandle(handle);

  DiscoveryStub.unbound() : super.unbound();

  static DiscoveryStub newFromEndpoint(
      core.MojoMessagePipeEndpoint endpoint) {
    assert(endpoint.setDescription("For DiscoveryStub"));
    return new DiscoveryStub.fromEndpoint(endpoint);
  }


  DiscoveryStartAdvertisingResponseParams _DiscoveryStartAdvertisingResponseParamsFactory(String instanceId, Error err) {
    var mojo_factory_result = new DiscoveryStartAdvertisingResponseParams();
    mojo_factory_result.instanceId = instanceId;
    mojo_factory_result.err = err;
    return mojo_factory_result;
  }
  DiscoveryStopAdvertisingResponseParams _DiscoveryStopAdvertisingResponseParamsFactory(Error err) {
    var mojo_factory_result = new DiscoveryStopAdvertisingResponseParams();
    mojo_factory_result.err = err;
    return mojo_factory_result;
  }
  DiscoveryStartScanResponseParams _DiscoveryStartScanResponseParamsFactory(int scanId, Error err) {
    var mojo_factory_result = new DiscoveryStartScanResponseParams();
    mojo_factory_result.scanId = scanId;
    mojo_factory_result.err = err;
    return mojo_factory_result;
  }
  DiscoveryStopScanResponseParams _DiscoveryStopScanResponseParamsFactory(Error err) {
    var mojo_factory_result = new DiscoveryStopScanResponseParams();
    mojo_factory_result.err = err;
    return mojo_factory_result;
  }

  dynamic handleMessage(bindings.ServiceMessage message) {
    if (bindings.ControlMessageHandler.isControlMessage(message)) {
      return bindings.ControlMessageHandler.handleMessage(this,
                                                          0,
                                                          message);
    }
    assert(_impl != null);
    switch (message.header.type) {
      case _Discovery_startAdvertisingName:
        var params = _DiscoveryStartAdvertisingParams.deserialize(
            message.payload);
        var response = _impl.startAdvertising(params.service,params.visibility,_DiscoveryStartAdvertisingResponseParamsFactory);
        if (response is Future) {
          return response.then((response) {
            if (response != null) {
              return buildResponseWithId(
                  response,
                  _Discovery_startAdvertisingName,
                  message.header.requestId,
                  bindings.MessageHeader.kMessageIsResponse);
            }
          });
        } else if (response != null) {
          return buildResponseWithId(
              response,
              _Discovery_startAdvertisingName,
              message.header.requestId,
              bindings.MessageHeader.kMessageIsResponse);
        }
        break;
      case _Discovery_stopAdvertisingName:
        var params = _DiscoveryStopAdvertisingParams.deserialize(
            message.payload);
        var response = _impl.stopAdvertising(params.instanceId,_DiscoveryStopAdvertisingResponseParamsFactory);
        if (response is Future) {
          return response.then((response) {
            if (response != null) {
              return buildResponseWithId(
                  response,
                  _Discovery_stopAdvertisingName,
                  message.header.requestId,
                  bindings.MessageHeader.kMessageIsResponse);
            }
          });
        } else if (response != null) {
          return buildResponseWithId(
              response,
              _Discovery_stopAdvertisingName,
              message.header.requestId,
              bindings.MessageHeader.kMessageIsResponse);
        }
        break;
      case _Discovery_startScanName:
        var params = _DiscoveryStartScanParams.deserialize(
            message.payload);
        var response = _impl.startScan(params.query,params.handler,_DiscoveryStartScanResponseParamsFactory);
        if (response is Future) {
          return response.then((response) {
            if (response != null) {
              return buildResponseWithId(
                  response,
                  _Discovery_startScanName,
                  message.header.requestId,
                  bindings.MessageHeader.kMessageIsResponse);
            }
          });
        } else if (response != null) {
          return buildResponseWithId(
              response,
              _Discovery_startScanName,
              message.header.requestId,
              bindings.MessageHeader.kMessageIsResponse);
        }
        break;
      case _Discovery_stopScanName:
        var params = _DiscoveryStopScanParams.deserialize(
            message.payload);
        var response = _impl.stopScan(params.scanId,_DiscoveryStopScanResponseParamsFactory);
        if (response is Future) {
          return response.then((response) {
            if (response != null) {
              return buildResponseWithId(
                  response,
                  _Discovery_stopScanName,
                  message.header.requestId,
                  bindings.MessageHeader.kMessageIsResponse);
            }
          });
        } else if (response != null) {
          return buildResponseWithId(
              response,
              _Discovery_stopScanName,
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
    assert(_impl == null);
    _impl = d;
  }

  String toString() {
    var superString = super.toString();
    return "DiscoveryStub($superString)";
  }

  int get version => 0;

  service_describer.ServiceDescription get serviceDescription =>
    new _DiscoveryServiceDescription();
}

const int _ScanHandler_updateName = 0;



class _ScanHandlerServiceDescription implements service_describer.ServiceDescription {
  dynamic getTopLevelInterface([Function responseFactory]) => null;

  dynamic getTypeDefinition(String typeKey, [Function responseFactory]) => null;

  dynamic getAllTypeDefinitions([Function responseFactory]) => null;
}

abstract class ScanHandler {
  static const String serviceName = "v23::discovery::ScanHandler";
  void update(ScanUpdate update);
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
    void update(ScanUpdate update) {
      if (!_proxyImpl.isBound) {
        _proxyImpl.proxyError("The Proxy is closed.");
        return;
      }
      var params = new _ScanHandlerUpdateParams();
      params.update = update;
      _proxyImpl.sendMessage(params, _ScanHandler_updateName);
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



  dynamic handleMessage(bindings.ServiceMessage message) {
    if (bindings.ControlMessageHandler.isControlMessage(message)) {
      return bindings.ControlMessageHandler.handleMessage(this,
                                                          0,
                                                          message);
    }
    assert(_impl != null);
    switch (message.header.type) {
      case _ScanHandler_updateName:
        var params = _ScanHandlerUpdateParams.deserialize(
            message.payload);
        _impl.update(params.update);
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

  service_describer.ServiceDescription get serviceDescription =>
    new _ScanHandlerServiceDescription();
}



