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