# Project: Naviga_Operator Snapshot V1.39.9

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
# Версия: 1.38.0
# Изменения: Архитектурный план, Шаг 1. Внедрение flutter_map_tile_caching для оффлайн-карт.
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
  flutter_map_tile_caching: ^9.0.1 # ИЗМЕНЕНИЕ: Шаг 1 (Интеграция FMTC)
  http: ^1.2.0
  geolocator: ^14.0.2
  flutter_background_service: ^5.0.5
  flutter_local_notifications: ^17.1.2
  shared_preferences: ^2.2.2 
  wakelock_plus: ^1.2.8 
  flutter_compass: ^0.8.0 # ИЗМЕНЕНИЕ 1.33.3: Пакет для интерактивного компаса
  path_provider: ^2.1.5
  share_plus: ^12.0.2
  file_picker: ^8.1.2
  
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
 * Версия: 1.38.0
 * Изменения: Архитектурный план, Шаг 1 (Хотфикс). Инициализация ObjectBoxBackend вместо удаленного класса FlutterMapTileCaching.
 * Описание: Главная точка входа в приложение с поддержкой фонового режима.
 */

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart'; 

import 'app_config.dart';
import 'scanner_screen.dart';
import 'background_manager.dart';
import 'app_settings.dart'; 

void main() async {
  // Гарантируем инициализацию фреймворка перед обращением к нативным плагинам
  WidgetsFlutterBinding.ensureInitialized();

  // ИЗМЕНЕНИЕ: Шаг 1 (Исправление). Инициализация ObjectBox и создание хранилища
  await FMTCObjectBoxBackend().initialise();
  await FMTCStore('NavigaStore').manage.create();

  // Инициализируем конфигурацию фонового сервиса
  await BackgroundManager.initializeService();

  // Загружаем сохраненные настройки с диска смартфона
  await AppSettings().init();

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
    // Подписываем всё приложение на настройки, чтобы тема менялась на лету
    return ListenableBuilder(
      listenable: AppSettings(),
      builder: (context, child) {
        return MaterialApp(
          title: 'Naviga Operator',
          
          // Светлая тема
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey, brightness: Brightness.light),
            useMaterial3: true,
          ),
          
          // Тёмная тема
          darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey, brightness: Brightness.dark),
          ),
          
          // Режим берется из настроек
          themeMode: AppSettings().darkTheme ? ThemeMode.dark : ThemeMode.light,
          
          home: const ScannerScreen(), 
        );
      },
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
 * Версия: 1.30
 * Изменения: ЭТАП 4, Шаг 15. Добавлен метод _updateBackgroundNotification для проброса телеметрии в изолированный фоновый поток через шину сообщений (invoke).
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

  // Проброс данных в фоновый процесс
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
        
        FlutterBackgroundService().startService();
        Future.delayed(const Duration(seconds: 1), _updateBackgroundNotification);
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
          _updateBackgroundNotification(); // ИЗМЕНЕНИЕ 1.30: Обновляем шторку при получении телеметрии
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
 * Версия: 1.32.6
 * Изменения: ЭТАП Настроек, Шаг 6. Интеграция Фильтра блуждания с AppSettings. Статические константы заменены на динамические параметры из настроек.
 * Описание: Центральная база данных Roster с поддержкой трекинга.
 */

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'ble_protocol.dart';
import 'app_settings.dart'; // ИЗМЕНЕНИЕ 1.32.6: Подключили настройки

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

  // Кольцевой буфер истории координат
  List<TrackPoint> track = [];
  static const int maxTrackPoints = 50;

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

  // Метод добавления точки в трек с динамическим фильтром блуждания
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

    // 2. Анти-джиттер: проверка дистанции до N последних добавленных точек
    bool isJitter = false;
    
    // ИЗМЕНЕНИЕ 1.32.6: Получаем актуальные настройки фильтра "на лету"
    int pointsToCheck = AppSettings().jitterPoints;
    double currentJitterRadius = AppSettings().jitterRadius;
    
    // Защита: проверяем не больше точек, чем есть в буфере
    if (track.length < pointsToCheck) {
      pointsToCheck = track.length;
    }

    // Проверяем с конца массива (track.length - 1 это Точка-1, track.length - 2 это Точка-2 и т.д.)
    for (int i = 1; i <= pointsToCheck; i++) {
      final checkPoint = track[track.length - i];
      final pLatLng = LatLng(checkPoint.lat, checkPoint.lon);
      final dist = Distance().as(LengthUnit.Meter, pLatLng, newPoint).toDouble();
      
      // Если хотя бы одна из проверяемых точек ближе порога - считаем это джиттером/стоянкой
      if (dist < currentJitterRadius) {
        isJitter = true;
        break; 
      }
    }

    // Если новая точка дальше порога от ВСЕХ проверяемых последних точек - сдвигаем буфер
    if (!isJitter) {
      track.removeAt(0); // Удаляем самую старую в начале
      track.add(TrackPoint(lat: newLat, lon: newLon, timestampMs: timestamp)); // Добавляем новую в конец
    }
  }

  // Вспомогательный метод для получения актуального хвоста для отрисовки
  List<LatLng> getRecentTrack(int maxAgeMs) {
    if (track.isEmpty) return [];
    final now = DateTime.now().millisecondsSinceEpoch;
    
    List<LatLng> recent = track
        .where((p) => p.timestampMs != 0 && (maxAgeMs == 0 || (now - p.timestampMs) <= maxAgeMs))
        .map((p) => LatLng(p.lat, p.lon))
        .toList();

    // Принудительно добавляем текущую позицию узла в конец трека
    if (hasValidGps) {
      recent.add(LatLng(lat, lon));
    }

    return recent;
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
      node._addPointToTrack(update.lat, update.lon, normalizedTime); 
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
      node._addPointToTrack(update.lat, update.lon, normalizedTime); 
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
      node._addPointToTrack(update.lat, update.lon, now); 
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
      node._addPointToTrack(update.lat, update.lon, now); 
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
 * Версия: 1.33.5
 * Изменения: Хотфикс UI. Полный переход на семантические цвета (Theme.of(context).colorScheme) для поддержки корректного отображения в тёмной теме. Убраны жёстко заданные цвета.
 * Описание: Экран отображения базы узлов (Ростер).
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
    final colorScheme = Theme.of(context).colorScheme; // Получаем текущую цветовую схему

    return Scaffold(
      appBar: AppBar(
        title: const Text('Топология Сети'),
        backgroundColor: colorScheme.inversePrimary,
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([
          bleService.nodeDatabase, 
          bleService.identityNotifier,
          bleService.sysConfigNotifier, 
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
              
              final isOnline = isMe ? true : (now - node.lastSeenTimeMs) <= connTimeoutMs;

              return Opacity(
                opacity: isOnline ? 1.0 : 0.5,
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  color: isMe ? colorScheme.primaryContainer : null,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isMe ? colorScheme.primary : (isOnline ? colorScheme.secondaryContainer : colorScheme.surfaceVariant),
                      child: Icon(_getRoleIcon(node.role, isMe), color: isMe ? colorScheme.onPrimary : (isOnline ? colorScheme.onSecondaryContainer : colorScheme.onSurfaceVariant)),
                    ),
                    title: Text(
                      node.nodeName, 
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        color: isMe ? colorScheme.onPrimaryContainer : (isOnline ? colorScheme.onSurface : colorScheme.onSurfaceVariant)
                      )
                    ),
                    subtitle: Text(
                      _getDistanceText(node, isMe, hasMyGps, isOnline),
                      style: TextStyle(color: isOnline ? colorScheme.onSurfaceVariant : colorScheme.error)
                    ),
                    trailing: Icon(Icons.info_outline, color: colorScheme.onSurfaceVariant),
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
    final colorScheme = Theme.of(context).colorScheme; // Получаем схему для модального окна

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(width: 40, height: 5, decoration: BoxDecoration(color: colorScheme.outlineVariant, borderRadius: BorderRadius.circular(10))),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(isMe ? Icons.person_pin : Icons.device_hub, size: 32, color: isMe ? colorScheme.primary : (isOnline ? colorScheme.onSurface : colorScheme.onSurfaceVariant)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  node.nodeName,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isOnline ? Colors.green.withOpacity(0.15) : colorScheme.errorContainer, 
                  borderRadius: BorderRadius.circular(15)
                ),
                child: Text(
                  isOnline ? 'ONLINE' : 'OFFLINE', 
                  style: TextStyle(fontWeight: FontWeight.bold, color: isOnline ? Colors.green : colorScheme.onErrorContainer)
                ),
              ),
            ],
          ),
          const Divider(height: 30),
          
          _buildInfoRow(Icons.badge, 'Роль', roleName, colorScheme),
          _buildInfoRow(Icons.location_on, 'Координаты', node.lat == 0.0 ? 'Не зафиксированы' : '${node.lat.toStringAsFixed(6)}, ${node.lon.toStringAsFixed(6)}', colorScheme),
          
          if (!isMe && node.lat != 0.0) ...[
            _buildInfoRow(Icons.straighten, 'Дистанция', '${node.distance.toStringAsFixed(1)} м', colorScheme),
            _buildInfoRow(Icons.explore, 'Азимут', '${node.azimuth.toStringAsFixed(1)}°', colorScheme),
            _buildInfoRow(Icons.signal_cellular_alt, 'Уровень сигнала (SNR)', '${node.snr} dB', colorScheme),
            _buildInfoRow(Icons.access_time, 'Последний контакт', '$secondsAgo сек. назад', colorScheme),
          ],
          
          if (isMe) 
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text('Это ваш собственный узел. Дистанция не применима.', style: TextStyle(color: colorScheme.onSurfaceVariant, fontStyle: FontStyle.italic)),
            ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: colorScheme.primary, size: 20),
          const SizedBox(width: 12),
          Text('$label:', style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant)),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSurface))),
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
 * Версия: 1.39.7
 * Описание: Главный экран-оркестратор интерактивной карты.
 * Изменения: Интеграция плавающего, перемещаемого виджета прогресса оффлайн-загрузки (UC-24).
 */

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter_compass/flutter_compass.dart'; 
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart'; 

import 'ble_service.dart';
import 'app_settings.dart'; 
import 'offline_map_manager.dart'; 

import 'map_components/map_scale_bar.dart';
import 'map_components/map_compass.dart';
import 'map_components/map_grid_layer.dart';
import 'map_components/drawing_toolbar.dart';
import 'map_components/drawing_manager.dart';
import 'map_components/drawing_models.dart';
import 'map_components/drawing_layer.dart';
import 'map_components/drawing_controller.dart';
import 'map_components/nodes_layer.dart';
import 'map_components/region_selection_layer.dart';

class MapScreen extends StatefulWidget {
  final bool isOfflineSelectMode; 

