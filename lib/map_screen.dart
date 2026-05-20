/*
 * Файл: map_screen.dart
 * Версия: 1.24
 * Изменения: ЭТАП 3, Шаг 7. Стилизация узлов на карте с учетом Роли, статуса (isMe, Online/Offline) и добавление текстовых подписей. Внедрен MarkerStyleManager.
 * Описание: Экран визуализации узлов на интерактивной карте.
 */

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'ble_service.dart';
import 'node_database.dart';

// ============================================================================
// Вспомогательный класс: Управление стилями маркеров (задел под Settings)
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

    // 1. Определяем базовую иконку по роли
    switch (role) {
      case 0: 
        icon = Icons.cell_tower; // Ретранслятор
        break;
      case 1: 
        icon = Icons.location_on; // Сталкер (Капля)
        break;
      case 2: 
        icon = Icons.gps_fixed; // Трекер (Мишень)
        break;
      default: 
        icon = Icons.device_unknown;
    }

    // 2. Определяем базовый цвет
    if (isMe) {
      color = Colors.red; // Свой узел всегда красный
    } else {
      switch (role) {
        case 0: color = Colors.purple; break;
        case 1: color = Colors.blue; break;
        case 2: color = Colors.black; break;
        default: color = Colors.blueGrey;
      }
    }

    // 3. Обработка потери связи (Offline)
    double opacity = 1.0;
    if (!isOnline) {
      color = Colors.grey;
      opacity = 0.5; // Полупрозрачность для оффлайна
    }

    return MarkerStyle(icon: icon, color: color, opacity: opacity);
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
        ]),
        builder: (context, child) {
          // Выбираем только те узлы, у которых есть валидные координаты
          final nodes = _bleService.nodeDatabase.nodes.values
              .where((n) => n.hasValidGps)
              .toList();

          final myId = _bleService.identityNotifier.value?.myNodeId;
          final timeoutMs = _bleService.sysConfigNotifier.value?.nodeConnectionTimeout ?? 600000;
          final now = DateTime.now().millisecondsSinceEpoch;

          // Первоначальное центрирование карты (на свой узел или первый попавшийся)
          LatLng initialCenter = const LatLng(0, 0);
          if (nodes.isNotEmpty) {
            final myNode = nodes.firstWhere((n) => n.nodeId == myId, orElse: () => nodes.first);
            initialCenter = LatLng(myNode.lat, myNode.lon);
          }

          return FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: initialCenter,
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.michroz2.naviga_operator',
              ),
              MarkerLayer(
                markers: nodes.map((node) {
                  final isMe = node.nodeId == myId;
                  final isOnline = isMe ? true : (now - node.lastSeenTimeMs) <= timeoutMs;
                  
                  // Получаем готовый стиль из нашего менеджера
                  final style = MarkerStyleManager.getStyle(
                    role: node.role,
                    isMe: isMe,
                    isOnline: isOnline,
                  );

                  return Marker(
                    point: LatLng(node.lat, node.lon),
                    width: 120, // Ширина с запасом под длинные имена
                    height: 80, // Высота для иконки и подписи
                    child: Opacity(
                      opacity: style.opacity,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 1. Круглый бейдж с иконкой
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
                          // 2. Шильдик с именем узла
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
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Быстрый возврат камеры к собственному узлу
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