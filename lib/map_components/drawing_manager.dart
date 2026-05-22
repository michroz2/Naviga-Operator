/*
 * Файл: drawing_manager.dart
 * Версия: 1.36.5
 * Описание: Менеджер состояния для тактической разметки.
 * Изменения: Добавлена память последних использованных атрибутов (Sticky Attributes) и метод updateElement.
 */

import 'package:flutter/material.dart';
import 'drawing_models.dart';
import 'drawing_storage.dart';

class DrawingManager extends ChangeNotifier {
  static final DrawingManager _instance = DrawingManager._internal();
  factory DrawingManager() => _instance;
  DrawingManager._internal();

  final DrawingStorage _storage = DrawingStorage();
  List<TacticalElement> _elements = [];

  List<TacticalElement> get elements => List.unmodifiable(_elements);

  // Память последних атрибутов (дефолты для новых объектов)
  String lastPointIconKey = 'pin';
  String lastPointColorHex = '#FF0000';
  
  String lastLineColorHex = '#0000FF';
  double lastLineWidth = 4.0;

  // Инициализация
  Future<void> load() async {
    _elements = await _storage.loadTacticalData();
    notifyListeners();
  }

  // Добавление и синхронизация
  void addElement(TacticalElement element) {
    _elements.add(element);
    _updateDefaults(element);
    _save();
  }

  // Обновление существующего элемента
  void updateElement(TacticalElement updatedElement) {
    final index = _elements.indexWhere((e) => e.id == updatedElement.id);
    if (index != -1) {
      _elements[index] = updatedElement;
      _updateDefaults(updatedElement);
      _save();
    }
  }

  // Удаление и синхронизация
  void removeElement(String id) {
    _elements.removeWhere((e) => e.id == id);
    _save();
  }

  // Автоматическое запоминание атрибутов для следующего объекта
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