/*
 * Файл: map_screen.dart
 * Версия: 1.33.1
 * Изменения: UC-23, Шаг 1. Добавлен компонент MapScaleBar для динамического отображения масштабной линейки в левом нижнем углу карты.
 * Описание: Экран визуализации узлов на интерактивной карте.
 */

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'ble_service.dart';
import 'node_database.dart';
import 'roster_screen.dart'; 
import 'app_settings.dart'; 

// ============================================================================
// Вспомогательный класс: Управление стилями маркеров
// ============================================================================
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

// ============================================================================
// Компонент: Масштабная линейка (Scale Bar)
// ============================================================================
class MapScaleBar extends StatelessWidget {
  const MapScaleBar({super.key});

  @override
  Widget build(BuildContext context) {
    // Получаем текущее состояние камеры карты
    final camera = MapCamera.of(context);
    final lat = camera.center.latitude;
    final zoom = camera.zoom;

    // Расчет метров в одном пикселе для текущей широты и зума (EPSG:3857)
    final metersPerPixel = (math.cos(lat * math.pi / 180) * 2 * math.pi * 6378137) / (256 * math.pow(2, zoom));
    
    // Предустановленные красивые шаги линейки в метрах
    final List<double> scaleSteps = [
      1, 2, 5, 10, 20, 50, 100, 200, 500, 
      1000, 2000, 5000, 10000, 20000, 50000, 
      100000, 200000, 500000, 1000000, 2000000, 5000000
    ];
    
    // Целевая ширина линейки около 100 пикселей
    const double targetPixels = 100.0;
    final double distanceMeters = targetPixels * metersPerPixel;
    
    // Ищем наиболее подходящий шаг
    double selectedScale = scaleSteps.first;
    for (var step in scaleSteps) {
      if (distanceMeters >= step) {
        selectedScale = step;
      } else {
        break;
      }
    }
    
    // Вычисляем фактическую ширину плашки в пикселях
    final double scaleWidth = selectedScale / metersPerPixel;
    
    // Формируем подпись
    final String label = selectedScale >= 1000 
        ? '${(selectedScale / 1000).toStringAsFixed(0)} км' 
        : '${selectedScale.toStringAsFixed(0)} м';

    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Container(
            width: scaleWidth,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.black87,
              border: Border.all(color: Colors.white, width: 1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Экран Карты
// ============================================================================
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final BleService _bleService = BleService();
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    if (AppSettings().keepScreenOn) {
      WakelockPlus.enable();
      debugPrint('Wakelock: Экран заблокирован от засыпания (только на Карте)');
    }
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    debugPrint('Wakelock: Ограничение сна экрана снято при выходе из Карты');
    _mapController.dispose();
    super.dispose();
  }

  String _getRoleName(int roleCode) {
    switch (roleCode) {
      case 0: return 'Ретранслятор';
      case 1: return 'Сталкер';
      case 2: return 'Трекер';
      default: return 'Неизвестно';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Naviga Map'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([
          _bleService.nodeDatabase,
          _bleService.identityNotifier,
          _bleService.sysConfigNotifier,
          AppSettings(), 
        ]),
        builder: (context, child) {
          final nodes = _bleService.nodeDatabase.nodes.values
              .where((n) => n.hasValidGps)
              .toList();

          final myId = _bleService.identityNotifier.value?.myNodeId;
          final timeoutMs = _bleService.sysConfigNotifier.value?.nodeConnectionTimeout ?? 600000;
          final now = DateTime.now().millisecondsSinceEpoch;

          LatLng initialCenter = const LatLng(0, 0);
          if (nodes.isNotEmpty) {
            final myNode = nodes.firstWhere((n) => n.nodeId == myId, orElse: () => nodes.first);
            initialCenter = LatLng(myNode.lat, myNode.lon);
          }

          return FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: initialCenter,
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.michroz2.naviga_operator',
              ),
              PolylineLayer(
                polylines: nodes.map((node) {
                  final isMe = node.nodeId == myId;
                  final isOnline = isMe ? true : (now - node.lastSeenTimeMs) <= timeoutMs;
                  final style = MarkerStyleManager.getStyle(role: node.role, isMe: isMe, isOnline: isOnline);
                  
                  final track = node.getRecentTrack(AppSettings().trackTimeMs);

                  return Polyline(
                    points: track,
                    strokeWidth: AppSettings().trackWidth, 
                    color: style.color.withOpacity(isOnline ? 0.6 : 0.3),
                  );
                }).where((p) => p.points.length > 1).toList(), 
              ),
              MarkerLayer(
                markers: nodes.map((node) {
                  final isMe = node.nodeId == myId;
                  final isOnline = isMe ? true : (now - node.lastSeenTimeMs) <= timeoutMs;
                  
                  final style = MarkerStyleManager.getStyle(
                    role: node.role,
                    isMe: isMe,
                    isOnline: isOnline,
                  );

                  return Marker(
                    point: LatLng(node.lat, node.lon),
                    width: 120, 
                    height: 80, 
                    child: GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (context) => NodeDetailsSheet(
                            node: node,
                            isMe: isMe,
                            roleName: _getRoleName(node.role),
                            isOnline: isOnline,
                          ),
                        );
                      },
                      child: Opacity(
                        opacity: style.opacity,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(color: Colors.black26, blurRadius: 3, offset: Offset(0, 2))
                                ],
                              ),
                              padding: const EdgeInsets.all(6),
                              child: Icon(style.icon, color: style.color, size: 28),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.85),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.black12),
                              ),
                              child: Text(
                                node.nodeName,
                                style: const TextStyle(
                                  fontSize: 11, 
                                  fontWeight: FontWeight.bold, 
                                  color: Colors.black87
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              // Масштабная линейка в левом нижнем углу
              const Align(
                alignment: Alignment.bottomLeft,
                child: MapScaleBar(),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final myId = _bleService.identityNotifier.value?.myNodeId;
          final myNode = _bleService.nodeDatabase.nodes[myId];
          if (myNode != null && myNode.hasValidGps) {
            _mapController.move(LatLng(myNode.lat, myNode.lon), 16.0);
          }
        },
        tooltip: 'Найти себя',
        child: const Icon(Icons.my_location),
      ),
    );
  }
}