/*
 * Файл: app_logger.dart
 * Версия: 1.23
 * Изменения: Добавлена расшифровка 3-позиционного статуса gpsState и логгер для Anchor Coords.
 * Описание: Статический класс для human-readable вывода Bluetooth-событий в консоль.
 */

import 'package:flutter/foundation.dart';
import 'ble_protocol.dart';

class AppLogger {
  // Логирование исходящих команд (TX)
  static void logTx(String commandName) {
    debugPrint('[TX] ➔ Отправка команды: $commandName');
  }

  // ИЗМЕНЕНИЕ 1.48: Специфичный лог для отправки опорных координат
  static void logTxAnchorCoords(double lat, double lon) {
    debugPrint('[TX] ➔ 0x08 (CMD_SET_ANCHOR_COORDS) | Передача опорных координат телефона: [$lat, $lon]');
  }

  // Логирование входящих пакетов (RX)
  static void logRxIdentity(BleIdentity pkt) {
    debugPrint('[RX] ⬅ 0x12 (EVT_IDENTITY) | Мой ID: ${pkt.myNodeId}, Имя: ${pkt.myName}, Роль: ${pkt.myRole}');
  }
  
  static void logRxSysConfig(BleSysConfig pkt) {
    debugPrint('[RX] ⬅ 0x13 (EVT_SYS_CONFIG) | TX Движ: ${pkt.txIntervalMoving ~/ 1000}с, TX Стоянка: ${pkt.txIntervalStill ~/ 1000}с, Таймаут: ${pkt.nodeConnectionTimeout ~/ 1000}с');
  }

  static void logRxNodeUpdate(BleEvtNodeUpdate pkt) {
    debugPrint('[RX] ⬅ 0x11 (EVT_NODE_UPDATE) | Узел: ${pkt.nodeId}, Имя: ${pkt.nodeName}, Роль: ${pkt.nodeRole}, Координаты: [${pkt.lat}, ${pkt.lon}], SNR: ${pkt.snr}');
  }

  static void logRxMyStatus(BleEvtMyStatus pkt) {
    String gpsStr;
    // ИЗМЕНЕНИЕ 1.48: Трехпозиционный парсинг состояния
    switch (pkt.gpsState) {
      case 0: gpsStr = "Поиск (Нет фикса)"; break;
      case 1: gpsStr = "Зафиксирован (ОК)"; break;
      case 2: gpsStr = "Слепое Реле (No HW)"; break;
      default: gpsStr = "Неизвестно (${pkt.gpsState})";
    }
    debugPrint('[RX] ⬅ 0x10 (EVT_MY_STATUS) | GPS: $gpsStr (Спутников: ${pkt.satellites}), Батарея: ${pkt.batteryPercent}% (${pkt.batteryVoltage / 1000} В)');
  }

  static void logRxNodeCoords(BleEvtNodeCoords pkt) {
    debugPrint('[RX] ⬅ 0x15 (EVT_NODE_COORDS) | Узел: ${pkt.nodeId}, Координаты: [${pkt.lat}, ${pkt.lon}]');
  }

  static void logRxNodeInfo(BleEvtNodeInfo pkt) {
    debugPrint('[RX] ⬅ 0x14 (EVT_NODE_INFO) | Узел: ${pkt.nodeId}, Имя: ${pkt.nodeName}, Роль: ${pkt.nodeRole}');
  }
  
  // Общие информационные сообщения
  static void logInfo(String message) {
    debugPrint('[INFO] ℹ️ $message');
  }

  // Критические ошибки
  static void logError(String message) {
    debugPrint('[ERROR] ❌ $message');
  }
}