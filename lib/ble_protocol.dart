/*
 * Файл: ble_protocol.dart
 * Версия: 1.23
 * Изменения: Внедрена спецификация v1.47.1. Добавлен cmdSetAnchorCoords (0x08). gpsValid заменен на gpsState (3 позиции) в телеметрии.
 * Описание: Структуры данных и константы протокола Naviga.
 */

import 'dart:typed_data';

class BleConfig {
  static const String deviceNamePrefix = "Naviga";
  static const String serviceUuid = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E";
  static const String rxCharacteristicUuid = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E";
  static const String txCharacteristicUuid = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E";
}

class BleOpCode {
  static const int cmdSetIdentity = 0x01;
  static const int cmdSetSysConfig = 0x02;
  static const int cmdActionReset = 0x03;
  static const int cmdActionClearDb = 0x04;
  static const int cmdReqFullSync = 0x05;
  static const int cmdReqIdentity = 0x06;
  static const int cmdReqSysConfig = 0x07;
  static const int cmdSetAnchorCoords = 0x08; // ИЗМЕНЕНИЕ 1.48: Новая команда

  static const int evtMyStatus = 0x10;
  static const int evtNodeUpdate = 0x11;
  static const int evtIdentity = 0x12;
  static const int evtSysConfig = 0x13;
  static const int evtNodeDelete = 0x14;
  static const int evtNodeCoords = 0x15;
  static const int evtNodeInfo = 0x16;
}

class BleIdentity {
  final int opCode;
  final int myNodeId;
  final String myName;
  final int myRole;

  BleIdentity({required this.opCode, required this.myNodeId, required this.myName, required this.myRole});

  factory BleIdentity.fromBytes(List<int> data) {
    int nullIndex = data.indexOf(0, 2);
    if (nullIndex == -1 || nullIndex > 26) nullIndex = 26;
    String parsedName = String.fromCharCodes(data.sublist(2, nullIndex));
    return BleIdentity(
      opCode: data[0],
      myNodeId: data[1],
      myName: parsedName,
      myRole: data[26],
    );
  }
}

class BleSysConfig {
  final int opCode;
  final int txIntervalMoving;
  final int txIntervalStill;
  final int nodeConnectionTimeout;
  final int nodeActiveTimeoutMs;

  BleSysConfig({
    required this.opCode,
    required this.txIntervalMoving,
    required this.txIntervalStill,
    required this.nodeConnectionTimeout,
    required this.nodeActiveTimeoutMs,
  });

  factory BleSysConfig.fromBytes(List<int> data) {
    final byteData = ByteData.view(Uint8List.fromList(data).buffer);
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

  BleEvtNodeUpdate({
    required this.opCode,
    required this.nodeId,
    required this.nodeRole,
    required this.nodeName,
    required this.lat,
    required this.lon,
    required this.snr,
    required this.lastSeenAge,
  });

  factory BleEvtNodeUpdate.fromBytes(List<int> data) {
    int nullIndex = data.indexOf(0, 3);
    if (nullIndex == -1 || nullIndex > 27) nullIndex = 27;
    String parsedName = String.fromCharCodes(data.sublist(3, nullIndex));
    final byteData = ByteData.view(Uint8List.fromList(data).buffer);

    return BleEvtNodeUpdate(
      opCode: byteData.getUint8(0),
      nodeId: byteData.getUint8(1),
      nodeRole: byteData.getUint8(2),
      nodeName: parsedName,
      lat: byteData.getFloat32(27, Endian.little),
      lon: byteData.getFloat32(31, Endian.little),
      snr: byteData.getFloat32(35, Endian.little),
      lastSeenAge: byteData.getUint32(39, Endian.little),
    );
  }
}

class BleEvtMyStatus {
  final int opCode;
  final int gpsState; // ИЗМЕНЕНИЕ 1.48: 3-позиционный статус (0, 1, 2)
  final int satellites;
  final int batteryPercent;
  final int batteryVoltage;

  BleEvtMyStatus({
    required this.opCode,
    required this.gpsState,
    required this.satellites,
    required this.batteryPercent,
    required this.batteryVoltage,
  });

  factory BleEvtMyStatus.fromBytes(List<int> data) {
    final byteData = ByteData.view(Uint8List.fromList(data).buffer);
    return BleEvtMyStatus(
      opCode: byteData.getUint8(0),
      gpsState: byteData.getUint8(1),
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

  factory BleEvtNodeDelete.fromBytes(List<int> data) {
    return BleEvtNodeDelete(
      opCode: data[0],
      nodeId: data[1],
    );
  }
}

class BleEvtNodeCoords {
  final int opCode;
  final int nodeId;
  final double lat;
  final double lon;
  final double snr;

  BleEvtNodeCoords({
    required this.opCode,
    required this.nodeId,
    required this.lat,
    required this.lon,
    required this.snr,
  });

  factory BleEvtNodeCoords.fromBytes(List<int> data) {
    final byteData = ByteData.view(Uint8List.fromList(data).buffer);
    return BleEvtNodeCoords(
      opCode: byteData.getUint8(0),
      nodeId: byteData.getUint8(1),
      lat: byteData.getFloat32(2, Endian.little),
      lon: byteData.getFloat32(6, Endian.little),
      snr: byteData.getFloat32(10, Endian.little),
    );
  }
}

class BleEvtNodeInfo {
  final int opCode;
  final int nodeId;
  final int nodeRole;
  final String nodeName;

  BleEvtNodeInfo({
    required this.opCode,
    required this.nodeId,
    required this.nodeRole,
    required this.nodeName,
  });

  factory BleEvtNodeInfo.fromBytes(List<int> data) {
    int nullIndex = data.indexOf(0, 3);
    if (nullIndex == -1 || nullIndex > 27) nullIndex = 27;
    String parsedName = String.fromCharCodes(data.sublist(3, nullIndex));
    return BleEvtNodeInfo(
      opCode: data[0],
      nodeId: data[1],
      nodeRole: data[2],
      nodeName: parsedName,
    );
  }
}