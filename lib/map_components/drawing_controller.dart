/*
 * Файл: drawing_controller.dart
 * Версия: 1.39.9
 * Изменения: Добавлена логика Hit-Test для TacticalRegion. Тапы определяются по интерполированному контуру borderPath, позволяя корректно взаимодействовать с периметром прямоугольника.
 */

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../ble_service.dart';
import 'drawing_manager.dart';
import 'drawing_models.dart';
import 'drawing_menu_sheet.dart';
import 'drawing_toolbar.dart'; 

class DrawingController {
  final BleService _bleService = BleService();

  Future<void> handleDrawingTap({
    required BuildContext context,
    required LatLng tappedPoint,
    required MapCamera camera,
    required DrawingTool activeTool,
    required List<LatLng> currentDrawingLinePath,
    required VoidCallback onPathUpdated,
  }) async {
    final manager = DrawingManager();
    final metersPerPixel = (math.cos(tappedPoint.latitude * math.pi / 180) * 2 * math.pi * 6378137) / (256 * math.pow(2, camera.zoom));
    final searchRadiusMeters = 40.0 * metersPerPixel;
    const distanceCalculator = Distance();

    TacticalPoint? closestPoint;
    double minPointDistMeters = searchRadiusMeters;

    TacticalLine? closestLine;
    double minLineDistMeters = searchRadiusMeters;

    TacticalRegion? closestRegion;
    double minRegionDistMeters = searchRadiusMeters;

    for (var element in manager.elements) {
      if (element is TacticalPoint) {
        final dist = distanceCalculator.distance(tappedPoint, LatLng(element.lat, element.lon));
        if (dist < minPointDistMeters) {
          minPointDistMeters = dist;
          closestPoint = element;
        }
      } else if (element is TacticalLine) {
        if (element.path.isEmpty) continue;
        for (var latLng in element.path) {
          final dist = distanceCalculator.distance(tappedPoint, latLng);
          if (dist < minLineDistMeters) {
            minLineDistMeters = dist;
            closestLine = element;
          }
        }
      } else if (element is TacticalRegion) {
        // ИЗМЕНЕНИЕ: Обработка попаданий в границы региона. Используется borderPath с плотными точками.
        for (var latLng in element.borderPath) {
          final dist = distanceCalculator.distance(tappedPoint, latLng);
          if (dist < minRegionDistMeters) {
            minRegionDistMeters = dist;
            closestRegion = element;
          }
        }
      }
    }

    if (activeTool == DrawingTool.line) {
      LatLng pointToAdd = tappedPoint;
      
      if (closestPoint != null) {
        pointToAdd = LatLng(closestPoint.lat, closestPoint.lon);
      } else {
        final nodes = _bleService.nodeDatabase.nodes.values.where((n) => n.hasValidGps);
        double minNodeDist = searchRadiusMeters;
        for (var node in nodes) {
          final dist = distanceCalculator.distance(tappedPoint, LatLng(node.lat, node.lon));
          if (dist < minNodeDist) {
            minNodeDist = dist;
            pointToAdd = LatLng(node.lat, node.lon);
          }
        }
      }

      currentDrawingLinePath.add(pointToAdd);
      onPathUpdated();
      return; 
    }

    if (activeTool == DrawingTool.point) {
      final attrs = await showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        isScrollControlled: true,
        builder: (_) => const DrawingMenuSheet(targetType: TacticalType.point),
      );

      if (attrs != null) {
        final newId = DateTime.now().millisecondsSinceEpoch.toString();
        manager.addElement(TacticalPoint(
          id: newId, lat: tappedPoint.latitude, lon: tappedPoint.longitude,
          label: attrs['label'], description: attrs['description'],
          colorHex: attrs['colorHex'], iconKey: attrs['iconKey'],
        ));
      }
      return; 
    }

    // Определяем абсолютно ближайший элемент из всех категорий
    TacticalElement? closest = closestPoint;
    double minDist = minPointDistMeters;

    if (minLineDistMeters < minDist) {
      closest = closestLine;
      minDist = minLineDistMeters;
    }
    if (minRegionDistMeters < minDist) {
      closest = closestRegion;
      minDist = minRegionDistMeters;
    }

    if (closest != null) {
      if (activeTool == DrawingTool.view) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => DrawingInfoSheet(element: closest!),
        );
      } else if (activeTool == DrawingTool.select) {
        final attrs = await showModalBottomSheet<Map<String, dynamic>>(
          context: context,
          isScrollControlled: true,
          builder: (_) => DrawingMenuSheet(
            existingElement: closest,
            targetType: closest!.type,
          ),
        );

        if (attrs != null) {
          if (closest is TacticalPoint) {
            manager.updateElement(TacticalPoint(
              id: closest.id, lat: closest.lat, lon: closest.lon,
              label: attrs['label'], description: attrs['description'],
              colorHex: attrs['colorHex'], iconKey: attrs['iconKey'],
            ));
          } else if (closest is TacticalLine) {
            manager.updateElement(TacticalLine(
              id: closest.id, path: closest.path,
              label: attrs['label'], description: attrs['description'],
              colorHex: attrs['colorHex'], width: attrs['lineWidth'],
            ));
          } else if (closest is TacticalRegion) {
            manager.updateElement(TacticalRegion(
              id: closest.id, topLeft: closest.topLeft, bottomRight: closest.bottomRight,
              label: attrs['label'], description: attrs['description'],
              colorHex: attrs['colorHex'], borderWidth: attrs['lineWidth'], isDashed: closest.isDashed,
            ));
          }
        }
      } else if (activeTool == DrawingTool.eraser) {
        manager.removeElement(closest.id);
      }
    }
  }

  Future<void> processLineCompletion({
    required BuildContext context,
    required List<LatLng> currentDrawingLinePath,
    required VoidCallback onPathCleared,
  }) async {
    if (currentDrawingLinePath.length > 1) {
      final attrs = await showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        isScrollControlled: true,
        builder: (_) => const DrawingMenuSheet(targetType: TacticalType.line),
      );

      if (attrs != null) {
        final newId = DateTime.now().millisecondsSinceEpoch.toString();
        DrawingManager().addElement(TacticalLine(
          id: newId,
          label: attrs['label'],
          description: attrs['description'],
          colorHex: attrs['colorHex'],
          path: List.from(currentDrawingLinePath),
          width: attrs['lineWidth'],
        ));
      }
    }
    onPathCleared();
  }
}