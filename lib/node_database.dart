/*
 * Файл: node_database.dart
 * Версия: 1.16
 * Изменения: Внедрена нормализация абсолютного времени (lastSeenTimeMs) и фоновый Garbage Collector.
 * Описание: Центральная база данных Roster.
 */

import 'dart:async';
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
  
  int lastSeenTimeMs; // Абсолютное Unix-время последнего контакта
  
  double distance; 
  double azimuth;

  NodeRecord({
    required this.nodeId,
    required this.role,
    required this.nodeName,
    required this.lat,
    required this.lon,
    required this.snr,
    required this.lastSeenTimeMs,
    this.distance = 0.0,
    this.azimuth = 0.0,
  });
}

class NodeDatabase extends ChangeNotifier {
  final Map<int, NodeRecord> _nodes = {};
  Timer? _gcTimer;
  int? _myNodeId;

  Map<int, NodeRecord> get nodes => Map.unmodifiable(_nodes);

  void setMyNodeId(int? id) {
    _myNodeId = id;
  }

  int getNeighborsCount() {
    if (_myNodeId == null) return _nodes.length;
    return _nodes.containsKey(_myNodeId) ? _nodes.length - 1 : _nodes.length;
  }

  void startGarbageCollector(int activeTimeoutMs) {
    _gcTimer?.cancel();
    // GC работает каждые 10 секунд: удаляет мертвые узлы и дергает UI для обновления статусов
    _gcTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      bool hasChanges = false;
      final now = DateTime.now().millisecondsSinceEpoch;
      final List<int> toDelete = [];

      _nodes.forEach((id, node) {
        if (id == _myNodeId) return; // Свой узел никогда не удаляем

        if ((now - node.lastSeenTimeMs) > activeTimeoutMs) {
          toDelete.add(id);
        }
      });

      for (var id in toDelete) {
        _nodes.remove(id);
        debugPrint('NodeDatabase GC: Узел $id удален по таймауту');
        hasChanges = true;
      }

      // Всегда обновляем UI, чтобы пересчитать время "Х сек. назад" и статус Offline
      notifyListeners();
    });
  }

  void updateNodeFull(BleEvtNodeUpdate update) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final normalizedTime = now - update.lastSeenAge;

    if (_nodes.containsKey(update.nodeId)) {
      final node = _nodes[update.nodeId]!;
      node.role = update.nodeRole;
      node.nodeName = update.nodeName;
      node.lat = update.lat;
      node.lon = update.lon;
      node.snr = update.snr;
      node.lastSeenTimeMs = normalizedTime;
    } else {
      _nodes[update.nodeId] = NodeRecord(
        nodeId: update.nodeId,
        role: update.nodeRole,
        nodeName: update.nodeName,
        lat: update.lat,
        lon: update.lon,
        snr: update.snr,
        lastSeenTimeMs: normalizedTime,
      );
    }
    _runGeometryUpdate(update.nodeId);
    notifyListeners();
  }

  void updateNodeCoords(BleEvtNodeCoords update) {
    final now = DateTime.now().millisecondsSinceEpoch;

    if (_nodes.containsKey(update.nodeId)) {
      final node = _nodes[update.nodeId]!;
      node.lat = update.lat;
      node.lon = update.lon;
      node.snr = update.snr;
      node.lastSeenTimeMs = now; 
    } else {
      _nodes[update.nodeId] = NodeRecord(
        nodeId: update.nodeId,
        role: 1, 
        nodeName: "Node ${update.nodeId}",
        lat: update.lat,
        lon: update.lon,
        snr: update.snr,
        lastSeenTimeMs: now,
      );
    }
    _runGeometryUpdate(update.nodeId);
    notifyListeners();
  }

  void updateNodeInfo(BleEvtNodeInfo update) {
    final now = DateTime.now().millisecondsSinceEpoch;

    if (_nodes.containsKey(update.nodeId)) {
      final node = _nodes[update.nodeId]!;
      node.role = update.nodeRole;
      node.nodeName = update.nodeName;
      node.lastSeenTimeMs = now;
    } else {
      _nodes[update.nodeId] = NodeRecord(
        nodeId: update.nodeId,
        role: update.nodeRole,
        nodeName: update.nodeName,
        lat: 0.0,
        lon: 0.0,
        snr: 0.0,
        lastSeenTimeMs: now,
      );
    }
    notifyListeners();
  }

  void _runGeometryUpdate(int updatedId) {
    if (_myNodeId == null) return;
    if (updatedId == _myNodeId) {
      _recalculateAllDistances();
    } else {
      if (_nodes.containsKey(_myNodeId)) {
        _calcDistanceAndAzimuth(_nodes[_myNodeId]!, _nodes[updatedId]!);
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
    _gcTimer?.cancel();
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

  void _recalculateAllDistances() {
    final myNode = _nodes[_myNodeId];
    if (myNode == null) return;
    for (var node in _nodes.values) {
      if (node.nodeId != _myNodeId) {
        _calcDistanceAndAzimuth(myNode, node);
      }
    }
  }
}