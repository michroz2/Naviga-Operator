/*
 * Файл: roster_screen.dart
 * Версия: 1.14.1
 * Изменения: Исправлена логика отображения статуса GPS (проверка наличия собственных координат).
 */

import 'package:flutter/material.dart';
import 'ble_service.dart';
import 'node_database.dart';

class RosterScreen extends StatelessWidget {
  const RosterScreen({super.key});

  IconData _getRoleIcon(int role, bool isMe) {
    if (isMe) return Icons.person_pin;
    switch (role) {
      case 0: return Icons.cell_tower;
      case 1: return Icons.directions_walk;
      case 2: return Icons.gps_fixed;
      default: return Icons.device_unknown;
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

  // НОВЫЙ АРГУМЕНТ: hasMyGps - знаем ли мы свои координаты
  String _getDistanceText(NodeRecord node, bool isMe, bool hasMyGps) {
    if (isMe) return 'Мой узел (Я)';
    if (!hasMyGps) return 'Ожидание нашего GPS...';
    if (node.lat == 0.0 || node.lon == 0.0) return 'Ожидание GPS узла...';
    if (node.distance < 20.0) return 'Рядом (< 20 м)';
    
    return '~ ${node.distance.toStringAsFixed(0)} м | Азимут: ${node.azimuth.toStringAsFixed(0)}°';
  }

  @override
  Widget build(BuildContext context) {
    final bleService = BleService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Топология Сети'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([bleService.nodeDatabase, bleService.identityNotifier]),
        builder: (context, child) {
          final nodesMap = bleService.nodeDatabase.nodes;
          final myNodeId = bleService.identityNotifier.value?.myNodeId;

          if (nodesMap.isEmpty) {
            return const Center(child: Text('База узлов пуста', style: TextStyle(fontSize: 16)));
          }

          // ПРОВЕРКА: Знаем ли мы свои координаты?
          final myNode = nodesMap[myNodeId];
          final bool hasMyGps = myNode != null && myNode.lat != 0.0 && myNode.lon != 0.0;

          List<NodeRecord> sortedNodes = nodesMap.values.toList();

          sortedNodes.sort((a, b) {
            if (a.nodeId == myNodeId) return -1;
            if (b.nodeId == myNodeId) return 1;

            bool aHasGps = a.lat != 0.0 && a.lon != 0.0;
            bool bHasGps = b.lat != 0.0 && b.lon != 0.0;
            if (aHasGps && !bHasGps) return -1;
            if (!aHasGps && bHasGps) return 1;

            if (!aHasGps && !bHasGps) return a.nodeId.compareTo(b.nodeId);

            return a.distance.compareTo(b.distance);
          });

          return ListView.builder(
            itemCount: sortedNodes.length,
            itemBuilder: (context, index) {
              final node = sortedNodes[index];
              final isMe = node.nodeId == myNodeId;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                color: isMe ? Colors.blue.shade50 : null,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isMe ? Colors.blue.shade200 : Colors.grey.shade300,
                    child: Icon(_getRoleIcon(node.role, isMe), color: Colors.black87),
                  ),
                  title: Text(
                    node.nodeName, 
                    style: TextStyle(fontWeight: FontWeight.bold, color: isMe ? Colors.blue.shade800 : Colors.black)
                  ),
                  // Передаем флаг наличия нашего GPS
                  subtitle: Text(_getDistanceText(node, isMe, hasMyGps)),
                  trailing: const Icon(Icons.info_outline, color: Colors.grey),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (context) => NodeDetailsSheet(node: node, isMe: isMe, roleName: _getRoleName(node.role)),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// (Виджет NodeDetailsSheet остается без изменений, как в предыдущей версии)
class NodeDetailsSheet extends StatelessWidget {
  final NodeRecord node;
  final bool isMe;
  final String roleName;

  const NodeDetailsSheet({super.key, required this.node, required this.isMe, required this.roleName});

  @override
  Widget build(BuildContext context) {
    final secondsAgo = node.lastSeenAge > 0 ? (node.lastSeenAge / 1000).toStringAsFixed(1) : '0';

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(10))),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(isMe ? Icons.person_pin : Icons.device_hub, size: 32, color: isMe ? Colors.blue : Colors.black),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  node.nodeName,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(15)),
                child: Text('ID: ${node.nodeId}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const Divider(height: 30),
          
          _buildInfoRow(Icons.badge, 'Роль', roleName),
          _buildInfoRow(Icons.location_on, 'Координаты', node.lat == 0.0 ? 'Не зафиксированы' : '${node.lat.toStringAsFixed(6)}, ${node.lon.toStringAsFixed(6)}'),
          
          if (!isMe && node.lat != 0.0) ...[
            _buildInfoRow(Icons.straighten, 'Дистанция', '${node.distance.toStringAsFixed(1)} м'),
            _buildInfoRow(Icons.explore, 'Азимут', '${node.azimuth.toStringAsFixed(1)}°'),
            _buildInfoRow(Icons.signal_cellular_alt, 'Уровень сигнала (SNR)', '${node.snr} dB'),
            _buildInfoRow(Icons.access_time, 'Последний контакт', '$secondsAgo сек. назад'),
          ],
          
          if (isMe) 
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text('Это ваш собственный узел. Дистанция не применима.', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
            ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey, size: 20),
          const SizedBox(width: 12),
          Text('$label:', style: const TextStyle(fontSize: 16, color: Colors.blueGrey)),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}