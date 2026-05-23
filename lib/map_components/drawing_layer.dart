/*
 * Файл: drawing_layer.dart
 * Версия: 1.36.13
 * Описание: Слой отрисовки тактической разметки поверх карты.
 * Изменения: Внедрен алгоритм отсечения Лианга-Барски (Dynamic Viewport Labeling). 
 * Подписи линий рассчитываются исключительно по сегментам, видимым на экране в данный момент,
 * плавно скользя вдоль маршрута при перемещении карты (без искажения углов и отрыва от линии).
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
            // Отрисовка гео-маршрута
            polylines.add(Polyline(
              points: el.path,
              strokeWidth: el.width,
              color: color,
            ));

            // Адаптивный расчет подписи во фрустуме экрана
            if (el.path.length >= 2 && el.label.isNotEmpty) {
              final labelMarker = _calculateDynamicLineLabel(el, camera, color);
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

  // Алгоритм отсечения отрезка Лианга-Барски (Liang-Barsky Line Clipping)
  // Возвращает видимую на экране часть отрезка или null, если он полностью невидим.
  List<math.Point<double>>? _clipSegment(math.Point<double> p1, math.Point<double> p2, double minX, double minY, double maxX, double maxY) {
    double t0 = 0.0;
    double t1 = 1.0;
    double dx = p2.x - p1.x;
    double dy = p2.y - p1.y;

    for (int edge = 0; edge < 4; edge++) {
      double p = 0, q = 0;
      if (edge == 0) { p = -dx; q = p1.x - minX; } // Левая граница
      else if (edge == 1) { p = dx; q = maxX - p1.x; } // Правая граница
      else if (edge == 2) { p = -dy; q = p1.y - minY; } // Верхняя граница
      else if (edge == 3) { p = dy; q = maxY - p1.y; } // Нижняя граница

      if (p == 0 && q < 0) return null; // Отрезок параллелен границе и находится снаружи

      if (p != 0) {
        double r = q / p;
        if (p < 0) {
          if (r > t1) return null;
          if (r > t0) t0 = r;
        } else {
          if (r < t0) return null;
          if (r < t1) t1 = r;
        }
      }
    }

    return [
      math.Point(p1.x + t0 * dx, p1.y + t0 * dy),
      math.Point(p1.x + t1 * dx, p1.y + t1 * dy)
    ];
  }

  // Расчет плавающей подписи линии на основе видимых сегментов
  Marker? _calculateDynamicLineLabel(TacticalLine line, MapCamera camera, Color color) {
    // Внутренний отступ 20px, чтобы текст не "бился" о самые края экрана
    final double minX = 20.0;
    final double minY = 20.0;
    final double maxX = camera.size.x - 20.0;
    final double maxY = camera.size.y - 20.0;

    double maxVisibleSegmentDistPx = 0;
    math.Point<double>? bestMidPoint;
    double bestAngle = 0.0;

    // Перевод линии в экранные координаты
    List<math.Point<double>> screenPoints = [];
    for (var latLng in line.path) {
      final p = camera.latLngToScreenPoint(latLng);
      screenPoints.add(math.Point(p.x.toDouble(), p.y.toDouble()));
    }

    // Анализ сегментов
    for (int i = 0; i < screenPoints.length - 1; i++) {
      final p1 = screenPoints[i];
      final p2 = screenPoints[i + 1];

      // Получаем видимую часть отрезка на экране
      final clipped = _clipSegment(p1, p2, minX, minY, maxX, maxY);
      
      if (clipped != null) {
        // Длина только той части, которую видит оператор
        final visibleDistPx = math.sqrt(math.pow(clipped[1].x - clipped[0].x, 2) + math.pow(clipped[1].y - clipped[0].y, 2));

        if (visibleDistPx > maxVisibleSegmentDistPx) {
          maxVisibleSegmentDistPx = visibleDistPx;
          
          // Центр высчитывается строго по видимой части отрезка
          bestMidPoint = math.Point((clipped[0].x + clipped[1].x) / 2, (clipped[0].y + clipped[1].y) / 2);
          
          // Угол сохраняем от оригинального вектора, чтобы избежать математических артефактов
          bestAngle = math.atan2(p2.y - p1.y, p2.x - p1.x);
        }
      }
    }

    // Защита: если на экране нет куска линии длиннее 85px, скрываем текст
    if (maxVisibleSegmentDistPx < 85 || bestMidPoint == null) return null;

    final labelLatLng = camera.pointToLatLng(bestMidPoint);

    // Нормализация текста (слева направо)
    if (bestAngle > math.pi / 2) {
      bestAngle -= math.pi;
    } else if (bestAngle < -math.pi / 2) {
      bestAngle += math.pi;
    }

    return Marker(
      point: labelLatLng,
      width: 140,
      height: 24,
      rotate: true,
      child: Container(
        alignment: Alignment.center,
        child: Transform.rotate(
          angle: bestAngle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(4),
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
                color: Colors.black87,
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