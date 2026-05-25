/*
 * Файл: exchange_screen.dart
 * Версия: 1.37.2
 * Описание: Экран управления импортом и экспортом данных (Разметка и Карты).
 */

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';

import 'map_components/drawing_manager.dart';
import 'map_components/drawing_storage.dart';
import 'map_components/drawing_models.dart';

class ExchangeScreen extends StatefulWidget {
  const ExchangeScreen({super.key});

  @override
  State<ExchangeScreen> createState() => _ExchangeScreenState();
}

class _ExchangeScreenState extends State<ExchangeScreen> {
  
  // Экспорт разметки (JSON)
  Future<void> _exportMarkup() async {
    final manager = DrawingManager();
    if (manager.elements.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ваша тактическая карта пуста. Нечего отправлять.')),
      );
      return;
    }

    try {
      final path = await DrawingStorage().prepareExportFile(manager.elements);
      await Share.shareXFiles(
        [XFile(path, mimeType: 'application/json')], 
        text: 'Тактическая разметка Naviga',
      );
    } catch (e) {
      _showError('Ошибка экспорта разметки: $e');
    }
  }

  // Импорт разметки (JSON)
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

  // Плейсхолдеры для будущих функций
  void _futureFeature() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Эта функция будет доступна в следующих версиях.'),
        backgroundColor: Colors.blueGrey,
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
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
                  DrawingManager().importElements(importedElements, replace: true);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Данные ЗАМЕНЕНЫ')));
                },
                icon: const Icon(Icons.warning_amber_rounded),
                label: const Text('ЗАМЕНИТЬ'),
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
                label: const Text('ДОБАВИТЬ'),
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Обмен картами'),
        backgroundColor: colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          _buildActionCard(
            context,
            title: 'Тактическая Разметка',
            subtitle: 'Обмен нарисованными точками и линиями',
            icon: Icons.edit_location_alt,
            onSend: _exportMarkup,
            onLoad: _importMarkup,
          ),
          const SizedBox(height: 24),
          _buildActionCard(
            context,
            title: 'Оффлайн Карты',
            subtitle: 'Обмен файлами картографической подложки',
            icon: Icons.map_outlined,
            onSend: _futureFeature,
            onLoad: _futureFeature,
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
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: colorScheme.primary, size: 28),
                const SizedBox(width: 12),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant)),
            const Divider(height: 32),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onSend,
                    icon: const Icon(Icons.send_rounded, size: 20),
                    label: const Text('ПОСЛАТЬ'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onLoad,
                    icon: const Icon(Icons.download_rounded, size: 20),
                    label: const Text('ЗАГРУЗИТЬ'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}