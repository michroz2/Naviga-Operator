/*
 * Файл: drawing_models.dart
 * Версия: 1.39.9
 * Изменения: В TacticalRegion добавлены стили границ (borderWidth, isDashed) и геттер borderPath с линейной интерполяцией граней для обеспечения кликабельности периметра.
 */

import 'package:latlong2/latlong.dart';

enum TacticalType { point, line, region }

abstract class TacticalElement {
  final String id;
  final TacticalType type;
  final String label;
  final String description;
  final String colorHex;

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
    'id': id, 'type': 'point', 'label': label, 'description': description,
    'colorHex': colorHex, 'lat': lat, 'lon': lon, 'iconKey': iconKey,
  };

  factory TacticalPoint.fromJson(Map<String, dynamic> json) => TacticalPoint(
    id: json['id'], lat: json['lat'], lon: json['lon'],
    label: json['label'], description: json['description'],
    colorHex: json['colorHex'], iconKey: json['iconKey'],
  );
}

class TacticalLine extends TacticalElement {
  final List<LatLng> path;
  final double width;

  TacticalLine({
    required super.id,
    required this.path,
    required super.label,
    required super.description,
    required super.colorHex,
    required this.width,
  }) : super(type: TacticalType.line);

  @override
  Map<String, dynamic> toJson() => {
    'id': id, 'type': 'line', 'label': label, 'description': description,
    'colorHex': colorHex, 'width': width,
    'path': path.map((p) => {'lat': p.latitude, 'lon': p.longitude}).toList(),
  };

  factory TacticalLine.fromJson(Map<String, dynamic> json) => TacticalLine(
    id: json['id'],
    label: json['label'], description: json['description'],
    colorHex: json['colorHex'], width: json['width']?.toDouble() ?? 3.0,
    path: (json['path'] as List).map((p) => LatLng(p['lat'], p['lon'])).toList(),
  );
}

class TacticalRegion extends TacticalElement {
  final LatLng topLeft;
  final LatLng bottomRight;
  final double borderWidth;
  final bool isDashed;

  TacticalRegion({
    required super.id,
    required this.topLeft,
    required this.bottomRight,
    required super.label,
    required super.description,
    required super.colorHex,
    this.borderWidth = 3.0,
    this.isDashed = true,
  }) : super(type: TacticalType.region);

  // ИЗМЕНЕНИЕ: Формируем замкнутый контур с интерполяцией (по 10 точек на грань).
  // Это позволяет алгоритму вычисления дистанции до вершин корректно обрабатывать тапы по всему периметру.
  List<LatLng> get borderPath {
    final corners = [
      topLeft,
      LatLng(topLeft.latitude, bottomRight.longitude),
      bottomRight,
      LatLng(bottomRight.latitude, topLeft.longitude),
      topLeft
    ];
    
    List<LatLng> path = [];
    for (int i = 0; i < corners.length - 1; i++) {
      final p1 = corners[i];
      final p2 = corners[i+1];
      path.add(p1);
      // Добавляем промежуточные точки
      for (int j = 1; j < 10; j++) {
        path.add(LatLng(
          p1.latitude + (p2.latitude - p1.latitude) * (j / 10),
          p1.longitude + (p2.longitude - p1.longitude) * (j / 10),
        ));
      }
    }
    path.add(corners.last);
    return path;
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id, 'type': 'region', 'label': label, 'description': description,
    'colorHex': colorHex,
    'topLeft': {'lat': topLeft.latitude, 'lon': topLeft.longitude},
    'bottomRight': {'lat': bottomRight.latitude, 'lon': bottomRight.longitude},
    'borderWidth': borderWidth,
    'isDashed': isDashed,
  };

  factory TacticalRegion.fromJson(Map<String, dynamic> json) => TacticalRegion(
    id: json['id'],
    label: json['label'], description: json['description'],
    colorHex: json['colorHex'],
    topLeft: LatLng(json['topLeft']['lat'], json['topLeft']['lon']),
    bottomRight: LatLng(json['bottomRight']['lat'], json['bottomRight']['lon']),
    borderWidth: json['borderWidth']?.toDouble() ?? 3.0,
    isDashed: json['isDashed'] ?? true,
  );
}