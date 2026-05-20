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