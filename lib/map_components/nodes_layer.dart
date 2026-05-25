/*
 * Файл: nodes_layer.dart
 * Версия: 1.39.2
 * Описание: Слой карты для отображения треков и маркеров узлов BLE-сети.
 */

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../ble_service.dart';
import '../app_settings.dart';
import 'map_marker_manager.dart';
import '../roster_screen.dart';

class NodesLayer extends StatelessWidget {
  final bool isInteractive;

  const NodesLayer({
    super.key, 
    this.isInteractive = true,
  });

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
    final bleService = BleService();

    return ListenableBuilder(
      listenable: Listenable.merge([
        bleService.nodeDatabase,
        bleService.identityNotifier,
        bleService.sysConfigNotifier,
        AppSettings(),
      ]),
      builder: (context, child) {
        final nodes = bleService.nodeDatabase.nodes.values
            .where((n) => n.hasValidGps)
            .toList();

        final myId = bleService.identityNotifier.value?.myNodeId;
        final timeoutMs = bleService.sysConfigNotifier.value?.nodeConnectionTimeout ?? 600000;
        final now = DateTime.now().millisecondsSinceEpoch;

        return Stack(
          children: [
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
              ignoring: !isInteractive,
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
          ],
        );
      },
    );
  }
}