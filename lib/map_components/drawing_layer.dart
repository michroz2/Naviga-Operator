/*
 * Файл: drawing_layer.dart
 * Версия: 1.38.4
 * Описание: Слой для отрисовки всех элементов тактической разметки на карте.
 */

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'drawing_models.dart';
import 'drawing_manager.dart';

IconData _getIconByKey(String key) {
  switch (key) {
    case 'flag': return Icons.flag;
    case 'warning': return Icons.warning;
    case 'target': return Icons.gps_fixed;
    case 'medical': return Icons.medical_services;
    default: return Icons.location_on;
  }
}

class MapDrawingLayer extends StatelessWidget {
  const MapDrawingLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: DrawingManager(),
      builder: (context, child) {
        final manager = DrawingManager();
        
        final regions = manager.elements.whereType<TacticalRegion>().toList();
        final lines = manager.elements.whereType<TacticalLine>().toList();
        final points = manager.elements.whereType<TacticalPoint>().toList();

        return Stack(
          children: [
            if (regions.isNotEmpty)
              PolygonLayer(
                polygons: regions.map((r) {
                  final color = Color(int.parse(r.colorHex.replaceFirst('#', '0xFF')));
                  return Polygon(
                    points: r.corners,
                    color: color.withOpacity(0.15), 
                    borderColor: color.withOpacity(0.8), 
                    borderStrokeWidth: 2.0,
                  );
                }).toList(),
              ),

            if (lines.isNotEmpty)
              PolylineLayer(
                polylines: lines.map((l) {
                  return Polyline(
                    points: l.path,
                    strokeWidth: l.width,
                    color: Color(int.parse(l.colorHex.replaceFirst('#', '0xFF'))).withOpacity(0.8),
                  );
                }).toList(),
              ),
              
            if (points.isNotEmpty)
              MarkerLayer(
                markers: points.map((p) {
                  final color = Color(int.parse(p.colorHex.replaceFirst('#', '0xFF')));
                  return Marker(
                    point: LatLng(p.lat, p.lon),
                    width: 40,
                    height: 40,
                    alignment: Alignment.topCenter,
                    child: Icon(
                      _getIconByKey(p.iconKey),
                      color: color,
                      size: 32,
                      shadows: const [
                        Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2))
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        );
      },
    );
  }
}