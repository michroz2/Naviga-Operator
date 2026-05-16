/*
 * Файл: map_screen.dart
 * Версия: 1.20
 * Изменения: ЭТАП 2, Шаг 4. Добавлен ListenableBuilder для реактивного прослушивания базы данных узлов (NodeDatabase) и локального ID.
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
          // Извлекаем данные для следующего шага (отрисовка маркеров)
          final nodesMap = bleService.nodeDatabase.nodes;
          final myNodeId = bleService.identityNotifier.value?.myNodeId;

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
              // TODO: Шаг 5 - Здесь будет MarkerLayer
            ],
          );
        },
      ),
    );
  }
}