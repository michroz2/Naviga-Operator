/*
 * Файл: map_marker_manager.dart
 * Версия: 1.35.0
 * Описание: Изолированная логика управления стилями (цвета, иконки, прозрачность) для маркеров узлов на карте.
 */

import 'package:flutter/material.dart';

class MarkerStyle {
  final IconData icon;
  final Color color;
  final double opacity;

  MarkerStyle({required this.icon, required this.color, required this.opacity});
}

class MarkerStyleManager {
  static MarkerStyle getStyle({
    required int role,
    required bool isMe,
    required bool isOnline,
  }) {
    IconData icon;
    Color color;

    switch (role) {
      case 0: 
        icon = Icons.cell_tower; 
        break;
      case 1: 
        icon = Icons.location_on; 
        break;
      case 2: 
        icon = Icons.gps_fixed; 
        break;
      default: 
        icon = Icons.device_unknown;
    }

    if (isMe) {
      color = Colors.red; 
    } else {
      switch (role) {
        case 0: color = Colors.purple; break;
        case 1: color = Colors.blue; break;
        case 2: color = Colors.black; break;
        default: color = Colors.blueGrey;
      }
    }

    double opacity = 1.0;
    if (!isOnline) {
      color = Colors.grey;
      opacity = 0.5; 
    }

    return MarkerStyle(icon: icon, color: color, opacity: opacity);
  }
}