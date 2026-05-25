/*
 * Файл: offline_map_manager.dart
 * Версия: 1.39.1
 * Описание: Сервис фоновой загрузки оффлайн-тайлов через FMTC.
 * Изменения: Код адаптирован под актуальный API flutter_map_tile_caching v9.0.1.
 */

import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'map_components/drawing_models.dart';

class OfflineMapManager {
  // Запуск загрузки региона
  Future<void> downloadRegion(TacticalRegion region) async {
    final store = FMTCStore('NavigaStore');
    
    // В версии FMTC 9.0+ используется LatLngBounds для RectangleRegion
    final regionBounds = RectangleRegion(
      LatLngBounds(region.topLeft, region.bottomRight),
    );

    // Конвертируем в DownloadableRegion с обязательными параметрами источника тайлов
    final downloadableRegion = regionBounds.toDownloadable(
      minZoom: 12,
      maxZoom: 16,
      options: TileLayer(
        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        userAgentPackageName: 'com.michroz2.naviga_operator',
      ),
    );

    try {
      // В FMTC 9.0+ startForeground запускает загрузку и возвращает Stream<DownloadProgress>
      final downloadStream = store.download.startForeground(
        region: downloadableRegion,
      );
      
      // Слушатель прогресса (пока выводим в консоль для проверки)
      downloadStream.listen(
        (progress) {
          print('Загрузка региона ${region.label}: ${progress.percentageProgress.toStringAsFixed(1)}%');
        },
        onError: (e) => print('Ошибка загрузки региона ${region.label}: $e'),
        onDone: () => print('Регион ${region.label} успешно загружен.'),
      );
    } catch (e) {
      print('Критическая ошибка запуска загрузки: $e');
    }
  }
}