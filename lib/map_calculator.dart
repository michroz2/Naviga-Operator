/*
 * Файл: map_calculator.dart
 * Версия: 1.22.2
 * Изменения: ЭТАП 2, Шаг 6 (Хотфикс). Создан модуль для картографической математики.
 * Описание: Изолированная логика вычисления границ карты (Bounds) и центрирования.
 */

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'node_database.dart';

class MapCalculator {
  // ~0.0018 градусов это примерно 200 метров. 
  // Это гарантирует, что если все узлы в одной точке, зум не будет микроскопическим.
  static const double minDeltaDegrees = 0.0018;

  static CameraFit? calculateInitialFit(Map<int, NodeRecord> nodes, int? myNodeId) {
    // 1. Отбираем только те узлы, у которых реально есть GPS
    final validNodes = nodes.values.where((n) => n.lat != 0.0 && n.lon != 0.0).toList();
    if (validNodes.isEmpty) return null;

    final myNode = myNodeId != null ? nodes[myNodeId] : null;
    final hasMyGps = myNode != null && myNode.lat != 0.0 && myNode.lon != 0.0;

    double minLat, maxLat, minLon, maxLon;

    if (hasMyGps) {
      // СЦЕНАРИЙ А: Есть наш узел. Делаем СИММЕТРИЧНЫЕ границы вокруг нас.
      double maxDLat = 0.0;
      double maxDLon = 0.0;

      for (final n in validNodes) {
        if (n.nodeId == myNodeId) continue;
        final dLat = (n.lat - myNode.lat).abs();
        final dLon = (n.lon - myNode.lon).abs();
        if (dLat > maxDLat) maxDLat = dLat;
        if (dLon > maxDLon) maxDLon = dLon;
      }

      // Применяем минимальный радиус обзора (защита от чрезмерного зума)
      maxDLat = max(maxDLat, minDeltaDegrees);
      maxDLon = max(maxDLon, minDeltaDegrees);

      minLat = myNode.lat - maxDLat;
      maxLat = myNode.lat + maxDLat;
      minLon = myNode.lon - maxDLon;
      maxLon = myNode.lon + maxDLon;
    } else {
      // СЦЕНАРИЙ Б: Нашего GPS нет, но есть соседи. Обычный Bounding Box по ним.
      minLat = validNodes.first.lat;
      maxLat = validNodes.first.lat;
      minLon = validNodes.first.lon;
      maxLon = validNodes.first.lon;

      for (final n in validNodes) {
        if (n.lat < minLat) minLat = n.lat;
        if (n.lat > maxLat) maxLat = n.lat;
        if (n.lon < minLon) minLon = n.lon;
        if (n.lon > maxLon) maxLon = n.lon;
      }

      // Защита от слишком близкого расположения соседей (или если сосед всего один)
      if ((maxLat - minLat) < minDeltaDegrees * 2) {
        final centerLat = (maxLat + minLat) / 2;
        minLat = centerLat - minDeltaDegrees;
        maxLat = centerLat + minDeltaDegrees;
      }
      if ((maxLon - minLon) < minDeltaDegrees * 2) {
        final centerLon = (maxLon + minLon) / 2;
        minLon = centerLon - minDeltaDegrees;
        maxLon = centerLon + minDeltaDegrees;
      }
    }

    return CameraFit.bounds(
      bounds: LatLngBounds(LatLng(minLat, minLon), LatLng(maxLat, maxLon)),
      padding: const EdgeInsets.all(50.0), // Отступ от краев экрана
    );
  }
}