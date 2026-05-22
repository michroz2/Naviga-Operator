/*
 * Файл: drawing_storage.dart
 * Версия: 1.36.0
 * Описание: Файловый менеджер для сохранения и загрузки тактической разметки в формате JSON.
 */

import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'drawing_models.dart';

class DrawingStorage {
  static const String _fileName = 'tactical_map.json';

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }

  // Сохранение разметки
  Future<void> saveTacticalData(List<TacticalElement> elements) async {
    final file = await _getFile();
    final jsonList = elements.map((e) => e.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonList));
  }

  // Загрузка разметки
  Future<List<TacticalElement>> loadTacticalData() async {
    try {
      final file = await _getFile();
      if (!await file.exists()) return [];

      final content = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(content);

      return jsonList.map((item) {
        final type = TacticalType.values[item['type']];
        if (type == TacticalType.point) {
          return TacticalPoint(
            id: item['id'],
            lat: item['lat'],
            lon: item['lon'],
            label: item['label'],
            description: item['description'],
            colorHex: item['colorHex'],
            iconKey: item['iconKey'],
          );
        } else {
          return TacticalLine(
            id: item['id'],
            label: item['label'],
            description: item['description'],
            colorHex: item['colorHex'],
            width: item['width'],
            path: (item['path'] as List).map((p) => LatLng(p['lat'], p['lon'])).toList(),
          );
        }
      }).toList();
    } catch (e) {
      // Файл поврежден или отсутствует — возвращаем пустую разметку
      return [];
    }
  }
}