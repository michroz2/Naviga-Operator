/*
 * Файл: node_database.dart
 * Версия: 1.14.1
 * Описание: Локальная база данных (Roster). 
 * Изменения: Переход на Mutable-архитектуру для поддержки будущих частичных обновлений и фикс сброса дистанции.
 */

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'ble_protocol.dart';

class NodeRecord {
  final int nodeId; // Идентификатор неизменен
  int role;         // Убран final
  String nodeName;  // Убран final
  double lat;       // Убран final
  double lon;       // Убран final
  double snr;       // Убран final
  int lastSeenAge;  // Убран final
  
  double distance; 
  double azimuth;

  NodeRecord({
    required this.nodeId,
    required this.role,
    required this.nodeName,
    required this.lat,
    required this.lon,
    required this.snr,
    required this.lastSeenAge,
    this.distance = 0.0,
    this.azimuth = 0.0,
  });
}

class NodeDatabase extends ChangeNotifier {
  final Map<int, NodeRecord> _nodes = {};

  Map<int, NodeRecord> get nodes => Map.unmodifiable(_nodes);

  int getNeighborsCount(int? myNodeId) {
    if (myNodeId == null) return _nodes.length;
    return _nodes.containsKey(myNodeId) ? _nodes.length - 1 : _nodes.length;
  }

  void updateNode(BleEvtNodeUpdate update, int? myNodeId) {
    // 1. Классический (mutable) подход: обновляем или создаем
    if (_nodes.containsKey(update.nodeId)) {
      // Обновляем только поля, пришедшие в пакете
      final node = _nodes[update.nodeId]!;
      node.role = update.nodeRole;
      node.nodeName = update.nodeName;
      node.lat = update.lat;
      node.lon = update.lon;
      node.snr = update.snr;
      node.lastSeenAge = update.lastSeenAge;
    } else {
      // Создаем новую запись
      _nodes[update.nodeId] = NodeRecord(
        nodeId: update.nodeId,
        role: update.nodeRole,
        nodeName: update.nodeName,
        lat: update.lat,
        lon: update.lon,
        snr: update.snr,
        lastSeenAge: update.lastSeenAge,
      );
    }

    // 2. Пересчет геометрии (дистанции и азимуты теперь не затираются!)
    if (myNodeId != null) {
      if (update.nodeId == myNodeId) {
        _recalculateAllDistances(myNodeId);
      } else {
        if (_nodes.containsKey(myNodeId)) {
          _calcDistanceAndAzimuth(_nodes[myNodeId]!, _nodes[update.nodeId]!);
        }
      }
    }

    notifyListeners();
  }

  void deleteNode(int nodeId) {
    if (_nodes.containsKey(nodeId)) {
      _nodes.remove(nodeId);
      debugPrint('NodeDatabase: Узел $nodeId удален.');
      notifyListeners();
    }
  }

  void clear() {
    _nodes.clear();
    notifyListeners();
  }

  void _calcDistanceAndAzimuth(NodeRecord me, NodeRecord other) {
    if (me.lat != 0.0 && me.lon != 0.0 && other.lat != 0.0 && other.lon != 0.0) {
      final myLatLng = LatLng(me.lat, me.lon);
      final otherLatLng = LatLng(other.lat, other.lon);
      
      other.distance = Distance().as(LengthUnit.Meter, myLatLng, otherLatLng).toDouble();
      other.azimuth = Distance().bearing(myLatLng, otherLatLng);
      
      if (other.azimuth < 0) other.azimuth += 360.0;
    } else {
      other.distance = 0.0;
      other.azimuth = 0.0;
    }
  }

  void _recalculateAllDistances(int myNodeId) {
    final myNode = _nodes[myNodeId];
    if (myNode == null) return;

    for (var node in _nodes.values) {
      if (node.nodeId != myNodeId) {
        _calcDistanceAndAzimuth(myNode, node);
      }
    }
  }
}