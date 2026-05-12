/*
 * Файл: ble_service.dart
 * Версия: 1.13
 * Изменения: Интеграция с локальной NodeDatabase. Обработка пакетов EVT_NODE_UPDATE и EVT_NODE_DELETE.
 */

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'ble_protocol.dart';
import 'node_database.dart'; // ИЗМЕНЕНИЕ 1.13

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

  // ИЗМЕНЕНИЕ 1.13: Инициализация нашей базы узлов
  final NodeDatabase nodeDatabase = NodeDatabase();

  Future<void> startScan() async {
    await _scanSubscription?.cancel();
    scanResultsNotifier.value = []; 
    isScanning.value = true;
    debugPrint('Запуск сканирования BLE...');
    
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
      debugPrint('Попытка подключения к ${device.remoteId}...');
      await device.connect(license: License.free, autoConnect: false);
      _connectedDevice = device;
      
      connectedDeviceName.value = device.platformName.isEmpty ? device.advName : device.platformName;
      isConnected.value = true;
      
      debugPrint('Успешное подключение!');

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
        debugPrint('Подписка на TX успешно оформлена.');

        _requestIdentity();

      } else {
        debugPrint('ОШИБКА: RX или TX характеристика не найдена!');
      }
    } catch (e) {
      debugPrint('Ошибка при подключении: $e');
      isConnected.value = false;
    }
  }

  Future<void> _sendCommand(List<int> data) async {
    if (_rxCharacteristic == null) return;
    try {
      bool withoutResp = _rxCharacteristic!.properties.writeWithoutResponse;
      await _rxCharacteristic!.write(data, withoutResponse: withoutResp);
    } catch (e) {
      debugPrint('Ошибка при отправке: $e');
    }
  }

  void _requestIdentity() {
    _sendCommand([BleOpCode.cmdReqIdentity]);
  }

  void _requestSysConfig() {
    _sendCommand([BleOpCode.cmdReqSysConfig]);
  }

  Future<void> setIdentity(int nodeId, String name, int role) async {
    try {
      List<int> payload = List<int>.filled(27, 0);
      payload[0] = BleOpCode.cmdSetIdentity; 
      payload[1] = nodeId;                   

      List<int> nameBytes = utf8.encode(name);
      for (int i = 0; i < 24; i++) {
        if (i < nameBytes.length && i < 23) { 
          payload[2 + i] = nameBytes[i];
        }
      }
      payload[26] = role;

      await _sendCommand(payload);
      Future.delayed(const Duration(milliseconds: 300), () {
        _requestIdentity();
      });
    } catch (e) {
      debugPrint('Ошибка CMD_SET_IDENTITY: $e');
    }
  }

  Future<void> setSysConfig({
    required int txMoving,
    required int txStill,
    required int connTimeout,
    required int activeTimeout,
  }) async {
    try {
      final payload = Uint8List(17);
      final byteData = ByteData.view(payload.buffer);

      byteData.setUint8(0, BleOpCode.cmdSetSysConfig); 
      byteData.setUint32(1, txMoving, Endian.little);
      byteData.setUint32(5, txStill, Endian.little);
      byteData.setUint32(9, connTimeout, Endian.little);
      byteData.setUint32(13, activeTimeout, Endian.little);

      await _sendCommand(payload.toList());

      Future.delayed(const Duration(milliseconds: 300), () {
        _requestSysConfig();
      });
    } catch (e) {
      debugPrint('Ошибка CMD_SET_SYS_CONFIG: $e');
    }
  }

  Future<void> factoryReset() async {
    try {
      await _sendCommand([BleOpCode.cmdActionReset]);
      await disconnect();
    } catch (e) {
      debugPrint('Ошибка Factory Reset: $e');
    }
  }

  void _handleIncomingData(List<int> data) {
    if (data.isEmpty) return;
    int opCode = data[0];
    try {
      if (opCode == BleOpCode.evtIdentity) {
        final identity = BleIdentity.fromBytes(data);
        identityNotifier.value = identity; 
        if (sysConfigNotifier.value == null) _requestSysConfig();
      } 
      else if (opCode == BleOpCode.evtSysConfig) {
        sysConfigNotifier.value = BleSysConfig.fromBytes(data); 
      }
      else if (opCode == BleOpCode.evtMyStatus) {
        myStatusNotifier.value = BleEvtMyStatus.fromBytes(data);
      }
      // ИЗМЕНЕНИЕ 1.13: Передаем данные в БД (включая MyNodeId для математики)
      else if (opCode == BleOpCode.evtNodeUpdate) {
        final update = BleEvtNodeUpdate.fromBytes(data);
        nodeDatabase.updateNode(update, identityNotifier.value?.myNodeId);
      }
      else if (opCode == BleOpCode.evtNodeDelete) {
        final delNode = BleEvtNodeDelete.fromBytes(data);
        nodeDatabase.deleteNode(delNode.nodeId);
      }
    } catch (e) {
      debugPrint('Ошибка парсинга пакета 0x${opCode.toRadixString(16)}: $e');
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
    
    nodeDatabase.clear(); // ИЗМЕНЕНИЕ 1.13: Очистка базы при отключении
    
    debugPrint('Устройство отключено');
  }
}