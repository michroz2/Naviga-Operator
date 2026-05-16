/*
 * Файл: node_database.dart
 * Версия: 1.16.1
 * Изменения: Добавлен метод initLocalNode для проактивной инъекции собственного узла на основе данных Identity.
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

  Map<int, NodeRecord> get nodes => Map.unmodifiable(_nodes);

  int getNeighborsCount(int? myNodeId) {
    if (myNodeId == null) return _nodes.length;
    return _nodes.containsKey(myNodeId) ? _nodes.length - 1 : _nodes.length;
  }

  // --- ИЗМЕНЕНИЕ 1.16.1: Инъекция собственного узла ---
  void initLocalNode(BleIdentity identity, int? oldNodeId) {
    final newId = identity.myNodeId;
    
    // Если произошла коллизия и Донгл сменил ID - удаляем фантома
    if (oldNodeId != null && oldNodeId != newId) {
      _nodes.remove(oldNodeId);
      debugPrint('NodeDatabase: ID изменен с $oldNodeId на $newId. Старый узел удален.');
    }
    
    final now = DateTime.now().millisecondsSinceEpoch;
    
    if (_nodes.containsKey(newId)) {
      _nodes[newId]!.nodeName = identity.myName;
      _nodes[newId]!.role = identity.myRole;
      _nodes[newId]!.lastSeenTimeMs = now;
    } else {
      _nodes[newId] = NodeRecord(
        nodeId: newId,
        role: identity.myRole,
        nodeName: identity.myName,
        lat: 0.0, // Координаты подтянутся позже из 0x15
        lon: 0.0,
        snr: 0.0,
        lastSeenTimeMs: now,
      );
    }
    notifyListeners();
  }

  void startGarbageCollector(int activeTimeoutMs, int? currentMyNodeId) {
    _gcTimer?.cancel();
    _gcTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final List<int> toDelete = [];

      _nodes.forEach((id, node) {
        if (id == currentMyNodeId) return; // Свой узел имеет иммунитет

        if ((now - node.lastSeenTimeMs) > activeTimeoutMs) {
          toDelete.add(id);
        }
      });

      bool hasChanges = false;
      for (var id in toDelete) {
        _nodes.remove(id);
        debugPrint('NodeDatabase GC: Узел $id удален по таймауту');
        hasChanges = true;
      }

      notifyListeners();
    });
  }

  void updateNodeFull(BleEvtNodeUpdate update, int? myNodeId) {
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
    _runGeometryUpdate(update.nodeId, myNodeId);
    notifyListeners();
  }

  void updateNodeCoords(BleEvtNodeCoords update, int? myNodeId) {
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
    _runGeometryUpdate(update.nodeId, myNodeId);
    notifyListeners();
  }

  void updateNodeInfo(BleEvtNodeInfo update, int? myNodeId) {
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