/*
 * Файл: offline_menu_screen.dart
 * Версия: 1.42.1
 * Описание: Главное дашборд-меню для автономной работы приложения (без подключения по Bluetooth).
 */

import 'package:flutter/material.dart';
import 'settings_screen.dart';
import 'map_screen.dart';
import 'exchange_screen.dart';
import 'offline_map_manager.dart';

class OfflineMenuScreen extends StatelessWidget {
  const OfflineMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Naviga Меню (Автономно)'),
        backgroundColor: colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Карточка настроек приложения
            Card(
              elevation: 4,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.settings, color: Colors.blueGrey, size: 32),
                      SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Настройки приложения',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // 2. Карточка оффлайн-карт с поддержкой прогресса скачивания
            ListenableBuilder(
              listenable: OfflineMapManager(),
              builder: (context, child) {
                final manager = OfflineMapManager();
                
                return Card(
                  elevation: 4,
                  color: manager.isDownloading ? colorScheme.primaryContainer.withValues(alpha: 0.5) : null,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MapScreen(isOfflineSelectMode: true)),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.download_for_offline, color: Colors.blueGrey, size: 32),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Оффлайн-карты', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                if (manager.isDownloading) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Скачивание "${manager.currentRegionName}": ${manager.progressPercentage.toStringAsFixed(1)}%', 
                                    style: TextStyle(fontSize: 14, color: colorScheme.primary, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  LinearProgressIndicator(
                                    value: manager.progressPercentage / 100.0,
                                    backgroundColor: colorScheme.surfaceContainerHighest,
                                    color: colorScheme.primary,
                                  ),
                                ] else ...[
                                  const Text('Выбор региона для загрузки', style: TextStyle(fontSize: 14, color: Colors.grey)),
                                ]
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),

            // 3. Карточка импорта/экспорта данных
            Card(
              elevation: 4,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ExchangeScreen()),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.import_export, color: Colors.blueGrey, size: 32),
                      SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Данные и Обмен',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}