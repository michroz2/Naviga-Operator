/*
 * Файл: map_screen.dart
 * Версия: 1.39.0
 * Описание: Главный экран-оркестратор интерактивной карты с поддержкой тактической разметки.
 * Изменения: 
 * - Шаг 4: Интеграция OfflineMapManager. Добавлен импорт и вызов запуска фоновой загрузки 
 * после успешного создания региона.
 */

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter_compass/flutter_compass.dart'; 
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart'; 

import 'ble_service.dart';
import 'roster_screen.dart'; 
import 'app_settings.dart'; 
import 'offline_map_manager.dart'; // ИНТЕГРАЦИЯ: Импорт сервиса загрузки

import 'map_components/map_marker_manager.dart';
import 'map_components/map_scale_bar.dart';
import 'map_components/map_compass.dart';
import 'map_components/map_grid_layer.dart';

import 'map_components/drawing_toolbar.dart';
import 'map_components/drawing_manager.dart';
import 'map_components/drawing_models.dart';
import 'map_components/drawing_layer.dart';
import 'map_components/drawing_menu_sheet.dart'; 
import 'map_components/region_download_sheet.dart';

class MapScreen extends StatefulWidget {
  final bool isOfflineSelectMode; 

  const MapScreen({
    super.key, 
    this.isOfflineSelectMode = false,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final BleService _bleService = BleService();
  final MapController _mapController = MapController();
  
  StreamSubscription<CompassEvent>? _compassSubscription;
  late int _lastCompassMode;
  bool _isMapReady = false;

  DrawingTool _activeTool = DrawingTool.view;
  final List<LatLng> _currentDrawingLinePath = [];

  bool _isRegionDrawingActive = false; 
  LatLng? _regionDragStart;
  LatLng? _regionDragCurrent;

  @override
  void initState() {
    super.initState();
    _lastCompassMode = AppSettings().compassMode;
    
    if (AppSettings().keepScreenOn) {
      WakelockPlus.enable();
    }
    AppSettings().addListener(_onSettingsChanged);
    DrawingManager().load();
  }

  @override
  void dispose() {
    AppSettings().removeListener(_onSettingsChanged);
    _compassSubscription?.cancel();
    WakelockPlus.disable();
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
    
    if (widget.isOfflineSelectMode) {
      _compassSubscription?.cancel();
      _compassSubscription = null;
      _mapController.rotate(0);
      return;
    }

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

  Future<void> _handleDrawingTap(LatLng tappedPoint, MapCamera camera) async {
    if (widget.isOfflineSelectMode) return;

    final manager = DrawingManager();
    final metersPerPixel = (math.cos(tappedPoint.latitude * math.pi / 180) * 2 * math.pi * 6378137) / (256 * math.pow(2, camera.zoom));
    final searchRadiusMeters = 40.0 * metersPerPixel;
    const distanceCalculator = Distance();

    TacticalPoint? closestPoint;
    double minPointDistMeters = searchRadiusMeters;

    TacticalLine? closestLine;
    double minLineDistMeters = searchRadiusMeters;

    for (var element in manager.elements) {
      if (element is TacticalPoint) {
        final dist = distanceCalculator.distance(tappedPoint, LatLng(element.lat, element.lon));
        if (dist < minPointDistMeters) {
          minPointDistMeters = dist;
          closestPoint = element;
        }
      } else if (element is TacticalLine) {
        if (element.path.isEmpty) continue;
        for (var latLng in element.path) {
          final dist = distanceCalculator.distance(tappedPoint, latLng);
          if (dist < minLineDistMeters) {
            minLineDistMeters = dist;
            closestLine = element;
          }
        }
      }
    }

    if (_activeTool == DrawingTool.line) {
      LatLng pointToAdd = tappedPoint;
      
      if (closestPoint != null) {
        pointToAdd = LatLng(closestPoint.lat, closestPoint.lon);
      } else {
        final nodes = _bleService.nodeDatabase.nodes.values.where((n) => n.hasValidGps);
        double minNodeDist = searchRadiusMeters;
        for (var node in nodes) {
          final dist = distanceCalculator.distance(tappedPoint, LatLng(node.lat, node.lon));
          if (dist < minNodeDist) {
            minNodeDist = dist;
            pointToAdd = LatLng(node.lat, node.lon);
          }
        }
      }

      setState(() {
        _currentDrawingLinePath.add(pointToAdd);
      });
      return; 
    }

    if (_activeTool == DrawingTool.point) {
      final attrs = await showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        isScrollControlled: true,
        builder: (_) => const DrawingMenuSheet(targetType: TacticalType.point),
      );

      if (attrs != null) {
        final newId = DateTime.now().millisecondsSinceEpoch.toString();
        manager.addElement(TacticalPoint(
          id: newId, lat: tappedPoint.latitude, lon: tappedPoint.longitude,
          label: attrs['label'], description: attrs['description'],
          colorHex: attrs['colorHex'], iconKey: attrs['iconKey'],
        ));
      }
      return; 
    }

    TacticalElement? closest = closestPoint ?? closestLine;

    if (closest != null) {
      if (_activeTool == DrawingTool.view) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => DrawingInfoSheet(element: closest),
        );
      } else if (_activeTool == DrawingTool.select) {
        final attrs = await showModalBottomSheet<Map<String, dynamic>>(
          context: context,
          isScrollControlled: true,
          builder: (_) => DrawingMenuSheet(
            existingElement: closest,
            targetType: closest.type,
          ),
        );

        if (attrs != null) {
          if (closest is TacticalPoint) {
            manager.updateElement(TacticalPoint(
              id: closest.id, lat: closest.lat, lon: closest.lon,
              label: attrs['label'], description: attrs['description'],
              colorHex: attrs['colorHex'], iconKey: attrs['iconKey'],
            ));
          } else if (closest is TacticalLine) {
            manager.updateElement(TacticalLine(
              id: closest.id, path: closest.path,
              label: attrs['label'], description: attrs['description'],
              colorHex: attrs['colorHex'], width: attrs['lineWidth'],
            ));
          }
        }
      } else if (_activeTool == DrawingTool.eraser) {
        manager.removeElement(closest.id);
      }
    }
  }

