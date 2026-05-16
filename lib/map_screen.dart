/*
 * Файл: map_screen.dart
 * Версия: 1.19
 * Изменения: ЭТАП 1, Шаг 3. Внедрение базового виджета FlutterMap и TileLayer (OSM).
 * Описание: Главный экран картографического модуля (интеграция flutter_map).
 */

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Карта (Naviga)'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: FlutterMap(
        options: const MapOptions(
          initialCenter: LatLng(59.4370, 24.7536), // Дефолтный центр (Таллин)
          initialZoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.naviga_operator',
          ),
        ],
      ),
    );
  }
}