  const MapScreen({
    super.key, 
    this.isOfflineSelectMode = false,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final BleService _bleService = BleService();
  final MapController _mapController = MapController();
  final DrawingController _drawingController = DrawingController();
  
  StreamSubscription<CompassEvent>? _compassSubscription;
  late int _lastCompassMode;
  bool _isMapReady = false;

  DrawingTool _activeTool = DrawingTool.view;
  List<LatLng> _currentDrawingLinePath = [];
  bool _isRegionDrawingActive = false; 

  // Координаты плавающего виджета загрузки
  double _downloadWidgetX = 16.0;
  double _downloadWidgetY = 100.0;

  @override
  void initState() {
    super.initState();
    _lastCompassMode = AppSettings().compassMode;
    if (AppSettings().keepScreenOn) WakelockPlus.enable();
    AppSettings().addListener(_onSettingsChanged);
    DrawingManager().load();
  }

  @override
  void dispose() {
    AppSettings().removeListener(_onSettingsChanged);
    _compassSubscription?.cancel();
    WakelockPlus.disable();
    _mapController.dispose();
    super.dispose();
  }

  void _onSettingsChanged() {
    if (_lastCompassMode != AppSettings().compassMode) {
      _lastCompassMode = AppSettings().compassMode;
      _applyCompassMode();
    }
  }

  void _applyCompassMode() {
    if (!_isMapReady) return;
    
    if (widget.isOfflineSelectMode) {
      _compassSubscription?.cancel();
      _compassSubscription = null;
      _mapController.rotate(0);
      return;
    }

    final mode = AppSettings().compassMode;
    if (mode == 2) {
      _compassSubscription ??= FlutterCompass.events?.listen((event) {
          if (event.heading != null && mounted) {
            _mapController.rotate(360 - event.heading!);
          }
        });
    } else {
      _compassSubscription?.cancel();
      _compassSubscription = null;
      if (mode == 0) _mapController.rotate(0);
    }
  }

  Widget _buildOfflineRegionToolbar() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: _isRegionDrawingActive
          ? IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              tooltip: 'Отменить выделение',
              onPressed: () => setState(() => _isRegionDrawingActive = false),
            )
          : IconButton(
              icon: const Icon(Icons.crop_square, color: Colors.blueGrey),
              tooltip: 'Активировать рамку региона',
              onPressed: () => setState(() => _isRegionDrawingActive = true),
            ),
    );
  }

  // Визуализация плавающего виджета загрузки
  Widget _buildDraggableDownloadWidget() {
    return ListenableBuilder(
      listenable: OfflineMapManager(),
      builder: (context, child) {
        final manager = OfflineMapManager();
        if (!manager.isDownloading) return const SizedBox.shrink();

        final colorScheme = Theme.of(context).colorScheme;

        return Positioned(
          left: _downloadWidgetX,
          top: _downloadWidgetY,
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                // Простое ограничение, чтобы не утащить за левый/верхний край экрана
                _downloadWidgetX = math.max(0, _downloadWidgetX + details.delta.dx);
                _downloadWidgetY = math.max(0, _downloadWidgetY + details.delta.dy);
              });
            },
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 260,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))
                  ],
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.cloud_download, size: 20, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            manager.currentRegionName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        InkWell(
                          onTap: () => manager.cancelDownload(),
                          child: Icon(Icons.cancel, size: 20, color: colorScheme.error),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: manager.progressPercentage / 100.0,
                      backgroundColor: colorScheme.surfaceVariant,
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${manager.downloadedTiles} / ${manager.totalTiles} тайлов',
                          style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                        ),
                        Text(
                          '${manager.progressPercentage.toStringAsFixed(1)}%',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isOfflineSelectMode ? 'Выбор оффлайн-карты' : 'Naviga Map'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      // Оборачиваем тело в Stack, чтобы плавающий виджет был поверх карты
      body: Stack(
        children: [
          ListenableBuilder(
            listenable: Listenable.merge([
              _bleService.nodeDatabase,
              _bleService.identityNotifier,
              DrawingManager(), 
            ]),
            builder: (context, child) {
              final nodes = _bleService.nodeDatabase.nodes.values.where((n) => n.hasValidGps);
              final myId = _bleService.identityNotifier.value?.myNodeId;

              LatLng initialCenter = const LatLng(0, 0);
              if (nodes.isNotEmpty) {
                final myNode = nodes.firstWhere((n) => n.nodeId == myId, orElse: () => nodes.first);
                initialCenter = LatLng(myNode.lat, myNode.lon);
              }

              int interactiveFlags = InteractiveFlag.all;
              if (widget.isOfflineSelectMode) {
                interactiveFlags = interactiveFlags & ~InteractiveFlag.rotate;
                if (_isRegionDrawingActive) interactiveFlags = interactiveFlags & ~InteractiveFlag.drag; 
              } else if (AppSettings().compassMode != 1) {
                interactiveFlags = interactiveFlags & ~InteractiveFlag.rotate;
              }

              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: initialCenter,
                  initialZoom: 15.0,
                  interactionOptions: InteractionOptions(flags: interactiveFlags),
                  onTap: (tapPosition, latLng) {
                    _drawingController.handleDrawingTap(
                      context: context,
                      tappedPoint: latLng,
                      camera: _mapController.camera,
                      activeTool: _activeTool,
                      currentDrawingLinePath: _currentDrawingLinePath,
                      onPathUpdated: () => setState(() {}),
                    );
                  },
                  onMapReady: () {
                    _isMapReady = true;
                    _applyCompassMode();
                    setState(() {});
                  },
                ),
                children: [
                  if (AppSettings().invertMapColors)
                    ColorFiltered(
                      colorFilter: const ColorFilter.matrix(<double>[
                        -1, 0, 0, 0, 255, 0, -1, 0, 0, 255, 0, 0, -1, 0, 255, 0, 0, 0, 1, 0,
                      ]),
                      child: TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.michroz2.naviga_operator',
                        tileProvider: FMTCStore('NavigaStore').getTileProvider(), 
                      ),
                    )
                  else
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.michroz2.naviga_operator',
                      tileProvider: FMTCStore('NavigaStore').getTileProvider(), 
                    ),
                  
                  if (_isMapReady && AppSettings().showGrid) const MapGridLayer(),

                  const MapDrawingLayer(),

                  if (widget.isOfflineSelectMode && _isRegionDrawingActive)
                    RegionSelectionLayer(
                      mapController: _mapController,
                      isMapReady: _isMapReady,
                      onCancel: () => setState(() => _isRegionDrawingActive = false),
                      onRegionSelected: (newRegion) {
                        DrawingManager().addElement(newRegion);
                        OfflineMapManager().downloadRegion(newRegion);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Загрузка региона "${newRegion.label}" запущена в фоне'))
                          );
                        }
                        setState(() => _isRegionDrawingActive = false);
                      },
                    ),

                  if (_currentDrawingLinePath.length > 1 && !widget.isOfflineSelectMode)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: _currentDrawingLinePath,
                          strokeWidth: DrawingManager().lastLineWidth,
                          color: Color(int.parse(DrawingManager().lastLineColorHex.replaceFirst('#', '0xFF'))).withOpacity(0.7),
                        ),
                      ],
                    ),
                    
                  NodesLayer(isInteractive: _activeTool == DrawingTool.view && !widget.isOfflineSelectMode),
                  
                  const Align(alignment: Alignment.bottomLeft, child: MapScaleBar()),
                  
                  if (!widget.isOfflineSelectMode)
                    const Align(alignment: Alignment.topRight, child: SafeArea(child: MapCompassWidget())),

                  if (widget.isOfflineSelectMode)
                    Align(
                      alignment: Alignment.topLeft,
                      child: SafeArea(
                        child: Padding(padding: const EdgeInsets.only(top: 16.0, left: 16.0), child: _buildOfflineRegionToolbar()),
                      ),
                    )
                  else if (AppSettings().showDrawingToolbar)
                    Align(
                      alignment: Alignment.topLeft,
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 16.0, left: 16.0),
                          child: DrawingToolbar(
                            activeTool: _activeTool,
                            onToolSelected: (tool) {
                              final previousTool = _activeTool;
                              setState(() => _activeTool = tool);
                              
                              if (previousTool == DrawingTool.line && tool != DrawingTool.line) {
                                _drawingController.processLineCompletion(
                                  context: context,
                                  currentDrawingLinePath: _currentDrawingLinePath,
                                  onPathCleared: () => setState(() => _currentDrawingLinePath.clear()),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          
          // Виджет прогресса оффлайн-загрузки
          _buildDraggableDownloadWidget(),
        ],
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
 */

class AppConfig {
  static const String version = '1.39.9';
}
```

---

## File: .\lib\scanner_screen.dart
```dart
/*
 * Файл: scanner_screen.dart
 * Версия: 1.32.9
 * Изменения: ЭТАП Настроек, Шаг 9 (Финал). UI-рефакторинг для поддержки Тёмной темы. Жесткий цвет кнопки поиска заменен на динамический Theme.of(context).colorScheme.
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
    final colorScheme = Theme.of(context).colorScheme; // Получаем текущую цветовую схему

    return Scaffold(
      appBar: AppBar(
        title: const Text('Naviga v${AppConfig.version} Подключение'),
        backgroundColor: colorScheme.inversePrimary,
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
                    // ИЗМЕНЕНИЕ 1.32.9: Динамические контрастные цвета вместо жесткого Colors.blue.shade100
                    backgroundColor: colorScheme.primaryContainer,
                    foregroundColor: colorScheme.onPrimaryContainer,
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
                        leading: Icon(Icons.bluetooth, color: colorScheme.primary),
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
 * Версия: 1.39.7
 * Описание: Главный дашборд управления Донглом.
 * Изменения: Карточка Оффлайн-карт теперь реагирует на состояние фоновой загрузки (UC-24).
 */

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_config.dart';
import 'ble_protocol.dart';
import 'ble_service.dart';
import 'roster_screen.dart';
import 'map_screen.dart';
import 'settings_screen.dart';
import 'exchange_screen.dart'; 

import 'map_components/drawing_manager.dart';
import 'offline_map_manager.dart'; // ИЗМЕНЕНИЕ: Добавлен импорт

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
    _bleService.isConnected.addListener(_connectionListener);
    DrawingManager().load();
  }

  @override
  void dispose() {
    _bleService.isConnected.removeListener(_connectionListener);
    super.dispose();
  }

  void _connectionListener() {
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
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        await _bleService.disconnect(); 
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Naviga Меню'),
          backgroundColor: colorScheme.inversePrimary,
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
                  backgroundColor: colorScheme.errorContainer,
                  foregroundColor: colorScheme.onErrorContainer,
                ),
              ),
              const SizedBox(height: 20),

              ListenableBuilder(
                listenable: Listenable.merge([_bleService.nodeDatabase, _bleService.identityNotifier]),
                builder: (context, child) {
                  final myId = _bleService.identityNotifier.value?.myNodeId;
                  final neighborsCount = _bleService.nodeDatabase.getNeighborsCount(myId);

                  return Card(
                    elevation: 4,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const RosterScreen()));
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

              ListenableBuilder(
                listenable: _bleService.nodeDatabase,
                builder: (context, child) {
                  final hasValidGps = _bleService.nodeDatabase.hasAnyValidGps;
                  return Card(
                    elevation: hasValidGps ? 4 : 1,
                    color: hasValidGps ? null : colorScheme.surfaceVariant,
                    child: InkWell(
                      onTap: hasValidGps ? () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const MapScreen()));
                      } : null, 
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(Icons.map, color: hasValidGps ? colorScheme.primary : Colors.grey, size: 32),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(hasValidGps ? 'Карта' : 'Карта недоступна', 
                                    style: TextStyle(
                                      fontSize: 18, 
                                      fontWeight: FontWeight.bold,
                                      color: hasValidGps ? null : colorScheme.onSurfaceVariant
                                    )),
                                  Text(hasValidGps ? 'Визуализация узлов' : 'Ожидание геоданных из сети...', 
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: hasValidGps ? null : colorScheme.onSurfaceVariant
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
                      gpsColor = colorScheme.error;
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
                                backgroundColor: colorScheme.tertiaryContainer,
                                foregroundColor: colorScheme.onTertiaryContainer,
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
                                icon: Icon(Icons.edit, color: colorScheme.primary),
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => EditIdentityScreen(currentIdentity: identity)));
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
                                icon: Icon(Icons.edit, color: colorScheme.primary),
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => EditSysConfigScreen(config: config)));
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
              const SizedBox(height: 10),

              Card(
                elevation: 4,
                child: InkWell(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.settings, color: Colors.blueGrey, size: 32),
                        SizedBox(width: 16),
                        Expanded(
                          child: Text('Настройки приложения', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                        Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // ИЗМЕНЕНИЕ 1.39.7: Динамическое состояние загрузки на дашборде
              ListenableBuilder(
                listenable: OfflineMapManager(),
                builder: (context, child) {
                  final manager = OfflineMapManager();
                  
                  return Card(
                    elevation: 4,
                    color: manager.isDownloading ? colorScheme.primaryContainer.withOpacity(0.5) : null,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const MapScreen(isOfflineSelectMode: true)));
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(Icons.download_for_offline, color: Colors.blueGrey, size: 32),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Оффлайн-карты', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  if (manager.isDownloading) ...[
                                    const SizedBox(height: 4),
                                    Text('Скачивание "${manager.currentRegionName}": ${manager.progressPercentage.toStringAsFixed(1)}%', 
                                      style: TextStyle(fontSize: 14, color: colorScheme.primary, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    LinearProgressIndicator(
                                      value: manager.progressPercentage / 100.0,
                                      backgroundColor: colorScheme.surfaceVariant,
                                      color: colorScheme.primary,
                                    ),
                                  ] else ...[
                                    const Text('Выбор региона для загрузки', style: TextStyle(fontSize: 14, color: Colors.grey)),
                                  ]
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

              Card(
                elevation: 4,
                child: InkWell(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ExchangeScreen()));
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.import_export, color: Colors.blueGrey, size: 32),
                        SizedBox(width: 16),
                        Expanded(
                          child: Text('Обмен картами', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                        Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}

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
  void dispose() { _nameController.dispose(); super.dispose(); }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text('Внимание!', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          content: const Text('Вы уверены? Это действие безвозвратно удалит все данные на Донгле, сбросит его Имя и Роль.'),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('ОТМЕНА')),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _bleService.factoryReset();
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
              child: const Text('СБРОСИТЬ'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
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
              decoration: const InputDecoration(labelText: 'Имя устройства', border: OutlineInputBorder()),
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
              onChanged: (int? newValue) { if (newValue != null) setState(() { _selectedRole = newValue; }); },
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                _bleService.setIdentity(widget.currentIdentity.myNodeId, _nameController.text, _selectedRole);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: colorScheme.primary, foregroundColor: colorScheme.onPrimary
              ),
              child: const Text('СОХРАНИТЬ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () => _showResetDialog(context),
              icon: const Icon(Icons.warning_amber_rounded),
              label: const Text('СБРОС К ЗАВОДСКИМ НАСТРОЙКАМ'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: colorScheme.error, foregroundColor: colorScheme.onError
              ),
            ),
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
  void dispose() { _movingController.dispose(); _stillController.dispose(); _connTimeoutController.dispose(); _activeTimeoutController.dispose(); super.dispose(); }

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
                backgroundColor: Theme.of(context).colorScheme.primary, 
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
        decoration: InputDecoration(labelText: label, suffixText: 'сек', border: const OutlineInputBorder()),
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
 * Версия: 1.30
 * Изменения: ЭТАП 4, Шаг 15 (Исправление Изолята). Удалено создание фантомного BleService в фоновом потоке. Внедрен слушатель 'updateNotification' для приема данных от главного UI потока (IPC).
 * Описание: Управление фоновым жизненным циклом приложения.
 */

import 'dart:ui';
import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'app_config.dart';

class BackgroundManager {
  static const String notificationChannelId = 'naviga_fg_service';
  static const int notificationId = 888;

  static Future<void> initializeService() async {
    final service = FlutterBackgroundService();
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
        autoStart: false, 
        isForegroundMode: true,
        notificationChannelId: notificationChannelId,
        initialNotificationTitle: 'Naviga v${AppConfig.version}',
        initialNotificationContent: 'Ожидание синхронизации...',
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

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();
    final FlutterLocalNotificationsPlugin notificationPlugin = FlutterLocalNotificationsPlugin();

    print('=== Фоновый Isolate Naviga запущен ===');

    // Слушаем данные, прилетающие из главного потока приложения
    service.on('updateNotification').listen((event) {
      if (event != null && event['content'] != null) {
        notificationPlugin.show(
          notificationId,
          'Naviga v${AppConfig.version}',
          event['content'],
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
      }
    });

    service.on('stopService').listen((event) {
      service.stopSelf();
      print('=== Фоновый Isolate остановлен ===');
    });
  }
}
```

---

## File: .\lib\settings_screen.dart
```dart
/*
 * Файл: settings_screen.dart
 * Версия: 1.37.3
 * Изменения: Добавлен блок "Тактическая разметка" со свитчами управления тулбаром и подписями.
 */

import 'package:flutter/material.dart';
import 'app_settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AppSettings _settings = AppSettings();

  late int _trackTimeMs;
  late double _trackWidth;
  late double _jitterRadius;
  late int _jitterPoints;
  late bool _keepScreenOn;
  late bool _darkTheme;
  late bool _showGrid;
  late int _compassMode;
  late double _gridWidth;
  late double _gridOpacity;
  late bool _invertMapColors;
  
  // Новые параметры
  late bool _showDrawingToolbar;
  late bool _showDrawingLabels;

  bool _isCancelled = false;

  final Map<int, String> _trackTimeOptions = {
    300000: '5 минут',
    900000: '15 минут',
    1800000: '30 минут',
    3600000: '1 час',
    7200000: '2 часа',
    0: 'Не ограничено',
  };

  final Map<int, String> _compassOptions = {
    0: 'Север всегда сверху',
    1: 'Свободное вращение',
    2: 'По магнитному компасу',
  };

  @override
  void initState() {
    super.initState();
    _trackTimeMs = _settings.trackTimeMs;
    _trackWidth = _settings.trackWidth;
    _jitterRadius = _settings.jitterRadius;
    _jitterPoints = _settings.jitterPoints;
    _keepScreenOn = _settings.keepScreenOn;
    _darkTheme = _settings.darkTheme;
    _showGrid = _settings.showGrid;
    _compassMode = _settings.compassMode;
    _gridWidth = _settings.gridWidth;
    _gridOpacity = _settings.gridOpacity;
    _invertMapColors = _settings.invertMapColors;
    
    _showDrawingToolbar = _settings.showDrawingToolbar;
    _showDrawingLabels = _settings.showDrawingLabels;
  }

  void _saveAllSettings() {
    _settings.setTrackTimeMs(_trackTimeMs);
    _settings.setTrackWidth(_trackWidth);
    _settings.setJitterRadius(_jitterRadius);
    _settings.setJitterPoints(_jitterPoints);
    _settings.setKeepScreenOn(_keepScreenOn);
    _settings.setDarkTheme(_darkTheme);
    _settings.setShowGrid(_showGrid);
    _settings.setCompassMode(_compassMode);
    _settings.setGridWidth(_gridWidth);
    _settings.setGridOpacity(_gridOpacity);
    _settings.setInvertMapColors(_invertMapColors);
    
    _settings.setShowDrawingToolbar(_showDrawingToolbar);
    _settings.setShowDrawingLabels(_showDrawingLabels);
  }

  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Сброс настроек'),
          content: const Text('Вы уверены, что хотите восстановить все настройки приложения по умолчанию?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('ОТМЕНА'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                setState(() {
                  _trackTimeMs = 1800000;
                  _trackWidth = 4.0;
                  _jitterRadius = 10.0;
                  _jitterPoints = 3;
                  _keepScreenOn = false;
                  _darkTheme = false;
                  _showGrid = false;
                  _compassMode = 0;
                  _gridWidth = 1.0;
                  _gridOpacity = 0.35;
                  _invertMapColors = false;
                  
                  _showDrawingToolbar = false;
                  _showDrawingLabels = true;
                });
              },
              style: TextButton.styleFrom(foregroundColor: Colors.orange.shade900),
              child: const Text('СБРОСИТЬ'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (didPop && !_isCancelled) {
          _saveAllSettings();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Настройки приложения'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          children: [
            _buildSectionHeader(Icons.map, 'Визуализация на карте'),
            SwitchListTile(
              title: const Text('Инверсия цветов карты', style: TextStyle(fontWeight: FontWeight.w500)),
              subtitle: const Text('Тактический (ночной) режим отображения карты'),
              value: _invertMapColors,
              onChanged: (val) => setState(() => _invertMapColors = val),
            ),
            SwitchListTile(
              title: const Text('Координатная сетка', style: TextStyle(fontWeight: FontWeight.w500)),
              subtitle: const Text('Отображение географической сетки поверх карты'),
              value: _showGrid,
              onChanged: (val) => setState(() => _showGrid = val),
            ),
            _buildSliderRow(
              'Толщина линий сетки',
              _gridWidth,
              0.5,
              5.0,
              9,
              (val) => setState(() => _gridWidth = val),
            ),
            _buildSliderRow(
              'Яркость сетки',
              _gridOpacity * 100,
              10.0,
              100.0,
              9,
              (val) => setState(() => _gridOpacity = val / 100),
              suffix: '%',
              isInteger: true,
            ),
            _buildDropdownRow(
              'Режим компаса',
              _compassMode,
              _compassOptions,
              (val) => setState(() => _compassMode = val as int),
            ),
            _buildDropdownRow(
              'Время отображения трека',
              _trackTimeMs,
              _trackTimeOptions,
              (val) => setState(() => _trackTimeMs = val as int),
            ),
            _buildSliderRow(
              'Толщина линии трека',
              _trackWidth,
              1.0,
              10.0,
              9,
              (val) => setState(() => _trackWidth = val),
            ),
            const Divider(height: 32),

            // ИЗМЕНЕНИЕ 1.37.3: Новый блок настроек разметки
            _buildSectionHeader(Icons.edit_location_alt, 'Тактическая разметка'),
            SwitchListTile(
              title: const Text('Панель инструментов разметки', style: TextStyle(fontWeight: FontWeight.w500)),
              subtitle: const Text('Отображать кнопку редактирования на карте. Отключите для защиты от случайных действий.'),
              value: _showDrawingToolbar,
              onChanged: (val) => setState(() => _showDrawingToolbar = val),
            ),
            SwitchListTile(
              title: const Text('Текстовые подписи объектов', style: TextStyle(fontWeight: FontWeight.w500)),
              subtitle: const Text('Показывать названия рядом с нарисованными точками и линиями.'),
              value: _showDrawingLabels,
              onChanged: (val) => setState(() => _showDrawingLabels = val),
            ),
            const Divider(height: 32),

            _buildSectionHeader(Icons.filter_alt, 'Фильтр блуждания'),
            _buildSliderRow(
              'Радиус фильтрации',
              _jitterRadius,
              5.0,
              30.0,
              25,
              (val) => setState(() => _jitterRadius = val),
              suffix: ' м',
            ),
            _buildSliderRow(
              'Количество проверяемых точек',
              _jitterPoints.toDouble(),
              1.0,
              10.0,
              9,
              (val) => setState(() => _jitterPoints = val.toInt()),
              isInteger: true,
            ),
            const Divider(height: 32),

            _buildSectionHeader(Icons.settings_system_daydream, 'Системные'),
            SwitchListTile(
              title: const Text('Не гасить карту', style: TextStyle(fontWeight: FontWeight.w500)),
              subtitle: const Text('Предотвращает засыпание устройства на Карте'),
              value: _keepScreenOn,
              onChanged: (val) => setState(() => _keepScreenOn = val),
            ),
            SwitchListTile(
              title: const Text('Тёмная тема', style: TextStyle(fontWeight: FontWeight.w500)),
              subtitle: const Text('Снижает расход батареи смартфона (глобально)'),
              value: _darkTheme,
              onChanged: (val) => setState(() => _darkTheme = val),
            ),
            
            const SizedBox(height: 24),
            const Divider(height: 1),
            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _isCancelled = true; 
                        });
                        Navigator.pop(context); 
                      },
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('Отменить изменения'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey.shade400),
                        foregroundColor: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showResetConfirmation(context),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('По умолчанию'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.orange.shade50,
                        foregroundColor: Colors.orange.shade900,
                        elevation: 0,
                        side: BorderSide(color: Colors.orange.shade200),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey, size: 24),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownRow(String label, int currentValue, Map<int, String> options, Function(int?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
          DropdownButton<int>(
            value: currentValue,
            items: options.entries.map((entry) {
              return DropdownMenuItem<int>(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSliderRow(String label, double value, double min, double max, int divisions, Function(double) onChanged, {String suffix = '', bool isInteger = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              Text('${isInteger ? value.toInt() : value.toStringAsFixed(1)}$suffix', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
```

---

## File: .\lib\app_settings.dart
```dart
/*
 * Файл: app_settings.dart
 * Версия: 1.37.3
 * Изменения: Добавлены параметры showDrawingToolbar и showDrawingLabels для управления тактической разметкой.
 */

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  static final AppSettings _instance = AppSettings._internal();
  factory AppSettings() => _instance;
  AppSettings._internal();

  SharedPreferences? _prefs;

  int _trackTimeMs = 1800000; 
  double _trackWidth = 4.0;
  double _jitterRadius = 10.0;
  int _jitterPoints = 3;
  bool _keepScreenOn = false;
  bool _darkTheme = false;
  
  bool _showGrid = false;
  int _compassMode = 0; 
  
  double _gridWidth = 1.0;
  double _gridOpacity = 0.35;
  
  bool _invertMapColors = false;

  // ИЗМЕНЕНИЕ 1.37.3: Новые настройки тактической разметки
  bool _showDrawingToolbar = false;
  bool _showDrawingLabels = true;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSettings();
  }

  void _loadSettings() {
    if (_prefs == null) return;
    
    _trackTimeMs = _prefs!.getInt('trackTimeMs') ?? 1800000;
    _trackWidth = _prefs!.getDouble('trackWidth') ?? 4.0;
    _jitterRadius = _prefs!.getDouble('jitterRadius') ?? 10.0;
    _jitterPoints = _prefs!.getInt('jitterPoints') ?? 3;
    _keepScreenOn = _prefs!.getBool('keepScreenOn') ?? false;
    _darkTheme = _prefs!.getBool('darkTheme') ?? false;
    
    _showGrid = _prefs!.getBool('showGrid') ?? false;
    _compassMode = _prefs!.getInt('compassMode') ?? 0;
    
    _gridWidth = _prefs!.getDouble('gridWidth') ?? 1.0;
    _gridOpacity = _prefs!.getDouble('gridOpacity') ?? 0.35;
    
    _invertMapColors = _prefs!.getBool('invertMapColors') ?? false;

    // Чтение новых параметров разметки
    _showDrawingToolbar = _prefs!.getBool('showDrawingToolbar') ?? false;
    _showDrawingLabels = _prefs!.getBool('showDrawingLabels') ?? true;
    
    notifyListeners();
  }

  int get trackTimeMs => _trackTimeMs;
  double get trackWidth => _trackWidth;
  double get jitterRadius => _jitterRadius;
  int get jitterPoints => _jitterPoints;
  bool get keepScreenOn => _keepScreenOn;
  bool get darkTheme => _darkTheme;
  
  bool get showGrid => _showGrid;
  int get compassMode => _compassMode;
  
  double get gridWidth => _gridWidth;
  double get gridOpacity => _gridOpacity;
  
  bool get invertMapColors => _invertMapColors;

  bool get showDrawingToolbar => _showDrawingToolbar;
  bool get showDrawingLabels => _showDrawingLabels;

  void setTrackTimeMs(int value) {
    if (_trackTimeMs != value) {
      _trackTimeMs = value;
      _prefs?.setInt('trackTimeMs', value);
      notifyListeners();
    }
  }

  void setTrackWidth(double value) {
    if (_trackWidth != value) {
      _trackWidth = value;
      _prefs?.setDouble('trackWidth', value);
      notifyListeners();
    }
  }

  void setJitterRadius(double value) {
    if (_jitterRadius != value) {
      _jitterRadius = value;
      _prefs?.setDouble('jitterRadius', value); 
      notifyListeners();
    }
  }

  void setJitterPoints(int value) {
    if (_jitterPoints != value) {
      _jitterPoints = value;
      _prefs?.setInt('jitterPoints', value);
      notifyListeners();
    }
  }

  void setKeepScreenOn(bool value) {
    if (_keepScreenOn != value) {
      _keepScreenOn = value;
      _prefs?.setBool('keepScreenOn', value);
      notifyListeners(); 
    }
  }

  void setDarkTheme(bool value) {
    if (_darkTheme != value) {
      _darkTheme = value;
      _prefs?.setBool('darkTheme', value);
      notifyListeners();
    }
  }

  void setShowGrid(bool value) {
    if (_showGrid != value) {
      _showGrid = value;
      _prefs?.setBool('showGrid', value);
      notifyListeners();
    }
  }

  void setCompassMode(int value) {
    if (_compassMode != value) {
      _compassMode = value;
      _prefs?.setInt('compassMode', value);
      notifyListeners();
    }
  }

  void setGridWidth(double value) {
    if (_gridWidth != value) {
      _gridWidth = value;
      _prefs?.setDouble('gridWidth', value);
      notifyListeners();
    }
  }

  void setGridOpacity(double value) {
    if (_gridOpacity != value) {
      _gridOpacity = value;
      _prefs?.setDouble('gridOpacity', value);
      notifyListeners();
    }
  }

  void setInvertMapColors(bool value) {
    if (_invertMapColors != value) {
      _invertMapColors = value;
      _prefs?.setBool('invertMapColors', value);
      notifyListeners();
    }
  }

  // Сеттеры для новых параметров
  void setShowDrawingToolbar(bool value) {
    if (_showDrawingToolbar != value) {
      _showDrawingToolbar = value;
      _prefs?.setBool('showDrawingToolbar', value);
      notifyListeners();
    }
  }

  void setShowDrawingLabels(bool value) {
    if (_showDrawingLabels != value) {
      _showDrawingLabels = value;
      _prefs?.setBool('showDrawingLabels', value);
      notifyListeners();
    }
  }
}
```

---

## File: .\lib\exchange_screen.dart
```dart
/*
 * Файл: exchange_screen.dart
 * Версия: 1.37.2
 * Описание: Экран управления импортом и экспортом данных (Разметка и Карты).
 */

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';

import 'map_components/drawing_manager.dart';
import 'map_components/drawing_storage.dart';
import 'map_components/drawing_models.dart';

class ExchangeScreen extends StatefulWidget {
  const ExchangeScreen({super.key});

  @override
  State<ExchangeScreen> createState() => _ExchangeScreenState();
}

class _ExchangeScreenState extends State<ExchangeScreen> {
  
  // Экспорт разметки (JSON)
  Future<void> _exportMarkup() async {
    final manager = DrawingManager();
    if (manager.elements.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ваша тактическая карта пуста. Нечего отправлять.')),
      );
      return;
    }

    try {
      final path = await DrawingStorage().prepareExportFile(manager.elements);
      await Share.shareXFiles(
        [XFile(path, mimeType: 'application/json')], 
        text: 'Тактическая разметка Naviga',
      );
    } catch (e) {
      _showError('Ошибка экспорта разметки: $e');
    }
  }

  // Импорт разметки (JSON)
  Future<void> _importMarkup() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any);
      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;
        final importedElements = await DrawingStorage().parseImportFile(path);
        
        if (importedElements.isEmpty) {
          _showError('Файл пуст или имеет неверный формат.');
          return;
        }
        _showMergeDialog(importedElements);
      }
    } catch (e) {
      _showError('Ошибка импорта: $e');
    }
  }

  // Плейсхолдеры для будущих функций
  void _futureFeature() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Эта функция будет доступна в следующих версиях.'),
        backgroundColor: Colors.blueGrey,
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showMergeDialog(List<TacticalElement> importedElements) {
    int points = importedElements.whereType<TacticalPoint>().length;
    int lines = importedElements.whereType<TacticalLine>().length;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        final colorScheme = Theme.of(context).colorScheme;
        return AlertDialog(
          title: const Text('Получена Разметка'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Объектов: Точек ($points), Линий ($lines)', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text('Как применить эти данные к вашей карте?'),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsOverflowDirection: VerticalDirection.down,
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  DrawingManager().importElements(importedElements, replace: true);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Данные ЗАМЕНЕНЫ')));
                },
                icon: const Icon(Icons.warning_amber_rounded),
                label: const Text('ЗАМЕНИТЬ'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.errorContainer, 
                  foregroundColor: colorScheme.onErrorContainer
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  DrawingManager().importElements(importedElements, replace: false);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Данные ДОБАВЛЕНЫ')));
                },
                icon: const Icon(Icons.library_add),
                label: const Text('ДОБАВИТЬ'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primaryContainer, 
                  foregroundColor: colorScheme.onPrimaryContainer
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('ОТМЕНА', style: TextStyle(color: Colors.grey)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Обмен картами'),
        backgroundColor: colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          _buildActionCard(
            context,
            title: 'Тактическая Разметка',
            subtitle: 'Обмен нарисованными точками и линиями',
            icon: Icons.edit_location_alt,
            onSend: _exportMarkup,
            onLoad: _importMarkup,
          ),
          const SizedBox(height: 24),
          _buildActionCard(
            context,
            title: 'Оффлайн Карты',
            subtitle: 'Обмен файлами картографической подложки',
            icon: Icons.map_outlined,
            onSend: _futureFeature,
            onLoad: _futureFeature,
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onSend,
    required VoidCallback onLoad,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: colorScheme.primary, size: 28),
                const SizedBox(width: 12),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant)),
            const Divider(height: 32),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onSend,
                    icon: const Icon(Icons.send_rounded, size: 20),
                    label: const Text('ПОСЛАТЬ'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onLoad,
                    icon: const Icon(Icons.download_rounded, size: 20),
                    label: const Text('ЗАГРУЗИТЬ'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## File: .\lib\offline_map_manager.dart
```dart
/*
 * Файл: offline_map_manager.dart
 * Версия: 1.39.9
 * Изменения: Добавлено сохранение ID текущего региона и его автоматическое удаление с карты (через DrawingManager) при отмене загрузки.
 */

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'map_components/drawing_models.dart';
import 'map_components/drawing_manager.dart'; // ИЗМЕНЕНИЕ: Доступ к разметке

class OfflineMapManager extends ChangeNotifier {
  static final OfflineMapManager _instance = OfflineMapManager._internal();
  factory OfflineMapManager() => _instance;
  OfflineMapManager._internal();

  bool isDownloading = false;
  double progressPercentage = 0.0;
  int downloadedTiles = 0;
  int totalTiles = 0;
  String currentRegionName = '';
  String? _currentRegionId; // ИЗМЕНЕНИЕ: ID для связи с разметкой

  StreamSubscription<DownloadProgress>? _downloadSubscription;
  static int _instanceCounter = 1;
  int? _currentInstanceId;

  Future<void> downloadRegion(TacticalRegion region) async {
    if (isDownloading) return;

    final store = FMTCStore('NavigaStore');
    
    final regionBounds = RectangleRegion(
      LatLngBounds(region.topLeft, region.bottomRight),
    );

    final downloadableRegion = regionBounds.toDownloadable(
      minZoom: 12,
      maxZoom: 16,
      options: TileLayer(
        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        userAgentPackageName: 'com.michroz2.naviga_operator',
      ),
    );

    try {
      isDownloading = true;
      currentRegionName = region.label;
      _currentRegionId = region.id; // Запоминаем ID
      progressPercentage = 0.0;
      downloadedTiles = 0;
      totalTiles = 0;
      _currentInstanceId = _instanceCounter++;
      notifyListeners();

      final downloadStream = store.download.startForeground(
        region: downloadableRegion,
        instanceId: _currentInstanceId!,
      );
      
      _downloadSubscription = downloadStream.listen(
        (progress) {
          progressPercentage = progress.percentageProgress;
          downloadedTiles = progress.successfulTiles;
          totalTiles = progress.maxTiles;
          notifyListeners();
        },
        onError: (e) {
          print('Ошибка загрузки региона ${region.label}: $e');
          _resetState();
        },
        onDone: () {
          print('Регион ${region.label} успешно загружен.');
          _resetState();
        },
        cancelOnError: true,
      );
    } catch (e) {
      print('Критическая ошибка запуска загрузки: $e');
      _resetState();
    }
  }

  void cancelDownload() {
    if (!isDownloading || _currentInstanceId == null) return;
    
    try {
      FMTCStore('NavigaStore').download.cancel(instanceId: _currentInstanceId!);
    } catch (e) {
      print('Ошибка при отмене загрузки FMTC: $e');
    }
    
    _downloadSubscription?.cancel();
    
    // ИЗМЕНЕНИЕ: Удаляем рамку региона с карты при отмене
    if (_currentRegionId != null) {
      DrawingManager().removeElement(_currentRegionId!);
    }
    
    _resetState();
  }

  void _resetState() {
    isDownloading = false;
    progressPercentage = 0.0;
    downloadedTiles = 0;
    totalTiles = 0;
    currentRegionName = '';
    _currentRegionId = null;
    _downloadSubscription = null;
    _currentInstanceId = null;
    notifyListeners();
  }
}
```

---

## File: .\lib\map_components\map_marker_manager.dart
```dart
/*
 * Файл: map_marker_manager.dart
 * Версия: 1.35.0
 * Описание: Изолированная логика управления стилями (цвета, иконки, прозрачность) для маркеров узлов на карте.
 */

import 'package:flutter/material.dart';

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
```

---

## File: .\lib\map_components\map_scale_bar.dart
```dart
/*
 * Файл: map_scale_bar.dart
 * Версия: 1.35.1
 * Изменения: Цвета контейнера, текста и линии адаптированы к системной теме (Surface/OnSurface).
 */

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import '../app_settings.dart';

class MapScaleBar extends StatelessWidget {
  const MapScaleBar({super.key});

  @override
  Widget build(BuildContext context) {
    final camera = MapCamera.of(context);
    final lat = camera.center.latitude;
    final zoom = camera.zoom;

    final metersPerPixel = (math.cos(lat * math.pi / 180) * 2 * math.pi * 6378137) / (256 * math.pow(2, zoom));
    
    final List<double> scaleSteps = [
      1, 2, 5, 10, 20, 50, 100, 200, 500, 
      1000, 2000, 5000, 10000, 20000, 50000, 
      100000, 200000, 500000, 1000000, 2000000, 5000000
    ];
    
    const double targetPixels = 100.0;
    final double distanceMeters = targetPixels * metersPerPixel;
    
    double selectedScale = scaleSteps.first;
    for (var step in scaleSteps) {
      if (distanceMeters >= step) {
        selectedScale = step;
      } else {
        break;
      }
    }
    
    final double scaleWidth = selectedScale / metersPerPixel;
    
    final String label = selectedScale >= 1000 
        ? '${(selectedScale / 1000).toStringAsFixed(0)} км' 
        : '${selectedScale.toStringAsFixed(0)} м';

    final bool showGrid = AppSettings().showGrid;
    
    // Адаптация под активную тему
    final colorScheme = Theme.of(context).colorScheme;
    final surfaceColor = colorScheme.surface;
    final onSurfaceColor = colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 24.0),
      child: GestureDetector(
        onTap: () {
          AppSettings().setShowGrid(!showGrid);
        },
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: surfaceColor.withOpacity(0.85),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: onSurfaceColor,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Container(
              width: scaleWidth,
              height: 4,
              decoration: BoxDecoration(
                color: onSurfaceColor,
                border: Border.all(color: surfaceColor.withOpacity(0.85), width: 1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## File: .\lib\map_components\map_compass.dart
```dart
/*
 * Файл: map_compass.dart
 * Версия: 1.35.1
 * Изменения: Цвета виджета адаптированы к системной теме (Surface/OnSurface).
 */

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import '../app_settings.dart';

class MapCompassWidget extends StatelessWidget {
  const MapCompassWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final camera = MapCamera.of(context);
    final rotation = camera.rotation; 
    final mode = AppSettings().compassMode;

    // Адаптация под активную тему
    final colorScheme = Theme.of(context).colorScheme;
    final surfaceColor = colorScheme.surface;
    final onSurfaceColor = colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.only(top: 16.0, right: 16.0),
      child: GestureDetector(
        onTap: () {
          AppSettings().setCompassMode((mode + 1) % 3);
        },
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: surfaceColor.withOpacity(0.85),
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
            ],
          ),
          child: Transform.rotate(
            angle: rotation * math.pi / 180,
            child: Icon(
              Icons.navigation, 
              // При включенном датчике оставляем синий цвет индикации, иначе цвет темы
              color: mode == 2 ? Colors.blue.shade700 : onSurfaceColor,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## File: .\lib\map_components\map_grid_layer.dart
```dart
/*
 * Файл: map_grid_layer.dart
 * Версия: 1.35.0
 * Описание: Оптимизированный слой отрисовки метрической координатной сетки с мемоизацией.
 */

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../app_settings.dart';

class MapGridLayer extends StatefulWidget {
  const MapGridLayer({super.key});

  @override
  State<MapGridLayer> createState() => _MapGridLayerState();
}

class _MapGridLayerState extends State<MapGridLayer> {
  // Кэширование (Мемоизация)
  List<Polyline> _cachedGrid = [];
  double _lastGridScale = -1;
  LatLng _lastGridCenter = const LatLng(0, 0);
  double _lastGridWidth = -1;
  double _lastGridOpacity = -1;
  double _currentGridBufferLat = 0;
  double _currentGridBufferLon = 0;

  @override
  Widget build(BuildContext context) {
    final camera = MapCamera.of(context);
    final lat = camera.center.latitude;
    final lon = camera.center.longitude;
    final zoom = camera.zoom;

    final metersPerPixel = (math.cos(lat * math.pi / 180) * 2 * math.pi * 6378137) / (256 * math.pow(2, zoom));
    
    final List<double> scaleSteps = [
      1, 2, 5, 10, 20, 50, 100, 200, 500, 
      1000, 2000, 5000, 10000, 20000, 50000, 
      100000, 200000, 500000, 1000000, 2000000, 5000000
    ];
    
    const double targetPixels = 100.0;
    final double distanceMeters = targetPixels * metersPerPixel;
    
    double selectedScale = scaleSteps.first;
    for (var step in scaleSteps) {
      if (distanceMeters >= step) {
        selectedScale = step;
      } else {
        break;
      }
    }

    final double strokeWidth = AppSettings().gridWidth;
    final double gridOpacity = AppSettings().gridOpacity;

    final double distLat = (lat - _lastGridCenter.latitude).abs();
    final double distLon = (lon - _lastGridCenter.longitude).abs();

    if (_cachedGrid.isNotEmpty &&
        _lastGridScale == selectedScale &&
        _lastGridWidth == strokeWidth &&
        _lastGridOpacity == gridOpacity &&
        distLat < (_currentGridBufferLat * 0.6) && 
        distLon < (_currentGridBufferLon * 0.6)) {
      return PolylineLayer(polylines: _cachedGrid);
    }

    const double metersPerLatDegree = 111319.9;
    final double latStep = selectedScale / metersPerLatDegree;
    
    final double cosLat = math.max(0.01, math.cos(lat * math.pi / 180));
    final double lonStep = selectedScale / (metersPerLatDegree * cosLat);

    if (latStep <= 0 || lonStep <= 0) return const SizedBox.shrink();

    _currentGridBufferLat = math.min(0.5, 100 * latStep);
    _currentGridBufferLon = math.min(0.5 / cosLat, 100 * lonStep);

    final double startLat = ((lat - _currentGridBufferLat) / latStep).floor() * latStep;
    final double endLat = ((lat + _currentGridBufferLat) / latStep).ceil() * latStep;
    final double startLon = ((lon - _currentGridBufferLon) / lonStep).floor() * lonStep;
    final double endLon = ((lon + _currentGridBufferLon) / lonStep).ceil() * lonStep;

    List<Polyline> lines = [];
    final Color gridColor = Colors.grey.withOpacity(gridOpacity);

    for (double l = startLat; l <= endLat; l += latStep) {
      lines.add(Polyline(
        points: [LatLng(l, startLon), LatLng(l, endLon)],
        strokeWidth: strokeWidth,
        color: gridColor,
      ));
    }

    for (double ln = startLon; ln <= endLon; ln += lonStep) {
      lines.add(Polyline(
        points: [LatLng(startLat, ln), LatLng(endLat, ln)],
        strokeWidth: strokeWidth,
        color: gridColor,
      ));
    }

    _cachedGrid = lines;
    _lastGridScale = selectedScale;
    _lastGridCenter = LatLng(lat, lon);
    _lastGridWidth = strokeWidth;
    _lastGridOpacity = gridOpacity;

    return PolylineLayer(polylines: _cachedGrid);
  }
}
```

---

## File: .\lib\map_components\drawing_models.dart
```dart
/*
 * Файл: drawing_models.dart
 * Версия: 1.39.9
 * Изменения: В TacticalRegion добавлены стили границ (borderWidth, isDashed) и геттер borderPath с линейной интерполяцией граней для обеспечения кликабельности периметра.
 */

import 'package:latlong2/latlong.dart';

enum TacticalType { point, line, region }

abstract class TacticalElement {
  final String id;
  final TacticalType type;
  final String label;
  final String description;
  final String colorHex;

  TacticalElement({
    required this.id,
    required this.type,
    required this.label,
    required this.description,
    required this.colorHex,
  });

  Map<String, dynamic> toJson();
}

class TacticalPoint extends TacticalElement {
  final double lat;
  final double lon;
  final String iconKey;

  TacticalPoint({
    required super.id,
    required this.lat,
    required this.lon,
    required super.label,
    required super.description,
    required super.colorHex,
    required this.iconKey,
  }) : super(type: TacticalType.point);

  @override
  Map<String, dynamic> toJson() => {
    'id': id, 'type': 'point', 'label': label, 'description': description,
    'colorHex': colorHex, 'lat': lat, 'lon': lon, 'iconKey': iconKey,
  };

  factory TacticalPoint.fromJson(Map<String, dynamic> json) => TacticalPoint(
    id: json['id'], lat: json['lat'], lon: json['lon'],
    label: json['label'], description: json['description'],
    colorHex: json['colorHex'], iconKey: json['iconKey'],
  );
}

class TacticalLine extends TacticalElement {
  final List<LatLng> path;
  final double width;

  TacticalLine({
    required super.id,
    required this.path,
    required super.label,
    required super.description,
    required super.colorHex,
    required this.width,
  }) : super(type: TacticalType.line);

  @override
  Map<String, dynamic> toJson() => {
    'id': id, 'type': 'line', 'label': label, 'description': description,
    'colorHex': colorHex, 'width': width,
    'path': path.map((p) => {'lat': p.latitude, 'lon': p.longitude}).toList(),
  };

  factory TacticalLine.fromJson(Map<String, dynamic> json) => TacticalLine(
    id: json['id'],
    label: json['label'], description: json['description'],
    colorHex: json['colorHex'], width: json['width']?.toDouble() ?? 3.0,
    path: (json['path'] as List).map((p) => LatLng(p['lat'], p['lon'])).toList(),
  );
}

class TacticalRegion extends TacticalElement {
  final LatLng topLeft;
  final LatLng bottomRight;
  final double borderWidth;
  final bool isDashed;

  TacticalRegion({
    required super.id,
    required this.topLeft,
    required this.bottomRight,
    required super.label,
    required super.description,
    required super.colorHex,
    this.borderWidth = 3.0,
    this.isDashed = true,
  }) : super(type: TacticalType.region);

  // ИЗМЕНЕНИЕ: Формируем замкнутый контур с интерполяцией (по 10 точек на грань).
  // Это позволяет алгоритму вычисления дистанции до вершин корректно обрабатывать тапы по всему периметру.
  List<LatLng> get borderPath {
    final corners = [
      topLeft,
      LatLng(topLeft.latitude, bottomRight.longitude),
      bottomRight,
      LatLng(bottomRight.latitude, topLeft.longitude),
      topLeft
    ];
    
    List<LatLng> path = [];
    for (int i = 0; i < corners.length - 1; i++) {
      final p1 = corners[i];
      final p2 = corners[i+1];
      path.add(p1);
      // Добавляем промежуточные точки
      for (int j = 1; j < 10; j++) {
        path.add(LatLng(
          p1.latitude + (p2.latitude - p1.latitude) * (j / 10),
          p1.longitude + (p2.longitude - p1.longitude) * (j / 10),
        ));
      }
    }
    path.add(corners.last);
    return path;
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id, 'type': 'region', 'label': label, 'description': description,
    'colorHex': colorHex,
    'topLeft': {'lat': topLeft.latitude, 'lon': topLeft.longitude},
    'bottomRight': {'lat': bottomRight.latitude, 'lon': bottomRight.longitude},
    'borderWidth': borderWidth,
    'isDashed': isDashed,
  };

  factory TacticalRegion.fromJson(Map<String, dynamic> json) => TacticalRegion(
    id: json['id'],
    label: json['label'], description: json['description'],
    colorHex: json['colorHex'],
    topLeft: LatLng(json['topLeft']['lat'], json['topLeft']['lon']),
    bottomRight: LatLng(json['bottomRight']['lat'], json['bottomRight']['lon']),
    borderWidth: json['borderWidth']?.toDouble() ?? 3.0,
    isDashed: json['isDashed'] ?? true,
  );
}
```

---

## File: .\lib\map_components\tactical_icon_manager.dart
```dart
/*
 * Файл: tactical_icon_manager.dart
 * Версия: 1.36.13
 * Описание: Оптимизированный справочник тактических иконок для Outdoors/Hunting.
 * Изменения: Расширение словаря до 24 элементов (добавлены иконки рельефа, маршрутов и инфраструктуры).
 */

import 'package:flutter/material.dart';

class TacticalIcon {
  final String key;
  final IconData data;
  final String label;

  const TacticalIcon(this.key, this.data, this.label);
}

class TacticalIconManager {
  static const List<TacticalIcon> availableIcons = [
    // Основные маркеры
    TacticalIcon('pin', Icons.pin_drop, 'Точка'),
    TacticalIcon('flag', Icons.flag, 'Ориентир'),
    TacticalIcon('warning', Icons.warning, 'Опасность'),
    
    // Camping & Outdoors
    TacticalIcon('tent', Icons.forest, 'Стоянка'),
    TacticalIcon('campfire', Icons.local_fire_department, 'Кострище'),
    TacticalIcon('water', Icons.water_drop, 'Вода'),
    TacticalIcon('shelter', Icons.roofing, 'Укрытие'),
    
    // Hunting & Dogs
    TacticalIcon('dog', Icons.pets, 'Собака'),
    TacticalIcon('target', Icons.track_changes, 'Цель'),
    TacticalIcon('tracker', Icons.gps_fixed, 'Трекер'),
    
    // Инфраструктура
    TacticalIcon('tower', Icons.cell_tower, 'Вышка'),
    TacticalIcon('bridge', Icons.alt_route, 'Переправа'),
    TacticalIcon('home', Icons.home, 'База'),
    TacticalIcon('hospital', Icons.local_hospital, 'Медпункт'),

    // НОВЫЕ: Природа и Рельеф
    TacticalIcon('terrain', Icons.terrain, 'Высота'),
    TacticalIcon('park', Icons.park, 'Заросли'),
    
    // НОВЫЕ: Маршруты и Транспорт
    TacticalIcon('walk', Icons.directions_walk, 'Тропа'),
    TacticalIcon('car', Icons.directions_car, 'Парковка'),
    TacticalIcon('boat', Icons.directions_boat, 'Причал'),
    
    // НОВЫЕ: Outdoor & Разное
    TacticalIcon('backpack', Icons.backpack, 'Тайник'),
    TacticalIcon('visibility', Icons.visibility, 'Обзор'),
    TacticalIcon('group', Icons.group, 'Сбор'),
    TacticalIcon('dining', Icons.local_dining, 'Привал'),
    TacticalIcon('camera', Icons.camera_alt, 'Снимок'),
  ];

  static IconData getIconData(String key) {
    return availableIcons.firstWhere(
      (i) => i.key == key,
      orElse: () => availableIcons.first,
    ).data;
  }
}
```

---

## File: .\lib\map_components\drawing_storage.dart
```dart
/*
 * Файл: drawing_storage.dart
 * Версия: 1.38.6
 * Описание: Локальное сохранение и загрузка элементов тактической разметки.
 * Изменения: Исправлена сигнатура prepareExportFile (добавлен аргумент List<TacticalElement>).
 */

import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'drawing_models.dart';

class DrawingStorage {
  Future<File> get _localFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/tactical_drawing.json');
  }

  Future<void> saveTacticalData(List<TacticalElement> elements) async {
    final file = await _localFile;
    final jsonList = elements.map((e) => e.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonList));
  }

  Future<List<TacticalElement>> loadTacticalData() async {
    try {
      final file = await _localFile;
      if (!await file.exists()) return [];

      final contents = await file.readAsString();
      final jsonList = jsonDecode(contents) as List;

      return jsonList.map((json) {
        switch (json['type']) {
          case 'point': return TacticalPoint.fromJson(json);
          case 'line': return TacticalLine.fromJson(json);
          case 'region': return TacticalRegion.fromJson(json);
          default: throw Exception('Unknown tactical element type');
        }
      }).toList();
    } catch (e) {
      print('Ошибка загрузки разметки: $e');
      return [];
    }
  }

  // ИСПРАВЛЕНИЕ: Добавлен аргумент List<TacticalElement> для совместимости с exchange_screen.dart
  Future<String> prepareExportFile(List<TacticalElement> elements) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/tactical_export.json');
    final jsonList = elements.map((e) => e.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonList));
    return file.path;
  }

  Future<List<TacticalElement>> parseImportFile(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) return [];

      final contents = await file.readAsString();
      final jsonList = jsonDecode(contents) as List;

      return jsonList.map((json) {
        switch (json['type']) {
          case 'point': return TacticalPoint.fromJson(json);
          case 'line': return TacticalLine.fromJson(json);
          case 'region': return TacticalRegion.fromJson(json);
          default: throw Exception('Unknown type');
        }
      }).toList();
    } catch (e) {
      print('Ошибка импорта: $e');
      return [];
    }
  }
}
```

---

## File: .\lib\map_components\drawing_manager.dart
```dart
/*
 * Файл: drawing_manager.dart
 * Версия: 1.37.0
 * Описание: Менеджер состояния для тактической разметки.
 * Изменения: Добавлен метод importElements с логикой ЗАМЕНИТЬ (Replace) и ДОБАВИТЬ (Append).
 */

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'drawing_models.dart';
import 'drawing_storage.dart';
import 'tactical_icon_manager.dart';

class DrawingManager extends ChangeNotifier {
  static final DrawingManager _instance = DrawingManager._internal();
  factory DrawingManager() => _instance;
  DrawingManager._internal();

  final DrawingStorage _storage = DrawingStorage();
  List<TacticalElement> _elements = [];

  List<String> _mruIconKeys = [];

  List<TacticalElement> get elements => List.unmodifiable(_elements);

  String lastPointIconKey = 'pin';
  String lastPointColorHex = '#FF0000';
  
  String lastLineColorHex = '#0000FF';
  double lastLineWidth = 4.0;

  Future<void> load() async {
    _elements = await _storage.loadTacticalData();
    
    final prefs = await SharedPreferences.getInstance();
    _mruIconKeys = prefs.getStringList('mru_icon_keys') ?? [];
    
    notifyListeners();
  }

  // ============================================================================
  // ЛОГИКА ИМПОРТА (UC-25)
  // ============================================================================
  void importElements(List<TacticalElement> importedElements, {required bool replace}) {
    if (replace) {
      // Жесткая замена
      _elements = List.from(importedElements);
    } else {
      // Мягкое добавление с перегенерацией ID для избежания конфликтов
      final uniquePrefix = DateTime.now().microsecondsSinceEpoch.toString();
      
      for (var el in importedElements) {
        final newId = '${uniquePrefix}_${el.id}';
        
        if (el is TacticalPoint) {
          _elements.add(TacticalPoint(
            id: newId, lat: el.lat, lon: el.lon, 
            label: el.label, description: el.description, 
            colorHex: el.colorHex, iconKey: el.iconKey
          ));
        } else if (el is TacticalLine) {
          _elements.add(TacticalLine(
            id: newId, label: el.label, description: el.description, 
            colorHex: el.colorHex, path: List.from(el.path), width: el.width
          ));
        }
      }
    }
    _save();
  }

  Future<void> promoteIcon(String iconKey) async {
    _mruIconKeys.remove(iconKey);
    _mruIconKeys.insert(0, iconKey);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('mru_icon_keys', _mruIconKeys);
  }

  List<TacticalIcon> get sortedIcons {
    List<TacticalIcon> result = [];
    for (String key in _mruIconKeys) {
      try {
        result.add(TacticalIconManager.availableIcons.firstWhere((i) => i.key == key));
      } catch (_) {} 
    }
    for (var icon in TacticalIconManager.availableIcons) {
      if (!_mruIconKeys.contains(icon.key)) {
        result.add(icon);
      }
    }
    return result;
  }

  int getNextPointNumber() {
    final count = _elements.whereType<TacticalPoint>().length;
    return count + 1;
  }

  int getNextLineNumber() {
    final count = _elements.whereType<TacticalLine>().length;
    return count + 1;
  }

  void addElement(TacticalElement element) {
    _elements.add(element);
    _updateDefaults(element);
    _save();
  }

  void updateElement(TacticalElement updatedElement) {
    final index = _elements.indexWhere((e) => e.id == updatedElement.id);
    if (index != -1) {
      _elements[index] = updatedElement;
      _updateDefaults(updatedElement);
      _save();
    }
  }

  void removeElement(String id) {
    _elements.removeWhere((e) => e.id == id);
    _save();
  }

  void _updateDefaults(TacticalElement element) {
    if (element is TacticalPoint) {
      lastPointIconKey = element.iconKey;
      lastPointColorHex = element.colorHex;
    } else if (element is TacticalLine) {
      lastLineColorHex = element.colorHex;
      lastLineWidth = element.width;
    }
  }

  void _save() {
    _storage.saveTacticalData(_elements);
    notifyListeners();
  }
}
```

---

## File: .\lib\map_components\drawing_layer.dart
```dart
/*
 * Файл: drawing_layer.dart 
 * Версия: 1.39.9 (Хотфикс)
 * Изменения: Исправлена ошибка компиляции. Свойство StrokePattern (flutter_map v7+) заменено на isDotted (flutter_map v6.x).
 */

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'drawing_manager.dart';
import 'drawing_models.dart';
import 'tactical_icon_manager.dart';
import '../app_settings.dart'; 

class MapDrawingLayer extends StatelessWidget {
  const MapDrawingLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([DrawingManager(), AppSettings()]),
      builder: (context, _) {
        final camera = MapCamera.of(context);
        final elements = DrawingManager().elements;
        final showLabels = AppSettings().showDrawingLabels;
        
        // Разделяем списки для соблюдения Z-индекса (Регионы на дне)
        List<Polyline> regionPolylines = [];
        List<Polyline> tacticalPolylines = [];
        
        List<Marker> regionMarkers = [];
        List<Marker> tacticalMarkers = [];

        for (var el in elements) {
          final color = Color(int.parse(el.colorHex.replaceFirst('#', '0xFF')));

          if (el is TacticalRegion) {
            regionPolylines.add(Polyline(
              points: el.borderPath,
              strokeWidth: el.borderWidth,
              color: color,
              // ИСПРАВЛЕНИЕ: Использование API flutter_map v6 для прерывистой линии
              isDotted: el.isDashed, 
            ));

            if (showLabels && el.label.isNotEmpty) {
              final labelMarker = _calculateDynamicLineLabel(el.borderPath, el.label, camera, color);
              if (labelMarker != null) regionMarkers.add(labelMarker);
            }
          } 
          else if (el is TacticalLine) {
            tacticalPolylines.add(Polyline(
              points: el.path,
              strokeWidth: el.width,
              color: color,
            ));

            if (showLabels && el.path.length >= 2 && el.label.isNotEmpty) {
              final labelMarker = _calculateDynamicLineLabel(el.path, el.label, camera, color);
              if (labelMarker != null) tacticalMarkers.add(labelMarker);
            }
          } 
          else if (el is TacticalPoint) {
            tacticalMarkers.add(Marker(
              point: LatLng(el.lat, el.lon),
              width: 100,
              height: showLabels ? 55 : 30, 
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(TacticalIconManager.getIconData(el.iconKey), color: color, size: 28),
                  if (showLabels) ...[
                    const SizedBox(height: 1),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.black12, width: 0.5),
                      ),
                      child: Text(
                        el.label,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ],
              ),
            ));
          }
        }

        return Stack(
          children: [
            // Сначала рисуем регионы, затем тактические линии
            PolylineLayer(polylines: [...regionPolylines, ...tacticalPolylines]),
            // Лейблы регионов под маркерами разметки
            MarkerLayer(markers: [...regionMarkers, ...tacticalMarkers]),
          ],
        );
      },
    );
  }

  List<math.Point<double>>? _clipSegment(math.Point<double> p1, math.Point<double> p2, double minX, double minY, double maxX, double maxY) {
    double t0 = 0.0;
    double t1 = 1.0;
    double dx = p2.x - p1.x;
    double dy = p2.y - p1.y;

    for (int edge = 0; edge < 4; edge++) {
      double p = 0, q = 0;
      if (edge == 0) { p = -dx; q = p1.x - minX; } 
      else if (edge == 1) { p = dx; q = maxX - p1.x; } 
      else if (edge == 2) { p = -dy; q = p1.y - minY; } 
      else if (edge == 3) { p = dy; q = maxY - p1.y; } 

      if (p == 0 && q < 0) return null; 

      if (p != 0) {
        double r = q / p;
        if (p < 0) {
          if (r > t1) return null;
          if (r > t0) t0 = r;
        } else {
          if (r < t0) return null;
          if (r < t1) t1 = r;
        }
      }
    }

    return [
      math.Point(p1.x + t0 * dx, p1.y + t0 * dy),
      math.Point(p1.x + t1 * dx, p1.y + t1 * dy)
    ];
  }

  Marker? _calculateDynamicLineLabel(List<LatLng> path, String labelText, MapCamera camera, Color color) {
    final double minX = 20.0;
    final double minY = 20.0;
    final double maxX = camera.size.x - 20.0;
    final double maxY = camera.size.y - 20.0;

    double maxVisibleSegmentDistPx = 0;
    math.Point<double>? bestMidPoint;
    double bestAngle = 0.0;

    List<math.Point<double>> screenPoints = [];
    for (var latLng in path) {
      final p = camera.latLngToScreenPoint(latLng);
      screenPoints.add(math.Point(p.x.toDouble(), p.y.toDouble()));
    }

    for (int i = 0; i < screenPoints.length - 1; i++) {
      final p1 = screenPoints[i];
      final p2 = screenPoints[i + 1];

      final clipped = _clipSegment(p1, p2, minX, minY, maxX, maxY);
      
      if (clipped != null) {
        final visibleDistPx = math.sqrt(math.pow(clipped[1].x - clipped[0].x, 2) + math.pow(clipped[1].y - clipped[0].y, 2));

        if (visibleDistPx > maxVisibleSegmentDistPx) {
          maxVisibleSegmentDistPx = visibleDistPx;
          bestMidPoint = math.Point((clipped[0].x + clipped[1].x) / 2, (clipped[0].y + clipped[1].y) / 2);
          bestAngle = math.atan2(p2.y - p1.y, p2.x - p1.x);
        }
      }
    }

    if (maxVisibleSegmentDistPx < 85 || bestMidPoint == null) return null;

    final labelLatLng = camera.pointToLatLng(bestMidPoint);

    if (bestAngle > math.pi / 2) {
      bestAngle -= math.pi;
    } else if (bestAngle < -math.pi / 2) {
      bestAngle += math.pi;
    }

    return Marker(
      point: labelLatLng,
      width: 140,
      height: 24,
      rotate: true,
      child: Container(
        alignment: Alignment.center,
        child: Transform.rotate(
          angle: bestAngle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: color.withOpacity(0.6), width: 1.0),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))],
            ),
            child: Text(
              labelText,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## File: .\lib\map_components\drawing_toolbar.dart
```dart
/*
 * Файл: drawing_toolbar.dart
 * Версия: 1.36.15
 * Описание: Компактная анимированная горизонтальная панель инструментов (Pill-shaped Toolbar).
 * Изменения: Полный переход на тему оформления (colorScheme) для поддержки корректного отображения в тёмной теме.
 */

import 'package:flutter/material.dart';

enum DrawingTool { view, select, point, line, eraser }

class DrawingToolbar extends StatelessWidget {
  final DrawingTool activeTool;
  final Function(DrawingTool) onToolSelected;

  const DrawingToolbar({
    super.key,
    required this.activeTool,
    required this.onToolSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isExpanded = activeTool != DrawingTool.view;
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      height: 48.0,
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.95),
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: colorScheme.brightness == Brightness.dark ? Colors.black45 : Colors.black26, 
            blurRadius: 6, 
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: isExpanded ? _buildExpandedToolbar(context) : _buildCollapsedButton(context),
    );
  }

  // Свернутое состояние (кнопка Edit) с учётом темы
  Widget _buildCollapsedButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return IconButton(
      icon: Icon(Icons.edit, color: colorScheme.onSurface),
      onPressed: () => onToolSelected(DrawingTool.select),
      tooltip: 'Режим редактирования',
    );
  }

  // Развернутое состояние с динамическими цветами темы
  Widget _buildExpandedToolbar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 4),
        _buildToolBtn(context, DrawingTool.select, Icons.near_me, 'Выбор'),
        _buildToolBtn(context, DrawingTool.point, Icons.location_on, 'Точка'),
        _buildToolBtn(context, DrawingTool.line, Icons.timeline, 'Линия'),
        _buildToolBtn(context, DrawingTool.eraser, Icons.auto_delete, 'Удалить'),
        
        // Вертикальный разделитель адаптивного цвета
        Container(
          height: 24,
          width: 1,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          color: colorScheme.outlineVariant,
        ),
        
        IconButton(
          icon: const Icon(Icons.close, color: Colors.red),
          onPressed: () => onToolSelected(DrawingTool.view),
          tooltip: 'Выход',
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildToolBtn(BuildContext context, DrawingTool tool, IconData icon, String tooltip) {
    final isSelected = activeTool == tool;
    final colorScheme = Theme.of(context).colorScheme;
    return IconButton(
      icon: Icon(
        icon, 
        color: isSelected ? colorScheme.primary : colorScheme.onSurface,
      ),
      onPressed: () => onToolSelected(tool),
      tooltip: tooltip,
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(),
    );
  }
}
```

---

## File: .\lib\map_components\drawing_menu_sheet.dart
```dart
/*
 * Файл: drawing_menu_sheet.dart
 * Версия: 1.39.9
 * Изменения: Интегрирована поддержка редактирования свойств регионов (цвет рамки, толщина, название). Инфо-окно адаптировано для отображения параметров TacticalRegion.
 */

import 'package:flutter/material.dart';
import 'drawing_models.dart';
import 'drawing_manager.dart';
import 'tactical_icon_manager.dart';

class DrawingMenuSheet extends StatefulWidget {
  final TacticalElement? existingElement;
  final TacticalType targetType;

  const DrawingMenuSheet({
    super.key,
    this.existingElement,
    required this.targetType,
  });

  @override
  State<DrawingMenuSheet> createState() => _DrawingMenuSheetState();
}

class _DrawingMenuSheetState extends State<DrawingMenuSheet> {
  late TextEditingController _labelController;
  late TextEditingController _descController;
  
  late String _currentColorHex;
  late String _currentIconKey;
  late double _currentLineWidth;

  final List<String> _palette = [
    '#FF0000', '#0000FF', '#008000', '#FFA500', '#000000', '#FFFFFF',
    '#FFFF00', '#800080', '#00FFFF', '#FF00FF', '#8B4513', '#808080'
  ];

  @override
  void initState() {
    super.initState();
    final manager = DrawingManager();
    final el = widget.existingElement;

    String defaultLabel = '';
    if (el == null) {
      if (widget.targetType == TacticalType.point) {
        defaultLabel = 'Точка-${manager.getNextPointNumber()}';
      } else if (widget.targetType == TacticalType.line) {
        defaultLabel = 'Линия-${manager.getNextLineNumber()}';
      } else {
        defaultLabel = 'Регион';
      }
    }

    _labelController = TextEditingController(text: el?.label ?? defaultLabel);
    _descController = TextEditingController(text: el?.description ?? '');

    if (el == null) {
      _labelController.selection = TextSelection(baseOffset: 0, extentOffset: _labelController.text.length);
    }

    if (widget.targetType == TacticalType.point) {
      if (el is TacticalPoint) {
        _currentColorHex = el.colorHex;
        _currentIconKey = el.iconKey;
      } else {
        _currentColorHex = manager.lastPointColorHex;
        _currentIconKey = manager.lastPointIconKey;
      }
      _currentLineWidth = 4.0;
    } else if (widget.targetType == TacticalType.line) {
      if (el is TacticalLine) {
        _currentColorHex = el.colorHex;
        _currentLineWidth = el.width;
      } else {
        _currentColorHex = manager.lastLineColorHex;
        _currentLineWidth = manager.lastLineWidth;
      }
      _currentIconKey = 'pin';
    } else if (widget.targetType == TacticalType.region) {
      // ИЗМЕНЕНИЕ: Инициализация полей для региона (рамка трактуется как линия)
      if (el is TacticalRegion) {
        _currentColorHex = el.colorHex;
        _currentLineWidth = el.borderWidth;
      } else {
        _currentColorHex = '#2196F3';
        _currentLineWidth = 3.0;
      }
      _currentIconKey = 'map';
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _save() {
    if (_labelController.text.trim().isEmpty) {
      if (widget.targetType == TacticalType.point) _labelController.text = 'Точка';
      else if (widget.targetType == TacticalType.line) _labelController.text = 'Линия';
      else _labelController.text = 'Регион';
    }

    if (widget.targetType == TacticalType.point) {
      DrawingManager().promoteIcon(_currentIconKey);
    }

    Navigator.of(context).pop({
      'label': _labelController.text.trim(),
      'description': _descController.text.trim(),
      'colorHex': _currentColorHex,
      'iconKey': _currentIconKey,
      'lineWidth': _currentLineWidth,
    });
  }

  @override
  Widget build(BuildContext context) {
    final isPoint = widget.targetType == TacticalType.point;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final colorScheme = Theme.of(context).colorScheme;
    
    final sortedIcons = DrawingManager().sortedIcons;

    return Padding(
      padding: EdgeInsets.only(
        left: 16.0, right: 16.0, top: 16.0, bottom: bottomInset + 16.0,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.existingElement == null 
                  ? (isPoint ? 'Новая точка' : 'Новая линия') 
                  : 'Редактирование',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            TextField(
              controller: _labelController,
              decoration: const InputDecoration(labelText: 'Название (Label)', border: OutlineInputBorder(), isDense: true),
              autofocus: widget.existingElement == null,
            ),
            const SizedBox(height: 12),
            
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Описание (опционально)', border: OutlineInputBorder(), isDense: true),
              maxLines: 1,
            ),
            const SizedBox(height: 16),
            
            const Text('Цвет:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            
            Wrap(
              spacing: 10, runSpacing: 10, alignment: WrapAlignment.start,
              children: _palette.map((hex) {
                final color = Color(int.parse(hex.replaceFirst('#', '0xFF')));
                final isSelected = _currentColorHex == hex;
                final bool showBorder = hex == '#FFFFFF' && colorScheme.brightness == Brightness.light;

                return GestureDetector(
                  onTap: () => setState(() => _currentColorHex = hex),
                  child: Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: color, shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? colorScheme.primary : (showBorder ? colorScheme.outline : Colors.transparent),
                        width: isSelected ? 3 : 1,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            
            if (isPoint) ...[
              const SizedBox(height: 16),
              const Text('Иконка:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6, crossAxisSpacing: 14, mainAxisSpacing: 10),
                itemCount: sortedIcons.length,
                itemBuilder: (context, index) {
                  final iconItem = sortedIcons[index];
                  final isSelected = _currentIconKey == iconItem.key;
                  return GestureDetector(
                    onTap: () => setState(() => _currentIconKey = iconItem.key),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? colorScheme.primaryContainer : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isSelected ? colorScheme.primary : Colors.transparent),
                      ),
                      child: Icon(iconItem.data, color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurface),
                    ),
                  );
                },
              ),
            ],

            if (!isPoint) ...[
              const SizedBox(height: 16),
              Text(widget.targetType == TacticalType.region ? 'Толщина рамки: ${_currentLineWidth.toStringAsFixed(1)}' : 'Толщина линии: ${_currentLineWidth.toStringAsFixed(1)}', 
                   style: const TextStyle(fontWeight: FontWeight.bold)),
              Slider(
                value: _currentLineWidth,
                min: 2.0, max: 8.0, divisions: 6,
                onChanged: (val) => setState(() => _currentLineWidth = val),
              ),
            ],

            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => Navigator.of(context).pop(null), child: const Text('Отмена')),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _save, child: const Text('Сохранить')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DrawingInfoSheet extends StatelessWidget {
  final TacticalElement element;

  const DrawingInfoSheet({super.key, required this.element});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = Color(int.parse(element.colorHex.replaceFirst('#', '0xFF')));
    
    // ИЗМЕНЕНИЕ: Настройка иконки окна для регионов
    IconData icon;
    if (element is TacticalPoint) {
      icon = TacticalIconManager.getIconData((element as TacticalPoint).iconKey);
    } else if (element is TacticalRegion) {
      icon = Icons.map_outlined;
    } else {
      icon = Icons.timeline;
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(width: 40, height: 5, decoration: BoxDecoration(color: colorScheme.outlineVariant, borderRadius: BorderRadius.circular(10))),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  element.label,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Divider(height: 30),
          Row(
            children: [
              Icon(Icons.info_outline, color: colorScheme.primary, size: 20),
              const SizedBox(width: 12),
              Text('Описание:', style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            element.description.isNotEmpty ? element.description : 'Нет описания',
            style: TextStyle(
              fontSize: 16, 
              fontWeight: element.description.isNotEmpty ? FontWeight.bold : FontWeight.normal,
              fontStyle: element.description.isNotEmpty ? FontStyle.normal : FontStyle.italic,
              color: element.description.isNotEmpty ? colorScheme.onSurface : colorScheme.onSurfaceVariant
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
```

---

## File: .\lib\map_components\region_download_sheet.dart
```dart
/*
 * Файл: region_download_sheet.dart
 * Версия: 1.38.7
 * Описание: Модальное окно настройки перед загрузкой оффлайн-региона.
 * Изменения: Шаг 3.4. Интегрировано математическое ядро Slippy Map для точного подсчета количества тайлов (зумы 12-16) и прогнозирования размера кэша. Добавлен предохранитель от переполнения памяти.
 */

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class RegionDownloadSheet extends StatefulWidget {
  final LatLng topLeft;
  final LatLng bottomRight;

  const RegionDownloadSheet({
    super.key,
    required this.topLeft,
    required this.bottomRight,
  });

  @override
  State<RegionDownloadSheet> createState() => _RegionDownloadSheetState();
}

class _RegionDownloadSheetState extends State<RegionDownloadSheet> {
  late TextEditingController _nameController;
  
  int _totalTiles = 0;
  double _estimatedSizeMb = 0.0;
  bool _isOverLimit = false;
  
  // Ограничитель для защиты устройства оператора от зависания и переполнения памяти
  static const int _maxTileLimit = 50000; 

  @override
  void initState() {
    super.initState();
    final h = DateTime.now().hour.toString().padLeft(2, '0');
    final m = DateTime.now().minute.toString().padLeft(2, '0');
    _nameController = TextEditingController(text: 'Регион-$h$m');
    
    _calculateTileMetrics();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Синхронный математический расчет сетки тайлов Меркатора (Slippy Map) без блокировки UI
  void _calculateTileMetrics() {
    int total = 0;

    for (int zoom = 12; zoom <= 16; zoom++) {
      // Перевод долготы в индекс тайла X
      int x1 = ((widget.topLeft.longitude + 180.0) / 360.0 * math.pow(2, zoom)).floor();
      int x2 = ((widget.bottomRight.longitude + 180.0) / 360.0 * math.pow(2, zoom)).floor();
      
      // Перевод широты в индекс тайла Y (Проекция Меркатора)
      double latRad1 = widget.topLeft.latitude * math.pi / 180.0;
      int y1 = ((1.0 - math.log(math.tan(latRad1) + 1.0 / math.cos(latRad1)) / math.pi) / 2.0 * math.pow(2, zoom)).floor();
      
      double latRad2 = widget.bottomRight.latitude * math.pi / 180.0;
      int y2 = ((1.0 - math.log(math.tan(latRad2) + 1.0 / math.cos(latRad2)) / math.pi) / 2.0 * math.pow(2, zoom)).floor();
      
      int minX = math.min(x1, x2);
      int maxX = math.max(x1, x2);
      int minY = math.min(y1, y2);
      int maxY = math.max(y1, y2);
      
      // Количество тайлов на текущем уровне детализации
      int tilesInZoom = (maxX - minX + 1) * (maxY - minY + 1);
      total += tilesInZoom;
    }

    setState(() {
      _totalTiles = total;
      // Средний вес тайла OSM (PNG подложка) составляет ~15 КБ
      _estimatedSizeMb = (total * 15.0) / 1024.0; 
      _isOverLimit = total > _maxTileLimit;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16, right: 16, top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Параметры Оффлайн-Карты',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Имя региона',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.map),
            ),
          ),
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _isOverLimit ? colorScheme.errorContainer : colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
              border: _isOverLimit ? Border.all(color: colorScheme.error, width: 1) : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Масштабы (Zoom): 12 — 16 (зафиксировано)', 
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'Количество тайлов: $_totalTiles шт.', 
                  style: TextStyle(
                    color: _isOverLimit ? colorScheme.onErrorContainer : colorScheme.onSurfaceVariant,
                    fontWeight: _isOverLimit ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                Text(
                  'Ориентировочный размер: ${_estimatedSizeMb.toStringAsFixed(1)} МБ', 
                  style: TextStyle(
                    color: _isOverLimit ? colorScheme.onErrorContainer : colorScheme.onSurfaceVariant,
                    fontWeight: _isOverLimit ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (_isOverLimit) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: colorScheme.error, size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Превышен лимит размера пакета (макс. $_maxTileLimit тайлов). Выделите меньшую область.',
                          style: TextStyle(color: colorScheme.error, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: const Text('ОТМЕНА'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: (_nameController.text.trim().isEmpty || _isOverLimit)
                      ? null 
                      : () {
                          Navigator.pop(context, _nameController.text.trim());
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                  child: const Text('НАЧАТЬ ЗАГРУЗКУ'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
```

---

## File: .\lib\map_components\drawing_controller.dart
```dart
/*
 * Файл: drawing_controller.dart
 * Версия: 1.39.9
 * Изменения: Добавлена логика Hit-Test для TacticalRegion. Тапы определяются по интерполированному контуру borderPath, позволяя корректно взаимодействовать с периметром прямоугольника.
 */

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../ble_service.dart';
import 'drawing_manager.dart';
import 'drawing_models.dart';
import 'drawing_menu_sheet.dart';
import 'drawing_toolbar.dart'; 

class DrawingController {
  final BleService _bleService = BleService();

  Future<void> handleDrawingTap({
    required BuildContext context,
    required LatLng tappedPoint,
    required MapCamera camera,
    required DrawingTool activeTool,
    required List<LatLng> currentDrawingLinePath,
    required VoidCallback onPathUpdated,
  }) async {
    final manager = DrawingManager();
    final metersPerPixel = (math.cos(tappedPoint.latitude * math.pi / 180) * 2 * math.pi * 6378137) / (256 * math.pow(2, camera.zoom));
    final searchRadiusMeters = 40.0 * metersPerPixel;
    const distanceCalculator = Distance();

    TacticalPoint? closestPoint;
    double minPointDistMeters = searchRadiusMeters;

    TacticalLine? closestLine;
    double minLineDistMeters = searchRadiusMeters;

    TacticalRegion? closestRegion;
    double minRegionDistMeters = searchRadiusMeters;

    for (var element in manager.elements) {
      if (element is TacticalPoint) {
        final dist = distanceCalculator.distance(tappedPoint, LatLng(element.lat, element.lon));
        if (dist < minPointDistMeters) {
          minPointDistMeters = dist;
          closestPoint = element;
        }
      } else if (element is TacticalLine) {
        if (element.path.isEmpty) continue;
        for (var latLng in element.path) {
          final dist = distanceCalculator.distance(tappedPoint, latLng);
          if (dist < minLineDistMeters) {
            minLineDistMeters = dist;
            closestLine = element;
          }
        }
      } else if (element is TacticalRegion) {
        // ИЗМЕНЕНИЕ: Обработка попаданий в границы региона. Используется borderPath с плотными точками.
        for (var latLng in element.borderPath) {
          final dist = distanceCalculator.distance(tappedPoint, latLng);
          if (dist < minRegionDistMeters) {
            minRegionDistMeters = dist;
            closestRegion = element;
          }
        }
      }
    }

    if (activeTool == DrawingTool.line) {
      LatLng pointToAdd = tappedPoint;
      
      if (closestPoint != null) {
        pointToAdd = LatLng(closestPoint.lat, closestPoint.lon);
      } else {
        final nodes = _bleService.nodeDatabase.nodes.values.where((n) => n.hasValidGps);
        double minNodeDist = searchRadiusMeters;
        for (var node in nodes) {
          final dist = distanceCalculator.distance(tappedPoint, LatLng(node.lat, node.lon));
          if (dist < minNodeDist) {
            minNodeDist = dist;
            pointToAdd = LatLng(node.lat, node.lon);
          }
        }
      }

      currentDrawingLinePath.add(pointToAdd);
      onPathUpdated();
      return; 
    }

    if (activeTool == DrawingTool.point) {
      final attrs = await showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        isScrollControlled: true,
        builder: (_) => const DrawingMenuSheet(targetType: TacticalType.point),
      );

      if (attrs != null) {
        final newId = DateTime.now().millisecondsSinceEpoch.toString();
        manager.addElement(TacticalPoint(
          id: newId, lat: tappedPoint.latitude, lon: tappedPoint.longitude,
          label: attrs['label'], description: attrs['description'],
          colorHex: attrs['colorHex'], iconKey: attrs['iconKey'],
        ));
      }
      return; 
    }

    // Определяем абсолютно ближайший элемент из всех категорий
    TacticalElement? closest = closestPoint;
    double minDist = minPointDistMeters;

    if (minLineDistMeters < minDist) {
      closest = closestLine;
      minDist = minLineDistMeters;
    }
    if (minRegionDistMeters < minDist) {
      closest = closestRegion;
      minDist = minRegionDistMeters;
    }

    if (closest != null) {
      if (activeTool == DrawingTool.view) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => DrawingInfoSheet(element: closest!),
        );
      } else if (activeTool == DrawingTool.select) {
        final attrs = await showModalBottomSheet<Map<String, dynamic>>(
          context: context,
          isScrollControlled: true,
          builder: (_) => DrawingMenuSheet(
            existingElement: closest,
            targetType: closest!.type,
          ),
        );

        if (attrs != null) {
          if (closest is TacticalPoint) {
            manager.updateElement(TacticalPoint(
              id: closest.id, lat: closest.lat, lon: closest.lon,
              label: attrs['label'], description: attrs['description'],
              colorHex: attrs['colorHex'], iconKey: attrs['iconKey'],
            ));
          } else if (closest is TacticalLine) {
            manager.updateElement(TacticalLine(
              id: closest.id, path: closest.path,
              label: attrs['label'], description: attrs['description'],
              colorHex: attrs['colorHex'], width: attrs['lineWidth'],
            ));
          } else if (closest is TacticalRegion) {
            manager.updateElement(TacticalRegion(
              id: closest.id, topLeft: closest.topLeft, bottomRight: closest.bottomRight,
              label: attrs['label'], description: attrs['description'],
              colorHex: attrs['colorHex'], borderWidth: attrs['lineWidth'], isDashed: closest.isDashed,
            ));
          }
        }
      } else if (activeTool == DrawingTool.eraser) {
        manager.removeElement(closest.id);
      }
    }
  }

  Future<void> processLineCompletion({
    required BuildContext context,
    required List<LatLng> currentDrawingLinePath,
    required VoidCallback onPathCleared,
  }) async {
    if (currentDrawingLinePath.length > 1) {
      final attrs = await showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        isScrollControlled: true,
        builder: (_) => const DrawingMenuSheet(targetType: TacticalType.line),
      );

      if (attrs != null) {
        final newId = DateTime.now().millisecondsSinceEpoch.toString();
        DrawingManager().addElement(TacticalLine(
          id: newId,
          label: attrs['label'],
          description: attrs['description'],
          colorHex: attrs['colorHex'],
          path: List.from(currentDrawingLinePath),
          width: attrs['lineWidth'],
        ));
      }
    }
    onPathCleared();
  }
}
```

---

## File: .\lib\map_components\nodes_layer.dart
```dart
/*
 * Файл: nodes_layer.dart
 * Версия: 1.39.2
 * Описание: Слой карты для отображения треков и маркеров узлов BLE-сети.
 */

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../ble_service.dart';
import '../app_settings.dart';
import 'map_marker_manager.dart';
import '../roster_screen.dart';

class NodesLayer extends StatelessWidget {
  final bool isInteractive;

  const NodesLayer({
    super.key, 
    this.isInteractive = true,
  });

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
    final bleService = BleService();

    return ListenableBuilder(
      listenable: Listenable.merge([
        bleService.nodeDatabase,
        bleService.identityNotifier,
        bleService.sysConfigNotifier,
        AppSettings(),
      ]),
      builder: (context, child) {
        final nodes = bleService.nodeDatabase.nodes.values
            .where((n) => n.hasValidGps)
            .toList();

        final myId = bleService.identityNotifier.value?.myNodeId;
        final timeoutMs = bleService.sysConfigNotifier.value?.nodeConnectionTimeout ?? 600000;
        final now = DateTime.now().millisecondsSinceEpoch;

        return Stack(
          children: [
            PolylineLayer(
              polylines: nodes.map((node) {
                final isMe = node.nodeId == myId;
                final isOnline = isMe ? true : (now - node.lastSeenTimeMs) <= timeoutMs;
                final style = MarkerStyleManager.getStyle(role: node.role, isMe: isMe, isOnline: isOnline);
                
                final track = node.getRecentTrack(AppSettings().trackTimeMs);

                return Polyline(
                  points: track,
                  strokeWidth: AppSettings().trackWidth, 
                  color: style.color.withOpacity(isOnline ? 0.6 : 0.3),
                );
              }).where((p) => p.points.length > 1).toList(), 
            ),
            
            IgnorePointer(
              ignoring: !isInteractive,
              child: MarkerLayer(
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
            ),
          ],
        );
      },
    );
  }
}
```

---

## File: .\lib\map_components\region_selection_layer.dart
```dart
/*
 * Файл: region_selection_layer.dart
 * Версия: 1.39.9
 * Изменения: При инициализации TacticalRegion передаются дефолтные параметры стиля границы (isDashed, borderWidth).
 */

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'drawing_models.dart';
import 'region_download_sheet.dart';

class RegionSelectionLayer extends StatefulWidget {
  final MapController mapController;
  final bool isMapReady;
  final Function(TacticalRegion) onRegionSelected;
  final VoidCallback onCancel;

  const RegionSelectionLayer({
    super.key,
    required this.mapController,
    required this.isMapReady,
    required this.onRegionSelected,
    required this.onCancel,
  });

  @override
  State<RegionSelectionLayer> createState() => _RegionSelectionLayerState();
}

class _RegionSelectionLayerState extends State<RegionSelectionLayer> {
  LatLng? _regionDragStart;
  LatLng? _regionDragCurrent;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_regionDragStart != null && _regionDragCurrent != null)
          PolygonLayer(
            polygons: [
              Polygon(
                points: [
                  _regionDragStart!,
                  LatLng(_regionDragStart!.latitude, _regionDragCurrent!.longitude),
                  _regionDragCurrent!,
                  LatLng(_regionDragCurrent!.latitude, _regionDragStart!.longitude),
                ],
                color: Colors.blue.withOpacity(0.3),
                borderColor: Colors.blue,
                borderStrokeWidth: 2.0,
              )
            ],
          ),
        Positioned.fill(
          child: Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: (event) {
              if (!widget.isMapReady) return;
              final point = widget.mapController.camera.pointToLatLng(math.Point(event.localPosition.dx, event.localPosition.dy));
              setState(() {
                _regionDragStart = point;
                _regionDragCurrent = point;
              });
            },
            onPointerMove: (event) {
              if (_regionDragStart == null || !widget.isMapReady) return;
              final point = widget.mapController.camera.pointToLatLng(math.Point(event.localPosition.dx, event.localPosition.dy));
              setState(() {
                _regionDragCurrent = point;
              });
            },
            onPointerUp: (event) async {
              if (_regionDragStart == null || _regionDragCurrent == null) {
                widget.onCancel();
                return;
              }

              final start = _regionDragStart!;
              final end = _regionDragCurrent!;
              
              const dist = Distance();
              if (dist.distance(start, end) < 50) {
                setState(() {
                  _regionDragStart = null;
                  _regionDragCurrent = null;
                });
                return;
              }

              final double topLat = math.max(start.latitude, end.latitude);
              final double bottomLat = math.min(start.latitude, end.latitude);
              final double leftLon = math.min(start.longitude, end.longitude);
              final double rightLon = math.max(start.longitude, end.longitude);
              
              final topLeft = LatLng(topLat, leftLon);
              final bottomRight = LatLng(bottomLat, rightLon);

              final regionName = await showModalBottomSheet<String>(
                context: context,
                isScrollControlled: true,
                builder: (_) => RegionDownloadSheet(topLeft: topLeft, bottomRight: bottomRight),
              );

              if (regionName != null) {
                final newRegion = TacticalRegion(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  topLeft: topLeft,
                  bottomRight: bottomRight,
                  label: regionName,
                  description: 'Оффлайн карта',
                  colorHex: '#2196F3',
                  borderWidth: 3.0, // ИЗМЕНЕНИЕ: Дефолтная толщина
                  isDashed: true,   // ИЗМЕНЕНИЕ: Дефолтный стиль (пунктир)
                );
                
                widget.onRegionSelected(newRegion);
              } else {
                widget.onCancel();
              }

              setState(() {
                _regionDragStart = null;
                _regionDragCurrent = null;
              });
            },
            onPointerCancel: (event) {
              setState(() {
                _regionDragStart = null;
                _regionDragCurrent = null;
              });
            },
            child: Container(color: Colors.transparent),
          ),
        ),
      ],
    );
  }
}
```

---

