/*
 * Файл: map_screen.dart
 * Версия: 1.35.1
 * Изменения: Интеграция математического инвертирования цветов (тактический режим) для TileLayer на основе AppSettings().invertMapColors.
 */

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter_compass/flutter_compass.dart'; 

import 'ble_service.dart';
import 'roster_screen.dart'; 
import 'app_settings.dart'; 

import 'map_components/map_marker_manager.dart';
import 'map_components/map_scale_bar.dart';
import 'map_components/map_compass.dart';
import 'map_components/map_grid_layer.dart';

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
              // 1. Фон карты с аппаратным фильтром инверсии (Тактический режим)
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
                  ),
                )
              else
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.michroz2.naviga_operator',
                ),
              
              // 2. Оптимизированный слой сетки
              if (_isMapReady && AppSettings().showGrid)
                const MapGridLayer(),
                
              // 3. Слой треков узлов
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
              
              // 4. Слой маркеров узлов
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
              
              // 5. UI Оверлеи
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