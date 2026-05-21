/*
 * Файл: app_settings.dart
 * Версия: 1.32.1
 * Изменения: ЭТАП Настроек, Шаг 2. Создан синглтон для хранения и управления состоянием локальных настроек приложения (в оперативной памяти).
 * Описание: Менеджер локальных настроек приложения.
 */

import 'package:flutter/foundation.dart';

class AppSettings extends ChangeNotifier {
  // Реализация паттерна Singleton для доступа из любой точки приложения
  static final AppSettings _instance = AppSettings._internal();
  factory AppSettings() => _instance;
  AppSettings._internal();

  // --- Значения по умолчанию ---
  
  // Визуализация на карте
  int _trackTimeMs = 1800000; // 30 минут
  double _trackWidth = 4.0;

  // Пространственный фильтр
  double _jitterRadius = 10.0;
  int _jitterPoints = 3;

  // Системные
  bool _keepScreenOn = false;
  bool _darkTheme = false;

  // --- Геттеры ---
  int get trackTimeMs => _trackTimeMs;
  double get trackWidth => _trackWidth;
  double get jitterRadius => _jitterRadius;
  int get jitterPoints => _jitterPoints;
  bool get keepScreenOn => _keepScreenOn;
  bool get darkTheme => _darkTheme;

  // --- Сеттеры с уведомлением слушателей ---
  void setTrackTimeMs(int value) {
    if (_trackTimeMs != value) {
      _trackTimeMs = value;
      notifyListeners();
    }
  }

  void setTrackWidth(double value) {
    if (_trackWidth != value) {
      _trackWidth = value;
      notifyListeners();
    }
  }

  void setJitterRadius(double value) {
    if (_jitterRadius != value) {
      _jitterRadius = value;
      notifyListeners();
    }
  }

  void setJitterPoints(int value) {
    if (_jitterPoints != value) {
      _jitterPoints = value;
      notifyListeners();
    }
  }

  void setKeepScreenOn(bool value) {
    if (_keepScreenOn != value) {
      _keepScreenOn = value;
      notifyListeners();
    }
  }

  void setDarkTheme(bool value) {
    if (_darkTheme != value) {
      _darkTheme = value;
      notifyListeners();
    }
  }
}