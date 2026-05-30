/*
 * Файл: region_download_sheet.dart
 * Версия: 1.38.7
 * Описание: Модальное окно настройки перед загрузкой оффлайн-региона.
 * Изменения: Шаг 3.4. Интегрировано математическое ядро Slippy Map для точного подсчета количества тайлов (зумы 12-16) и прогнозирования размера кэша. Добавлен предохранитель от переполнения памяти.
 */

import 'dart:math' as math;
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
  
  int _totalTiles = 0;
  double _estimatedSizeMb = 0.0;
  bool _isOverLimit = false;
  
  // Ограничитель для защиты устройства оператора от зависания и переполнения памяти
  static const int _maxTileLimit = 50000; 

  @override
  void initState() {
    super.initState();
    final h = DateTime.now().hour.toString().padLeft(2, '0');
    final m = DateTime.now().minute.toString().padLeft(2, '0');
    _nameController = TextEditingController(text: 'Регион-$h$m');
    
    _calculateTileMetrics();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Синхронный математический расчет сетки тайлов Меркатора (Slippy Map) без блокировки UI
  void _calculateTileMetrics() {
    int total = 0;

    for (int zoom = 12; zoom <= 16; zoom++) {
      // Перевод долготы в индекс тайла X
      int x1 = ((widget.topLeft.longitude + 180.0) / 360.0 * math.pow(2, zoom)).floor();
      int x2 = ((widget.bottomRight.longitude + 180.0) / 360.0 * math.pow(2, zoom)).floor();
      
      // Перевод широты в индекс тайла Y (Проекция Меркатора)
      double latRad1 = widget.topLeft.latitude * math.pi / 180.0;
      int y1 = ((1.0 - math.log(math.tan(latRad1) + 1.0 / math.cos(latRad1)) / math.pi) / 2.0 * math.pow(2, zoom)).floor();
      
      double latRad2 = widget.bottomRight.latitude * math.pi / 180.0;
      int y2 = ((1.0 - math.log(math.tan(latRad2) + 1.0 / math.cos(latRad2)) / math.pi) / 2.0 * math.pow(2, zoom)).floor();
      
      int minX = math.min(x1, x2);
      int maxX = math.max(x1, x2);
      int minY = math.min(y1, y2);
      int maxY = math.max(y1, y2);
      
      // Количество тайлов на текущем уровне детализации
      int tilesInZoom = (maxX - minX + 1) * (maxY - minY + 1);
      total += tilesInZoom;
    }

    setState(() {
      _totalTiles = total;
      // Средний вес тайла OSM (PNG подложка) составляет ~15 КБ
      _estimatedSizeMb = (total * 15.0) / 1024.0; 
      _isOverLimit = total > _maxTileLimit;
    });
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
              color: _isOverLimit ? colorScheme.errorContainer : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              border: _isOverLimit ? Border.all(color: colorScheme.error, width: 1) : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Масштабы (Zoom): 12 — 16 (зафиксировано)', 
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'Количество тайлов: $_totalTiles шт.', 
                  style: TextStyle(
                    color: _isOverLimit ? colorScheme.onErrorContainer : colorScheme.onSurfaceVariant,
                    fontWeight: _isOverLimit ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                Text(
                  'Ориентировочный размер: ${_estimatedSizeMb.toStringAsFixed(1)} МБ', 
                  style: TextStyle(
                    color: _isOverLimit ? colorScheme.onErrorContainer : colorScheme.onSurfaceVariant,
                    fontWeight: _isOverLimit ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (_isOverLimit) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: colorScheme.error, size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Превышен лимит размера пакета (макс. $_maxTileLimit тайлов). Выделите меньшую область.',
                          style: TextStyle(color: colorScheme.error, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
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
                  onPressed: (_nameController.text.trim().isEmpty || _isOverLimit)
                      ? null 
                      : () {
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