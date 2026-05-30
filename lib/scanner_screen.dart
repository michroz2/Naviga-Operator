/*
 * Файл: scanner_screen.dart
 * Версия: 1.41.6
 * Изменения: Добавлена карточка «Без подключения к Донглу» для быстрого перехода в полноценный автономный оффлайн-режим работы.
 * Описание: Экран сканирования BLE устройств.
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'app_config.dart';
import 'app_settings.dart';
import 'ble_service.dart';
import 'main_menu_screen.dart';
import 'offline_menu_screen.dart'; // ИЗМЕНЕНИЕ 1.41.6: Импорт автономного меню

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final BleService _bleService = BleService();
  bool _isAutoConnecting = false;

  @override
  void initState() {
    super.initState();
    _checkAutoConnect();
  }

  Future<void> _checkAutoConnect() async {
    final savedId = AppSettings().savedDongleId;
    
    if (savedId.isNotEmpty) {
      setState(() {
        _isAutoConnecting = true;
      });
      
      try {
        final device = BluetoothDevice.fromId(savedId);
        await _bleService.connectToDevice(device);
        
        if (_bleService.isConnected.value && mounted) {
          setState(() {
            _isAutoConnecting = false;
          });
          
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MainMenuScreen()),
          );
          
          _bleService.startScan();
          return;
        }
      } catch (e) {
        debugPrint('Ошибка автоподключения: $e');
      }
      
      if (mounted) {
        setState(() {
          _isAutoConnecting = false;
        });
      }
    }
    
    _bleService.startScan();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
      body: _isAutoConnecting
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text('Автоподключение к ${AppSettings().savedDongleName}...'),
                ],
              ),
            )
          : Column(
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
                          backgroundColor: colorScheme.primaryContainer,
                          foregroundColor: colorScheme.onPrimaryContainer,
                        ),
                      );
                    },
                  ),
                ),
                
                // ИЗМЕНЕНИЕ 1.41.6: Статическая карточка автономного режима над списком устройств
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                  elevation: 2,
                  child: ListTile(
                    leading: Icon(Icons.cloud_off_rounded, color: colorScheme.secondary),
                    title: const Text('Без подключения к Донглу', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Автономный режим (Карты, Настройки, Обмен)'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const OfflineMenuScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),

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
                                  
                                  if (_bleService.isConnected.value && context.mounted) {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const MainMenuScreen()),
                                    );
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