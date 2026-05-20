/*
 * Файл: main.dart
 * Версия: 1.26
 * Изменения: ЭТАП 4, Шаг 1 (Рефакторинг ядра). Файл полностью очищен от громоздкой UI-логики. Оставлена только инициализация и роутинг на экран сканера.
 * Описание: Главная точка входа в приложение.
 */

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'app_config.dart';
import 'scanner_screen.dart';

void main() {
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
      // Маршрутизация на новый выделенный экран сканирования
      home: const ScannerScreen(), 
    );
  }
}