/*
 * Файл: main.dart
 * Версия: 1.5
 * Изменения: UI адаптирован для отображения списка найденных Донглов с сортировкой по RSSI. Подключение осуществляется по нажатию на элемент списка.
 * Описание: Главный экран приложения.
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'ble_protocol.dart';
import 'ble_service.dart';

void main() {
  print('\n=========================================');
  print('===== ОПЕРАТОР START version 1.5 =====');
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
  final BleService _bleService = BleService();

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Naviga Setup'),
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
      // Используем ValueListenableBuilder на уровне body, чтобы переключать экраны
      body: ValueListenableBuilder<bool>(
        valueListenable: _bleService.isConnected,
        builder: (context, isConnected, child) {
          if (isConnected) {
            // --- ЭКРАН 2: ПОДКЛЮЧЕНО (ОТОБРАЖЕНИЕ ДАННЫХ) ---
            return _buildConnectedView();
          } else {
            // --- ЭКРАН 1: ПОИСК И СПИСОК УСТРОЙСТВ ---
            return _buildScanningView();
          }
        },
      ),
    );
  }

  // Виджет для состояния сканирования
  Widget _buildScanningView() {
    return Column(
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
                  // Извлекаем имя для отображения в списке
                  String deviceName = r.device.platformName.isEmpty ? r.device.advName : r.device.platformName;
                  
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: ListTile(
                      leading: const Icon(Icons.bluetooth, color: Colors.blue),
                      title: Text(deviceName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('MAC: ${r.device.remoteId}\nМощность сигнала (RSSI): ${r.rssi} dBm'),
                      trailing: ElevatedButton(
                        onPressed: () => _bleService.connectToDevice(r.device),
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
    );
  }

  // Виджет для состояния успешного подключения (Карточки)
  Widget _buildConnectedView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            onPressed: _bleService.disconnect,
            icon: const Icon(Icons.bluetooth_disabled),
            label: const Text('Отключить Донгл'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              backgroundColor: Colors.red.shade100,
            ),
          ),
          const SizedBox(height: 20),
          
          ValueListenableBuilder<BleIdentity?>(
            valueListenable: _bleService.identityNotifier,
            builder: (context, identity, child) {
              if (identity == null) return const Center(child: CircularProgressIndicator());
              return Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Идентификация Узла', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                      const Text('Системные Таймеры', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
    );
  }
}