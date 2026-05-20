/*
 * Файл: main_menu_screen.dart
 * Версия: 1.26
 * Изменения: ЭТАП 4, Шаг 2. Выделено главное меню. Внедрена защита (PopScope и Listener) для корректной отработки потери соединения.
 * Описание: Главный дашборд управления Донглом.
 */

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_config.dart';
import 'ble_protocol.dart';
import 'ble_service.dart';
import 'roster_screen.dart';
import 'map_screen.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  final BleService _bleService = BleService();

  @override
  void initState() {
    super.initState();
    // Подписываемся на разрыв связи (например, если Донгл выключился)
    _bleService.isConnected.addListener(_connectionListener);
  }

  @override
  void dispose() {
    _bleService.isConnected.removeListener(_connectionListener);
    super.dispose();
  }

  void _connectionListener() {
    // Если связь оборвалась, автоматически закрываем меню и возвращаемся в сканер
    if (!_bleService.isConnected.value && mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

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
    // PopScope защищает от системного жеста "Назад", гарантируя отключение BLE
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        await _bleService.disconnect(); 
        // При вызове disconnect изменится isConnected, и сработает _connectionListener
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Naviga v${AppConfig.version} Меню'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton.icon(
                onPressed: () => _bleService.disconnect(),
                icon: const Icon(Icons.bluetooth_disabled),
                label: Text('Отключить ${_bleService.connectedDeviceName.value}'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.red.shade100,
                ),
              ),
              const SizedBox(height: 20),

              // --- БЛОК ТОПОЛОГИИ СЕТИ (Список) ---
              ListenableBuilder(
                listenable: Listenable.merge([_bleService.nodeDatabase, _bleService.identityNotifier]),
                builder: (context, child) {
                  final myId = _bleService.identityNotifier.value?.myNodeId;
                  final neighborsCount = _bleService.nodeDatabase.getNeighborsCount(myId);

                  return Card(
                    elevation: 4,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RosterScreen()),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            const Icon(Icons.hub, color: Colors.blue, size: 32),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Топология Сети (Список)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  Text('Найдено соседей: $neighborsCount', style: const TextStyle(fontSize: 16)),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),

              // --- БЛОК КАРТЫ С УМНОЙ БЛОКИРОВКОЙ ---
              ListenableBuilder(
                listenable: _bleService.nodeDatabase,
                builder: (context, child) {
                  final hasValidGps = _bleService.nodeDatabase.hasAnyValidGps;

                  return Card(
                    elevation: hasValidGps ? 4 : 1,
                    color: hasValidGps ? Colors.blueGrey.shade50 : Colors.grey.shade200,
                    child: InkWell(
                      onTap: hasValidGps ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MapScreen()),
                        );
                      } : null, 
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(Icons.map, color: hasValidGps ? Colors.deepOrange : Colors.grey, size: 32),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(hasValidGps ? 'Карта (Naviga Map)' : 'Карта недоступна', 
                                    style: TextStyle(
                                      fontSize: 18, 
                                      fontWeight: FontWeight.bold,
                                      color: hasValidGps ? Colors.black87 : Colors.grey.shade600
                                    )),
                                  Text(hasValidGps ? 'Визуализация узлов' : 'Ожидание геоданных из сети...', 
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: hasValidGps ? Colors.black87 : Colors.grey.shade600
                                    )),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right, color: hasValidGps ? Colors.grey : Colors.transparent),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              
              // --- БЛОК ТЕЛЕМЕТРИИ С ПОДДЕРЖКОЙ ANCHOR ---
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

                  String gpsText;
                  Color gpsColor;
                  bool showAnchorButton = false;

                  switch (status.gpsState) {
                    case 0:
                      gpsText = 'Поиск спутников...';
                      gpsColor = Colors.orange.shade700;
                      showAnchorButton = true; 
                      break;
                    case 1:
                      gpsText = 'Зафиксирован (Fix OK)';
                      gpsColor = Colors.green.shade700;
                      showAnchorButton = false; 
                      break;
                    case 2:
                      gpsText = 'Нет'; 
                      gpsColor = Colors.blueGrey;
                      showAnchorButton = true; 
                      break;
                    default:
                      gpsText = 'Неизвестный статус (${status.gpsState})';
                      gpsColor = Colors.red;
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
                          Row(
                            children: [
                              const Text('GPS: ', style: TextStyle(fontSize: 16)),
                              Text(gpsText, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: gpsColor)),
                            ],
                          ),
                          if (status.gpsState != 2)
                            Text('Спутники: ${status.satellites}', style: const TextStyle(fontSize: 16)),
                          
                          if (showAnchorButton) ...[
                            const SizedBox(height: 14),
                            const Divider(height: 1),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: () => _bleService.sendAnchorCoords(),
                              icon: const Icon(Icons.pin_drop_rounded),
                              label: const Text('ПЕРЕДАТЬ КООРДИНАТЫ СМАРТФОНА (ANCHOR)'),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(45),
                                backgroundColor: Colors.deepOrange.shade50,
                                foregroundColor: Colors.deepOrange.shade800,
                                side: BorderSide(color: Colors.deepOrange.shade200),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),

              // --- БЛОК ИДЕНТИФИКАЦИИ ---
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

              // --- БЛОК СИСТЕМНЫХ ТАЙМЕРОВ ---
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
        ),
      ),
    );
  }
}

// ============================================================================
// Вспомогательные классы и экраны настроек (EditIdentity, EditSysConfig)
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

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Внимание!', style: TextStyle(color: Colors.red)),
          content: const Text(
            'Вы уверены? Это действие безвозвратно удалит все данные на Донгле, сбросит его Имя и Роль, а также разорвет текущее соединение.'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('ОТМЕНА'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _bleService.factoryReset();
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('СБРОСИТЬ'),
            ),
          ],
        );
      },
    );
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
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: Colors.blueAccent, 
                foregroundColor: Colors.white
              ),
              child: const Text('СОХРАНИТЬ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () => _showResetDialog(context),
              icon: const Icon(Icons.warning_amber_rounded),
              label: const Text('СБРОС К ЗАВОДСКИМ НАСТРОЙКАМ'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

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