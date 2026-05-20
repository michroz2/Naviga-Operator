# Project: Naviga_Operator Snapshot V1.29

## File: .\analysis_options.yaml
```yaml
# This file configures the analyzer, which statically analyzes Dart code to
# check for errors, warnings, and lints.
#
# The issues identified by the analyzer are surfaced in the UI of Dart-enabled
# IDEs (https://dart.dev/tools#ides-and-editors). The analyzer can also be
# invoked from the command line by running `flutter analyze`.

# The following line activates a set of recommended lints for Flutter apps,
# packages, and plugins designed to encourage good coding practices.
include: package:flutter_lints/flutter.yaml

linter:
  # The lint rules applied to this project can be customized in the
  # section below to disable rules from the `package:flutter_lints/flutter.yaml`
  # included above or to enable additional rules. A list of all available lints
  # and their documentation is published at https://dart.dev/lints.
  #
  # Instead of disabling a lint rule for the entire project in the
  # section below, it can also be suppressed for a single line of code
  # or a specific dart file by using the `// ignore: name_of_lint` and
  # `// ignore_for_file: name_of_lint` syntax on the line or in the file
  # producing the lint.
  rules:
    # avoid_print: false  # Uncomment to disable the `avoid_print` rule
    # prefer_single_quotes: true  # Uncomment to enable the `prefer_single_quotes` rule

# Additional information about this file can be found at
# https://dart.dev/guides/language/analysis-options

```

---

## File: .\pubspec.yaml
```yaml
# Файл: pubspec.yaml
# Версия: 1.18
# Изменения: Разрешение конфликта зависимостей. Даунгрейд latlong2 до ^0.9.1 для совместимости с flutter_map ^6.1.0.
# Описание: Конфигурация пакетов, ресурсов и зависимостей проекта.

name: naviga_operator
description: "A new Flutter project."
# The following line prevents the package from being accidentally published to
# pub.dev using `flutter pub publish`. This is preferred for private packages.
publish_to: 'none' # Remove this line if you wish to publish to pub.dev

# The following defines the version and build number for your application.
# A version number is three numbers separated by dots, like 1.2.43
# followed by an optional build number separated by a +.
# Both the version and the builder number may be overridden in flutter
# build by specifying --build-name and --build-number, respectively.
# In Android, build-name is used as versionName while build-number used as versionCode.
# Read more about Android versioning at https://developer.android.com/studio/publish/versioning
# In iOS, build-name is used as CFBundleShortVersionString while build-number is used as CFBundleVersion.
# Read more about iOS versioning at
# https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/CoreFoundationKeys.html
# In Windows, build-name is used as the major, minor, and patch parts
# of the product and file versions while build-number is used as the build suffix.
version: 1.0.0+1

environment:
  sdk: ^3.11.5

# Dependencies specify other packages that your package needs in order to work.
# To automatically upgrade your package dependencies to the latest versions
# consider running `flutter pub upgrade --major-versions`. Alternatively,
# dependencies can be manually updated by changing the version numbers below to
# the latest version available on pub.dev. To see which dependencies have newer
# versions available, run `flutter pub outdated`.
dependencies:
  flutter:
    sdk: flutter

  # The following adds the Cupertino Icons font to your application.
  # Use with the CupertinoIcons class for iOS style icons.
  cupertino_icons: ^1.0.8
  flutter_blue_plus: ^2.2.1
  permission_handler: ^12.0.1
  latlong2: ^0.9.1
  flutter_map: ^6.1.0
  http: ^1.2.0
  geolocator: ^14.0.2
  flutter_background_service: ^5.0.5
  flutter_local_notifications: ^17.1.2

dev_dependencies:
  flutter_test:
    sdk: flutter

  # The "flutter_lints" package below contains a set of recommended lints to
  # encourage good coding practices. The lint set provided by the package is
  # activated in the `analysis_options.yaml` file located at the root of your
  # package. See that file for information about deactivating specific lint
  # rules and activating additional ones.
  flutter_lints: ^6.0.0

# For information on the generic Dart part of this file, see the
# following page: https://dart.dev/tools/pub/pubspec

# The following section is specific to Flutter packages.
flutter:

  # The following line ensures that the Material Icons font is
  # included with your application, so that you can use the icons in
  # the material Icons class.
  uses-material-design: true

  # To add assets to your application, add an assets section, like this:
  # assets:
  #   - images/a_dot_burr.jpeg
  #   - images/a_dot_ham.jpeg

  # An image asset can refer to one or more resolution-specific "variants", see
  # https://flutter.dev/to/resolution-aware-images

  # For details regarding adding assets from package dependencies, see
  # https://flutter.dev/to/asset-from-package

  # To add custom fonts to your application, add a fonts section here,
  # in this "flutter" section. Each entry in this list should have a
  # "family" key with the font family name, and a "fonts" key with a
  # list giving the asset and other descriptors for the font. For
  # example:
  # fonts:
  #   - family: Schyler
  #     fonts:
  #       - asset: fonts/Schyler-Regular.ttf
  #       - asset: fonts/Schyler-Italic.ttf
  #         style: italic
  #   - family: Trajan Pro
  #     fonts:
  #       - asset: fonts/TrajanPro.ttf
  #       - asset: fonts/TrajanPro_Bold.ttf
  #         weight: 700
  #
  # For details regarding fonts from package dependencies,
  # see https://flutter.dev/to/font-from-package
```

---

## File: .\lib\main.dart
```dart
/*
 * Файл: main.dart
 * Версия: 1.29
 * Изменения: ЭТАП 4, Шаг 15 (Путь А). Добавлена инициализация приоритетной фоновой службы (BackgroundManager) перед запуском корневого виджета. Исправлена опечатка WidgetsFlutterBinding.
 * Описание: Главная точка входа в приложение с поддержкой фонового режима.
 */

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'app_config.dart';
import 'scanner_screen.dart';
import 'background_manager.dart';

void main() async {
  // Гарантируем инициализацию фреймворка перед обращением к нативным плагинам
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализируем конфигурацию фонового сервиса
  await BackgroundManager.initializeService();

  // Настройка логгера Bluetooth
  FlutterBluePlus.setLogLevel(LogLevel.error, color: false);

  print('\n=========================================');
  print('===== ОПЕРАТОР START version ${AppConfig.version} =====');
  print('=========================================\n');
  
  runApp(const NavigaTestApp());
}

