/*
 * Файл: drawing_layer.dart
 * Версия: 1.36.12
 * Описание: Слой отрисовки тактической разметки поверх карты.
 * Исправление: Исправлен баг двойного вращения (добавлен rotate: true в Маркер), 
 * устранен overflow подписи линии, цвет текста приведен к общему стандарту темы.
 */

import 'dart:math' as math;
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
        final camera = MapCamera.of(context);
        final elements = DrawingManager().elements;
        
        List<Marker> markers = [];
        List<Polyline> polylines = [];

        for (var el in elements) {
          final color = Color(int.parse(el.colorHex.replaceFirst('#', '0xFF')));

          if (el is TacticalPoint) {
            markers.add(Marker(
              point: LatLng(el.lat, el.lon),
              width: 100,
              height: 55,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    TacticalIconManager.getIconData(el.iconKey),
                    color: color,
                    size: 28,
                  ),
                  const SizedBox(height: 1),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.black12, width: 0.5),
                    ),
                    child: Text(
                      el.label,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ));
          } else if (el is TacticalLine) {
            polylines.add(Polyline(
              points: el.path,
              strokeWidth: el.width,
              color: color,
            ));

            if (el.path.length >= 2 && el.label.isNotEmpty) {
              final labelMarker = _calculateLineLabelMarker(el, camera, color);
              if (labelMarker != null) {
                markers.add(labelMarker);
              }
            }
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

  Marker? _calculateLineLabelMarker(TacticalLine line, MapCamera camera, Color color) {
    double maxSegmentDistPx = 0;
    int bestSegmentIndex = 0;
    
    List<math.Point<double>> screenPoints = [];
    for (var latLng in line.path) {
      final point = camera.latLngToScreenPoint(latLng);
      screenPoints.add(math.Point(point.x.toDouble(), point.y.toDouble()));
    }

    for (int i = 0; i < screenPoints.length - 1; i++) {
      final p1 = screenPoints[i];
      final p2 = screenPoints[i + 1];
      final distPx = math.sqrt(math.pow(p2.x - p1.x, 2) + math.pow(p2.y - p1.y, 2));
      
      if (distPx > maxSegmentDistPx) {
        maxSegmentDistPx = distPx;
        bestSegmentIndex = i;
      }
    }

    if (maxSegmentDistPx < 90) return null;

    final p1 = screenPoints[bestSegmentIndex];
    final p2 = screenPoints[bestSegmentIndex + 1];
    
    final midX = (p1.x + p2.x) / 2;
    final midY = (p1.y + p2.y) / 2;
    
    final midLatLng = camera.pointToLatLng(math.Point(midX, midY));

    // Вычисляем базовый угол географического сегмента
    double angle = math.atan2(p2.y - p1.y, p2.x - p1.x);

    // Нормализация направления чтения (слева направо)
    if (angle > math.pi / 2) {
      angle -= math.pi;
    } else if (angle < -math.pi / 2) {
      angle += math.pi;
    }

    return Marker(
      point: midLatLng,
      width: 140,
      height: 24,
      rotate: true, // ФИКС: маркер теперь вращается синхронно вместе с картой
      child: Container(
        alignment: Alignment.center,
        child: Transform.rotate(
          angle: angle, // Накладывается только чистый угол наклона сегмента
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(4),
              // Оставляем цвет линии только как тонкую рамку для ассоциации
              border: Border.all(color: color.withOpacity(0.6), width: 1.0),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))
              ],
            ),
            child: Text(
              line.label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.black87, // ФИКС: цвет текста стандартный, читаемый
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ),
      ),
    );
  }
}