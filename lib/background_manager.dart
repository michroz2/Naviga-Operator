/*
 * Файл: background_manager.dart
 * Версия: 1.30
 * Изменения: ЭТАП 4, Шаг 15 (Исправление Изолята). Удалено создание фантомного BleService в фоновом потоке. Внедрен слушатель 'updateNotification' для приема данных от главного UI потока (IPC).
 * Описание: Управление фоновым жизненным циклом приложения.
 */

import 'dart:ui';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'app_config.dart';

class BackgroundManager {
  static const String notificationChannelId = 'naviga_fg_service';
  static const int notificationId = 888;

  static Future<void> initializeService() async {
    final service = FlutterBackgroundService();
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      notificationChannelId,
      'Naviga Background Service',
      description: 'Поддержание постоянного BLE-соединения с Донглом',
      importance: Importance.low, 
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false, 
        isForegroundMode: true,
        notificationChannelId: notificationChannelId,
        initialNotificationTitle: 'Naviga v${AppConfig.version}',
        initialNotificationContent: 'Ожидание синхронизации...',
        foregroundServiceTypes: [AndroidForegroundType.connectedDevice],
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    return true;
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();
    final FlutterLocalNotificationsPlugin notificationPlugin = FlutterLocalNotificationsPlugin();

    debugPrint('=== Фоновый Isolate Naviga запущен ===');

    // Слушаем данные, прилетающие из главного потока приложения
    service.on('updateNotification').listen((event) {
      if (event != null && event['content'] != null) {
        notificationPlugin.show(
          notificationId,
          'Naviga v${AppConfig.version}',
          event['content'],
          const NotificationDetails(
            android: AndroidNotificationDetails(
              notificationChannelId,
              'Naviga Background Service',
              ongoing: true,
              importance: Importance.low,
              priority: Priority.low,
              icon: '@mipmap/ic_launcher',
            ),
          ),
        );
      }
    });

    service.on('stopService').listen((event) {
      service.stopSelf();
      debugPrint('=== Фоновый Isolate остановлен ===');
    });
  }
}