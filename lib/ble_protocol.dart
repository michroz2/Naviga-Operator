/*
 * Файл: ble_protocol.dart
 * Версия: 1.15
 * Изменения: Поддержка протокола v1.46.4. Добавлены EVT_NODE_COORDS (0x15) и EVT_NODE_INFO (0x16).
 * Описание: Бинарные структуры и OpCodes.
 */

import 'dart:convert';
import 'dart:typed_data';

class BleConfig {
  static const String deviceNamePrefix = 'Naviga-';
  static const String serviceUuid = '6E400001-B5A3-F393-E0A9-E50E24DCCA9E';
  static const String rxCharacteristicUuid = '6E400002-B5A3-F393-E0A9-E50E24DCCA9E'; 
  static const String txCharacteristicUuid = '6E400003-B5A3-F393-E0A9-E50E24DCCA9E'; 
}

class BleOpCode {
  static const int cmdSetIdentity = 0x01;
  static const int cmdSetSysConfig = 0x02;
  static const int cmdActionReset = 0x03;
  static const int cmdActionClearDb = 0x04;
  static const int cmdReqFullSync = 0x05;
  static const int cmdReqIdentity = 0x06;
  static const int cmdReqSysConfig = 0x07;

  static const int evtMyStatus = 0x10;
  static const int evtNodeUpdate = 0x11;
  static const int evtIdentity = 0x12;
  static const int evtSysConfig = 0x13;
  static const int evtNodeDelete = 0x14;
  static const int evtNodeCoords = 0x15; // NEW: Delta Coords
  static const int evtNodeInfo = 0x16;   // NEW: Delta Name/Role
}

String _parseNullTerminatedString(Uint8List bytes, int offset, int length) {
  final sublist = bytes.sublist(offset, offset + length);
  int nullIndex = sublist.indexOf(0);
  if (nullIndex == -1) nullIndex = length;
  return utf8.decode(sublist.sublist(0, nullIndex), allowMalformed: true);
}

class BleIdentity {
  final int opCode;
  final int myNodeId;
  final String myName;
  final int myRole;

  BleIdentity({required this.opCode, required this.myNodeId, required this.myName, required this.myRole});

  factory BleIdentity.fromBytes(List<int> bytes) {
    if (bytes.length < 27) throw Exception('BleIdentity: Wrong size');
    final byteData = ByteData.sublistView(Uint8List.fromList(bytes));
    final rawBytes = Uint8List.fromList(bytes);

    return BleIdentity(
      opCode: byteData.getUint8(0),
      myNodeId: byteData.getUint8(1),
      myName: _parseNullTerminatedString(rawBytes, 2, 24),
      myRole: byteData.getUint8(26),
    );
  }
}

class BleSysConfig {
  final int opCode;
  final int txIntervalMoving;
  final int txIntervalStill;
  final int nodeConnectionTimeout;
  final int nodeActiveTimeoutMs;

  BleSysConfig({required this.opCode, required this.txIntervalMoving, required this.txIntervalStill, required this.nodeConnectionTimeout, required this.nodeActiveTimeoutMs});

  factory BleSysConfig.fromBytes(List<int> bytes) {
    if (bytes.length < 17) throw Exception('BleSysConfig: Wrong size');
    final byteData = ByteData.sublistView(Uint8List.fromList(bytes));

    return BleSysConfig(
      opCode: byteData.getUint8(0),
      txIntervalMoving: byteData.getUint32(1, Endian.little),
      txIntervalStill: byteData.getUint32(5, Endian.little),
      nodeConnectionTimeout: byteData.getUint32(9, Endian.little),
      nodeActiveTimeoutMs: byteData.getUint32(13, Endian.little),
    );
  }
}

class BleEvtNodeUpdate {
  final int opCode;
  final int nodeId;
  final int nodeRole;
  final String nodeName;
  final double lat;
  final double lon;
  final double snr;
  final int lastSeenAge;

