/*
 * Файл: map_screen.dart
 * Версия: 1.42.4
 * Изменения: Добавлена обработка долгого нажатия (onLongPress) на кнопку геолокации для автоматического центрирования и масштабирования карты по всем видимым узлам сети (через MapCalculator).
 */

import 'dart:async';
import 'dart:io'; 
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter_compass/flutter_compass.dart'; 
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart'; 

import 'ble_service.dart';
import 'app_settings.dart'; 
import 'offline_map_manager.dart'; 
import 'map_calculator.dart'; // ИЗМЕНЕНИЕ 1.42.4: Импорт калькулятора границ

import 'map_components/map_scale_bar.dart';
import 'map_components/map_compass.dart';
import 'map_components/map_grid_layer.dart'; 
import 'map_components/drawing_toolbar.dart';
import 'map_components/drawing_manager.dart';
import 'map_components/drawing_layer.dart';
import 'map_components/drawing_controller.dart';
import 'map_components/nodes_layer.dart';
import 'map_components/region_selection_layer.dart';

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
  final DrawingController _drawingController = DrawingController();
  
  StreamSubscription<CompassEvent>? _compassSubscription;
  late int _lastCompassMode;
  bool _isMapReady = false;

  DrawingTool _activeTool = DrawingTool.view;
  List<LatLng> _currentDrawingLinePath = [];
  bool _isRegionDrawingActive = false; 

  double _downloadWidgetX = 16.0;
  double _downloadWidgetY = 100.0;

  @override
  void initState() {
    super.initState();
    _lastCompassMode = AppSettings().compassMode;
    if (AppSettings().keepScreenOn) WakelockPlus.enable();
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
      _compassSubscription ??= FlutterCompass.events?.listen((event) {
          if (event.heading != null && mounted) {
            _mapController.rotate(360 - event.heading!);
          }
        });
    } else {
      _compassSubscription?.cancel();
      _compassSubscription = null;
      if (mode == 0) _mapController.rotate(0); 
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
              onPressed: () => setState(() => _isRegionDrawingActive = false),
            )
          : IconButton(
              icon: const Icon(Icons.crop_square, color: Colors.blueGrey),
              tooltip: 'Активировать рамку региона',
              onPressed: () => setState(() => _isRegionDrawingActive = true),
            ),
    );
  }

  Widget _buildDraggableDownloadWidget() {
    return ListenableBuilder(
      listenable: OfflineMapManager(),
      builder: (context, child) {
        final manager = OfflineMapManager();
        if (!manager.isDownloading) return const SizedBox.shrink();

        final colorScheme = Theme.of(context).colorScheme;

        return Positioned(
          left: _downloadWidgetX,
          top: _downloadWidgetY,
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                _downloadWidgetX = math.max(0, _downloadWidgetX + details.delta.dx);
                _downloadWidgetY = math.max(0, _downloadWidgetY + details.delta.dy);
              });
            },
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 260,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.cloud_download, size: 20, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            manager.currentRegionName, 
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        InkWell(
                          onTap: () => manager.cancelDownload(),
                          child: Icon(Icons.cancel, size: 20, color: colorScheme.error),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: manager.progressPercentage / 100.0,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${manager.downloadedTiles} / ${manager.totalTiles} тайлов',
                          style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                        ),
                        Text(
                          '${manager.progressPercentage.toStringAsFixed(1)}%',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isOfflineSelectMode ? 'Выбор оффлайн-карты' : 'Naviga Map'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Stack(
        children: [
          ListenableBuilder(
            listenable: Listenable.merge([
              _bleService.nodeDatabase,
              _bleService.identityNotifier,
              DrawingManager(), 
              AppSettings(), 
            ]),
            builder: (context, child) {
              final nodes = _bleService.nodeDatabase.nodes.values.where((n) => n.hasValidGps);
              final myId = _bleService.identityNotifier.value?.myNodeId;

              LatLng initialCenter;
              double initialZoom;

              if (AppSettings().mapLastLat != 0.0 && AppSettings().mapLastLng != 0.0) {
                initialCenter = LatLng(AppSettings().mapLastLat, AppSettings().mapLastLng);
                initialZoom = AppSettings().mapLastZoom;
              } else if (nodes.isNotEmpty) {
                final myNode = nodes.firstWhere((n) => n.nodeId == myId, orElse: () => nodes.first);
                initialCenter = LatLng(myNode.lat, myNode.lon);
                initialZoom = 15.0;
              } else {
                initialCenter = const LatLng(59.4370, 24.7536); 
                initialZoom = 13.0;
              }

              int interactiveFlags = InteractiveFlag.all;
              if (widget.isOfflineSelectMode) {
                interactiveFlags = interactiveFlags & ~InteractiveFlag.rotate; 
                if (_isRegionDrawingActive) interactiveFlags = interactiveFlags & ~InteractiveFlag.drag; 
              } else if (AppSettings().compassMode != 1) {
                interactiveFlags = interactiveFlags & ~InteractiveFlag.rotate; 
              }

              TileProvider tileProvider;
              if (AppSettings().mapNetworkMode == 2) {
                tileProvider = NetworkTileProvider(); 
              } else {
                final cacheBehavior = AppSettings().mapNetworkMode == 1
                    ? CacheBehavior.cacheOnly 
                    : CacheBehavior.cacheFirst; 
                    
                tileProvider = FMTCStore('NavigaStore').getTileProvider(
                  settings: FMTCTileProviderSettings(behavior: cacheBehavior), 
                );
              }

              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: initialCenter,
                  initialZoom: initialZoom,
                  interactionOptions: InteractionOptions(flags: interactiveFlags),
                  
                  onPositionChanged: (camera, hasGesture) {
                    if (hasGesture && camera.center != null && camera.zoom != null) {
                      AppSettings().saveMapPosition(
                        camera.center!.latitude, 
                        camera.center!.longitude, 
                        camera.zoom!
                      );
                    }
                  },

                  onTap: (tapPosition, latLng) {
                    _drawingController.handleDrawingTap(
                      context: context,
                      tappedPoint: latLng,
                      camera: _mapController.camera,
                      activeTool: _activeTool,
                      currentDrawingLinePath: _currentDrawingLinePath,
                      onPathUpdated: () => setState(() {}),
                    );
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
                        -1, 0, 0, 0, 255, 0, -1, 0, 0, 255, 0, 0, -1, 0, 255, 0, 0, 0, 1, 0,
                      ]),
                      child: TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.michroz2.naviga_operator',
                        tileProvider: tileProvider, 
                      ),
                    )
                  else
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.michroz2.naviga_operator',
                      tileProvider: tileProvider, 
                    ),
                  
                  if (_isMapReady && AppSettings().showGrid) const MapGridLayer(),

                  const MapDrawingLayer(),

                  if (widget.isOfflineSelectMode && _isRegionDrawingActive)
                    RegionSelectionLayer(
                      mapController: _mapController,
                      isMapReady: _isMapReady,
                      onCancel: () => setState(() => _isRegionDrawingActive = false),
                      onRegionSelected: (newRegion) async {
                        try {
                          final result = await InternetAddress.lookup('tile.openstreetmap.org');
                          if (result.isEmpty || result[0].rawAddress.isEmpty) {
                            throw const SocketException('No network');
                          }
                        } catch (_) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Нет соединения с сервером карт. Загрузка невозможна.'),
                                backgroundColor: Colors.red,
                              )
                            );
                            setState(() => _isRegionDrawingActive = false);
                          }
                          return; 
                        }

                        DrawingManager().addElement(newRegion);
                        OfflineMapManager().downloadRegion(newRegion);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Загрузка региона "${newRegion.label}" запущена в фоне'))
                          );
                        }
                        setState(() => _isRegionDrawingActive = false);
                      },
                    ),

                  if (_currentDrawingLinePath.length > 1 && !widget.isOfflineSelectMode)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: _currentDrawingLinePath,
                          strokeWidth: DrawingManager().lastLineWidth,
                          color: Color(int.parse(DrawingManager().lastLineColorHex.replaceFirst('#', '0xFF'))).withValues(alpha: 0.7),
                        ),
                      ],
                    ),
                    
                  NodesLayer(isInteractive: _activeTool == DrawingTool.view && !widget.isOfflineSelectMode),
                  
                  const Align(alignment: Alignment.bottomLeft, child: MapScaleBar()),
                  
                  if (!widget.isOfflineSelectMode)
                    const Align(alignment: Alignment.topRight, child: SafeArea(child: MapCompassWidget())),

                  if (widget.isOfflineSelectMode)
                    Align(
                      alignment: Alignment.topLeft,
                      child: SafeArea(
                        child: Padding(padding: const EdgeInsets.only(top: 16.0, left: 16.0), child: _buildOfflineRegionToolbar()),
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
                              setState(() => _activeTool = tool);
                              
                              if (previousTool == DrawingTool.line && tool != DrawingTool.line) {
                                _drawingController.processLineCompletion(
                                  context: context,
                                  currentDrawingLinePath: _currentDrawingLinePath,
                                  onPathCleared: () => setState(() => _currentDrawingLinePath.clear()),
                                );
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
          
          _buildDraggableDownloadWidget(),
        ],
      ),
      // ИЗМЕНЕНИЕ 1.42.4: Обертка в GestureDetector для перехвата длинного нажатия (FitBounds)
      floatingActionButton: GestureDetector(
        onLongPress: () {
          final nodes = _bleService.nodeDatabase.nodes;
          final myId = _bleService.identityNotifier.value?.myNodeId;
          
          final cameraFit = MapCalculator.calculateInitialFit(nodes, myId);
          if (cameraFit != null) {
            _mapController.fitCamera(cameraFit);
            // Примечание: Программное изменение позиции не меняет AppSettings, 
            // так как hasGesture в onPositionChanged будет false.
          }
        },
        child: FloatingActionButton(
          onPressed: () {
            final myId = _bleService.identityNotifier.value?.myNodeId;
            final myNode = _bleService.nodeDatabase.nodes[myId];
            if (myNode != null && myNode.hasValidGps) {
              // Считываем текущий зум перед перемещением
              final currentZoom = _mapController.camera.zoom;
         
              _mapController.move(LatLng(myNode.lat, myNode.lon), currentZoom);
              
              AppSettings().saveMapPosition(myNode.lat, myNode.lon, currentZoom);
            }
          },
          //tooltip: 'Найти себя (Удерж: Показать всех)',
          child: const Icon(Icons.my_location),
        ),
      ),
    );
  }
}