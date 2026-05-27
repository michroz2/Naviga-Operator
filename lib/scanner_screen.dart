/*
 * Файл: scanner_screen.dart
 * Версия: 1.41.0
 * Изменения: Добавлен автоматический старт сканирования при инициализации экрана (холодный старт) и при возврате из главного меню (после отключения).
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
  void initState() {
    super.initState();
    // Автоматический запуск сканирования при холодном старте экрана
    _bleService.startScan();
  }

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
                    // Динамические контрастные цвета вместо жесткого Colors.blue.shade100
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
                              await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const MainMenuScreen()),
                              );
                              // Автоматический запуск сканирования при возврате на этот экран (после отключения)
                              _bleService.startScan();
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