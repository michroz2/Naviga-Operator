/*
 * Файл: node_database.dart
 * Версия: 1.15
 * Изменения: Поддержка Delta-updates (0x15, 0x16). Логика инициализации "Нового узла". 
 * Описание: Центральная база данных Roster.
 */

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'ble_protocol.dart';

class NodeRecord {
  final int nodeId;
  int role;         
  String nodeName;  
  double lat;       
  double lon;       
  double snr;       
  int lastSeenAge;  
  
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

  // ОБРАБОТКА ПОЛНОГО ПАКЕТА (0x11)
  void updateNodeFull(BleEvtNodeUpdate update, int? myNodeId) {
    if (_nodes.containsKey(update.nodeId)) {
      final node = _nodes[update.nodeId]!;
      node.role = update.nodeRole;
      node.nodeName = update.nodeName;
      node.lat = update.lat;
      node.lon = update.lon;
      node.snr = update.snr;
      node.lastSeenAge = update.lastSeenAge;
    } else {
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
    _runGeometryUpdate(update.nodeId, myNodeId);
    notifyListeners();
  }

  // ОБРАБОТКА КООРДИНАТ (0x15)
  void updateNodeCoords(BleEvtNodeCoords update, int? myNodeId) {
    if (_nodes.containsKey(update.nodeId)) {
      final node = _nodes[update.nodeId]!;
      node.lat = update.lat;
      node.lon = update.lon;
      node.snr = update.snr;
      node.lastSeenAge = 0; // Считаем свежим
    } else {
      // Инициализация нового узла по координатам
      _nodes[update.nodeId] = NodeRecord(
        nodeId: update.nodeId,
        role: 1, // Stalker (default)
        nodeName: "Node ${update.nodeId}",
        lat: update.lat,
        lon: update.lon,
        snr: update.snr,
        lastSeenAge: 0,
      );
    }
    _runGeometryUpdate(update.nodeId, myNodeId);
    notifyListeners();
  }

  // ОБРАБОТКА ИМЕНИ/РОЛИ (0x16)
  void updateNodeInfo(BleEvtNodeInfo update, int? myNodeId) {
    if (_nodes.containsKey(update.nodeId)) {
      final node = _nodes[update.nodeId]!;
      node.role = update.nodeRole;
      node.nodeName = update.nodeName;
      node.lastSeenAge = 0;
    } else {
      // Инициализация нового узла по Info
      _nodes[update.nodeId] = NodeRecord(
        nodeId: update.nodeId,
        role: update.nodeRole,
        nodeName: update.nodeName,
        lat: 0.0,
        lon: 0.0,
        snr: 0.0,
        lastSeenAge: 0,
      );
    }
    notifyListeners();
  }

  void _runGeometryUpdate(int updatedId, int? myNodeId) {
    if (myNodeId == null) return;
    if (updatedId == myNodeId) {
      _recalculateAllDistances(myNodeId);
    } else {
      if (_nodes.containsKey(myNodeId)) {
        _calcDistanceAndAzimuth(_nodes[myNodeId]!, _nodes[updatedId]!);
      }
    }
  }

  void deleteNode(int nodeId) {
    if (_nodes.containsKey(nodeId)) {
      _nodes.remove(nodeId);
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