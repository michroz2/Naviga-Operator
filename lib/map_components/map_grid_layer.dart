/*
 * Файл: map_grid_layer.dart
 * Версия: 1.35.0
 * Описание: Оптимизированный слой отрисовки метрической координатной сетки с мемоизацией.
 */

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../app_settings.dart';

class MapGridLayer extends StatefulWidget {
  const MapGridLayer({super.key});

  @override
  State<MapGridLayer> createState() => _MapGridLayerState();
}

class _MapGridLayerState extends State<MapGridLayer> {
  // Кэширование (Мемоизация)
  List<Polyline> _cachedGrid = [];
  double _lastGridScale = -1;
  LatLng _lastGridCenter = const LatLng(0, 0);
  double _lastGridWidth = -1;
  double _lastGridOpacity = -1;
  double _currentGridBufferLat = 0;
  double _currentGridBufferLon = 0;

  @override
  Widget build(BuildContext context) {
    final camera = MapCamera.of(context);
    final lat = camera.center.latitude;
    final lon = camera.center.longitude;
    final zoom = camera.zoom;

    final metersPerPixel = (math.cos(lat * math.pi / 180) * 2 * math.pi * 6378137) / (256 * math.pow(2, zoom));
    
    final List<double> scaleSteps = [
      1, 2, 5, 10, 20, 50, 100, 200, 500, 
      1000, 2000, 5000, 10000, 20000, 50000, 
      100000, 200000, 500000, 1000000, 2000000, 5000000
    ];
    
    const double targetPixels = 100.0;
    final double distanceMeters = targetPixels * metersPerPixel;
    
    double selectedScale = scaleSteps.first;
    for (var step in scaleSteps) {
      if (distanceMeters >= step) {
        selectedScale = step;
      } else {
        break;
      }
    }

    final double strokeWidth = AppSettings().gridWidth;
    final double gridOpacity = AppSettings().gridOpacity;

    final double distLat = (lat - _lastGridCenter.latitude).abs();
    final double distLon = (lon - _lastGridCenter.longitude).abs();

    if (_cachedGrid.isNotEmpty &&
        _lastGridScale == selectedScale &&
        _lastGridWidth == strokeWidth &&
        _lastGridOpacity == gridOpacity &&
        distLat < (_currentGridBufferLat * 0.6) && 
        distLon < (_currentGridBufferLon * 0.6)) {
      return PolylineLayer(polylines: _cachedGrid);
    }

    const double metersPerLatDegree = 111319.9;
    final double latStep = selectedScale / metersPerLatDegree;
    
    final double cosLat = math.max(0.01, math.cos(lat * math.pi / 180));
    final double lonStep = selectedScale / (metersPerLatDegree * cosLat);

    if (latStep <= 0 || lonStep <= 0) return const SizedBox.shrink();

    _currentGridBufferLat = math.min(0.5, 100 * latStep);
    _currentGridBufferLon = math.min(0.5 / cosLat, 100 * lonStep);

    final double startLat = ((lat - _currentGridBufferLat) / latStep).floor() * latStep;
    final double endLat = ((lat + _currentGridBufferLat) / latStep).ceil() * latStep;
    final double startLon = ((lon - _currentGridBufferLon) / lonStep).floor() * lonStep;
    final double endLon = ((lon + _currentGridBufferLon) / lonStep).ceil() * lonStep;

    List<Polyline> lines = [];
    final Color gridColor = Colors.grey.withOpacity(gridOpacity);

    for (double l = startLat; l <= endLat; l += latStep) {
      lines.add(Polyline(
        points: [LatLng(l, startLon), LatLng(l, endLon)],
        strokeWidth: strokeWidth,
        color: gridColor,
      ));
    }

    for (double ln = startLon; ln <= endLon; ln += lonStep) {
      lines.add(Polyline(
        points: [LatLng(startLat, ln), LatLng(endLat, ln)],
        strokeWidth: strokeWidth,
        color: gridColor,
      ));
    }

    _cachedGrid = lines;
    _lastGridScale = selectedScale;
    _lastGridCenter = LatLng(lat, lon);
    _lastGridWidth = strokeWidth;
    _lastGridOpacity = gridOpacity;

    return PolylineLayer(polylines: _cachedGrid);
  }
}