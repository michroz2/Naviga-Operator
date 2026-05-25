/*
 * Файл: offline_map_manager.dart
 * Версия: 1.39.8
 * Описание: Сервис фоновой загрузки оффлайн-тайлов через FMTC с трансляцией состояния.
 * Изменения: Внедрена изоляция инстансов загрузки (динамический инкрементальный instanceId) для предотвращения коллизий ("Bad state: ID 0 already exists"). Исправлен порядок отмены скачивания.
 */

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'map_components/drawing_models.dart';

class OfflineMapManager extends ChangeNotifier {
  // Singleton архитектура для доступа из любой точки UI
  static final OfflineMapManager _instance = OfflineMapManager._internal();
  factory OfflineMapManager() => _instance;
  OfflineMapManager._internal();

  // Состояние загрузки
  bool isDownloading = false;
  double progressPercentage = 0.0;
  int downloadedTiles = 0;
  int totalTiles = 0;
  String currentRegionName = '';

  StreamSubscription<DownloadProgress>? _downloadSubscription;
  
  // Статический счетчик для генерации коротких уникальных ID сессий
  static int _instanceCounter = 1;
  int? _currentInstanceId;

  // Запуск загрузки региона
  Future<void> downloadRegion(TacticalRegion region) async {
    if (isDownloading) return; // Защита от дублирующего запуска

    final store = FMTCStore('NavigaStore');
    
    final regionBounds = RectangleRegion(
      LatLngBounds(region.topLeft, region.bottomRight),
    );

    final downloadableRegion = regionBounds.toDownloadable(
      minZoom: 12,
      maxZoom: 16,
      options: TileLayer(
        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        userAgentPackageName: 'com.michroz2.naviga_operator',
      ),
    );

    try {
      // Инициализация стейта и нового уникального ID
      isDownloading = true;
      currentRegionName = region.label;
      progressPercentage = 0.0;
      downloadedTiles = 0;
      totalTiles = 0;
      _currentInstanceId = _instanceCounter++;
      notifyListeners();

      final downloadStream = store.download.startForeground(
        region: downloadableRegion,
        instanceId: _currentInstanceId!, // Явная изоляция процесса
      );
      
      _downloadSubscription = downloadStream.listen(
        (progress) {
          progressPercentage = progress.percentageProgress;
          downloadedTiles = progress.successfulTiles;
          totalTiles = progress.maxTiles;
          notifyListeners();
        },
        onError: (e) {
          print('Ошибка загрузки региона ${region.label}: $e');
          _resetState();
        },
        onDone: () {
          print('Регион ${region.label} успешно загружен.');
          _resetState();
        },
        cancelOnError: true,
      );
    } catch (e) {
      print('Критическая ошибка запуска загрузки: $e');
      _resetState();
    }
  }

  // Принудительная отмена скачивания
  void cancelDownload() {
    if (!isDownloading || _currentInstanceId == null) return;
    
    try {
      // ИСПРАВЛЕНИЕ: Сначала корректно глушим движок с указанием конкретного ID инстанса
      FMTCStore('NavigaStore').download.cancel(instanceId: _currentInstanceId!);
    } catch (e) {
      print('Ошибка при отмене загрузки FMTC: $e');
    }
    
    // ИСПРАВЛЕНИЕ: Только после этого обрываем прослушивание Stream
    _downloadSubscription?.cancel();
    
    _resetState();
  }

  void _resetState() {
    isDownloading = false;
    progressPercentage = 0.0;
    downloadedTiles = 0;
    totalTiles = 0;
    currentRegionName = '';
    _downloadSubscription = null;
    _currentInstanceId = null;
    notifyListeners();
  }
}