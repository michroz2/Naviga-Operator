/*
 * Файл: main.dart
 * Версия: 1.11
 * Изменения: Добавлен EditSysConfigScreen для редактирования системных таймеров (UC-01). 
 * Восстановлено полное именование переменных и методов.
 * Описание: Главный экран приложения.
 */

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'ble_protocol.dart';
import 'ble_service.dart';

void main() {
  print('\n=========================================');
  print('===== ОПЕРАТОР START version 1.11 =====');
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
        title: const Text('Naviga v1.11 Setup'),
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
      body: ValueListenableBuilder<bool>(
        valueListenable: _bleService.isConnected,
        builder: (context, isConnected, child) {
          if (isConnected) {
            return _buildConnectedView();
          } else {
            return _buildScanningView();
          }
        },
      ),
    );
  }

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

  Widget _buildConnectedView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            onPressed: _bleService.disconnect,
            icon: const Icon(Icons.bluetooth_disabled),
            label: Text('Отключить ${_bleService.connectedDeviceName.value}'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              backgroundColor: Colors.red.shade100,
            ),
          ),
          const SizedBox(height: 20),
          
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
                      Text('GPS: ${status.gpsValid == 1 ? 'Зафиксирован' : 'Поиск...'}', style: const TextStyle(fontSize: 16)),
                      Text('Спутники: ${status.satellites}', style: const TextStyle(fontSize: 16)),
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
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditIdentityScreen(currentIdentity: identity),
                                ),
                              );
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
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditSysConfigScreen(config: config),
                                ),
                              );
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
        ],
      ),
    );
  }
}

// ============================================================================
// Вспомогательный класс: Ограничение длины строки в байтах UTF-8
// ============================================================================
class Utf8ByteLengthFormatter extends TextInputFormatter {
  final int maxBytes;
  Utf8ByteLengthFormatter(this.maxBytes);
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (utf8.encode(newValue.text).length > maxBytes) return oldValue;
    return newValue;
  }
}

// ============================================================================
// ЭКРАН: Редактирование Идентификации (UC-01)
// ============================================================================
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
  void dispose() { 
    _nameController.dispose(); 
    super.dispose(); 
  }

  @override
  Widget build(BuildContext context) {
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
              decoration: const InputDecoration(
                labelText: 'Имя устройства', 
                border: OutlineInputBorder(),
                helperText: 'Допускается до 23 латинских букв или 11 русских',
              ),
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
              onChanged: (int? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedRole = newValue;
                  });
                }
              },
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                _bleService.setIdentity(widget.currentIdentity.myNodeId, _nameController.text, _selectedRole);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
              child: const Text('СОХРАНИТЬ'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// ЭКРАН: Редактирование Системных Таймеров
// ============================================================================
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
  void dispose() { 
    _movingController.dispose(); 
    _stillController.dispose(); 
    _connTimeoutController.dispose(); 
    _activeTimeoutController.dispose(); 
    super.dispose(); 
  }

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
                backgroundColor: Colors.blueAccent, 
                foregroundColor: Colors.white,
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
        inputFormatters: [FilteringTextInputFormatter.digitsOnly], 
        decoration: InputDecoration(
          labelText: label, 
          suffixText: 'сек', 
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}