/*
 * Файл: map_screen.dart
 * Версия: 1.21
 * Изменения: ЭТАП 2, Шаг 5. Добавлен MarkerLayer для вывода базовых маркеров узлов (с валидными координатами).
 * Описание: Главный экран картографического модуля (интеграция flutter_map).
 */

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'ble_service.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bleService = BleService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Карта (Naviga)'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([
          bleService.nodeDatabase,
          bleService.identityNotifier,
        ]),
        builder: (context, child) {
          final nodesMap = bleService.nodeDatabase.nodes;
          // myNodeId пока не используем, он понадобится на следующих шагах для стилизации
          // final myNodeId = bleService.identityNotifier.value?.myNodeId;

          // Формируем список маркеров
          final List<Marker> nodeMarkers = [];
          
          for (final node in nodesMap.values) {
            // Исключаем узлы без зафиксированных координат (0.0, 0.0)
            if (node.lat != 0.0 && node.lon != 0.0) {
              nodeMarkers.add(
                Marker(
                  point: LatLng(node.lat, node.lon),
                  width: 40.0,
                  height: 40.0,
                  alignment: Alignment.center, // Центрируем иконку точно по координатам
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
            options: const MapOptions(
              initialCenter: LatLng(59.4370, 24.7536), // Дефолтный центр (Таллин)
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