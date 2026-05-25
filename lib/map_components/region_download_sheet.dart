/*
 * Файл: region_download_sheet.dart
 * Версия: 1.38.4
 * Описание: Модальное окно настройки перед загрузкой оффлайн-региона.
 */

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class RegionDownloadSheet extends StatefulWidget {
  final LatLng topLeft;
  final LatLng bottomRight;

  const RegionDownloadSheet({
    super.key,
    required this.topLeft,
    required this.bottomRight,
  });

  @override
  State<RegionDownloadSheet> createState() => _RegionDownloadSheetState();
}

class _RegionDownloadSheetState extends State<RegionDownloadSheet> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final h = DateTime.now().hour.toString().padLeft(2, '0');
    final m = DateTime.now().minute.toString().padLeft(2, '0');
    _nameController = TextEditingController(text: 'Регион-$h$m');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16, right: 16, top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Параметры Оффлайн-Карты',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Имя региона',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.map),
            ),
          ),
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Масштабы (Zoom): 12 — 16 (зафиксировано)', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Количество тайлов: подсчет...', style: TextStyle(color: colorScheme.onSurfaceVariant)),
                Text('Ориентировочный размер: подсчет...', style: TextStyle(color: colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: const Text('ОТМЕНА'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (_nameController.text.trim().isEmpty) return;
                    Navigator.pop(context, _nameController.text.trim());
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                  child: const Text('НАЧАТЬ ЗАГРУЗКУ'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}