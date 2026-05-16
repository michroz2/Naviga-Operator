/*
 * Файл: ble_service.dart
 * Версия: 1.16.1
 * Изменения: Вызов initLocalNode при парсинге Identity для гарантированного отображения "Я" в ростере.
 * Описание: BLE-сервис управления соединением и диспетчеризации пакетов.
 */

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'ble_protocol.dart';
import 'node_database.dart';

class BleService {
  static final BleService _instance = BleService._internal();
  factory BleService() => _instance;
  BleService._internal();

  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _rxCharacteristic;
  BluetoothCharacteristic? _txCharacteristic;

  StreamSubscription<List<ScanResult>>? _scanSubscription;

  final ValueNotifier<bool> isScanning = ValueNotifier(false);
  final ValueNotifier<bool> isConnected = ValueNotifier(false);
  final ValueNotifier<List<ScanResult>> scanResultsNotifier = ValueNotifier([]);
  final ValueNotifier<String> connectedDeviceName = ValueNotifier('');
  
  final ValueNotifier<BleIdentity?> identityNotifier = ValueNotifier(null);
  final ValueNotifier<BleSysConfig?> sysConfigNotifier = ValueNotifier(null);
  final ValueNotifier<BleEvtMyStatus?> myStatusNotifier = ValueNotifier(null);

  final NodeDatabase nodeDatabase = NodeDatabase();

