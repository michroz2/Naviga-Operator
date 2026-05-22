/*
 * Файл: map_compass.dart
 * Версия: 1.35.0
 * Описание: Интерактивный виджет управления режимами вращения карты (компас).
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
            color: Colors.white.withOpacity(0.85),
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
            ],
          ),
          child: Transform.rotate(
            angle: rotation * math.pi / 180,
            child: Icon(
              Icons.navigation, 
              color: mode == 2 ? Colors.blue.shade700 : Colors.blueGrey,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}