class NavigaTestApp extends StatelessWidget {
  const NavigaTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Naviga Operator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: const ScannerScreen(), 
    );
  }
}
```

---

## File: .\lib\ble_protocol.dart
```dart
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
```

---

## File: .\lib\ble_service.dart
```dart
/*
 * Файл: ble_service.dart
 * Версия: 1.29
 * Изменения: ЭТАП 4, Шаг 15 (Путь А). Добавлены триггеры запуска и остановки приоритетной фоновой службы (FlutterBackgroundService) для поддержания жизни главного потока при заблокированном экране смартфона.
 * Описание: BLE-сервис управления соединением и диспетчеризации пакетов.
 */

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_background_service/flutter_background_service.dart'; // ИЗМЕНЕНИЕ 1.29
import 'ble_protocol.dart';
import 'node_database.dart';
import 'app_logger.dart';

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

  Future<void> connectToDevice(BluetoothDevice device) async {
    await FlutterBluePlus.stopScan();
    isScanning.value = false;
    AppLogger.logInfo('Попытка подключения к ${device.remoteId}...');
    
    try {
      await device.connect(license: License.free, autoConnect: false);
      _connectedDevice = device;
      connectedDeviceName.value = device.platformName.isEmpty ? device.advName : device.platformName;
      isConnected.value = true;
      
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
        
        // ИЗМЕНЕНИЕ 1.29: Запуск фонового сервиса (Wakelock щит) при успешном подключении
        FlutterBackgroundService().startService();
      } else {
        AppLogger.logError('Не найдены нужные характеристики (TX/RX)');
      }
    } catch (e) {
      isConnected.value = false;
      AppLogger.logError('Ошибка подключения: $e');
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
    
    // ИЗМЕНЕНИЕ 1.29: Остановка фонового сервиса перед разрывом связи
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
```

---

## File: .\lib\node_database.dart
```dart
/*
 * Файл: node_database.dart
 * Версия: 1.27
 * Изменения: ЭТАП 4, Шаг 12. Внедрение структуры TrackPoint и кольцевого буфера истории перемещений (track). Добавлен анти-джиттер фильтр (10м) с инициализацией через 50 фиктивных нулевых точек.
 * Описание: Центральная база данных Roster с поддержкой трекинга.
 */

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'ble_protocol.dart';

// ============================================================================
// Структура точки для хвоста истории (Track)
// ============================================================================
class TrackPoint {
  final double lat;
  final double lon;
  final int timestampMs;

  TrackPoint({required this.lat, required this.lon, required this.timestampMs});
}

// ============================================================================
// Запись Узла
// ============================================================================
class NodeRecord {
  final int nodeId;
  int role;         
  String nodeName;  
  double lat;       
  double lon;       
  double snr;       
  
  int lastSeenTimeMs; // Абсолютное Unix-время последнего контакта
  
  double distance; 
  double azimuth;

  // ИЗМЕНЕНИЕ 1.27: Кольцевой буфер истории координат
  List<TrackPoint> track = [];
  static const int maxTrackPoints = 50;
  static const double trackJitterMeters = 10.0;

  bool get hasValidGps => lat != 0.0 && lon != 0.0;

  NodeRecord({
    required this.nodeId,
    required this.role,
    required this.nodeName,
    required this.lat,
    required this.lon,
    required this.snr,
    required this.lastSeenTimeMs,
    this.distance = 0.0,
    this.azimuth = 0.0,
  });

  // ИЗМЕНЕНИЕ 1.27: Метод добавления точки в трек с анти-джиттером
  void _addPointToTrack(double newLat, double newLon, int timestamp) {
    if (newLat == 0.0 || newLon == 0.0) return;

    final newPoint = LatLng(newLat, newLon);

    // 1. Инициализация буфера (50 нулевых клонов + 1 актуальный)
    if (track.isEmpty) {
      for (int i = 0; i < maxTrackPoints - 1; i++) {
        track.add(TrackPoint(lat: newLat, lon: newLon, timestampMs: 0));
      }
      track.add(TrackPoint(lat: newLat, lon: newLon, timestampMs: timestamp));
      return;
    }

    // 2. Анти-джиттер: проверка дистанции до последней добавленной точки (track.last)
    // Благодаря инициализации 50 клонами, track.last всегда существует.
    final lastPoint = LatLng(track.last.lat, track.last.lon);
    final distToLast = Distance().as(LengthUnit.Meter, lastPoint, newPoint).toDouble();

    // Если ушли дальше порога - сдвигаем буфер
    if (distToLast >= trackJitterMeters) {
      track.removeAt(0); // Удаляем самую старую
      track.add(TrackPoint(lat: newLat, lon: newLon, timestampMs: timestamp));
    }
  }

  // Вспомогательный метод для получения актуального хвоста для отрисовки
  List<LatLng> getRecentTrack(int maxAgeMs) {
    if (track.isEmpty) return [];
    final now = DateTime.now().millisecondsSinceEpoch;
    return track
        .where((p) => p.timestampMs != 0 && (now - p.timestampMs) <= maxAgeMs)
        .map((p) => LatLng(p.lat, p.lon))
        .toList();
  }
}

// ============================================================================
// База Данных Узлов
// ============================================================================
class NodeDatabase extends ChangeNotifier {
  final Map<int, NodeRecord> _nodes = {};
  Timer? _gcTimer;

  Map<int, NodeRecord> get nodes => Map.unmodifiable(_nodes);

  int getNeighborsCount(int? myNodeId) {
    if (myNodeId == null) return _nodes.length;
    return _nodes.containsKey(myNodeId) ? _nodes.length - 1 : _nodes.length;
  }

  bool get hasAnyValidGps => _nodes.values.any((n) => n.hasValidGps);

  void initLocalNode(BleIdentity identity, int? oldNodeId) {
    final newId = identity.myNodeId;
    
    if (oldNodeId != null && oldNodeId != newId) {
      _nodes.remove(oldNodeId);
      debugPrint('NodeDatabase: ID изменен с $oldNodeId на $newId. Старый узел удален.');
    }
    
    final now = DateTime.now().millisecondsSinceEpoch;
    
    if (_nodes.containsKey(newId)) {
      _nodes[newId]!.nodeName = identity.myName;
      _nodes[newId]!.role = identity.myRole;
      _nodes[newId]!.lastSeenTimeMs = now;
    } else {
      _nodes[newId] = NodeRecord(
        nodeId: newId,
        role: identity.myRole,
        nodeName: identity.myName,
        lat: 0.0,
        lon: 0.0,
        snr: 0.0,
        lastSeenTimeMs: now,
      );
    }
    notifyListeners();
  }

  void startGarbageCollector(int activeTimeoutMs, int? currentMyNodeId) {
    _gcTimer?.cancel();
    _gcTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final List<int> toDelete = [];

      _nodes.forEach((id, node) {
        if (id == currentMyNodeId) return; 

        if ((now - node.lastSeenTimeMs) > activeTimeoutMs) {
          toDelete.add(id);
        }
      });

      bool hasChanges = false;
      for (var id in toDelete) {
        _nodes.remove(id);
        debugPrint('NodeDatabase GC: Узел $id удален по таймауту');
        hasChanges = true;
      }

      if (hasChanges) notifyListeners();
    });
  }

  void updateNodeFull(BleEvtNodeUpdate update, int? myNodeId) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final normalizedTime = now - update.lastSeenAge;

    if (_nodes.containsKey(update.nodeId)) {
      final node = _nodes[update.nodeId]!;
      node.role = update.nodeRole;
      node.nodeName = update.nodeName;
      node.lat = update.lat;
      node.lon = update.lon;
      node.snr = update.snr;
      node.lastSeenTimeMs = normalizedTime;
      node._addPointToTrack(update.lat, update.lon, normalizedTime); // ИЗМЕНЕНИЕ 1.27
    } else {
      final node = NodeRecord(
        nodeId: update.nodeId,
        role: update.nodeRole,
        nodeName: update.nodeName,
        lat: update.lat,
        lon: update.lon,
        snr: update.snr,
        lastSeenTimeMs: normalizedTime,
      );
      node._addPointToTrack(update.lat, update.lon, normalizedTime); // ИЗМЕНЕНИЕ 1.27
      _nodes[update.nodeId] = node;
    }
    _runGeometryUpdate(update.nodeId, myNodeId);
    notifyListeners();
  }

  void updateNodeCoords(BleEvtNodeCoords update, int? myNodeId) {
    final now = DateTime.now().millisecondsSinceEpoch;

    if (_nodes.containsKey(update.nodeId)) {
      final node = _nodes[update.nodeId]!;
      node.lat = update.lat;
      node.lon = update.lon;
      node.snr = update.snr;
      node.lastSeenTimeMs = now; 
      node._addPointToTrack(update.lat, update.lon, now); // ИЗМЕНЕНИЕ 1.27
    } else {
      final node = NodeRecord(
        nodeId: update.nodeId,
        role: 1, 
        nodeName: "Node ${update.nodeId}",
        lat: update.lat,
        lon: update.lon,
        snr: update.snr,
        lastSeenTimeMs: now,
      );
      node._addPointToTrack(update.lat, update.lon, now); // ИЗМЕНЕНИЕ 1.27
      _nodes[update.nodeId] = node;
    }
    _runGeometryUpdate(update.nodeId, myNodeId);
    notifyListeners();
  }

  void updateNodeInfo(BleEvtNodeInfo update, int? myNodeId) {
    final now = DateTime.now().millisecondsSinceEpoch;

    if (_nodes.containsKey(update.nodeId)) {
      final node = _nodes[update.nodeId]!;
      node.role = update.nodeRole;
      node.nodeName = update.nodeName;
      node.lastSeenTimeMs = now;
    } else {
      _nodes[update.nodeId] = NodeRecord(
        nodeId: update.nodeId,
        role: update.nodeRole,
        nodeName: update.nodeName,
        lat: 0.0,
        lon: 0.0,
        snr: 0.0,
        lastSeenTimeMs: now,
      );
    }
    notifyListeners();
  }

  void _runGeometryUpdate(int updatedId, int? myNodeId) {
    if (myNodeId == null) return;
    if (updatedId == myNodeId) {
      _recalculateAllDistances(myNodeId);
    } else {
      if (_nodes.containsKey(myNodeId)) {
        _calcDistanceAndAzimuth(_nodes[myNodeId]!, _nodes[updatedId]!);
      }
    }
  }

  void deleteNode(int nodeId) {
    if (_nodes.containsKey(nodeId)) {
      _nodes.remove(nodeId);
      notifyListeners();
    }
  }

  void clear() {
    _gcTimer?.cancel();
    _nodes.clear();
    notifyListeners();
  }

  void _calcDistanceAndAzimuth(NodeRecord me, NodeRecord other) {
    if (me.hasValidGps && other.hasValidGps) {
      final myLatLng = LatLng(me.lat, me.lon);
      final otherLatLng = LatLng(other.lat, other.lon);
      other.distance = Distance().as(LengthUnit.Meter, myLatLng, otherLatLng).toDouble();
      other.azimuth = Distance().bearing(myLatLng, otherLatLng);
      if (other.azimuth < 0) other.azimuth += 360.0;
    } else {
      other.distance = 0.0;
      other.azimuth = 0.0;
    }
  }

  void _recalculateAllDistances(int myNodeId) {
    final myNode = _nodes[myNodeId];
    if (myNode == null) return;
    for (var node in _nodes.values) {
      if (node.nodeId != myNodeId) {
        _calcDistanceAndAzimuth(myNode, node);
      }
    }
  }
}
```

---

## File: .\lib\roster_screen.dart
```dart
/*
 * Файл: roster_screen.dart
 * Версия: 1.16
 * Изменения: Динамическое вычисление статуса Offline на основе lastSeenTimeMs. Визуализация потери связи.
 */

