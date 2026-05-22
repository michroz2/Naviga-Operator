/*
 * Файл: map_scale_bar.dart
 * Версия: 1.35.0
 * Описание: Перманентная интерактивная масштабная линейка карты.
 */

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import '../app_settings.dart';

class MapScaleBar extends StatelessWidget {
  const MapScaleBar({super.key});

  @override
  Widget build(BuildContext context) {
    final camera = MapCamera.of(context);
    final lat = camera.center.latitude;
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
    
    final double scaleWidth = selectedScale / metersPerPixel;
    
    final String label = selectedScale >= 1000 
        ? '${(selectedScale / 1000).toStringAsFixed(0)} км' 
        : '${selectedScale.toStringAsFixed(0)} м';

    final bool showGrid = AppSettings().showGrid;

    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 24.0),
      child: GestureDetector(
        onTap: () {
          AppSettings().setShowGrid(!showGrid);
        },
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Container(
              width: scaleWidth,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black87,
                border: Border.all(color: Colors.white, width: 1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}