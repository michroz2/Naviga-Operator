/*
 * Файл: drawing_manager.dart
 * Версия: 1.36.13
 * Описание: Менеджер состояния для тактической разметки.
 * Изменения: Интегрирован SharedPreferences для сохранения пользовательской сортировки иконок (MRU).
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

  // Список ключей иконок в порядке последнего использования (MRU)
  List<String> _mruIconKeys = [];

  List<TacticalElement> get elements => List.unmodifiable(_elements);

  String lastPointIconKey = 'pin';
  String lastPointColorHex = '#FF0000';
  
  String lastLineColorHex = '#0000FF';
  double lastLineWidth = 4.0;

  Future<void> load() async {
    // Загрузка объектов карты
    _elements = await _storage.loadTacticalData();
    
    // Загрузка пользовательской сортировки иконок из памяти устройства
    final prefs = await SharedPreferences.getInstance();
    _mruIconKeys = prefs.getStringList('mru_icon_keys') ?? [];
    
    notifyListeners();
  }

  // Метод для продвижения иконки на первое место
  Future<void> promoteIcon(String iconKey) async {
    _mruIconKeys.remove(iconKey);
    _mruIconKeys.insert(0, iconKey);
    
    // Сохраняем обновленный порядок
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('mru_icon_keys', _mruIconKeys);
  }

  // Динамически отсортированный список иконок для UI
  List<TacticalIcon> get sortedIcons {
    List<TacticalIcon> result = [];
    
    // Сначала добавляем те, что использовались недавно
    for (String key in _mruIconKeys) {
      try {
        result.add(TacticalIconManager.availableIcons.firstWhere((i) => i.key == key));
      } catch (_) {} // Игнорируем, если иконка была удалена из словаря в новых версиях
    }
    
    // Затем добавляем все остальные
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