import 'package:flutter/material.dart';
import 'ble_service.dart';
import 'node_database.dart';

class RosterScreen extends StatelessWidget {
  const RosterScreen({super.key});

  IconData _getRoleIcon(int role, bool isMe) {
    if (isMe) return Icons.person_pin;
    switch (role) {
      case 0: return Icons.cell_tower;
      case 1: return Icons.directions_walk;
      case 2: return Icons.gps_fixed;
      default: return Icons.device_unknown;
    }
  }

  String _getRoleName(int roleCode) {
    switch (roleCode) {
      case 0: return 'Ретранслятор';
      case 1: return 'Сталкер';
      case 2: return 'Трекер';
      default: return 'Неизвестно';
    }
  }

  String _getDistanceText(NodeRecord node, bool isMe, bool hasMyGps, bool isOnline) {
    if (isMe) return 'Мой узел (Я)';
    if (!isOnline) return 'Связь потеряна';
    if (!hasMyGps) return 'Ожидание нашего GPS...';
    if (node.lat == 0.0 || node.lon == 0.0) return 'Ожидание GPS узла...';
    if (node.distance < 20.0) return 'Рядом (< 20 м)';
    
    return '~ ${node.distance.toStringAsFixed(0)} м | Азимут: ${node.azimuth.toStringAsFixed(0)}°';
  }

