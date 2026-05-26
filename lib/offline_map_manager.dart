/*
 * Файл: offline_map_manager.dart
 * Версия: 1.39.9
 * Изменения: Добавлено сохранение ID текущего региона и его автоматическое удаление с карты (через DrawingManager) при отмене загрузки.
 */

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'map_components/drawing_models.dart';
import 'map_components/drawing_manager.dart'; // ИЗМЕНЕНИЕ: Доступ к разметке

class OfflineMapManager extends ChangeNotifier {
  static final OfflineMapManager _instance = OfflineMapManager._internal();
  factory OfflineMapManager() => _instance;
  OfflineMapManager._internal();

  bool isDownloading = false;
  double progressPercentage = 0.0;
  int downloadedTiles = 0;
  int totalTiles = 0;
  String currentRegionName = '';
  String? _currentRegionId; // ИЗМЕНЕНИЕ: ID для связи с разметкой

  StreamSubscription<DownloadProgress>? _downloadSubscription;
  static int _instanceCounter = 1;
  int? _currentInstanceId;

  Future<void> downloadRegion(TacticalRegion region) async {
    if (isDownloading) return;

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
      isDownloading = true;
      currentRegionName = region.label;
      _currentRegionId = region.id; // Запоминаем ID
      progressPercentage = 0.0;
      downloadedTiles = 0;
      totalTiles = 0;
      _currentInstanceId = _instanceCounter++;
      notifyListeners();

      final downloadStream = store.download.startForeground(
        region: downloadableRegion,
        instanceId: _currentInstanceId!,
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

  void cancelDownload() {
    if (!isDownloading || _currentInstanceId == null) return;
    
    try {
      FMTCStore('NavigaStore').download.cancel(instanceId: _currentInstanceId!);
    } catch (e) {
      print('Ошибка при отмене загрузки FMTC: $e');
    }
    
    _downloadSubscription?.cancel();
    
    // ИЗМЕНЕНИЕ: Удаляем рамку региона с карты при отмене
    if (_currentRegionId != null) {
      DrawingManager().removeElement(_currentRegionId!);
    }
    
    _resetState();
  }

  void _resetState() {
    isDownloading = false;
    progressPercentage = 0.0;
    downloadedTiles = 0;
    totalTiles = 0;
    currentRegionName = '';
    _currentRegionId = null;
    _downloadSubscription = null;
    _currentInstanceId = null;
    notifyListeners();
  }
}