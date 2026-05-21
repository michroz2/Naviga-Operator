/*
 * Файл: main.dart
 * Версия: 1.32.7
 * Изменения: ЭТАП Настроек, Шаг 7. Корневой виджет подписан на AppSettings. Настроена поддержка темной темы (ThemeMode).
 * Описание: Главная точка входа в приложение с поддержкой фонового режима.
 */

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'app_config.dart';
import 'scanner_screen.dart';
import 'background_manager.dart';
import 'app_settings.dart'; 

void main() async {
  // Гарантируем инициализацию фреймворка перед обращением к нативным плагинам
  WidgetsFlutterBinding.ensureInitialized();

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
    // ИЗМЕНЕНИЕ 1.32.7: Подписываем всё приложение на настройки, чтобы тема менялась на лету
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