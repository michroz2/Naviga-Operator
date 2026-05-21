/*
 * Файл: main.dart
 * Версия: 1.32.3
 * Изменения: ЭТАП Настроек, Шаг 4. Добавлена асинхронная загрузка локальных настроек из SharedPreferences перед запуском UI.
 * Описание: Главная точка входа в приложение с поддержкой фонового режима.
 */

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'app_config.dart';
import 'scanner_screen.dart';
import 'background_manager.dart';
import 'app_settings.dart'; // ИЗМЕНЕНИЕ 1.32.3: Импортируем менеджер настроек

void main() async {
  // Гарантируем инициализацию фреймворка перед обращением к нативным плагинам
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализируем конфигурацию фонового сервиса
  await BackgroundManager.initializeService();

  // ИЗМЕНЕНИЕ 1.32.3: Загружаем сохраненные настройки с диска смартфона
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