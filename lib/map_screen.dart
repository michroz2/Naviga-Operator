/*
 * Файл: map_screen.dart
 * Версия: 1.34.7
 * Изменения: UC-23, Шаг 9. Решена проблема рассинхронизации отрисовки сетки и маркера масштаба: логика сетки выделена в независимый виджет MapGridLayer, слушающий камеру напрямую. Линейка масштаба (MapScaleBar) сделана перманентной (видимой всегда).
 * Описание: Экран визуализации узлов на интерактивной карте.
 */

import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter_compass/flutter_compass.dart'; 
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
// Компонент: Масштабная линейка (Scale Bar) - Перманентная
// ============================================================================
class MapScaleBar extends StatelessWidget {
  const MapScaleBar({super.key});

  @override
  Widget build(BuildContext context) {
    final camera = MapCamera.of(context);
    final lat = camera.center.latitude;
    final zoom = camera.zoom;

    final metersPerPixel = (math.cos(lat * math.pi / 180) * 2 * math.pi * 6378137) / (256 * math.pow(2, zoom));
    
    final List<double> scaleSteps = [
      1, 2, 5, 10, 20, 50, 100, 200, 500, 
      1000, 2000, 5000, 10000, 20000, 50000, 
      100000, 200000, 500000, 1000000, 2000000, 5000000
    ];
    
    const double targetPixels = 100.0;
    final double distanceMeters = targetPixels * metersPerPixel;
    
    double selectedScale = scaleSteps.first;
    for (var step in scaleSteps) {
      if (distanceMeters >= step) {
        selectedScale = step;
      } else {
        break;
      }
    }
    
    final double scaleWidth = selectedScale / metersPerPixel;
    
    final String label = selectedScale >= 1000 
        ? '${(selectedScale / 1000).toStringAsFixed(0)} км' 
        : '${selectedScale.toStringAsFixed(0)} м';

    final bool showGrid = AppSettings().showGrid;

    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 24.0),
      child: GestureDetector(
        onTap: () {
          AppSettings().setShowGrid(!showGrid);
        },
        behavior: HitTestBehavior.opaque,
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
            // ИЗМЕНЕНИЕ: Линейка отрисовывается всегда, независимо от флага showGrid
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
      ),
    );
  }
}

// ============================================================================
// Компонент: Интерактивный компас
// ============================================================================
class MapCompassWidget extends StatelessWidget {
  const MapCompassWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final camera = MapCamera.of(context);
    final rotation = camera.rotation; 
    final mode = AppSettings().compassMode;

