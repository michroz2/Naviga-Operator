/*
 * Файл: ble_protocol.dart
 * Версия: 1.8
 * Изменения: Обновлена структура BleEvtMyStatus согласно спецификации 1.34 (добавлено batteryVoltage, удалено txQueueSize).
 * Описание: Содержит константы UUID, коды операций и дата-классы для парсинга бинарных структур.
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
    if (bytes.length < 15) throw Exception('BleIdentity: Неверная длина пакета');
    final byteData = ByteData.sublistView(Uint8List.fromList(bytes));
    final rawBytes = Uint8List.fromList(bytes);

    return BleIdentity(
      opCode: byteData.getUint8(0),
      myNodeId: byteData.getUint8(1),
      myName: _parseNullTerminatedString(rawBytes, 2, 12),
      myRole: byteData.getUint8(14),
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
    if (bytes.length < 17) throw Exception('BleSysConfig: Неверная длина пакета');
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
  final double distance;
  final double azimuth;
  final double snr;
  final int lastSeenAge;

  BleEvtNodeUpdate({required this.opCode, required this.nodeId, required this.nodeRole, required this.nodeName, required this.lat, required this.lon, required this.distance, required this.azimuth, required this.snr, required this.lastSeenAge});

  factory BleEvtNodeUpdate.fromBytes(List<int> bytes) {
    if (bytes.length < 39) throw Exception('BleEvtNodeUpdate: Неверная длина пакета');
    final byteData = ByteData.sublistView(Uint8List.fromList(bytes));
    final rawBytes = Uint8List.fromList(bytes);

    return BleEvtNodeUpdate(
      opCode: byteData.getUint8(0),
      nodeId: byteData.getUint8(1),
      nodeRole: byteData.getUint8(2),
      nodeName: _parseNullTerminatedString(rawBytes, 3, 12),
      lat: byteData.getFloat32(15, Endian.little),
      lon: byteData.getFloat32(19, Endian.little),
      distance: byteData.getFloat32(23, Endian.little),
      azimuth: byteData.getFloat32(27, Endian.little),
      snr: byteData.getFloat32(31, Endian.little),
      lastSeenAge: byteData.getUint32(35, Endian.little),
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
    if (bytes.length < 6) throw Exception('BleEvtMyStatus: Неверная длина пакета');
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