  Future<void> _processLineCompletion(DrawingTool newTool) async {
    if (_currentDrawingLinePath.length > 1) {
      if (newTool == DrawingTool.eraser) {
        setState(() => _currentDrawingLinePath.clear());
      } else {
        final attrs = await showModalBottomSheet<Map<String, dynamic>>(
          context: context,
          isScrollControlled: true,
          builder: (_) => const DrawingMenuSheet(targetType: TacticalType.line),
        );

        if (attrs != null) {
          final newId = DateTime.now().millisecondsSinceEpoch.toString();
          DrawingManager().addElement(TacticalLine(
            id: newId,
            label: attrs['label'],
            description: attrs['description'],
            colorHex: attrs['colorHex'],
            path: List.from(_currentDrawingLinePath),
            width: attrs['lineWidth'],
          ));
        }
        setState(() => _currentDrawingLinePath.clear());
      }
    } else {
      setState(() => _currentDrawingLinePath.clear());
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

  Widget _buildOfflineRegionToolbar() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: _isRegionDrawingActive
          ? IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              tooltip: 'Отменить выделение',
              onPressed: () {
                setState(() {
                  _isRegionDrawingActive = false;
                  _regionDragStart = null;
                  _regionDragCurrent = null;
                });
              },
            )
          : IconButton(
              icon: const Icon(Icons.crop_square, color: Colors.blueGrey),
              tooltip: 'Активировать рамку региона',
              onPressed: () {
                setState(() {
                  _isRegionDrawingActive = true;
                });
              },
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isOfflineSelectMode ? 'Выбор оффлайн-карты' : 'Naviga Map'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([
          _bleService.nodeDatabase,
          _bleService.identityNotifier,
          _bleService.sysConfigNotifier,
          AppSettings(),
          DrawingManager(), 
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
          
          if (widget.isOfflineSelectMode) {
            interactiveFlags = interactiveFlags & ~InteractiveFlag.rotate;
            if (_isRegionDrawingActive) {
              interactiveFlags = interactiveFlags & ~InteractiveFlag.drag; 
            }
          } else if (AppSettings().compassMode != 1) {
            interactiveFlags = interactiveFlags & ~InteractiveFlag.rotate;
          }

          return FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: initialCenter,
              initialZoom: 15.0,
              interactionOptions: InteractionOptions(
                flags: interactiveFlags,
              ),
              onTap: (tapPosition, latLng) {
                _handleDrawingTap(latLng, _mapController.camera);
              },
              onMapReady: () {
                _isMapReady = true;
                _applyCompassMode();
                setState(() {});
              },
            ),
            children: [
              if (AppSettings().invertMapColors)
                ColorFiltered(
                  colorFilter: const ColorFilter.matrix(<double>[
                    -1,  0,  0, 0, 255,
                     0, -1,  0, 0, 255,
                     0,  0, -1, 0, 255,
                     0,  0,  0, 1,   0,
                  ]),
                  child: TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.michroz2.naviga_operator',
                    tileProvider: FMTCStore('NavigaStore').getTileProvider(), 
                  ),
                )
              else
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.michroz2.naviga_operator',
                  tileProvider: FMTCStore('NavigaStore').getTileProvider(), 
                ),
              
              if (_isMapReady && AppSettings().showGrid)
                const MapGridLayer(),

              const MapDrawingLayer(),

              if (widget.isOfflineSelectMode && _regionDragStart != null && _regionDragCurrent != null)
                PolygonLayer(
                  polygons: [
                    Polygon(
                      points: [
                        _regionDragStart!,
                        LatLng(_regionDragStart!.latitude, _regionDragCurrent!.longitude),
                        _regionDragCurrent!,
                        LatLng(_regionDragCurrent!.latitude, _regionDragStart!.longitude),
                      ],
                      color: Colors.blue.withOpacity(0.3),
                      borderColor: Colors.blue,
                      borderStrokeWidth: 2.0,
                    )
                  ],
                ),

              if (widget.isOfflineSelectMode && _isRegionDrawingActive)
                Positioned.fill(
                  child: Listener(
                    behavior: HitTestBehavior.opaque, 
                    onPointerDown: (event) {
                      if (!_isMapReady) return;
                      final point = _mapController.camera.pointToLatLng(math.Point(event.localPosition.dx, event.localPosition.dy));
                      setState(() {
                        _regionDragStart = point;
                        _regionDragCurrent = point;
                      });
                    },
                    onPointerMove: (event) {
                      if (_regionDragStart == null || !_isMapReady) return;
                      final point = _mapController.camera.pointToLatLng(math.Point(event.localPosition.dx, event.localPosition.dy));
                      setState(() {
                        _regionDragCurrent = point;
                      });
                    },
                    onPointerUp: (event) async {
                      if (_regionDragStart == null || _regionDragCurrent == null) {
                        setState(() { _isRegionDrawingActive = false; });
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
                        );
                        DrawingManager().addElement(newRegion);
                        
                        // ИНТЕГРАЦИЯ: Запуск фоновой загрузки через менеджер
                        OfflineMapManager().downloadRegion(newRegion);
                        
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Загрузка региона "$regionName" запущена в фоне'))
                          );
                        }
                        
                        setState(() {
                          _isRegionDrawingActive = false;
                          _regionDragStart = null;
                          _regionDragCurrent = null;
                        });
                      } else {
                        setState(() {
                          _isRegionDrawingActive = false;
                          _regionDragStart = null;
                          _regionDragCurrent = null;
                        });
                      }
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

              if (_currentDrawingLinePath.length > 1 && !widget.isOfflineSelectMode)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _currentDrawingLinePath,
                      strokeWidth: DrawingManager().lastLineWidth,
                      color: Color(int.parse(DrawingManager().lastLineColorHex.replaceFirst('#', '0xFF'))).withOpacity(0.7),
                    ),
                  ],
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
              
              IgnorePointer(
                ignoring: _activeTool != DrawingTool.view || widget.isOfflineSelectMode,
                child: MarkerLayer(
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
              ),
              
              const Align(
                alignment: Alignment.bottomLeft,
                child: MapScaleBar(),
              ),
              
              if (!widget.isOfflineSelectMode)
                const Align(
                  alignment: Alignment.topRight,
                  child: SafeArea(child: MapCompassWidget()),
                ),

              if (widget.isOfflineSelectMode)
                Align(
                  alignment: Alignment.topLeft,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16.0, left: 16.0),
                      child: _buildOfflineRegionToolbar(),
                    ),
                  ),
                )
              else if (AppSettings().showDrawingToolbar)
                Align(
                  alignment: Alignment.topLeft,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16.0, left: 16.0),
                      child: DrawingToolbar(
                        activeTool: _activeTool,
                        onToolSelected: (tool) {
                          final previousTool = _activeTool;
                          setState(() {
                            _activeTool = tool;
                          });
                          
                          if (previousTool == DrawingTool.line && tool != DrawingTool.line) {
                            _processLineCompletion(tool);
                          }
                        },
                      ),
                    ),
                  ),
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