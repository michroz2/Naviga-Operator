/*
 * Файл: main.dart
 * Версия: 1.2
 * Изменения: Добавлена кнопка и логика вызова BLE-сервиса для сканирования эфира.
 * Описание: Главный экран приложения. Содержит базовый UI оператора.
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ble_service.dart'; // Подключаем наш сервис связи

void main() {
  // Этот лог появится в консоли самым первым при старте приложения на смартфоне
  print('\n=========================================');
  print('===== ОПЕРАТОР START version 1.3 =====');
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
      home: const HelloOperatorScreen(),
    );
  }
}

class HelloOperatorScreen extends StatefulWidget {
  const HelloOperatorScreen({super.key});

  @override
  State<HelloOperatorScreen> createState() => _HelloOperatorScreenState();
}

class _HelloOperatorScreenState extends State<HelloOperatorScreen> {
  // Инициализируем наш Singleton-сервис связи
  final BleService _bleService = BleService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Naviga Operator'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Тест связи с Донглом',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Вызов метода сканирования и подключения
                _bleService.scanAndConnect();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Подключить Донгл',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Корректное отключение перед выходом
                _bleService.disconnect();
                SystemNavigator.pop();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text('Выход', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}