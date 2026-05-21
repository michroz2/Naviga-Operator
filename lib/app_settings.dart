/*
 * Файл: app_settings.dart
 * Версия: 1.33.2
 * Изменения: UC-23, Шаг 2. Внедрение параметров showGrid и compassMode для управления навигационными элементами карты.
 * Описание: Менеджер локальных настроек приложения.
 */

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  
  // Новые параметры UC-23
  bool _showGrid = false;
  int _compassMode = 0; // 0 - Север сверху, 1 - Свободное вращение, 2 - Магнитный компас

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
    
    _showGrid = _prefs!.getBool('showGrid') ?? false;
    _compassMode = _prefs!.getInt('compassMode') ?? 0;
    
    notifyListeners();
  }

  // --- Геттеры ---
  int get trackTimeMs => _trackTimeMs;
  double get trackWidth => _trackWidth;
  double get jitterRadius => _jitterRadius;
  int get jitterPoints => _jitterPoints;
  bool get keepScreenOn => _keepScreenOn;
  bool get darkTheme => _darkTheme;
  
  bool get showGrid => _showGrid;
  int get compassMode => _compassMode;

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

  void setShowGrid(bool value) {
    if (_showGrid != value) {
      _showGrid = value;
      _prefs?.setBool('showGrid', value);
      notifyListeners();
    }
  }

  void setCompassMode(int value) {
    if (_compassMode != value) {
      _compassMode = value;
      _prefs?.setInt('compassMode', value);
      notifyListeners();
    }
  }
}