    return Padding(
      padding: const EdgeInsets.only(top: 16.0, right: 16.0),
      child: GestureDetector(
        onTap: () {
          AppSettings().setCompassMode((mode + 1) % 3);
        },
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
            ],
          ),
          child: Transform.rotate(
            angle: rotation * math.pi / 180,
            child: Icon(
              Icons.navigation, 
              color: mode == 2 ? Colors.blue.shade700 : Colors.blueGrey,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// Компонент: Слой координатной сетки (Синхронизированный с камерой)
// ============================================================================
class MapGridLayer extends StatefulWidget {
  const MapGridLayer({super.key});

  @override
  State<MapGridLayer> createState() => _MapGridLayerState();
}

class _MapGridLayerState extends State<MapGridLayer> {
  // --- Кэширование (Мемоизация) ---
  List<Polyline> _cachedGrid = [];
  double _lastGridScale = -1;
  LatLng _lastGridCenter = const LatLng(0, 0);
  double _lastGridWidth = -1;
  double _lastGridOpacity = -1;
  double _currentGridBufferLat = 0;
  double _currentGridBufferLon = 0;

  @override
  Widget build(BuildContext context) {
    // Подписываемся на обновления камеры карты напрямую! 
    // Это гарантирует мгновенную перерисовку сетки в тот же кадр, когда меняется маркер масштаба.
    final camera = MapCamera.of(context);
    final lat = camera.center.latitude;
    final lon = camera.center.longitude;
    final zoom = camera.zoom;

    final metersPerPixel = (math.cos(lat * math.pi / 180) * 2 * math.pi * 6378137) / (256 * math.pow(2, zoom));
    
    final List<double> scaleSteps = [
      1, 2, 5, 10, 20, 50, 100, 200, 500, 
      1000, 2000, 5000, 10000, 20000, 50000, 
      100000, 200000, 500000, 1000000, 2000000, 5000000
    ];
    
    const double targetPixels = 100.0;
    final double distanceMeters = targetPixels * metersPerPixel;
    
    double selectedScale = scaleSteps.first;
    for (var step in scaleSteps) {
      if (distanceMeters >= step) {
        selectedScale = step;
      } else {
        break;
      }
    }

    final double strokeWidth = AppSettings().gridWidth;
    final double gridOpacity = AppSettings().gridOpacity;

    final double distLat = (lat - _lastGridCenter.latitude).abs();
    final double distLon = (lon - _lastGridCenter.longitude).abs();

    // Проверка кэша
    if (_cachedGrid.isNotEmpty &&
        _lastGridScale == selectedScale &&
        _lastGridWidth == strokeWidth &&
        _lastGridOpacity == gridOpacity &&
        distLat < (_currentGridBufferLat * 0.6) && 
        distLon < (_currentGridBufferLon * 0.6)) {
      return PolylineLayer(polylines: _cachedGrid);
    }

    // --- Кэш промах: Генерация новой сетки ---
    const double metersPerLatDegree = 111319.9;
    final double latStep = selectedScale / metersPerLatDegree;
    
    final double cosLat = math.max(0.01, math.cos(lat * math.pi / 180));
    final double lonStep = selectedScale / (metersPerLatDegree * cosLat);

    if (latStep <= 0 || lonStep <= 0) return const SizedBox.shrink();

    _currentGridBufferLat = math.min(0.5, 100 * latStep);
    _currentGridBufferLon = math.min(0.5 / cosLat, 100 * lonStep);

    final double startLat = ((lat - _currentGridBufferLat) / latStep).floor() * latStep;
    final double endLat = ((lat + _currentGridBufferLat) / latStep).ceil() * latStep;
    final double startLon = ((lon - _currentGridBufferLon) / lonStep).floor() * lonStep;
    final double endLon = ((lon + _currentGridBufferLon) / lonStep).ceil() * lonStep;

    List<Polyline> lines = [];
    final Color gridColor = Colors.grey.withOpacity(gridOpacity);

    for (double l = startLat; l <= endLat; l += latStep) {
      lines.add(Polyline(
        points: [LatLng(l, startLon), LatLng(l, endLon)],
        strokeWidth: strokeWidth,
        color: gridColor,
      ));
    }

    for (double ln = startLon; ln <= endLon; ln += lonStep) {
      lines.add(Polyline(
        points: [LatLng(startLat, ln), LatLng(endLat, ln)],
        strokeWidth: strokeWidth,
        color: gridColor,
      ));
    }

    _cachedGrid = lines;
    _lastGridScale = selectedScale;
    _lastGridCenter = LatLng(lat, lon);
    _lastGridWidth = strokeWidth;
    _lastGridOpacity = gridOpacity;

    return PolylineLayer(polylines: _cachedGrid);
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
  
  StreamSubscription<CompassEvent>? _compassSubscription;
  late int _lastCompassMode;
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    _lastCompassMode = AppSettings().compassMode;
    
    if (AppSettings().keepScreenOn) {
      WakelockPlus.enable();
      debugPrint('Wakelock: Экран заблокирован от засыпания (только на Карте)');
    }

    AppSettings().addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    AppSettings().removeListener(_onSettingsChanged);
    _compassSubscription?.cancel();
    
    WakelockPlus.disable();
    debugPrint('Wakelock: Ограничение сна экрана снято при выходе из Карты');
    
    _mapController.dispose();
    super.dispose();
  }

  void _onSettingsChanged() {
    if (_lastCompassMode != AppSettings().compassMode) {
      _lastCompassMode = AppSettings().compassMode;
      _applyCompassMode();
    }
  }

  void _applyCompassMode() {
    if (!_isMapReady) return;

    final mode = AppSettings().compassMode;
    
    if (mode == 2) {
      if (_compassSubscription == null) {
        _compassSubscription = FlutterCompass.events?.listen((event) {
          if (event.heading != null && mounted) {
            _mapController.rotate(360 - event.heading!);
          }
        });
      }
    } else {
      _compassSubscription?.cancel();
      _compassSubscription = null;
      
      if (mode == 0) {
        _mapController.rotate(0);
      }
    }
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

          int interactiveFlags = InteractiveFlag.all;
          if (AppSettings().compassMode != 1) {
            interactiveFlags = InteractiveFlag.all & ~InteractiveFlag.rotate;
          }

          return FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: initialCenter,
              initialZoom: 15.0,
              interactionOptions: InteractionOptions(
                flags: interactiveFlags,
              ),
              onMapReady: () {
                _isMapReady = true;
                _applyCompassMode();
                setState(() {});
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.michroz2.naviga_operator',
              ),
              // Вызов независимого слоя сетки. Он будет обновляться абсолютно синхронно с маркером масштаба
              if (_isMapReady && AppSettings().showGrid)
                const MapGridLayer(),
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
              const Align(
                alignment: Alignment.bottomLeft,
                child: MapScaleBar(),
              ),
              const Align(
                alignment: Alignment.topRight,
                child: SafeArea(child: MapCompassWidget()),
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