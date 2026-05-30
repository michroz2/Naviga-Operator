/*
 * Файл: region_selection_layer.dart
 * Версия: 1.39.9
 * Изменения: При инициализации TacticalRegion передаются дефолтные параметры стиля границы (isDashed, borderWidth).
 */

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'drawing_models.dart';
import 'region_download_sheet.dart';

class RegionSelectionLayer extends StatefulWidget {
  final MapController mapController;
  final bool isMapReady;
  final Function(TacticalRegion) onRegionSelected;
  final VoidCallback onCancel;

  const RegionSelectionLayer({
    super.key,
    required this.mapController,
    required this.isMapReady,
    required this.onRegionSelected,
    required this.onCancel,
  });

  @override
  State<RegionSelectionLayer> createState() => _RegionSelectionLayerState();
}

class _RegionSelectionLayerState extends State<RegionSelectionLayer> {
  LatLng? _regionDragStart;
  LatLng? _regionDragCurrent;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_regionDragStart != null && _regionDragCurrent != null)
          PolygonLayer(
            polygons: [
              Polygon(
                points: [
                  _regionDragStart!,
                  LatLng(_regionDragStart!.latitude, _regionDragCurrent!.longitude),
                  _regionDragCurrent!,
                  LatLng(_regionDragCurrent!.latitude, _regionDragStart!.longitude),
                ],
                color: Colors.blue.withValues(alpha: 0.3),
                borderColor: Colors.blue,
                borderStrokeWidth: 2.0,
              )
            ],
          ),
        Positioned.fill(
          child: Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: (event) {
              if (!widget.isMapReady) return;
              final point = widget.mapController.camera.pointToLatLng(math.Point(event.localPosition.dx, event.localPosition.dy));
              setState(() {
                _regionDragStart = point;
                _regionDragCurrent = point;
              });
            },
            onPointerMove: (event) {
              if (_regionDragStart == null || !widget.isMapReady) return;
              final point = widget.mapController.camera.pointToLatLng(math.Point(event.localPosition.dx, event.localPosition.dy));
              setState(() {
                _regionDragCurrent = point;
              });
            },
            onPointerUp: (event) async {
              if (_regionDragStart == null || _regionDragCurrent == null) {
                widget.onCancel();
                return;
              }

              final start = _regionDragStart!;
              final end = _regionDragCurrent!;
              
              const dist = Distance();
              if (dist.distance(start, end) < 50) {
                setState(() {
                  _regionDragStart = null;
                  _regionDragCurrent = null;
                });
                return;
              }

              final double topLat = math.max(start.latitude, end.latitude);
              final double bottomLat = math.min(start.latitude, end.latitude);
              final double leftLon = math.min(start.longitude, end.longitude);
              final double rightLon = math.max(start.longitude, end.longitude);
              
              final topLeft = LatLng(topLat, leftLon);
              final bottomRight = LatLng(bottomLat, rightLon);

              final regionName = await showModalBottomSheet<String>(
                context: context,
                isScrollControlled: true,
                builder: (_) => RegionDownloadSheet(topLeft: topLeft, bottomRight: bottomRight),
              );

              if (regionName != null) {
                final newRegion = TacticalRegion(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  topLeft: topLeft,
                  bottomRight: bottomRight,
                  label: regionName,
                  description: 'Оффлайн карта',
                  colorHex: '#2196F3',
                  borderWidth: 3.0, // ИЗМЕНЕНИЕ: Дефолтная толщина
                  isDashed: true,   // ИЗМЕНЕНИЕ: Дефолтный стиль (пунктир)
                );
                
                widget.onRegionSelected(newRegion);
              } else {
                widget.onCancel();
              }

              setState(() {
                _regionDragStart = null;
                _regionDragCurrent = null;
              });
            },
            onPointerCancel: (event) {
              setState(() {
                _regionDragStart = null;
                _regionDragCurrent = null;
              });
            },
            child: Container(color: Colors.transparent),
          ),
        ),
      ],
    );
  }
}