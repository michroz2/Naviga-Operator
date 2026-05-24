/*
 * Файл: app_settings.dart
 * Версия: 1.37.3
 * Изменения: Добавлены параметры showDrawingToolbar и showDrawingLabels для управления тактической разметкой.
 */

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  static final AppSettings _instance = AppSettings._internal();
  factory AppSettings() => _instance;
  AppSettings._internal();

  SharedPreferences? _prefs;

  int _trackTimeMs = 1800000; 
  double _trackWidth = 4.0;
  double _jitterRadius = 10.0;
  int _jitterPoints = 3;
  bool _keepScreenOn = false;
  bool _darkTheme = false;
  
  bool _showGrid = false;
  int _compassMode = 0; 
  
  double _gridWidth = 1.0;
  double _gridOpacity = 0.35;
  
  bool _invertMapColors = false;

  // ИЗМЕНЕНИЕ 1.37.3: Новые настройки тактической разметки
  bool _showDrawingToolbar = false;
  bool _showDrawingLabels = true;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSettings();
  }

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
    
    _gridWidth = _prefs!.getDouble('gridWidth') ?? 1.0;
    _gridOpacity = _prefs!.getDouble('gridOpacity') ?? 0.35;
    
    _invertMapColors = _prefs!.getBool('invertMapColors') ?? false;

    // Чтение новых параметров разметки
    _showDrawingToolbar = _prefs!.getBool('showDrawingToolbar') ?? false;
    _showDrawingLabels = _prefs!.getBool('showDrawingLabels') ?? true;
    
    notifyListeners();
  }

  int get trackTimeMs => _trackTimeMs;
  double get trackWidth => _trackWidth;
  double get jitterRadius => _jitterRadius;
  int get jitterPoints => _jitterPoints;
  bool get keepScreenOn => _keepScreenOn;
  bool get darkTheme => _darkTheme;
  
  bool get showGrid => _showGrid;
  int get compassMode => _compassMode;
  
  double get gridWidth => _gridWidth;
  double get gridOpacity => _gridOpacity;
  
  bool get invertMapColors => _invertMapColors;

  bool get showDrawingToolbar => _showDrawingToolbar;
  bool get showDrawingLabels => _showDrawingLabels;

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

  void setGridWidth(double value) {
    if (_gridWidth != value) {
      _gridWidth = value;
      _prefs?.setDouble('gridWidth', value);
      notifyListeners();
    }
  }

  void setGridOpacity(double value) {
    if (_gridOpacity != value) {
      _gridOpacity = value;
      _prefs?.setDouble('gridOpacity', value);
      notifyListeners();
    }
  }

  void setInvertMapColors(bool value) {
    if (_invertMapColors != value) {
      _invertMapColors = value;
      _prefs?.setBool('invertMapColors', value);
      notifyListeners();
    }
  }

  // Сеттеры для новых параметров
  void setShowDrawingToolbar(bool value) {
    if (_showDrawingToolbar != value) {
      _showDrawingToolbar = value;
      _prefs?.setBool('showDrawingToolbar', value);
      notifyListeners();
    }
  }

  void setShowDrawingLabels(bool value) {
    if (_showDrawingLabels != value) {
      _showDrawingLabels = value;
      _prefs?.setBool('showDrawingLabels', value);
      notifyListeners();
    }
  }
}