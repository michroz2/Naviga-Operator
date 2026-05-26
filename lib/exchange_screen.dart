/*
 * Файл: exchange_screen.dart
 * Версия: 1.39.10
 * Описание: Хаб управления локальными данными (Data Management).
 * Изменения: Полный редизайн. Добавлены секции для тактики и оффлайн-карт, а также защищенные красные кнопки полного удаления данных (Очистка кэша и Очистка разметки).
 */

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';

import 'map_components/drawing_manager.dart';
import 'map_components/drawing_storage.dart';
import 'map_components/drawing_models.dart';

class ExchangeScreen extends StatefulWidget {
  const ExchangeScreen({super.key});

  @override
  State<ExchangeScreen> createState() => _ExchangeScreenState();
}

class _ExchangeScreenState extends State<ExchangeScreen> {
  
  // ==========================================================
  // ТАКТИЧЕСКАЯ РАЗМЕТКА
  // ==========================================================
  Future<void> _exportMarkup() async {
    final manager = DrawingManager();
    final pointsAndLines = manager.elements.where((e) => e.type != TacticalType.region).toList();

    if (pointsAndLines.isEmpty) {
      _showError('Ваша тактическая карта пуста. Нечего отправлять.');
      return;
    }

    try {
      final path = await DrawingStorage().prepareExportFile(pointsAndLines);
      await Share.shareXFiles(
        [XFile(path, mimeType: 'application/json')], 
        text: 'Тактическая разметка Naviga',
      );
    } catch (e) {
      _showError('Ошибка экспорта разметки: $e');
    }
  }

  Future<void> _importMarkup() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any);
      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;
        final importedElements = await DrawingStorage().parseImportFile(path);
        
        if (importedElements.isEmpty) {
          _showError('Файл пуст или имеет неверный формат.');
          return;
        }
        _showMergeDialog(importedElements);
      }
    } catch (e) {
      _showError('Ошибка импорта: $e');
    }
  }

  void _showMergeDialog(List<TacticalElement> importedElements) {
    int points = importedElements.whereType<TacticalPoint>().length;
    int lines = importedElements.whereType<TacticalLine>().length;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        final colorScheme = Theme.of(context).colorScheme;
        return AlertDialog(
          title: const Text('Получена Разметка'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Объектов: Точек ($points), Линий ($lines)', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text('Как применить эти данные к вашей карте?'),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsOverflowDirection: VerticalDirection.down,
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  DrawingManager().clearTacticalMarkup();
                  DrawingManager().importElements(importedElements, replace: false);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Данные ЗАМЕНЕНЫ')));
                },
                icon: const Icon(Icons.warning_amber_rounded),
                label: const Text('ЗАМЕНИТЬ СТАРУЮ РАЗМЕТКУ'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.errorContainer, 
                  foregroundColor: colorScheme.onErrorContainer
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  DrawingManager().importElements(importedElements, replace: false);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Данные ДОБАВЛЕНЫ')));
                },
                icon: const Icon(Icons.library_add),
                label: const Text('ДОБАВИТЬ К СУЩЕСТВУЮЩЕЙ'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primaryContainer, 
                  foregroundColor: colorScheme.onPrimaryContainer
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('ОТМЕНА', style: TextStyle(color: Colors.grey)),
            ),
          ],
        );
      },
    );
  }

  void _confirmClearMarkup() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удаление разметки', style: TextStyle(color: Colors.red)),
        content: const Text('Вы уверены, что хотите полностью удалить все нарисованные точки и линии? Отменить это действие невозможно.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('ОТМЕНА')),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              DrawingManager().clearTacticalMarkup();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Тактическая разметка полностью удалена.')));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('УДАЛИТЬ ВСЁ'),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // ОФФЛАЙН КАРТЫ
  // ==========================================================
  void _futureFeature() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Эта функция будет доступна в следующих версиях.'),
        backgroundColor: Colors.blueGrey,
      ),
    );
  }

  void _confirmClearCache() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Очистка кэша карт', style: TextStyle(color: Colors.red)),
        content: const Text('Это удалит ВСЕ скачанные фрагменты оффлайн-карт и выделенные регионы с устройства.\n\nПродолжить?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('ОТМЕНА')),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                final store = FMTCStore('NavigaStore');
                await store.manage.delete();
                await store.manage.create();
                DrawingManager().clearRegions();
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Кэш карт успешно очищен.')));
                }
              } catch (e) {
                _showError('Ошибка при очистке кэша: $e');
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('ОЧИСТИТЬ КЭШ'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // ==========================================================
  // UI СБОРКА
  // ==========================================================
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Данные и Обмен'),
        backgroundColor: colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          _buildActionCard(
            context,
            title: 'Тактическая Разметка',
            subtitle: 'Импорт, Экспорт и удаление нарисованных точек и линий (маршрутов).',
            icon: Icons.edit_location_alt,
            onSend: _exportMarkup,
            onLoad: _importMarkup,
            onClear: _confirmClearMarkup,
            clearText: 'ОЧИСТИТЬ ВСЮ РАЗМЕТКУ',
          ),
          const SizedBox(height: 24),
          _buildActionCard(
            context,
            title: 'Оффлайн Карты (Кэш)',
            subtitle: 'Управление массивом скачанных географических тайлов.',
            icon: Icons.map_outlined,
            onSend: _futureFeature,
            onLoad: _futureFeature,
            onClear: _confirmClearCache,
            clearText: 'ОЧИСТИТЬ ВЕСЬ КЭШ КАРТ',
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onSend,
    required VoidCallback onLoad,
    required VoidCallback onClear,
    required String clearText,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, color: colorScheme.primary, size: 28),
                const SizedBox(width: 12),
                Expanded(child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
              ],
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant)),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onSend,
                    icon: const Icon(Icons.send_rounded, size: 20),
                    label: const Text('ЭКСПОРТ'),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onLoad,
                    icon: const Icon(Icons.download_rounded, size: 20),
                    label: const Text('ИМПОРТ'),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.delete_forever),
              label: Text(clearText),
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.error,
                side: BorderSide(color: colorScheme.error.withOpacity(0.5)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}