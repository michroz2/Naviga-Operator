/*
 * Файл: app_settings.dart
 * Версия: 1.43.6
 * Изменения: Добавлена переменная startupScreenMode (0 - Главное меню, 1 - Карта) для выбора стартового экрана после успешного автоподключения.
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

  bool _showDrawingToolbar = false;
  bool _showDrawingLabels = true;
  bool _showRegions = true;

  int _mapNetworkMode = 0; 
  
  String _savedDongleId = '';   
  String _savedDongleName = ''; 

  // Переменные позиции карты
  double _mapLastLat = 0.0;
  double _mapLastLng = 0.0;
  double _mapLastZoom = 15.0;

  // ИЗМЕНЕНИЕ 1.43.6: Стартовый экран
  int _startupScreenMode = 0;

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

    _showDrawingToolbar = _prefs!.getBool('showDrawingToolbar') ?? false;
    _showDrawingLabels = _prefs!.getBool('showDrawingLabels') ?? true;
    _showRegions = _prefs!.getBool('showRegions') ?? true;
    
    _mapNetworkMode = _prefs!.getInt('mapNetworkMode') ?? 0;
    
    _savedDongleId = _prefs!.getString('savedDongleId') ?? '';     
    _savedDongleName = _prefs!.getString('savedDongleName') ?? ''; 

    // Загрузка позиции
    _mapLastLat = _prefs!.getDouble('mapLastLat') ?? 0.0;
    _mapLastLng = _prefs!.getDouble('mapLastLng') ?? 0.0;
    _mapLastZoom = _prefs!.getDouble('mapLastZoom') ?? 15.0;

    // ИЗМЕНЕНИЕ 1.43.6: Загрузка режима стартового экрана
    _startupScreenMode = _prefs!.getInt('startupScreenMode') ?? 0;
    
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
  bool get showRegions => _showRegions;

  int get mapNetworkMode => _mapNetworkMode;
  
  String get savedDongleId => _savedDongleId;     
  String get savedDongleName => _savedDongleName; 

  double get mapLastLat => _mapLastLat;
  double get mapLastLng => _mapLastLng;
  double get mapLastZoom => _mapLastZoom;

  // ИЗМЕНЕНИЕ 1.43.6: Геттер
  int get startupScreenMode => _startupScreenMode;

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
  
  void setShowRegions(bool value) {
    if (_showRegions != value) {
      _showRegions = value;
      _prefs?.setBool('showRegions', value);
      notifyListeners();
    }
  }

  void setMapNetworkMode(int value) {
    if (_mapNetworkMode != value) {
      _mapNetworkMode = value;
      _prefs?.setInt('mapNetworkMode', value);
      notifyListeners();
    }
  }

  void setSavedDongleId(String value) {
    if (_savedDongleId != value) {
      _savedDongleId = value;
      _prefs?.setString('savedDongleId', value);
      notifyListeners();
    }
  }

  void setSavedDongleName(String value) {
    if (_savedDongleName != value) {
      _savedDongleName = value;
      _prefs?.setString('savedDongleName', value);
      notifyListeners();
    }
  }

  // ИЗМЕНЕНИЕ 1.43.6: Сеттер
  void setStartupScreenMode(int value) {
    if (_startupScreenMode != value) {
      _startupScreenMode = value;
      _prefs?.setInt('startupScreenMode', value);
      notifyListeners();
    }
  }

  void saveMapPosition(double lat, double lng, double zoom) {
    _mapLastLat = lat;
    _mapLastLng = lng;
    _mapLastZoom = zoom;
    _prefs?.setDouble('mapLastLat', lat);
    _prefs?.setDouble('mapLastLng', lng);
    _prefs?.setDouble('mapLastZoom', zoom);
  }
}