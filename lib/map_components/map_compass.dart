/*
 * Файл: map_compass.dart
 * Версия: 1.35.1
 * Изменения: Цвета виджета адаптированы к системной теме (Surface/OnSurface).
 */

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import '../app_settings.dart';

class MapCompassWidget extends StatelessWidget {
  const MapCompassWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final camera = MapCamera.of(context);
    final rotation = camera.rotation; 
    final mode = AppSettings().compassMode;

    // Адаптация под активную тему
    final colorScheme = Theme.of(context).colorScheme;
    final surfaceColor = colorScheme.surface;
    final onSurfaceColor = colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.only(top: 16.0, right: 16.0),
      child: GestureDetector(
        onTap: () {
          AppSettings().setCompassMode((mode + 1) % 3);
        },
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: surfaceColor.withOpacity(0.85),
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
            ],
          ),
          child: Transform.rotate(
            angle: rotation * math.pi / 180,
            child: Icon(
              Icons.navigation, 
              // При включенном датчике оставляем синий цвет индикации, иначе цвет темы
              color: mode == 2 ? Colors.blue.shade700 : onSurfaceColor,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}