  BleEvtNodeUpdate({required this.opCode, required this.nodeId, required this.nodeRole, required this.nodeName, required this.lat, required this.lon, required this.snr, required this.lastSeenAge});

  factory BleEvtNodeUpdate.fromBytes(List<int> bytes) {
    if (bytes.length < 43) throw Exception('BleEvtNodeUpdate: Wrong size');
    final byteData = ByteData.sublistView(Uint8List.fromList(bytes));
    final rawBytes = Uint8List.fromList(bytes);

    return BleEvtNodeUpdate(
      opCode: byteData.getUint8(0),
      nodeId: byteData.getUint8(1),
      nodeRole: byteData.getUint8(2),
      nodeName: _parseNullTerminatedString(rawBytes, 3, 24),
      lat: byteData.getFloat32(27, Endian.little),
      lon: byteData.getFloat32(31, Endian.little),
      snr: byteData.getFloat32(35, Endian.little),
      lastSeenAge: byteData.getUint32(39, Endian.little),
    );
  }
}

class BleEvtMyStatus {
  final int opCode;
  final int gpsValid;
  final int satellites;
  final int batteryPercent;
  final int batteryVoltage;

  BleEvtMyStatus({required this.opCode, required this.gpsValid, required this.satellites, required this.batteryPercent, required this.batteryVoltage});

  factory BleEvtMyStatus.fromBytes(List<int> bytes) {
    if (bytes.length < 6) throw Exception('BleEvtMyStatus: Wrong size');
    final byteData = ByteData.sublistView(Uint8List.fromList(bytes));

    return BleEvtMyStatus(
      opCode: byteData.getUint8(0),
      gpsValid: byteData.getUint8(1),
      satellites: byteData.getUint8(2),
      batteryPercent: byteData.getUint8(3),
      batteryVoltage: byteData.getUint16(4, Endian.little),
    );
  }
}

class BleEvtNodeDelete {
  final int opCode;
  final int nodeId;
  BleEvtNodeDelete({required this.opCode, required this.nodeId});
  factory BleEvtNodeDelete.fromBytes(List<int> bytes) {
    return BleEvtNodeDelete(opCode: bytes[0], nodeId: bytes[1]);
  }
}

// 4.6. Обновление координат (BleEvtNodeCoords) - 14 байт
class BleEvtNodeCoords {
  final int nodeId;
  final double lat;
  final double lon;
  final double snr;

  BleEvtNodeCoords({required this.nodeId, required this.lat, required this.lon, required this.snr});

  factory BleEvtNodeCoords.fromBytes(List<int> bytes) {
    if (bytes.length < 14) throw Exception('BleEvtNodeCoords: Wrong size');
    final byteData = ByteData.sublistView(Uint8List.fromList(bytes));
    return BleEvtNodeCoords(
      nodeId: byteData.getUint8(1),
      lat: byteData.getFloat32(2, Endian.little),
      lon: byteData.getFloat32(6, Endian.little),
      snr: byteData.getFloat32(10, Endian.little),
    );
  }
}

// 4.7. Обновление Имени и Роли (BleEvtNodeInfo) - 27 байт
class BleEvtNodeInfo {
  final int nodeId;
  final int nodeRole;
  final String nodeName;

  BleEvtNodeInfo({required this.nodeId, required this.nodeRole, required this.nodeName});

  factory BleEvtNodeInfo.fromBytes(List<int> bytes) {
    if (bytes.length < 27) throw Exception('BleEvtNodeInfo: Wrong size');
    final byteData = ByteData.sublistView(Uint8List.fromList(bytes));
    final rawBytes = Uint8List.fromList(bytes);
    return BleEvtNodeInfo(
      nodeId: byteData.getUint8(1),
      nodeRole: byteData.getUint8(2),
      nodeName: _parseNullTerminatedString(rawBytes, 3, 24),
    );
  }
}