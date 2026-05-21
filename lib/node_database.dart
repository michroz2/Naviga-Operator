/*
 * Файл: node_database.dart
 * Версия: 1.32.5
 * Изменения: ЭТАП Настроек, Шаг 5. В метод getRecentTrack добавлена логика обработки maxAgeMs == 0 (Не ограничено).
 * Описание: Центральная база данных Roster с поддержкой трекинга.
 */

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'ble_protocol.dart';

// ============================================================================
// Структура точки для хвоста истории (Track)
// ============================================================================
class TrackPoint {
  final double lat;
  final double lon;
  final int timestampMs;

  TrackPoint({required this.lat, required this.lon, required this.timestampMs});
}

// ============================================================================
// Запись Узла
// ============================================================================
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

  // Кольцевой буфер истории координат и настройки анти-джиттера
  List<TrackPoint> track = [];
  static const int maxTrackPoints = 50;
  static const double trackJitterMeters = 10.0;
  static const int trackJitterPointsToCheck = 3; 

  bool get hasValidGps => lat != 0.0 && lon != 0.0;

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

  // Метод добавления точки в трек с фильтром по 3 последним точкам
  void _addPointToTrack(double newLat, double newLon, int timestamp) {
    if (newLat == 0.0 || newLon == 0.0) return;

    final newPoint = LatLng(newLat, newLon);

    // 1. Инициализация буфера (50 нулевых клонов + 1 актуальный)
    if (track.isEmpty) {
      for (int i = 0; i < maxTrackPoints - 1; i++) {
        track.add(TrackPoint(lat: newLat, lon: newLon, timestampMs: 0));
      }
      track.add(TrackPoint(lat: newLat, lon: newLon, timestampMs: timestamp));
      return;
    }

    // 2. Анти-джиттер: проверка дистанции до N последних добавленных точек
    bool isJitter = false;
    int pointsToCheck = trackJitterPointsToCheck;
    
    // Защита: проверяем не больше точек, чем есть в буфере
    if (track.length < pointsToCheck) {
      pointsToCheck = track.length;
    }

    // Проверяем с конца массива (track.length - 1 это Точка-1, track.length - 2 это Точка-2 и т.д.)
    for (int i = 1; i <= pointsToCheck; i++) {
      final checkPoint = track[track.length - i];
      final pLatLng = LatLng(checkPoint.lat, checkPoint.lon);
      final dist = Distance().as(LengthUnit.Meter, pLatLng, newPoint).toDouble();
      
      // Если хотя бы одна из проверяемых точек ближе порога - считаем это джиттером/стоянкой
      if (dist < trackJitterMeters) {
        isJitter = true;
        break; 
      }
    }

    // Если новая точка дальше порога от ВСЕХ 3 последних точек - сдвигаем буфер
    if (!isJitter) {
      track.removeAt(0); // Удаляем самую старую в начале
      track.add(TrackPoint(lat: newLat, lon: newLon, timestampMs: timestamp)); // Добавляем новую в конец
    }
  }

  // Вспомогательный метод для получения актуального хвоста для отрисовки
  List<LatLng> getRecentTrack(int maxAgeMs) {
    if (track.isEmpty) return [];
    final now = DateTime.now().millisecondsSinceEpoch;
    
    List<LatLng> recent = track
        // ИЗМЕНЕНИЕ 1.32.5: Добавлено (maxAgeMs == 0) для поддержки опции "Не ограничено"
        .where((p) => p.timestampMs != 0 && (maxAgeMs == 0 || (now - p.timestampMs) <= maxAgeMs))
        .map((p) => LatLng(p.lat, p.lon))
        .toList();

    // Принудительно добавляем текущую позицию узла в конец трека
    if (hasValidGps) {
      recent.add(LatLng(lat, lon));
    }

    return recent;
  }
}

// ============================================================================
// База Данных Узлов
// ============================================================================
class NodeDatabase extends ChangeNotifier {
  final Map<int, NodeRecord> _nodes = {};
  Timer? _gcTimer;

  Map<int, NodeRecord> get nodes => Map.unmodifiable(_nodes);

  int getNeighborsCount(int? myNodeId) {
    if (myNodeId == null) return _nodes.length;
    return _nodes.containsKey(myNodeId) ? _nodes.length - 1 : _nodes.length;
  }

  bool get hasAnyValidGps => _nodes.values.any((n) => n.hasValidGps);

  void initLocalNode(BleIdentity identity, int? oldNodeId) {
    final newId = identity.myNodeId;
    
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
        lat: 0.0,
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
        if (id == currentMyNodeId) return; 

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

      if (hasChanges) notifyListeners();
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
      node._addPointToTrack(update.lat, update.lon, normalizedTime); 
    } else {
      final node = NodeRecord(
        nodeId: update.nodeId,
        role: update.nodeRole,
        nodeName: update.nodeName,
        lat: update.lat,
        lon: update.lon,
        snr: update.snr,
        lastSeenTimeMs: normalizedTime,
      );
      node._addPointToTrack(update.lat, update.lon, normalizedTime); 
      _nodes[update.nodeId] = node;
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
      node._addPointToTrack(update.lat, update.lon, now); 
    } else {
      final node = NodeRecord(
        nodeId: update.nodeId,
        role: 1, 
        nodeName: "Node ${update.nodeId}",
        lat: update.lat,
        lon: update.lon,
        snr: update.snr,
        lastSeenTimeMs: now,
      );
      node._addPointToTrack(update.lat, update.lon, now); 
      _nodes[update.nodeId] = node;
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
    if (me.hasValidGps && other.hasValidGps) {
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