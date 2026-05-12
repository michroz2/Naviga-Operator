/*
 * Файл: node_database.dart
 * Версия: 1.13.1 (Hotfix)
 * Описание: Локальная база данных (Roster) соседних узлов и математика вычисления дистанции/азимута.
 * Исправление: Корректный импорт latlong2 и удаление const у конструктора Distance.
 */

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart'; // Исправленный импорт
import 'ble_protocol.dart';

class NodeRecord {
  final int nodeId;
  final int role;
  final String nodeName;
  final double lat;
  final double lon;
  final double snr;
  final int lastSeenAge;
  
  // Вычисляемые поля (рассчитываются Оператором локально)
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

  // Получить неизменяемую копию словаря
  Map<int, NodeRecord> get nodes => Map.unmodifiable(_nodes);

  // Получить количество ТОЛЬКО соседей (исключая наш собственный узел)
  int getNeighborsCount(int? myNodeId) {
    if (myNodeId == null) return _nodes.length;
    return _nodes.containsKey(myNodeId) ? _nodes.length - 1 : _nodes.length;
  }

  void updateNode(BleEvtNodeUpdate update, int? myNodeId) {
    // Создаем или обновляем запись из сырого пакета
    final record = NodeRecord(
      nodeId: update.nodeId,
      role: update.nodeRole,
      nodeName: update.nodeName,
      lat: update.lat,
      lon: update.lon,
      snr: update.snr,
      lastSeenAge: update.lastSeenAge,
    );

    _nodes[update.nodeId] = record;

    if (myNodeId != null) {
      if (update.nodeId == myNodeId) {
        // Это НАШ Донгл обновил свои координаты. 
        // Нужно пересчитать дистанцию до ВСЕХ соседей в базе.
        _recalculateAllDistances(myNodeId);
      } else {
        // Это чужой Донгл. Считаем дистанцию от нас до него (если мы уже знаем свои координаты)
        if (_nodes.containsKey(myNodeId)) {
          _calcDistanceAndAzimuth(_nodes[myNodeId]!, record);
        }
      }
    }

    notifyListeners(); // Сообщаем UI об изменениях в базе
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

  // Внутренняя функция вычисления с использованием latlong2
  void _calcDistanceAndAzimuth(NodeRecord me, NodeRecord other) {
    // Если координаты нулевые (нет GPS-фикса), дистанцию не считаем
    if (me.lat != 0.0 && me.lon != 0.0 && other.lat != 0.0 && other.lon != 0.0) {
      final myLatLng = LatLng(me.lat, me.lon);
      final otherLatLng = LatLng(other.lat, other.lon);
      
      // Исправлено: убран const перед Distance()
      other.distance = Distance().as(LengthUnit.Meter, myLatLng, otherLatLng);
      other.azimuth = Distance().bearing(myLatLng, otherLatLng);
      
      // Нормализация азимута (0-360)
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