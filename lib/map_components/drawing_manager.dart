/*
 * Файл: drawing_manager.dart
 * Версия: 1.37.0
 * Описание: Менеджер состояния для тактической разметки.
 * Изменения: Добавлен метод importElements с логикой ЗАМЕНИТЬ (Replace) и ДОБАВИТЬ (Append).
 */

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'drawing_models.dart';
import 'drawing_storage.dart';
import 'tactical_icon_manager.dart';

class DrawingManager extends ChangeNotifier {
  static final DrawingManager _instance = DrawingManager._internal();
  factory DrawingManager() => _instance;
  DrawingManager._internal();

  final DrawingStorage _storage = DrawingStorage();
  List<TacticalElement> _elements = [];

  List<String> _mruIconKeys = [];

  List<TacticalElement> get elements => List.unmodifiable(_elements);

  String lastPointIconKey = 'pin';
  String lastPointColorHex = '#FF0000';
  
  String lastLineColorHex = '#0000FF';
  double lastLineWidth = 4.0;

  Future<void> load() async {
    _elements = await _storage.loadTacticalData();
    
    final prefs = await SharedPreferences.getInstance();
    _mruIconKeys = prefs.getStringList('mru_icon_keys') ?? [];
    
    notifyListeners();
  }

  // ============================================================================
  // ЛОГИКА ИМПОРТА (UC-25)
  // ============================================================================
  void importElements(List<TacticalElement> importedElements, {required bool replace}) {
    if (replace) {
      // Жесткая замена
      _elements = List.from(importedElements);
    } else {
      // Мягкое добавление с перегенерацией ID для избежания конфликтов
      final uniquePrefix = DateTime.now().microsecondsSinceEpoch.toString();
      
      for (var el in importedElements) {
        final newId = '${uniquePrefix}_${el.id}';
        
        if (el is TacticalPoint) {
          _elements.add(TacticalPoint(
            id: newId, lat: el.lat, lon: el.lon, 
            label: el.label, description: el.description, 
            colorHex: el.colorHex, iconKey: el.iconKey
          ));
        } else if (el is TacticalLine) {
          _elements.add(TacticalLine(
            id: newId, label: el.label, description: el.description, 
            colorHex: el.colorHex, path: List.from(el.path), width: el.width
          ));
        }
      }
    }
    _save();
  }

  Future<void> promoteIcon(String iconKey) async {
    _mruIconKeys.remove(iconKey);
    _mruIconKeys.insert(0, iconKey);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('mru_icon_keys', _mruIconKeys);
  }

  List<TacticalIcon> get sortedIcons {
    List<TacticalIcon> result = [];
    for (String key in _mruIconKeys) {
      try {
        result.add(TacticalIconManager.availableIcons.firstWhere((i) => i.key == key));
      } catch (_) {} 
    }
    for (var icon in TacticalIconManager.availableIcons) {
      if (!_mruIconKeys.contains(icon.key)) {
        result.add(icon);
      }
    }
    return result;
  }

  int getNextPointNumber() {
    final count = _elements.whereType<TacticalPoint>().length;
    return count + 1;
  }

  int getNextLineNumber() {
    final count = _elements.whereType<TacticalLine>().length;
    return count + 1;
  }

  void addElement(TacticalElement element) {
    _elements.add(element);
    _updateDefaults(element);
    _save();
  }

  void updateElement(TacticalElement updatedElement) {
    final index = _elements.indexWhere((e) => e.id == updatedElement.id);
    if (index != -1) {
      _elements[index] = updatedElement;
      _updateDefaults(updatedElement);
      _save();
    }
  }

  void removeElement(String id) {
    _elements.removeWhere((e) => e.id == id);
    _save();
  }

  void _updateDefaults(TacticalElement element) {
    if (element is TacticalPoint) {
      lastPointIconKey = element.iconKey;
      lastPointColorHex = element.colorHex;
    } else if (element is TacticalLine) {
      lastLineColorHex = element.colorHex;
      lastLineWidth = element.width;
    }
  }

  void _save() {
    _storage.saveTacticalData(_elements);
    notifyListeners();
  }
}