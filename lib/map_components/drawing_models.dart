/*
 * Файл: drawing_models.dart
 * Версия: 1.36.3
 * Описание: Модель данных для тактической разметки. 
 * Исправление: Перевод базового класса на именованные параметры для совместимости с конструкторами Dart 2.17+.
 */

import 'package:latlong2/latlong.dart';

enum TacticalType { point, line }

abstract class TacticalElement {
  final String id;
  final TacticalType type;
  final String label;
  final String description;
  final String colorHex;

  // Используем именованные параметры
  TacticalElement({
    required this.id,
    required this.type,
    required this.label,
    required this.description,
    required this.colorHex,
  });

  Map<String, dynamic> toJson();
}

class TacticalPoint extends TacticalElement {
  final double lat;
  final double lon;
  final String iconKey;

  TacticalPoint({
    required super.id,
    required this.lat,
    required this.lon,
    required super.label,
    required super.description,
    required super.colorHex,
    required this.iconKey,
  }) : super(type: TacticalType.point);

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': TacticalType.point.index,
    'lat': lat,
    'lon': lon,
    'label': label,
    'description': description,
    'colorHex': colorHex,
    'iconKey': iconKey,
  };
}

class TacticalLine extends TacticalElement {
  final List<LatLng> path;
  final double width;

  TacticalLine({
    required super.id,
    required super.label,
    required super.description,
    required super.colorHex,
    required this.path,
    required this.width,
  }) : super(type: TacticalType.line);

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': TacticalType.line.index,
    'label': label,
    'description': description,
    'colorHex': colorHex,
    'width': width,
    'path': path.map((p) => {'lat': p.latitude, 'lon': p.longitude}).toList(),
  };
}