  @override
  Widget build(BuildContext context) {
    final bleService = BleService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Топология Сети'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([
          bleService.nodeDatabase, 
          bleService.identityNotifier,
          bleService.sysConfigNotifier, // ИЗМЕНЕНИЕ 1.16: Подписка на конфиг для таймаута
        ]),
        builder: (context, child) {
          final nodesMap = bleService.nodeDatabase.nodes;
          final myNodeId = bleService.identityNotifier.value?.myNodeId;
          
          final connTimeoutMs = bleService.sysConfigNotifier.value?.nodeConnectionTimeout ?? 600000;
          final now = DateTime.now().millisecondsSinceEpoch;

          if (nodesMap.isEmpty) {
            return const Center(child: Text('База узлов пуста', style: TextStyle(fontSize: 16)));
          }

          final myNode = nodesMap[myNodeId];
          final bool hasMyGps = myNode != null && myNode.lat != 0.0 && myNode.lon != 0.0;

          List<NodeRecord> sortedNodes = nodesMap.values.toList();

          sortedNodes.sort((a, b) {
            if (a.nodeId == myNodeId) return -1;
            if (b.nodeId == myNodeId) return 1;

            bool aHasGps = a.lat != 0.0 && a.lon != 0.0;
            bool bHasGps = b.lat != 0.0 && b.lon != 0.0;
            if (aHasGps && !bHasGps) return -1;
            if (!aHasGps && bHasGps) return 1;

            if (!aHasGps && !bHasGps) return a.nodeId.compareTo(b.nodeId);

            return a.distance.compareTo(b.distance);
          });

          return ListView.builder(
            itemCount: sortedNodes.length,
            itemBuilder: (context, index) {
              final node = sortedNodes[index];
              final isMe = node.nodeId == myNodeId;
              
              // ИЗМЕНЕНИЕ 1.16: Динамический статус Offline
              final isOnline = isMe ? true : (now - node.lastSeenTimeMs) <= connTimeoutMs;

              return Opacity(
                opacity: isOnline ? 1.0 : 0.4,
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  color: isMe ? Colors.blue.shade50 : null,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isMe ? Colors.blue.shade200 : (isOnline ? Colors.grey.shade300 : Colors.grey.shade400),
                      child: Icon(_getRoleIcon(node.role, isMe), color: isOnline ? Colors.black87 : Colors.black54),
                    ),
                    title: Text(
                      node.nodeName, 
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        color: isMe ? Colors.blue.shade800 : (isOnline ? Colors.black : Colors.black54)
                      )
                    ),
                    subtitle: Text(
                      _getDistanceText(node, isMe, hasMyGps, isOnline),
                      style: TextStyle(color: isOnline ? Colors.black87 : Colors.red.shade900)
                    ),
                    trailing: const Icon(Icons.info_outline, color: Colors.grey),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (context) => NodeDetailsSheet(
                          node: node, 
                          isMe: isMe, 
                          roleName: _getRoleName(node.role),
                          isOnline: isOnline,
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class NodeDetailsSheet extends StatelessWidget {
  final NodeRecord node;
  final bool isMe;
  final String roleName;
  final bool isOnline;

  const NodeDetailsSheet({
    super.key, 
    required this.node, 
    required this.isMe, 
    required this.roleName,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final secondsAgo = ((now - node.lastSeenTimeMs) / 1000).toStringAsFixed(1);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(10))),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(isMe ? Icons.person_pin : Icons.device_hub, size: 32, color: isMe ? Colors.blue : (isOnline ? Colors.black : Colors.grey)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  node.nodeName,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isOnline ? Colors.green.shade100 : Colors.red.shade100, 
                  borderRadius: BorderRadius.circular(15)
                ),
                child: Text(
                  isOnline ? 'ONLINE' : 'OFFLINE', 
                  style: TextStyle(fontWeight: FontWeight.bold, color: isOnline ? Colors.green.shade800 : Colors.red.shade800)
                ),
              ),
            ],
          ),
          const Divider(height: 30),
          
          _buildInfoRow(Icons.badge, 'Роль', roleName),
          _buildInfoRow(Icons.location_on, 'Координаты', node.lat == 0.0 ? 'Не зафиксированы' : '${node.lat.toStringAsFixed(6)}, ${node.lon.toStringAsFixed(6)}'),
          
          if (!isMe && node.lat != 0.0) ...[
            _buildInfoRow(Icons.straighten, 'Дистанция', '${node.distance.toStringAsFixed(1)} м'),
            _buildInfoRow(Icons.explore, 'Азимут', '${node.azimuth.toStringAsFixed(1)}°'),
            _buildInfoRow(Icons.signal_cellular_alt, 'Уровень сигнала (SNR)', '${node.snr} dB'),
            _buildInfoRow(Icons.access_time, 'Последний контакт', '$secondsAgo сек. назад'),
          ],
          
          if (isMe) 
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text('Это ваш собственный узел. Дистанция не применима.', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
            ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey, size: 20),
          const SizedBox(width: 12),
          Text('$label:', style: const TextStyle(fontSize: 16, color: Colors.blueGrey)),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}
```

---

## File: .\lib\map_screen.dart
```dart
/*
 * Файл: map_screen.dart
 * Версия: 1.28
 * Изменения: ЭТАП 4, Шаг 12 (UC-21). Добавлен PolylineLayer для визуализации «хвостов» перемещения узлов. Хвосты отрисовываются под маркерами с учетом ограничения по времени (30 минут).
 * Описание: Экран визуализации узлов на интерактивной карте.
 */

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'ble_service.dart';
import 'node_database.dart';
import 'roster_screen.dart'; 

// ============================================================================
// Вспомогательный класс: Управление стилями маркеров
// ============================================================================
class MarkerStyle {
  final IconData icon;
  final Color color;
  final double opacity;

  MarkerStyle({required this.icon, required this.color, required this.opacity});
}

class MarkerStyleManager {
  static MarkerStyle getStyle({
    required int role,
    required bool isMe,
    required bool isOnline,
  }) {
    IconData icon;
    Color color;

    switch (role) {
      case 0: 
        icon = Icons.cell_tower; 
        break;
      case 1: 
        icon = Icons.location_on; 
        break;
      case 2: 
        icon = Icons.gps_fixed; 
        break;
      default: 
        icon = Icons.device_unknown;
    }

    if (isMe) {
      color = Colors.red; 
    } else {
      switch (role) {
        case 0: color = Colors.purple; break;
        case 1: color = Colors.blue; break;
        case 2: color = Colors.black; break;
        default: color = Colors.blueGrey;
      }
    }

    double opacity = 1.0;
    if (!isOnline) {
      color = Colors.grey;
      opacity = 0.5; 
    }

    return MarkerStyle(icon: icon, color: color, opacity: opacity);
  }
}

