/*
 * Файл: settings_screen.dart
 * Версия: 1.33.2
 * Изменения: UC-23, Шаг 2. Добавлен UI для управления отображением сетки и выбором дефолтного режима компаса.
 * Описание: Экран управления локальными настройками приложения.
 */

import 'package:flutter/material.dart';
import 'app_settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AppSettings _settings = AppSettings();

  // Локальный буфер текущей сессии редактирования
  late int _trackTimeMs;
  late double _trackWidth;
  late double _jitterRadius;
  late int _jitterPoints;
  late bool _keepScreenOn;
  late bool _darkTheme;
  late bool _showGrid;
  late int _compassMode;

  // Флаг, указывающий, что пользователь явно отменил изменения
  bool _isCancelled = false;

  final Map<int, String> _trackTimeOptions = {
    300000: '5 минут',
    900000: '15 минут',
    1800000: '30 минут',
    3600000: '1 час',
    7200000: '2 часа',
    0: 'Не ограничено',
  };

  final Map<int, String> _compassOptions = {
    0: 'Север всегда сверху',
    1: 'Свободное вращение',
    2: 'По магнитному компасу',
  };

  @override
  void initState() {
    super.initState();
    // Кэшируем глобальные настройки в локальный буфер при инициализации экрана
    _trackTimeMs = _settings.trackTimeMs;
    _trackWidth = _settings.trackWidth;
    _jitterRadius = _settings.jitterRadius;
    _jitterPoints = _settings.jitterPoints;
    _keepScreenOn = _settings.keepScreenOn;
    _darkTheme = _settings.darkTheme;
    _showGrid = _settings.showGrid;
    _compassMode = _settings.compassMode;
  }

  // Метод сохранения локального буфера в глобальные настройки
  void _saveAllSettings() {
    _settings.setTrackTimeMs(_trackTimeMs);
    _settings.setTrackWidth(_trackWidth);
    _settings.setJitterRadius(_jitterRadius);
    _settings.setJitterPoints(_jitterPoints);
    _settings.setKeepScreenOn(_keepScreenOn);
    _settings.setDarkTheme(_darkTheme);
    _settings.setShowGrid(_showGrid);
    _settings.setCompassMode(_compassMode);
  }

  // Диалог подтверждения сброса настроек по умолчанию
  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Сброс настроек'),
          content: const Text('Вы уверены, что хотите восстановить все настройки приложения по умолчанию?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('ОТМЕНА'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                setState(() {
                  // Выставляем первоначальные жесткие дефолты в буфер
                  _trackTimeMs = 1800000;
                  _trackWidth = 4.0;
                  _jitterRadius = 10.0;
                  _jitterPoints = 3;
                  _keepScreenOn = false;
                  _darkTheme = false;
                  _showGrid = false;
                  _compassMode = 0;
                });
              },
              style: TextButton.styleFrom(foregroundColor: Colors.orange.shade900),
              child: const Text('СБРОСИТЬ'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // PopScope перехватывает выход с экрана (нажатие "Назад" в AppBar или системный жест)
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (didPop && !_isCancelled) {
          // Если это штатный выход (не через кнопку Отмена), применяем изменения
          _saveAllSettings();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Настройки приложения'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          children: [
            _buildSectionHeader(Icons.map, 'Визуализация на карте'),
            SwitchListTile(
              title: const Text('Координатная сетка', style: TextStyle(fontWeight: FontWeight.w500)),
              subtitle: const Text('Отображение географической сетки поверх карты'),
              value: _showGrid,
              onChanged: (val) => setState(() => _showGrid = val),
            ),
            _buildDropdownRow(
              'Режим компаса',
              _compassMode,
              _compassOptions,
              (val) => setState(() => _compassMode = val as int),
            ),
            _buildDropdownRow(
              'Время отображения трека',
              _trackTimeMs,
              _trackTimeOptions,
              (val) => setState(() => _trackTimeMs = val as int),
            ),
            _buildSliderRow(
              'Толщина линии трека',
              _trackWidth,
              1.0,
              10.0,
              9,
              (val) => setState(() => _trackWidth = val),
            ),
            const Divider(height: 32),

            _buildSectionHeader(Icons.filter_alt, 'Фильтр блуждания'),
            _buildSliderRow(
              'Радиус фильтрации',
              _jitterRadius,
              5.0,
              30.0,
              25,
              (val) => setState(() => _jitterRadius = val),
              suffix: ' м',
            ),
            _buildSliderRow(
              'Количество проверяемых точек',
              _jitterPoints.toDouble(),
              1.0,
              10.0,
              9,
              (val) => setState(() => _jitterPoints = val.toInt()),
              isInteger: true,
            ),
            const Divider(height: 32),

            _buildSectionHeader(Icons.settings_system_daydream, 'Системные'),
            SwitchListTile(
              title: const Text('Не гасить карту', style: TextStyle(fontWeight: FontWeight.w500)),
              subtitle: const Text('Предотвращает засыпание устройства на Карте'),
              value: _keepScreenOn,
              onChanged: (val) => setState(() => _keepScreenOn = val),
            ),
            SwitchListTile(
              title: const Text('Тёмная тема', style: TextStyle(fontWeight: FontWeight.w500)),
              subtitle: const Text('Снижает расход батареи смартфона'),
              value: _darkTheme,
              onChanged: (val) => setState(() => _darkTheme = val),
            ),
            
            const SizedBox(height: 24),
            const Divider(height: 1),
            const SizedBox(height: 24),

            // БЛОК УПРАВЛЕНИЯ ИЗМЕНЕНИЯМИ (Кнопки)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _isCancelled = true; // Выставляем флаг отмены
                        });
                        Navigator.pop(context); // Выходим, PopScope увидит флаг и не запишет данные
                      },
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('Отменить изменения'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey.shade400),
                        foregroundColor: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showResetConfirmation(context),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('По умолчанию'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.orange.shade50,
                        foregroundColor: Colors.orange.shade900,
                        elevation: 0,
                        side: BorderSide(color: Colors.orange.shade200),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Вспомогательные виджеты ---

  Widget _buildSectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey, size: 24),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownRow(String label, int currentValue, Map<int, String> options, Function(int?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
          DropdownButton<int>(
            value: currentValue,
            items: options.entries.map((entry) {
              return DropdownMenuItem<int>(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSliderRow(String label, double value, double min, double max, int divisions, Function(double) onChanged, {String suffix = '', bool isInteger = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              Text('${isInteger ? value.toInt() : value.toStringAsFixed(1)}$suffix', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}