/*
 * Файл: drawing_storage.dart
 * Версия: 1.38.6
 * Описание: Локальное сохранение и загрузка элементов тактической разметки.
 * Изменения: Исправлена сигнатура prepareExportFile (добавлен аргумент List<TacticalElement>).
 */

import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'drawing_models.dart';

class DrawingStorage {
  Future<File> get _localFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/tactical_drawing.json');
  }

  Future<void> saveTacticalData(List<TacticalElement> elements) async {
    final file = await _localFile;
    final jsonList = elements.map((e) => e.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonList));
  }

  Future<List<TacticalElement>> loadTacticalData() async {
    try {
      final file = await _localFile;
      if (!await file.exists()) return [];

      final contents = await file.readAsString();
      final jsonList = jsonDecode(contents) as List;

      return jsonList.map((json) {
        switch (json['type']) {
          case 'point': return TacticalPoint.fromJson(json);
          case 'line': return TacticalLine.fromJson(json);
          case 'region': return TacticalRegion.fromJson(json);
          default: throw Exception('Unknown tactical element type');
        }
      }).toList();
    } catch (e) {
      print('Ошибка загрузки разметки: $e');
      return [];
    }
  }

  // ИСПРАВЛЕНИЕ: Добавлен аргумент List<TacticalElement> для совместимости с exchange_screen.dart
  Future<String> prepareExportFile(List<TacticalElement> elements) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/tactical_export.json');
    final jsonList = elements.map((e) => e.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonList));
    return file.path;
  }

  Future<List<TacticalElement>> parseImportFile(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) return [];

      final contents = await file.readAsString();
      final jsonList = jsonDecode(contents) as List;

      return jsonList.map((json) {
        switch (json['type']) {
          case 'point': return TacticalPoint.fromJson(json);
          case 'line': return TacticalLine.fromJson(json);
          case 'region': return TacticalRegion.fromJson(json);
          default: throw Exception('Unknown type');
        }
      }).toList();
    } catch (e) {
      print('Ошибка импорта: $e');
      return [];
    }
  }
}