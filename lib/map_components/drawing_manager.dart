/*
 * Файл: drawing_manager.dart
 * Версия: 1.36.0
 * Описание: Менеджер состояния для тактической разметки.
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

  // Инициализация (вызвать при старте приложения)
  Future<void> load() async {
    _elements = await _storage.loadTacticalData();
    notifyListeners();
  }

  // Добавление и синхронизация
  void addElement(TacticalElement element) {
    _elements.add(element);
    _save();
  }

  // Удаление и синхронизация
  void removeElement(String id) {
    _elements.removeWhere((e) => e.id == id);
    _save();
  }

  void _save() {
    _storage.saveTacticalData(_elements);
    notifyListeners();
  }
}