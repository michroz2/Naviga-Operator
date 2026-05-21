/*
 * Файл: app_settings.dart
 * Версия: 1.32.7
 * Изменения: ЭТАП Настроек, Шаг 7. Подключен wakelock_plus. Логика управления системным экраном привязана к сеттеру keepScreenOn.
 * Описание: Менеджер локальных настроек приложения.
 */

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart'; // ИЗМЕНЕНИЕ 1.32.7: Импорт пакета

class AppSettings extends ChangeNotifier {
  static final AppSettings _instance = AppSettings._internal();
  factory AppSettings() => _instance;
  AppSettings._internal();

  SharedPreferences? _prefs;

  // --- Значения по умолчанию (заводские) ---
  int _trackTimeMs = 1800000; // 30 минут
  double _trackWidth = 4.0;
  double _jitterRadius = 10.0;
  int _jitterPoints = 3;
  bool _keepScreenOn = false;
  bool _darkTheme = false;

  // --- Инициализация (вызывается при старте приложения) ---
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSettings();
  }

  // --- Чтение с диска ---
  void _loadSettings() {
    if (_prefs == null) return;
    
    _trackTimeMs = _prefs!.getInt('trackTimeMs') ?? 1800000;
    _trackWidth = _prefs!.getDouble('trackWidth') ?? 4.0;
    _jitterRadius = _prefs!.getDouble('jitterRadius') ?? 10.0;
    _jitterPoints = _prefs!.getInt('jitterPoints') ?? 3;
    _keepScreenOn = _prefs!.getBool('keepScreenOn') ?? false;
    _darkTheme = _prefs!.getBool('darkTheme') ?? false;
    
    // ИЗМЕНЕНИЕ 1.32.7: Применяем Wakelock при загрузке, если он был включен
    if (_keepScreenOn) {
      WakelockPlus.enable();
    } else {
      WakelockPlus.disable();
    }

    notifyListeners();
  }

  // --- Геттеры ---
  int get trackTimeMs => _trackTimeMs;
  double get trackWidth => _trackWidth;
  double get jitterRadius => _jitterRadius;
  int get jitterPoints => _jitterPoints;
  bool get keepScreenOn => _keepScreenOn;
  bool get darkTheme => _darkTheme;

  // --- Сеттеры с сохранением на диск ---
  void setTrackTimeMs(int value) {
    if (_trackTimeMs != value) {
      _trackTimeMs = value;
      _prefs?.setInt('trackTimeMs', value);
      notifyListeners();
    }
  }

  void setTrackWidth(double value) {
    if (_trackWidth != value) {
      _trackWidth = value;
      _prefs?.setDouble('trackWidth', value);
      notifyListeners();
    }
  }

  void setJitterRadius(double value) {
    if (_jitterRadius != value) {
      _jitterRadius = value;
      _prefs?.setDouble('jitterRadius', value); 
      notifyListeners();
    }
  }

  void setJitterPoints(int value) {
    if (_jitterPoints != value) {
      _jitterPoints = value;
      _prefs?.setInt('jitterPoints', value);
      notifyListeners();
    }
  }

  void setKeepScreenOn(bool value) {
    if (_keepScreenOn != value) {
      _keepScreenOn = value;
      _prefs?.setBool('keepScreenOn', value);
      
      // ИЗМЕНЕНИЕ 1.32.7: Динамическое включение/выключение удержания экрана
      if (value) {
        WakelockPlus.enable();
      } else {
        WakelockPlus.disable();
      }
      
      notifyListeners();
    }
  }

  void setDarkTheme(bool value) {
    if (_darkTheme != value) {
      _darkTheme = value;
      _prefs?.setBool('darkTheme', value);
      notifyListeners();
    }
  }
}