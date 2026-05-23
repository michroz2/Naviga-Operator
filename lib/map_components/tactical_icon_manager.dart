/*
 * Файл: tactical_icon_manager.dart
 * Версия: 1.36.13
 * Описание: Оптимизированный справочник тактических иконок для Outdoors/Hunting.
 * Изменения: Расширение словаря до 24 элементов (добавлены иконки рельефа, маршрутов и инфраструктуры).
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
    TacticalIcon('bridge', Icons.alt_route, 'Переправа'),
    TacticalIcon('home', Icons.home, 'База'),
    TacticalIcon('hospital', Icons.local_hospital, 'Медпункт'),

    // НОВЫЕ: Природа и Рельеф
    TacticalIcon('terrain', Icons.terrain, 'Высота'),
    TacticalIcon('park', Icons.park, 'Заросли'),
    
    // НОВЫЕ: Маршруты и Транспорт
    TacticalIcon('walk', Icons.directions_walk, 'Тропа'),
    TacticalIcon('car', Icons.directions_car, 'Парковка'),
    TacticalIcon('boat', Icons.directions_boat, 'Причал'),
    
    // НОВЫЕ: Outdoor & Разное
    TacticalIcon('backpack', Icons.backpack, 'Тайник'),
    TacticalIcon('visibility', Icons.visibility, 'Обзор'),
    TacticalIcon('group', Icons.group, 'Сбор'),
    TacticalIcon('dining', Icons.local_dining, 'Привал'),
    TacticalIcon('camera', Icons.camera_alt, 'Снимок'),
  ];

  static IconData getIconData(String key) {
    return availableIcons.firstWhere(
      (i) => i.key == key,
      orElse: () => availableIcons.first,
    ).data;
  }
}