// ============================================================================
// Экран Карты
// ============================================================================
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final BleService _bleService = BleService();
  final MapController _mapController = MapController();

  String _getRoleName(int roleCode) {
    switch (roleCode) {
      case 0: return 'Ретранслятор';
      case 1: return 'Сталкер';
      case 2: return 'Трекер';
      default: return 'Неизвестно';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Naviga Map'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([
          _bleService.nodeDatabase,
          _bleService.identityNotifier,
          _bleService.sysConfigNotifier,
        ]),
        builder: (context, child) {
          final nodes = _bleService.nodeDatabase.nodes.values
              .where((n) => n.hasValidGps)
              .toList();

          final myId = _bleService.identityNotifier.value?.myNodeId;
          final timeoutMs = _bleService.sysConfigNotifier.value?.nodeConnectionTimeout ?? 600000;
          final now = DateTime.now().millisecondsSinceEpoch;

          LatLng initialCenter = const LatLng(0, 0);
          if (nodes.isNotEmpty) {
            final myNode = nodes.firstWhere((n) => n.nodeId == myId, orElse: () => nodes.first);
            initialCenter = LatLng(myNode.lat, myNode.lon);
          }

          return FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: initialCenter,
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.michroz2.naviga_operator',
              ),
              // ИЗМЕНЕНИЕ 1.28: Слой полилиний (хвостов) отрисовывается ПОД маркерами
              PolylineLayer(
                polylines: nodes.map((node) {
                  final isMe = node.nodeId == myId;
                  final isOnline = isMe ? true : (now - node.lastSeenTimeMs) <= timeoutMs;
                  final style = MarkerStyleManager.getStyle(role: node.role, isMe: isMe, isOnline: isOnline);
                  
                  // Запрашиваем актуальный трек (30 минут = 1 800 000 мс)
                  final track = node.getRecentTrack(1800000);

                  return Polyline(
                    points: track,
                    strokeWidth: 4.0,
                    color: style.color.withOpacity(isOnline ? 0.6 : 0.3),
                  );
                }).where((p) => p.points.length > 1).toList(), // Выводим только если есть минимум 2 точки
              ),
              MarkerLayer(
                markers: nodes.map((node) {
                  final isMe = node.nodeId == myId;
                  final isOnline = isMe ? true : (now - node.lastSeenTimeMs) <= timeoutMs;
                  
                  final style = MarkerStyleManager.getStyle(
                    role: node.role,
                    isMe: isMe,
                    isOnline: isOnline,
                  );

                  return Marker(
                    point: LatLng(node.lat, node.lon),
                    width: 120, 
                    height: 80, 
                    child: GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (context) => NodeDetailsSheet(
                            node: node,
                            isMe: isMe,
                            roleName: _getRoleName(node.role),
                            isOnline: isOnline,
                          ),
                        );
                      },
                      child: Opacity(
                        opacity: style.opacity,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(color: Colors.black26, blurRadius: 3, offset: Offset(0, 2))
                                ],
                              ),
                              padding: const EdgeInsets.all(6),
                              child: Icon(style.icon, color: style.color, size: 28),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.85),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.black12),
                              ),
                              child: Text(
                                node.nodeName,
                                style: const TextStyle(
                                  fontSize: 11, 
                                  fontWeight: FontWeight.bold, 
                                  color: Colors.black87
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final myId = _bleService.identityNotifier.value?.myNodeId;
          final myNode = _bleService.nodeDatabase.nodes[myId];
          if (myNode != null && myNode.hasValidGps) {
            _mapController.move(LatLng(myNode.lat, myNode.lon), 16.0);
          }
        },
        tooltip: 'Найти себя',
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
```

---

## File: .\lib\map_calculator.dart
```dart
/*
 * Файл: map_calculator.dart
 * Версия: 1.22.3
 * Изменения: ЭТАП 2, Шаг 6 (Хотфикс 2). Переход на использование свойства hasValidGps.
 * Описание: Изолированная логика вычисления границ карты (Bounds) и центрирования.
 */

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'node_database.dart';

class MapCalculator {
  static const double minDeltaDegrees = 0.0018;

  static CameraFit? calculateInitialFit(Map<int, NodeRecord> nodes, int? myNodeId) {
    // 1. Отбираем только те узлы, у которых реально есть GPS (используем hasValidGps)
    final validNodes = nodes.values.where((n) => n.hasValidGps).toList();
    if (validNodes.isEmpty) return null;

    final myNode = myNodeId != null ? nodes[myNodeId] : null;
    final hasMyGps = myNode != null && myNode.hasValidGps;

    double minLat, maxLat, minLon, maxLon;

    if (hasMyGps) {
      // СЦЕНАРИЙ А: Есть наш узел. Делаем СИММЕТРИЧНЫЕ границы вокруг нас.
      double maxDLat = 0.0;
      double maxDLon = 0.0;

      for (final n in validNodes) {
        if (n.nodeId == myNodeId) continue;
        final dLat = (n.lat - myNode.lat).abs();
        final dLon = (n.lon - myNode.lon).abs();
        if (dLat > maxDLat) maxDLat = dLat;
        if (dLon > maxDLon) maxDLon = dLon;
      }

      // Применяем минимальный радиус обзора
      maxDLat = max(maxDLat, minDeltaDegrees);
      maxDLon = max(maxDLon, minDeltaDegrees);

      minLat = myNode.lat - maxDLat;
      maxLat = myNode.lat + maxDLat;
      minLon = myNode.lon - maxDLon;
      maxLon = myNode.lon + maxDLon;
    } else {
      // СЦЕНАРИЙ Б: Нашего GPS нет, но есть соседи. Обычный Bounding Box по ним.
      minLat = validNodes.first.lat;
      maxLat = validNodes.first.lat;
      minLon = validNodes.first.lon;
      maxLon = validNodes.first.lon;

      for (final n in validNodes) {
        if (n.lat < minLat) minLat = n.lat;
        if (n.lat > maxLat) maxLat = n.lat;
        if (n.lon < minLon) minLon = n.lon;
        if (n.lon > maxLon) maxLon = n.lon;
      }

      // Защита от слишком близкого расположения соседей
      if ((maxLat - minLat) < minDeltaDegrees * 2) {
        final centerLat = (maxLat + minLat) / 2;
        minLat = centerLat - minDeltaDegrees;
        maxLat = centerLat + minDeltaDegrees;
      }
      if ((maxLon - minLon) < minDeltaDegrees * 2) {
        final centerLon = (maxLon + minLon) / 2;
        minLon = centerLon - minDeltaDegrees;
        maxLon = centerLon + minDeltaDegrees;
      }
    }

    return CameraFit.bounds(
      bounds: LatLngBounds(LatLng(minLat, minLon), LatLng(maxLat, maxLon)),
      padding: const EdgeInsets.all(50.0), // Отступ от краев экрана
    );
  }
}
```

---

## File: .\lib\app_logger.dart
```dart
/*
 * Файл: app_logger.dart
 * Версия: 1.23
 * Изменения: Добавлена расшифровка 3-позиционного статуса gpsState и логгер для Anchor Coords.
 * Описание: Статический класс для human-readable вывода Bluetooth-событий в консоль.
 */

import 'package:flutter/foundation.dart';
import 'ble_protocol.dart';

class AppLogger {
  // Логирование исходящих команд (TX)
  static void logTx(String commandName) {
    debugPrint('[TX] ➔ Отправка команды: $commandName');
  }

  // ИЗМЕНЕНИЕ 1.48: Специфичный лог для отправки опорных координат
  static void logTxAnchorCoords(double lat, double lon) {
    debugPrint('[TX] ➔ 0x08 (CMD_SET_ANCHOR_COORDS) | Передача опорных координат телефона: [$lat, $lon]');
  }

  // Логирование входящих пакетов (RX)
  static void logRxIdentity(BleIdentity pkt) {
    debugPrint('[RX] ⬅ 0x12 (EVT_IDENTITY) | Мой ID: ${pkt.myNodeId}, Имя: ${pkt.myName}, Роль: ${pkt.myRole}');
  }
  
  static void logRxSysConfig(BleSysConfig pkt) {
    debugPrint('[RX] ⬅ 0x13 (EVT_SYS_CONFIG) | TX Движ: ${pkt.txIntervalMoving ~/ 1000}с, TX Стоянка: ${pkt.txIntervalStill ~/ 1000}с, Таймаут: ${pkt.nodeConnectionTimeout ~/ 1000}с');
  }

  static void logRxNodeUpdate(BleEvtNodeUpdate pkt) {
    debugPrint('[RX] ⬅ 0x11 (EVT_NODE_UPDATE) | Узел: ${pkt.nodeId}, Имя: ${pkt.nodeName}, Роль: ${pkt.nodeRole}, Координаты: [${pkt.lat}, ${pkt.lon}], SNR: ${pkt.snr}');
  }

  static void logRxMyStatus(BleEvtMyStatus pkt) {
    String gpsStr;
    // ИЗМЕНЕНИЕ 1.48: Трехпозиционный парсинг состояния
    switch (pkt.gpsState) {
      case 0: gpsStr = "Поиск (Нет фикса)"; break;
      case 1: gpsStr = "Зафиксирован (ОК)"; break;
      case 2: gpsStr = "Слепое Реле (No HW)"; break;
      default: gpsStr = "Неизвестно (${pkt.gpsState})";
    }
    debugPrint('[RX] ⬅ 0x10 (EVT_MY_STATUS) | GPS: $gpsStr (Спутников: ${pkt.satellites}), Батарея: ${pkt.batteryPercent}% (${pkt.batteryVoltage / 1000} В)');
  }

  static void logRxNodeCoords(BleEvtNodeCoords pkt) {
    debugPrint('[RX] ⬅ 0x15 (EVT_NODE_COORDS) | Узел: ${pkt.nodeId}, Координаты: [${pkt.lat}, ${pkt.lon}]');
  }

  static void logRxNodeInfo(BleEvtNodeInfo pkt) {
    debugPrint('[RX] ⬅ 0x14 (EVT_NODE_INFO) | Узел: ${pkt.nodeId}, Имя: ${pkt.nodeName}, Роль: ${pkt.nodeRole}');
  }
  
  // Общие информационные сообщения
  static void logInfo(String message) {
    debugPrint('[INFO] ℹ️ $message');
  }

  // Критические ошибки
  static void logError(String message) {
    debugPrint('[ERROR] ❌ $message');
  }
}
```

---

## File: .\lib\app_config.dart
```dart
/*
 * Файл: app_config.dart
 * Версия: 1.26
 * Изменения: ЭТАП 4, Шаг 1 (Рефакторинг ядра). Создан единый источник правды (Single Source of Truth) для версии и глобальных констант.
 * Описание: Файл конфигурации приложения.
 */

class AppConfig {
  static const String version = '1.28';
}
```

---

## File: .\lib\scanner_screen.dart
```dart
/*
 * Файл: scanner_screen.dart
 * Версия: 1.26
 * Изменения: ЭТАП 4, Шаг 2. Выделен экран поиска и подключения. Навигация на главное меню при успешном коннекте.
 * Описание: Экран сканирования BLE устройств.
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'app_config.dart';
import 'ble_service.dart';
import 'main_menu_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final BleService _bleService = BleService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Naviga v${AppConfig.version} Подключение'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              _bleService.disconnect();
              SystemNavigator.pop();
            },
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ValueListenableBuilder<bool>(
              valueListenable: _bleService.isScanning,
              builder: (context, isScanning, child) {
                return ElevatedButton.icon(
                  onPressed: isScanning ? null : _bleService.startScan,
                  icon: isScanning 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                      : const Icon(Icons.search),
                  label: Text(isScanning ? 'Идет поиск...' : 'Поиск Донглов'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: Colors.blue.shade100,
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<List<ScanResult>>(
              valueListenable: _bleService.scanResultsNotifier,
              builder: (context, results, child) {
                if (results.isEmpty) {
                  return const Center(child: Text('Устройства не найдены. Нажмите "Поиск"'));
                }
                return ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final r = results[index];
                    String deviceName = r.device.platformName.isEmpty ? r.device.advName : r.device.platformName;
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: const Icon(Icons.bluetooth, color: Colors.blue),
                        title: Text(deviceName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('MAC: ${r.device.remoteId}\nМощность сигнала (RSSI): ${r.rssi} dBm'),
                        trailing: ElevatedButton(
                          onPressed: () async {
                            await _bleService.connectToDevice(r.device);
                            // Самопроверка: переход только при успешном соединении
                            if (_bleService.isConnected.value && context.mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const MainMenuScreen()),
                              );
                            }
                          },
                          child: const Text('Connect'),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## File: .\lib\main_menu_screen.dart
```dart
/*
 * Файл: main_menu_screen.dart
 * Версия: 1.26
 * Изменения: ЭТАП 4, Шаг 2. Выделено главное меню. Внедрена защита (PopScope и Listener) для корректной отработки потери соединения.
 * Описание: Главный дашборд управления Донглом.
 */

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_config.dart';
import 'ble_protocol.dart';
import 'ble_service.dart';
import 'roster_screen.dart';
import 'map_screen.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  final BleService _bleService = BleService();

  @override
  void initState() {
    super.initState();
    // Подписываемся на разрыв связи (например, если Донгл выключился)
    _bleService.isConnected.addListener(_connectionListener);
  }

  @override
  void dispose() {
    _bleService.isConnected.removeListener(_connectionListener);
    super.dispose();
  }

  void _connectionListener() {
    // Если связь оборвалась, автоматически закрываем меню и возвращаемся в сканер
    if (!_bleService.isConnected.value && mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  String _getRoleName(int roleCode) {
    switch (roleCode) {
      case 0: return 'Ретранслятор (Relay)';
      case 1: return 'Сталкер (Stalker)';
      case 2: return 'Трекер (Tracker)';
      default: return 'Неизвестно ($roleCode)';
    }
  }

  @override
  Widget build(BuildContext context) {
    // PopScope защищает от системного жеста "Назад", гарантируя отключение BLE
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        await _bleService.disconnect(); 
        // При вызове disconnect изменится isConnected, и сработает _connectionListener
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Naviga v${AppConfig.version} Меню'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton.icon(
                onPressed: () => _bleService.disconnect(),
                icon: const Icon(Icons.bluetooth_disabled),
                label: Text('Отключить ${_bleService.connectedDeviceName.value}'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.red.shade100,
                ),
              ),
              const SizedBox(height: 20),

              // --- БЛОК ТОПОЛОГИИ СЕТИ (Список) ---
              ListenableBuilder(
                listenable: Listenable.merge([_bleService.nodeDatabase, _bleService.identityNotifier]),
                builder: (context, child) {
                  final myId = _bleService.identityNotifier.value?.myNodeId;
                  final neighborsCount = _bleService.nodeDatabase.getNeighborsCount(myId);

                  return Card(
                    elevation: 4,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RosterScreen()),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            const Icon(Icons.hub, color: Colors.blue, size: 32),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Топология Сети (Список)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  Text('Найдено соседей: $neighborsCount', style: const TextStyle(fontSize: 16)),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),

              // --- БЛОК КАРТЫ С УМНОЙ БЛОКИРОВКОЙ ---
              ListenableBuilder(
                listenable: _bleService.nodeDatabase,
                builder: (context, child) {
                  final hasValidGps = _bleService.nodeDatabase.hasAnyValidGps;

                  return Card(
                    elevation: hasValidGps ? 4 : 1,
                    color: hasValidGps ? Colors.blueGrey.shade50 : Colors.grey.shade200,
                    child: InkWell(
                      onTap: hasValidGps ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MapScreen()),
                        );
                      } : null, 
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(Icons.map, color: hasValidGps ? Colors.deepOrange : Colors.grey, size: 32),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(hasValidGps ? 'Карта (Naviga Map)' : 'Карта недоступна', 
                                    style: TextStyle(
                                      fontSize: 18, 
                                      fontWeight: FontWeight.bold,
                                      color: hasValidGps ? Colors.black87 : Colors.grey.shade600
                                    )),
                                  Text(hasValidGps ? 'Визуализация узлов' : 'Ожидание геоданных из сети...', 
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: hasValidGps ? Colors.black87 : Colors.grey.shade600
                                    )),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right, color: hasValidGps ? Colors.grey : Colors.transparent),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              
              // --- БЛОК ТЕЛЕМЕТРИИ С ПОДДЕРЖКОЙ ANCHOR ---
              ValueListenableBuilder<BleEvtMyStatus?>(
                valueListenable: _bleService.myStatusNotifier,
                builder: (context, status, child) {
                  if (status == null) {
                    return const Card(
                      elevation: 4,
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('Ожидание данных телеметрии...', style: TextStyle(fontStyle: FontStyle.italic)),
                      ),
                    );
                  }

                  String gpsText;
                  Color gpsColor;
                  bool showAnchorButton = false;

                  switch (status.gpsState) {
                    case 0:
                      gpsText = 'Поиск спутников...';
                      gpsColor = Colors.orange.shade700;
                      showAnchorButton = true; 
                      break;
                    case 1:
                      gpsText = 'Зафиксирован (Fix OK)';
                      gpsColor = Colors.green.shade700;
                      showAnchorButton = false; 
                      break;
                    case 2:
                      gpsText = 'Нет'; 
                      gpsColor = Colors.blueGrey;
                      showAnchorButton = true; 
                      break;
                    default:
                      gpsText = 'Неизвестный статус (${status.gpsState})';
                      gpsColor = Colors.red;
                  }

                  return Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.speed, color: Colors.blueGrey),
                              SizedBox(width: 8),
                              Text('Телеметрия Донгла', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const Divider(),
                          Text('Батарея: ${status.batteryPercent}% (${(status.batteryVoltage / 1000).toStringAsFixed(2)} В)', style: const TextStyle(fontSize: 16)),
                          Row(
                            children: [
                              const Text('GPS: ', style: TextStyle(fontSize: 16)),
                              Text(gpsText, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: gpsColor)),
                            ],
                          ),
                          if (status.gpsState != 2)
                            Text('Спутники: ${status.satellites}', style: const TextStyle(fontSize: 16)),
                          
                          if (showAnchorButton) ...[
                            const SizedBox(height: 14),
                            const Divider(height: 1),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: () => _bleService.sendAnchorCoords(),
                              icon: const Icon(Icons.pin_drop_rounded),
                              label: const Text('ПЕРЕДАТЬ КООРДИНАТЫ СМАРТФОНА (ANCHOR)'),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(45),
                                backgroundColor: Colors.deepOrange.shade50,
                                foregroundColor: Colors.deepOrange.shade800,
                                side: BorderSide(color: Colors.deepOrange.shade200),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),

              // --- БЛОК ИДЕНТИФИКАЦИИ ---
              ValueListenableBuilder<BleIdentity?>(
                valueListenable: _bleService.identityNotifier,
                builder: (context, identity, child) {
                  if (identity == null) return const SizedBox.shrink();
                  return Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Идентификация Узла', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditIdentityScreen(currentIdentity: identity),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const Divider(),
                          Text('Имя: ${identity.myName}', style: const TextStyle(fontSize: 16)),
                          Text('Локальный ID: ${identity.myNodeId}', style: const TextStyle(fontSize: 16)),
                          Text('Роль: ${_getRoleName(identity.myRole)}', style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),

              // --- БЛОК СИСТЕМНЫХ ТАЙМЕРОВ ---
              ValueListenableBuilder<BleSysConfig?>(
                valueListenable: _bleService.sysConfigNotifier,
                builder: (context, config, child) {
                  if (config == null) return const SizedBox.shrink();
                  return Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Системные Таймеры', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditSysConfigScreen(config: config),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const Divider(),
                          Text('Передача в движении: ${config.txIntervalMoving / 1000} сек', style: const TextStyle(fontSize: 16)),
                          Text('Передача на стоянке: ${config.txIntervalStill / 1000} сек', style: const TextStyle(fontSize: 16)),
                          Text('Таймаут потери связи: ${config.nodeConnectionTimeout / 1000} сек', style: const TextStyle(fontSize: 16)),
                          Text('Удаление из БД: ${config.nodeActiveTimeoutMs / 1000} сек', style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// Вспомогательные классы и экраны настроек (EditIdentity, EditSysConfig)
// ============================================================================

class Utf8ByteLengthFormatter extends TextInputFormatter {
  final int maxBytes;
  Utf8ByteLengthFormatter(this.maxBytes);
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (utf8.encode(newValue.text).length > maxBytes) return oldValue;
    return newValue;
  }
}

class EditIdentityScreen extends StatefulWidget {
  final BleIdentity currentIdentity;
  const EditIdentityScreen({super.key, required this.currentIdentity});
  @override
  State<EditIdentityScreen> createState() => _EditIdentityScreenState();
}

class _EditIdentityScreenState extends State<EditIdentityScreen> {
  final BleService _bleService = BleService();
  late TextEditingController _nameController;
  late int _selectedRole;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentIdentity.myName);
    _selectedRole = widget.currentIdentity.myRole;
    if (_selectedRole < 0 || _selectedRole > 2) _selectedRole = 0;
  }

  @override
  void dispose() { 
    _nameController.dispose(); 
    super.dispose(); 
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Внимание!', style: TextStyle(color: Colors.red)),
          content: const Text(
            'Вы уверены? Это действие безвозвратно удалит все данные на Донгле, сбросит его Имя и Роль, а также разорвет текущее соединение.'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('ОТМЕНА'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _bleService.factoryReset();
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('СБРОСИТЬ'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Редактирование узла')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              inputFormatters: [Utf8ByteLengthFormatter(23)],
              decoration: const InputDecoration(
                labelText: 'Имя устройства', 
                border: OutlineInputBorder(),
                helperText: 'Допускается до 23 латинских букв или 11 русских',
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<int>(
              value: _selectedRole,
              decoration: const InputDecoration(labelText: 'Роль устройства', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 0, child: Text('Ретранслятор (Relay)')),
                DropdownMenuItem(value: 1, child: Text('Сталкер (Stalker)')),
                DropdownMenuItem(value: 2, child: Text('Трекер (Tracker)')),
              ],
              onChanged: (int? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedRole = newValue;
                  });
                }
              },
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                _bleService.setIdentity(widget.currentIdentity.myNodeId, _nameController.text, _selectedRole);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: Colors.blueAccent, 
                foregroundColor: Colors.white
              ),
              child: const Text('СОХРАНИТЬ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () => _showResetDialog(context),
              icon: const Icon(Icons.warning_amber_rounded),
              label: const Text('СБРОС К ЗАВОДСКИМ НАСТРОЙКАМ'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class EditSysConfigScreen extends StatefulWidget {
  final BleSysConfig config;
  const EditSysConfigScreen({super.key, required this.config});
  @override
  State<EditSysConfigScreen> createState() => _EditSysConfigScreenState();
}

class _EditSysConfigScreenState extends State<EditSysConfigScreen> {
  final BleService _bleService = BleService();
  late TextEditingController _movingController;
  late TextEditingController _stillController;
  late TextEditingController _connTimeoutController;
  late TextEditingController _activeTimeoutController;

  @override
  void initState() {
    super.initState();
    _movingController = TextEditingController(text: (widget.config.txIntervalMoving ~/ 1000).toString());
    _stillController = TextEditingController(text: (widget.config.txIntervalStill ~/ 1000).toString());
    _connTimeoutController = TextEditingController(text: (widget.config.nodeConnectionTimeout ~/ 1000).toString());
    _activeTimeoutController = TextEditingController(text: (widget.config.nodeActiveTimeoutMs ~/ 1000).toString());
  }

  @override
  void dispose() { 
    _movingController.dispose(); 
    _stillController.dispose(); 
    _connTimeoutController.dispose(); 
    _activeTimeoutController.dispose(); 
    super.dispose(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройка таймеров')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildField('Интервал передачи (движение)', _movingController),
            _buildField('Интервал передачи (стоянка)', _stillController),
            _buildField('Таймаут потери связи', _connTimeoutController),
            _buildField('Таймаут удаления из БД', _activeTimeoutController),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _bleService.setSysConfig(
                  txMoving: (int.tryParse(_movingController.text) ?? 30) * 1000,
                  txStill: (int.tryParse(_stillController.text) ?? 300) * 1000,
                  connTimeout: (int.tryParse(_connTimeoutController.text) ?? 600) * 1000,
                  activeTimeout: (int.tryParse(_activeTimeoutController.text) ?? 3600) * 1000,
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50), 
                backgroundColor: Colors.blueAccent, 
                foregroundColor: Colors.white,
              ),
              child: const Text('СОХРАНИТЬ ТАЙМЕРЫ'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller, 
        keyboardType: TextInputType.number, 
        inputFormatters: [FilteringTextInputFormatter.digitsOnly], 
        decoration: InputDecoration(
          labelText: label, 
          suffixText: 'сек', 
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
```

---

## File: .\lib\background_manager.dart
```dart
/*
 * Файл: background_manager.dart
 * Версия: 1.29
 * Изменения: ЭТАП 4, Шаг 15. Создан менеджер приоритетной фоновой службы. Исправлены импорты и синтаксис проверки AndroidServiceInstance для пакета версии 5.x.
 * Описание: Управление фоновым жизненным циклом приложения.
 */

import 'dart:ui';
import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'ble_service.dart';
import 'app_config.dart';

class BackgroundManager {
  static const String notificationChannelId = 'naviga_fg_service';
  static const int notificationId = 888;

  static Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    // Настройка уведомлений для шторки Android
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      notificationChannelId,
      'Naviga Background Service',
      description: 'Поддержание постоянного BLE-соединения с Донглом',
      importance: Importance.low, 
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false, // Запускаем вручную только при успешном Connect
        isForegroundMode: true,
        notificationChannelId: notificationChannelId,
        initialNotificationTitle: 'Naviga Operator',
        initialNotificationContent: 'Ожидание подключения к радиосети...',
        foregroundServiceTypes: [AndroidForegroundType.connectedDevice],
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    return true;
  }

  // Точка входа для фонового Isolate
  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();
    
    final BleService bleService = BleService();
    final FlutterLocalNotificationsPlugin notificationPlugin = FlutterLocalNotificationsPlugin();

    print('=== Фоновый Isolate Naviga успешно запущен ===');

    // Обновление текста в шторке при получении данных от BleService
    Timer.periodic(const Duration(seconds: 2), (timer) async {
      // Обновленный синтаксис для версии 5.x: проверяем через AndroidServiceInstance
      if (service is AndroidServiceInstance) {
        if (!await service.isForegroundService()) {
          timer.cancel();
          return;
        }
      }

      final isConnected = bleService.isConnected.value;
      final deviceName = bleService.connectedDeviceName.value;
      final status = bleService.myStatusNotifier.value;

      String title = 'Naviga v${AppConfig.version}';
      String content = isConnected 
          ? 'Подключено: $deviceName | Батарея: ${status?.batteryPercent ?? "---"}%'
          : 'Связь с Донглом разорвана. Ожидание...';

      // Обновляем уведомление в реальном времени
      notificationPlugin.show(
        notificationId,
        title,
        content,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            notificationChannelId,
            'Naviga Background Service',
            ongoing: true,
            importance: Importance.low,
            priority: Priority.low,
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
    });

    // Слушаем команду на остановку сервиса из основного UI
    service.on('stopService').listen((event) {
      service.stopSelf();
      print('=== Фоновый Isolate остановлен по команде UI ===');
    });
  }
}
```

---

