/*
 * Файл: map_screen.dart
 * Версия: 1.22.2
 * Изменения: ЭТАП 2, Шаг 6 (Хотфикс). Использование MapCalculator.initialCameraFit для безупречного центрирования без визуальных "прыжков".
 * Описание: Главный экран картографического модуля (интеграция flutter_map).
 */

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'ble_service.dart';
import 'map_calculator.dart'; // ИЗМЕНЕНИЕ: Подключен математический модуль

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final BleService _bleService = BleService();
  final MapController _mapController = MapController();
  
  bool _hasCenteredOnMe = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Карта (Naviga)'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([
          _bleService.nodeDatabase,
          _bleService.identityNotifier,
        ]),
        builder: (context, child) {
          final nodesMap = _bleService.nodeDatabase.nodes;
          final myNodeId = _bleService.identityNotifier.value?.myNodeId;
          final myNode = myNodeId != null ? nodesMap[myNodeId] : null;

          // Логика "прыжка", только если мы зашли слепыми, и вдруг поймали свой GPS
          if (!_hasCenteredOnMe && myNode != null && myNode.lat != 0.0 && myNode.lon != 0.0) {
            _hasCenteredOnMe = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final dynamicFit = MapCalculator.calculateInitialFit(nodesMap, myNodeId);
              if (dynamicFit != null) {
                _mapController.fitCamera(dynamicFit);
              }
            });
          }

          // Формируем список маркеров
          final List<Marker> nodeMarkers = [];
          
          for (final node in nodesMap.values) {
            if (node.lat != 0.0 && node.lon != 0.0) {
              nodeMarkers.add(
                Marker(
                  point: LatLng(node.lat, node.lon),
                  width: 40.0,
                  height: 40.0,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.location_pin,
                    color: Colors.blueAccent,
                    size: 40.0,
                  ),
                ),
              );
            }
          }

          // Первоначальное вычисление границ. Если GPS нет ни у кого, MapCalculator вернет null.
          // В этом случае сработает резервный initialCenter (Таллин).
          final initialFit = MapCalculator.calculateInitialFit(nodesMap, myNodeId);

          return FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCameraFit: initialFit, // Умное вычисление Bounds при открытии
              initialCenter: const LatLng(59.4370, 24.7536), // Резервный центр
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.naviga_operator',
              ),
              MarkerLayer(
                markers: nodeMarkers,
              ),
            ],
          );
        },
      ),
    );
  }
}