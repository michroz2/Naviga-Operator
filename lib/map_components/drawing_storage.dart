/*
 * Файл: drawing_storage.dart
 * Версия: 1.37.0
 * Описание: Файловый менеджер для сохранения и загрузки тактической разметки в формате JSON.
 * Изменения: Добавлены методы экспорта во временный файл .naviga и парсинга импортированного файла.
 */

import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:latlong2/latlong.dart';
import 'drawing_models.dart';

class DrawingStorage {
  static const String _fileName = 'tactical_map.json';

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }

  // Сохранение разметки (внутренняя база)
  Future<void> saveTacticalData(List<TacticalElement> elements) async {
    final file = await _getFile();
    final jsonList = elements.map((e) => e.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonList));
  }

  // Загрузка разметки (внутренняя база)
  Future<List<TacticalElement>> loadTacticalData() async {
    try {
      final file = await _getFile();
      if (!await file.exists()) return [];

      final content = await file.readAsString();
      return _parseJsonContent(content);
    } catch (e) {
      return [];
    }
  }

  // ============================================================================
  // ИМПОРТ / ЭКСПОРТ (UC-25)
  // ============================================================================

  // Подготовка файла для отправки через Share
  Future<File> prepareExportFile(List<TacticalElement> elements) async {
    final directory = await getTemporaryDirectory();
    // ИЗМЕНЕНИЕ: Использование стандартного расширения .json для обхода блокировок мессенджеров
    final file = File('${directory.path}/razmetka_naviga.json');
    final jsonList = elements.map((e) => e.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonList));
    return file;
  }

  // Чтение внешнего файла (импорт)
  Future<List<TacticalElement>> parseImportFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return [];
      
      final content = await file.readAsString();
      return _parseJsonContent(content);
    } catch (e) {
      return [];
    }
  }

  // Общий парсер JSON строки в список элементов
  List<TacticalElement> _parseJsonContent(String content) {
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
  }
}