/*
 * Файл: drawing_layer.dart
 * Версия: 1.36.0
 * Описание: Слой отрисовки тактической разметки поверх карты.
 */

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'drawing_manager.dart';
import 'drawing_models.dart';
import 'tactical_icon_manager.dart';

class MapDrawingLayer extends StatelessWidget {
  const MapDrawingLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: DrawingManager(),
      builder: (context, _) {
        final elements = DrawingManager().elements;
        List<Marker> markers = [];
        List<Polyline> polylines = [];

        for (var el in elements) {
          if (el is TacticalPoint) {
            markers.add(Marker(
              point: LatLng(el.lat, el.lon),
              child: Icon(
                TacticalIconManager.getIconData(el.iconKey),
                color: Color(int.parse(el.colorHex.replaceFirst('#', '0xFF'))),
              ),
            ));
          } else if (el is TacticalLine) {
            polylines.add(Polyline(
              points: el.path,
              strokeWidth: el.width,
              color: Color(int.parse(el.colorHex.replaceFirst('#', '0xFF'))),
            ));
          }
        }

        return Stack(
          children: [
            PolylineLayer(polylines: polylines),
            MarkerLayer(markers: markers),
          ],
        );
      },
    );
  }
}