  Future<void> startScan() async {
    await _scanSubscription?.cancel();
    scanResultsNotifier.value = []; 
    isScanning.value = true;
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      List<ScanResult> navigaDevices = results.where((r) {
        String deviceName = r.device.platformName.isEmpty ? r.device.advName : r.device.platformName;
        return deviceName.startsWith(BleConfig.deviceNamePrefix);
      }).toList();
      navigaDevices.sort((a, b) => b.rssi.compareTo(a.rssi));
      scanResultsNotifier.value = navigaDevices;
    });
    Future.delayed(const Duration(seconds: 15), () {
      if (isScanning.value) isScanning.value = false;
    });
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    await FlutterBluePlus.stopScan();
    isScanning.value = false;
    try {
      await device.connect(license: License.free, autoConnect: false);
      _connectedDevice = device;
      connectedDeviceName.value = device.platformName.isEmpty ? device.advName : device.platformName;
      isConnected.value = true;
      if (defaultTargetPlatform == TargetPlatform.android) {
        await device.requestMtu(128); 
      }
      List<BluetoothService> services = await device.discoverServices();
      for (BluetoothService service in services) {
        if (service.uuid.toString().toLowerCase() == BleConfig.serviceUuid.toLowerCase()) {
          for (BluetoothCharacteristic char in service.characteristics) {
            String charUuid = char.uuid.toString().toLowerCase();
            if (charUuid == BleConfig.rxCharacteristicUuid.toLowerCase()) {
              _rxCharacteristic = char;
            } else if (charUuid == BleConfig.txCharacteristicUuid.toLowerCase()) {
              _txCharacteristic = char;
            }
          }
        }
      }
      if (_txCharacteristic != null && _rxCharacteristic != null) {
        await _txCharacteristic!.setNotifyValue(true);
        _txCharacteristic!.lastValueStream.listen(_handleIncomingData);
        _requestIdentity();
      }
    } catch (e) {
      isConnected.value = false;
    }
  }

  Future<void> _sendCommand(List<int> data) async {
    if (_rxCharacteristic == null) return;
    try {
      bool withoutResp = _rxCharacteristic!.properties.writeWithoutResponse;
      await _rxCharacteristic!.write(data, withoutResponse: withoutResp);
    } catch (e) {
      debugPrint('Error sending: $e');
    }
  }

  void _requestIdentity() => _sendCommand([BleOpCode.cmdReqIdentity]);
  void _requestSysConfig() => _sendCommand([BleOpCode.cmdReqSysConfig]);
  
  void requestFullSync() {
    debugPrint('>>> Запрос полной синхронизации базы (0x05)');
    _sendCommand([BleOpCode.cmdReqFullSync]);
  }

  Future<void> setIdentity(int nodeId, String name, int role) async {
    try {
      List<int> payload = List<int>.filled(27, 0);
      payload[0] = BleOpCode.cmdSetIdentity; 
      payload[1] = nodeId;                   
      List<int> nameBytes = utf8.encode(name);
      for (int i = 0; i < 24; i++) {
        if (i < nameBytes.length && i < 23) payload[2 + i] = nameBytes[i];
      }
      payload[26] = role;
      await _sendCommand(payload);
      Future.delayed(const Duration(milliseconds: 300), _requestIdentity);
    } catch (e) {
      debugPrint('Error CMD_SET_IDENTITY: $e');
    }
  }

  Future<void> setSysConfig({required int txMoving, required int txStill, required int connTimeout, required int activeTimeout}) async {
    try {
      final payload = Uint8List(17);
      final byteData = ByteData.view(payload.buffer);
      byteData.setUint8(0, BleOpCode.cmdSetSysConfig); 
      byteData.setUint32(1, txMoving, Endian.little);
      byteData.setUint32(5, txStill, Endian.little);
      byteData.setUint32(9, connTimeout, Endian.little);
      byteData.setUint32(13, activeTimeout, Endian.little);
      await _sendCommand(payload.toList());
      Future.delayed(const Duration(milliseconds: 300), _requestSysConfig);
    } catch (e) {
      debugPrint('Error CMD_SET_SYS_CONFIG: $e');
    }
  }

  Future<void> factoryReset() async {
    try {
      await _sendCommand([BleOpCode.cmdActionReset]);
      await disconnect();
    } catch (e) {
      debugPrint('Error Factory Reset: $e');
    }
  }

  void _handleIncomingData(List<int> data) {
    if (data.isEmpty) return;
    int opCode = data[0];
    int? myId = identityNotifier.value?.myNodeId;
    
    try {
      switch (opCode) {
        case BleOpCode.evtIdentity:
          int? oldId = myId; // Запоминаем старый ID до обновления
          identityNotifier.value = BleIdentity.fromBytes(data);
          
          // ИЗМЕНЕНИЕ 1.16.1: Инъекция собственного узла в базу
          nodeDatabase.initLocalNode(identityNotifier.value!, oldId);

          if (sysConfigNotifier.value == null) {
            _requestSysConfig();
          } else {
            nodeDatabase.startGarbageCollector(sysConfigNotifier.value!.nodeActiveTimeoutMs, identityNotifier.value?.myNodeId);
          }
          break;
        case BleOpCode.evtSysConfig:
          final config = BleSysConfig.fromBytes(data);
          sysConfigNotifier.value = config;
          nodeDatabase.startGarbageCollector(config.nodeActiveTimeoutMs, myId);
          requestFullSync();
          break;
        case BleOpCode.evtMyStatus:
          myStatusNotifier.value = BleEvtMyStatus.fromBytes(data);
          break;
        case BleOpCode.evtNodeUpdate:
          nodeDatabase.updateNodeFull(BleEvtNodeUpdate.fromBytes(data), myId);
          break;
        case BleOpCode.evtNodeDelete:
          nodeDatabase.deleteNode(BleEvtNodeDelete.fromBytes(data).nodeId);
          break;
        case BleOpCode.evtNodeCoords:
          nodeDatabase.updateNodeCoords(BleEvtNodeCoords.fromBytes(data), myId);
          break;
        case BleOpCode.evtNodeInfo:
          nodeDatabase.updateNodeInfo(BleEvtNodeInfo.fromBytes(data), myId);
          break;
      }
    } catch (e) {
      debugPrint('Parsing error 0x${opCode.toRadixString(16)}: $e');
    }
  }

  Future<void> disconnect() async {
    await _connectedDevice?.disconnect();
    _connectedDevice = null;
    _rxCharacteristic = null;
    _txCharacteristic = null;
    isConnected.value = false;
    isScanning.value = false;
    connectedDeviceName.value = '';
    scanResultsNotifier.value = [];
    identityNotifier.value = null;
    sysConfigNotifier.value = null;
    myStatusNotifier.value = null;
    nodeDatabase.clear();
  }
}