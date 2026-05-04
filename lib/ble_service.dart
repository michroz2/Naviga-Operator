/*
 * Файл: ble_service.dart
 * Версия: 1.5
 * Изменения: Разделена логика сканирования и подключения. Добавлен сбор списка устройств с фильтрацией и сортировкой по RSSI.
 * Описание: Класс-синглтон для управления модулем Bluetooth.
 */

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'ble_protocol.dart';

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
  // Новый уведомитель для списка найденных устройств
  final ValueNotifier<List<ScanResult>> scanResultsNotifier = ValueNotifier([]);
  
  final ValueNotifier<BleIdentity?> identityNotifier = ValueNotifier(null);
  final ValueNotifier<BleSysConfig?> sysConfigNotifier = ValueNotifier(null);

  /// Запуск сканирования (без автоматического подключения)
  Future<void> startScan() async {
    await _scanSubscription?.cancel();
    scanResultsNotifier.value = []; // Очищаем старый список
    isScanning.value = true;
    debugPrint('Запуск сканирования BLE...');
    
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));

    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      // Фильтруем устройства по префиксу "Naviga-"
      List<ScanResult> navigaDevices = results.where((r) {
        String deviceName = r.device.platformName.isEmpty ? r.device.advName : r.device.platformName;
        return deviceName.startsWith(BleConfig.deviceNamePrefix);
      }).toList();

      // Сортируем по силе сигнала (от сильного к слабому: -50 сильнее, чем -90)
      navigaDevices.sort((a, b) => b.rssi.compareTo(a.rssi));

      // Обновляем UI
      scanResultsNotifier.value = navigaDevices;
    });

    Future.delayed(const Duration(seconds: 15), () {
      if (isScanning.value) isScanning.value = false;
    });
  }

  /// Ручное подключение к выбранному устройству из списка
  Future<void> connectToDevice(BluetoothDevice device) async {
    // Останавливаем сканирование перед подключением
    await FlutterBluePlus.stopScan();
    isScanning.value = false;

    try {
      debugPrint('Попытка подключения к ${device.remoteId}...');
      await device.connect(license: License.free, autoConnect: false);
      _connectedDevice = device;
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
      debugPrint('>>> Отправлено в RX: $data');
    } catch (e) {
      debugPrint('Ошибка при отправке: $e');
    }
  }

  void _requestIdentity() {
    debugPrint('Запрос Identity (OpCode 0x06)...');
    _sendCommand([BleOpCode.cmdReqIdentity]);
  }

  void _requestSysConfig() {
    debugPrint('Запрос SysConfig (OpCode 0x07)...');
    _sendCommand([BleOpCode.cmdReqSysConfig]);
  }

  void _handleIncomingData(List<int> data) {
    if (data.isEmpty) return;
    
    int opCode = data[0];
    
    try {
      if (opCode == BleOpCode.evtIdentity) {
        final identity = BleIdentity.fromBytes(data);
        debugPrint('<<< Получен EVT_IDENTITY: ID=${identity.myNodeId}');
        identityNotifier.value = identity; 
        _requestSysConfig();
      } 
      else if (opCode == BleOpCode.evtSysConfig) {
        final config = BleSysConfig.fromBytes(data);
        debugPrint('<<< Получен EVT_SYS_CONFIG: Moving=${config.txIntervalMoving}мс');
        sysConfigNotifier.value = config; 
      }
    } catch (e) {
      debugPrint('Ошибка парсинга пакета: $e');
    }
  }

  Future<void> disconnect() async {
    await _connectedDevice?.disconnect();
    _connectedDevice = null;
    _rxCharacteristic = null;
    _txCharacteristic = null;
    
    isConnected.value = false;
    isScanning.value = false;
    scanResultsNotifier.value = []; // Очищаем список после отключения
    identityNotifier.value = null;
    sysConfigNotifier.value = null;
    
    debugPrint('Устройство отключено');
  }
}