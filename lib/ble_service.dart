/*
 * Файл: ble_service.dart
 * Версия: 1.41.5
 * Изменения: Оптимизирована логика после реконнекта: команда _requestIdentity() вызывается при любом восстановлении связи, а requestFullSync() — только при длительном отсутствии (attemptCount >= 5).
 * Описание: BLE-сервис управления соединением и диспетчеризации пакетов.
 */

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'ble_protocol.dart';
import 'node_database.dart';
import 'app_logger.dart';
import 'app_settings.dart';

class BleService {
  static final BleService _instance = BleService._internal();
  factory BleService() => _instance;
  BleService._internal();

  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _rxCharacteristic;
  BluetoothCharacteristic? _txCharacteristic;

  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;

  final ValueNotifier<bool> isScanning = ValueNotifier(false);
  final ValueNotifier<bool> isConnected = ValueNotifier(false);
  final ValueNotifier<bool> isReconnecting = ValueNotifier(false);
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
    AppLogger.logInfo('Запуск сканирования BLE устройств...');
    
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
      if (isScanning.value) {
        isScanning.value = false;
        AppLogger.logInfo('Сканирование завершено по таймауту');
      }
    });
  }

  void _updateBackgroundNotification() {
    if (!isConnected.value) return;
    final status = myStatusNotifier.value;
    final deviceName = connectedDeviceName.value;
    String content = 'Подключено: $deviceName | Батарея: ${status?.batteryPercent ?? "---"}%';
    FlutterBackgroundService().invoke('updateNotification', {'content': content});
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    await FlutterBluePlus.stopScan();
    isScanning.value = false;
    AppLogger.logInfo('Попытка подключения к ${device.remoteId}...');
    
    try {
      await device.connect(license: License.free, autoConnect: false);
      _connectedDevice = device;
      
      String platformName = device.platformName.isEmpty ? device.advName : device.platformName;
      
      if (platformName.isNotEmpty) {
        connectedDeviceName.value = platformName;
        AppSettings().setSavedDongleId(device.remoteId.toString());
        AppSettings().setSavedDongleName(platformName);
      } else {
        connectedDeviceName.value = AppSettings().savedDongleName;
      }
      
      isConnected.value = true;
      isReconnecting.value = false;
      
      AppLogger.logInfo('Подключение успешно. Запрос MTU и поиск сервисов...');
      
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
        AppLogger.logInfo('Характеристики найдены. Подписка на уведомления...');
        await _txCharacteristic!.setNotifyValue(true);
        _txCharacteristic!.lastValueStream.listen(_handleIncomingData);
        _requestIdentity();
        
        FlutterBackgroundService().startService();
        Future.delayed(const Duration(seconds: 1), _updateBackgroundNotification);
      } else {
        AppLogger.logError('Не найдены нужные характеристики (TX/RX)');
      }

      _setupConnectionListener(device);

    } catch (e) {
      isConnected.value = false;
      AppLogger.logError('Ошибка подключения: $e');
    }
  }

  void _setupConnectionListener(BluetoothDevice device) {
    _connectionStateSubscription?.cancel();
    _connectionStateSubscription = device.connectionState.listen((state) {
      if (state == BluetoothConnectionState.disconnected) {
        if (AppSettings().savedDongleId.isNotEmpty && isConnected.value) {
          isReconnecting.value = true;
          isConnected.value = false;
          
          _rxCharacteristic = null;
          _txCharacteristic = null;
          identityNotifier.value = null;
          sysConfigNotifier.value = null;
          
          AppLogger.logError('Аварийный обрыв связи! Запуск фонового автопереподключения...');
          _attemptReconnect();
        }
      }
    });
  }

  Future<void> _attemptReconnect() async {
    int attemptCount = 0; // ИЗМЕНЕНИЕ 1.41.5: Локальный счетчик попыток реконнекта
    
    while (AppSettings().savedDongleId.isNotEmpty && !isConnected.value) {
      await Future.delayed(const Duration(seconds: 4));
      if (AppSettings().savedDongleId.isEmpty || isConnected.value) break;

      AppLogger.logInfo('Попытка восстановления связи с Донглом (Попытка №${attemptCount + 1})...');
      try {
        final device = BluetoothDevice.fromId(AppSettings().savedDongleId);
        await device.connect(license: License.free, autoConnect: false, timeout: const Duration(seconds: 5));
        
        _connectedDevice = device;
        connectedDeviceName.value = AppSettings().savedDongleName;
        isConnected.value = true;
        isReconnecting.value = false;

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
          
          // ИЗМЕНЕНИЕ 1.41.5: Безопасный опрос устройства после восстановления связи
          _requestIdentity(); // Запрашиваем имя и актуальный ID всегда
          
          if (attemptCount >= 5) {
            // Если Донгл отсутствовал долго, докачиваем всю топологию сети
            requestFullSync(); 
          }
          
          FlutterBackgroundService().startService();
          Future.delayed(const Duration(seconds: 1), _updateBackgroundNotification);
        }
        
        _setupConnectionListener(device);
        AppLogger.logInfo('Связь с Донглом успешно восстановлена на лету.');
        break;
      } catch (e) {
        attemptCount++; // ИЗМЕНЕНИЕ 1.41.5: Инкремент при неудаче
        AppLogger.logError('Неудачный автореконнект: $e. Ожидание следующего цикла...');
      }
    }
  }

  String _getCommandName(int opCode) {
    switch (opCode) {
      case BleOpCode.cmdReqIdentity: return 'cmdReqIdentity (0x06)';
      case BleOpCode.cmdReqSysConfig: return 'cmdReqSysConfig (0x07)';
      case BleOpCode.cmdReqFullSync: return 'cmdReqFullSync (0x05)';
      case BleOpCode.cmdSetIdentity: return 'cmdSetIdentity (0x01)';
      case BleOpCode.cmdSetSysConfig: return 'cmdSetSysConfig (0x02)';
      case BleOpCode.cmdActionReset: return 'cmdActionReset (0x03)';
      case BleOpCode.cmdSetAnchorCoords: return 'cmdSetAnchorCoords (0x08)';
      default: return 'Неизвестная команда (0x${opCode.toRadixString(16)})';
    }
  }

  Future<void> _sendCommand(List<int> data) async {
    if (_rxCharacteristic == null) return;
    if (data.isNotEmpty && data[0] != BleOpCode.cmdSetAnchorCoords) {
      AppLogger.logTx(_getCommandName(data[0]));
    }
    try {
      bool withoutResp = _rxCharacteristic!.properties.writeWithoutResponse;
      await _rxCharacteristic!.write(data, withoutResponse: withoutResp);
    } catch (e) {
      AppLogger.logError('Ошибка при отправке команды: $e');
    }
  }

  void _requestIdentity() => _sendCommand([BleOpCode.cmdReqIdentity]);
  void _requestSysConfig() => _sendCommand([BleOpCode.cmdReqSysConfig]);
  void requestFullSync() => _sendCommand([BleOpCode.cmdReqFullSync]);

  Future<void> sendAnchorCoords() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        AppLogger.logError('Геолокация на смартфоне отключена в настройках ОС.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          AppLogger.logError('Пользователь отклонил запрос разрешений геолокации.');
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        AppLogger.logError('Разрешения геолокации заблокированы навсегда в настройках смартфона.');
        return;
      }

      AppLogger.logInfo('Запрос точных координат смартфона...');
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );

      final payload = Uint8List(9);
      final byteData = ByteData.view(payload.buffer);
      byteData.setUint8(0, BleOpCode.cmdSetAnchorCoords);
      byteData.setFloat32(1, position.latitude, Endian.little);
      byteData.setFloat32(5, position.longitude, Endian.little);

      AppLogger.logTxAnchorCoords(position.latitude, position.longitude);
      await _sendCommand(payload.toList());

      Future.delayed(const Duration(milliseconds: 500), requestFullSync);
    } catch (e) {
      AppLogger.logError('Исключение при отправке опорных координат: $e');
    }
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
      AppLogger.logError('Ошибка CMD_SET_IDENTITY: $e');
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
      AppLogger.logError('Ошибка CMD_SET_SYS_CONFIG: $e');
    }
  }

  Future<void> factoryReset() async {
    try {
      await _sendCommand([BleOpCode.cmdActionReset]);
      await disconnect();
    } catch (e) {
      AppLogger.logError('Ошибка Factory Reset: $e');
    }
  }

  void _handleIncomingData(List<int> data) {
    if (data.isEmpty) return;
    int opCode = data[0];
    int? myId = identityNotifier.value?.myNodeId;
    
    try {
      switch (opCode) {
        case BleOpCode.evtIdentity:
          final pkt = BleIdentity.fromBytes(data);
          AppLogger.logRxIdentity(pkt);
          int? oldId = myId;
          identityNotifier.value = pkt;
          nodeDatabase.initLocalNode(pkt, oldId);

          if (sysConfigNotifier.value == null) {
            _requestSysConfig();
          } else {
            nodeDatabase.startGarbageCollector(sysConfigNotifier.value!.nodeActiveTimeoutMs, identityNotifier.value?.myNodeId);
          }
          break;
          
        case BleOpCode.evtSysConfig:
          final config = BleSysConfig.fromBytes(data);
          AppLogger.logRxSysConfig(config);
          sysConfigNotifier.value = config;
          nodeDatabase.startGarbageCollector(config.nodeActiveTimeoutMs, myId);
          requestFullSync();
          break;
          
        case BleOpCode.evtMyStatus:
          final pkt = BleEvtMyStatus.fromBytes(data);
          AppLogger.logRxMyStatus(pkt);
          myStatusNotifier.value = pkt;
          _updateBackgroundNotification();
          break;
          
        case BleOpCode.evtNodeUpdate:
          final pkt = BleEvtNodeUpdate.fromBytes(data);
          AppLogger.logRxNodeUpdate(pkt);
          nodeDatabase.updateNodeFull(pkt, myId);
          break;
          
        case BleOpCode.evtNodeDelete:
          final pkt = BleEvtNodeDelete.fromBytes(data);
          AppLogger.logInfo('⬅ 0x14 (EVT_NODE_DELETE) | Удаление узла: ${pkt.nodeId}');
          nodeDatabase.deleteNode(pkt.nodeId);
          break;
          
        case BleOpCode.evtNodeCoords:
          final pkt = BleEvtNodeCoords.fromBytes(data);
          AppLogger.logRxNodeCoords(pkt);
          nodeDatabase.updateNodeCoords(pkt, myId);
          break;
          
        case BleOpCode.evtNodeInfo:
          final pkt = BleEvtNodeInfo.fromBytes(data);
          AppLogger.logRxNodeInfo(pkt);
          nodeDatabase.updateNodeInfo(pkt, myId);
          break;
          
        default:
          AppLogger.logError('Получен неизвестный код операции: 0x${opCode.toRadixString(16)}');
      }
    } catch (e) {
      AppLogger.logError('Ошибка парсинга пакета 0x${opCode.toRadixString(16)}: $e');
    }
  }

  Future<void> disconnect() async {
    AppLogger.logInfo('Отключение от устройства...');
    
    AppSettings().setSavedDongleId('');
    AppSettings().setSavedDongleName('');
    
    _connectionStateSubscription?.cancel();
    _connectionStateSubscription = null;
    isReconnecting.value = false;

    FlutterBackgroundService().invoke('stopService');

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
    AppLogger.logInfo('Сессия завершена, данные очищены.');
  }
}