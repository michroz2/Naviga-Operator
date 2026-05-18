/*
 * Файл: map_screen.dart
 * Версия: 1.23
 * Изменения: ЭТАП 2, Шаг 6 (Исправление). Вычисление initialCenter в initState для мгновенного центрирования при открытии экрана.
 * Описание: Главный экран картографического модуля (интеграция flutter_map).
 */

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'ble_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final BleService _bleService = BleService();
  final MapController _mapController = MapController();
  
  bool _hasCenteredOnMe = false;
  late LatLng _initialCenter;
  late double _initialZoom;

  @override
  void initState() {
    super.initState();
    
    // Считываем базу данных прямо в момент создания экрана
    final myId = _bleService.identityNotifier.value?.myNodeId;
    final myNode = myId != null ? _bleService.nodeDatabase.nodes[myId] : null;

    // Если координаты уже есть в базе на момент открытия экрана - стартуем прямо с них
    if (myNode != null && myNode.lat != 0.0 && myNode.lon != 0.0) {
      _initialCenter = LatLng(myNode.lat, myNode.lon);
      _initialZoom = 15.0; // Приближаем, так как это мы
      _hasCenteredOnMe = true;
    } else {
      _initialCenter = const LatLng(59.4370, 24.7536); // Таллин по умолчанию
      _initialZoom = 13.0;
    }
  }

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

          // Эта логика сработает только если мы зашли на карту БЕЗ координат, 
          // и Донгл поймал GPS уже в процессе просмотра карты
          if (!_hasCenteredOnMe && myNode != null && myNode.lat != 0.0 && myNode.lon != 0.0) {
            _hasCenteredOnMe = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _mapController.move(LatLng(myNode.lat, myNode.lon), 15.0);
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

          return FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialCenter, 
              initialZoom: _initialZoom,
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