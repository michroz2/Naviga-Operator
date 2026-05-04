/*
 * Файл: ble_service.dart
 * Версия: 1.3
 * Изменения: Добавлена функция отправки команд (write) и первичный парсинг входящих пакетов.
 * Описание: Класс-синглтон для управления модулем Bluetooth.
 *           Осуществляет поиск, подключение, подписку на TX и отправку базовых команд в RX.
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

  Future<void> scanAndConnect() async {
    await _scanSubscription?.cancel();
    debugPrint('Запуск сканирования BLE...');
    
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));

    _scanSubscription = FlutterBluePlus.scanResults.listen((results) async {
      for (ScanResult r in results) {
        String deviceName = r.device.platformName.isEmpty ? r.device.advName : r.device.platformName;

        if (deviceName.startsWith(BleConfig.deviceNamePrefix)) {
          debugPrint('Найдено устройство Naviga: $deviceName (MAC: ${r.device.remoteId})');
          await FlutterBluePlus.stopScan();
          await _connectToDevice(r.device);
          break;
        }
      }
    });
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      debugPrint('Попытка подключения к ${device.remoteId}...');
      await device.connect(license: License.free, autoConnect: false);
      _connectedDevice = device;
      debugPrint('Успешное подключение!');

      if (defaultTargetPlatform == TargetPlatform.android) {
        await device.requestMtu(128); // MTU 128 с запасом[cite: 4]
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

        // Запуск сценария UC-04: Запрашиваем Identity[cite: 1, 4]
        _requestIdentity();

      } else {
        debugPrint('ОШИБКА: RX или TX характеристика не найдена!');
      }
    } catch (e) {
      debugPrint('Ошибка при подключении: $e');
    }
  }

  /// Отправка массива байт в RX-характеристику Донгла
  Future<void> _sendCommand(List<int> data) async {
    if (_rxCharacteristic == null) return;
    try {
      // Используем withoutResponse, если характеристика это поддерживает[cite: 4]
      bool withoutResp = _rxCharacteristic!.properties.writeWithoutResponse;
      await _rxCharacteristic!.write(data, withoutResponse: withoutResp);
      debugPrint('>>> Отправлено в RX: $data');
    } catch (e) {
      debugPrint('Ошибка при отправке: $e');
    }
  }

  /// Запрос идентификации (Имя, Роль, ID)[cite: 4]
  void _requestIdentity() {
    debugPrint('Запрос Identity (OpCode 0x06)...');
    _sendCommand([BleOpCode.cmdReqIdentity]);
  }

  /// Запрос системных настроек (Таймеры)[cite: 4]
  void _requestSysConfig() {
    debugPrint('Запрос SysConfig (OpCode 0x07)...');
    _sendCommand([BleOpCode.cmdReqSysConfig]);
  }

  /// Обработчик входящих байтов из потока NOTIFY
  void _handleIncomingData(List<int> data) {
    if (data.isEmpty) return;
    
    int opCode = data[0];
    
    try {
      if (opCode == BleOpCode.evtIdentity) {
        final identity = BleIdentity.fromBytes(data);
        debugPrint('<<< Получен EVT_IDENTITY: ID=${identity.myNodeId}, Имя=${identity.myName}, Роль=${identity.myRole}');
        
        // После получения Identity сразу запрашиваем таймеры[cite: 4]
        _requestSysConfig();
      } 
      else if (opCode == BleOpCode.evtSysConfig) {
        final config = BleSysConfig.fromBytes(data);
        debugPrint('<<< Получен EVT_SYS_CONFIG: Moving=${config.txIntervalMoving}мс, Still=${config.txIntervalStill}мс');
        debugPrint('--- СОПРЯЖЕНИЕ УСПЕШНО ЗАВЕРШЕНО ---');
      } 
      else {
        debugPrint('<<< Получен неизвестный/другой пакет (OpCode: 0x${opCode.toRadixString(16)}, Размер: ${data.length} байт)');
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
    debugPrint('Устройство отключено');
  }
}