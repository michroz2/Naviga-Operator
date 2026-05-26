/*
 * Файл: map_screen.dart
 * Версия: 1.39.10
 * Изменения: TileLayer подстраивается под AppSettings().mapNetworkMode. Если выбран режим Только Онлайн, используется стандартный NetworkTileProvider().
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
import 'app_settings.dart'; 
import 'offline_map_manager.dart'; 

import 'map_components/map_scale_bar.dart';
import 'map_components/map_compass.dart';
import 'map_components/map_grid_layer.dart';
import 'map_components/drawing_toolbar.dart';
import 'map_components/drawing_manager.dart';
import 'map_components/drawing_models.dart';
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
                  color: colorScheme.surface.withOpacity(0.95),
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
                      backgroundColor: colorScheme.surfaceVariant,
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
              AppSettings(), // ИЗМЕНЕНИЕ: Подписка на настройки для динамического обновления провайдера
            ]),
            builder: (context, child) {
              final nodes = _bleService.nodeDatabase.nodes.values.where((n) => n.hasValidGps);
              final myId = _bleService.identityNotifier.value?.myNodeId;

              LatLng initialCenter = const LatLng(0, 0);
              if (nodes.isNotEmpty) {
                final myNode = nodes.firstWhere((n) => n.nodeId == myId, orElse: () => nodes.first);
                initialCenter = LatLng(myNode.lat, myNode.lon);
              }

              int interactiveFlags = InteractiveFlag.all;
              if (widget.isOfflineSelectMode) {
                interactiveFlags = interactiveFlags & ~InteractiveFlag.rotate;
                if (_isRegionDrawingActive) interactiveFlags = interactiveFlags & ~InteractiveFlag.drag; 
              } else if (AppSettings().compassMode != 1) {
                interactiveFlags = interactiveFlags & ~InteractiveFlag.rotate;
              }

              // ИЗМЕНЕНИЕ: Выбор провайдера тайлов в зависимости от режима сети
              final tileProvider = AppSettings().mapNetworkMode == 2
                  ? NetworkTileProvider()
                  : FMTCStore('NavigaStore').getTileProvider();

              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: initialCenter,
                  initialZoom: 15.0,
                  interactionOptions: InteractionOptions(flags: interactiveFlags),
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
                      onRegionSelected: (newRegion) {
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
                          color: Color(int.parse(DrawingManager().lastLineColorHex.replaceFirst('#', '0xFF'))).withOpacity(0.7),
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