/*
 * Файл: tactical_icon_manager.dart
 * Версия: 1.36.3
 * Описание: Оптимизированный справочник тактических иконок для Outdoors/Hunting.
 * Исправление: Замена Icons.bridge на валидный Icons.alt_route.
 */

import 'package:flutter/material.dart';

class TacticalIcon {
  final String key;
  final IconData data;
  final String label;

  const TacticalIcon(this.key, this.data, this.label);
}

class TacticalIconManager {
  static const List<TacticalIcon> availableIcons = [
    // Основные маркеры
    TacticalIcon('pin', Icons.pin_drop, 'Точка'),
    TacticalIcon('flag', Icons.flag, 'Ориентир'),
    TacticalIcon('warning', Icons.warning, 'Опасность'),
    
    // Camping & Outdoors
    TacticalIcon('tent', Icons.forest, 'Стоянка'),
    TacticalIcon('campfire', Icons.local_fire_department, 'Кострище'),
    TacticalIcon('water', Icons.water_drop, 'Вода'),
    TacticalIcon('shelter', Icons.roofing, 'Укрытие'),
    
    // Hunting & Dogs
    TacticalIcon('dog', Icons.pets, 'Собака'),
    TacticalIcon('target', Icons.track_changes, 'Цель'),
    TacticalIcon('tracker', Icons.gps_fixed, 'Трекер'),
    
    // Инфраструктура
    TacticalIcon('tower', Icons.cell_tower, 'Вышка'),
    TacticalIcon('bridge', Icons.alt_route, 'Переправа'), // Исправлено здесь
    TacticalIcon('home', Icons.home, 'База'),
    TacticalIcon('hospital', Icons.local_hospital, 'Медпункт'),
  ];

  static IconData getIconData(String key) {
    return availableIcons.firstWhere(
      (i) => i.key == key,
      orElse: () => availableIcons.first,
    ).data;
  }
}