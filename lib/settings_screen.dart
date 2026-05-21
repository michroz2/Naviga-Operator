/*
 * Файл: settings_screen.dart
 * Версия: 1.32.0
 * Изменения: ЭТАП Настроек, Шаг 1. Создан визуальный каркас экрана настроек приложения.
 * Описание: Экран управления локальными настройками приложения.
 */

import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Временные локальные переменные для визуального тестирования (Шаг 1)
  int _trackTimeMs = 1800000; // 30 минут по умолчанию
  double _trackWidth = 4.0;
  double _jitterRadius = 10.0;
  int _jitterPoints = 3;
  bool _keepScreenOn = false;
  bool _darkTheme = false;

  final Map<int, String> _trackTimeOptions = {
    300000: '5 минут',
    900000: '15 минут',
    1800000: '30 минут',
    3600000: '1 час',
    7200000: '2 часа',
    0: 'Не ограничено',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки приложения'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        children: [
          _buildSectionHeader(Icons.map, 'Визуализация на карте'),
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

          _buildSectionHeader(Icons.filter_alt, 'Анти-джиттер фильтр'),
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
            title: const Text('Не выключать экран (Wakelock)', style: TextStyle(fontWeight: FontWeight.w500)),
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
        ],
      ),
    );
  }

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