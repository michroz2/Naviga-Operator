/*
 * Файл: exchange_screen.dart
 * Версия: 1.39.16
 * Описание: Хаб управления локальными данными.
 * Изменения: Синтаксис FMTCRoot.external исправлен на использование обязательного именованного параметра pathToArchive.
 */

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';

import 'map_components/drawing_manager.dart';
import 'map_components/drawing_storage.dart';
import 'map_components/drawing_models.dart';

class ExchangeScreen extends StatefulWidget {
  const ExchangeScreen({super.key});

  @override
  State<ExchangeScreen> createState() => _ExchangeScreenState();
}

class _ExchangeScreenState extends State<ExchangeScreen> {
  // Флаг для блокировки UI и отображения прогресс-бара во время тяжелых файловых операций
  bool _isMapTransferring = false;
  // Текстовый статус для информирования пользователя о текущем этапе операции
  String _mapTransferStatus = '';
  
  // ==========================================================
  // ТАКТИЧЕСКАЯ РАЗМЕТКА
  // ==========================================================
  Future<void> _exportMarkup() async {
    final manager = DrawingManager();
    // Фильтруем элементы: для экспорта берем только точки и линии (маршруты). 
    // Регионы (рамки скачивания) игнорируются, так как они имеют смысл только локально.
    final pointsAndLines = manager.elements.where((e) => e.type != TacticalType.region).toList();

    // Защита от экспорта пустого файла
    if (pointsAndLines.isEmpty) {
      _showError('Ваша тактическая карта пуста. Нечего отправлять.');
      return;
    }

    try {
      // Сериализуем данные в JSON и сохраняем во временный файл
      final path = await DrawingStorage().prepareExportFile(pointsAndLines);
      // Вызываем системное диалоговое окно "Поделиться" для передачи файла в другие приложения
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(path, mimeType: 'application/json')],
          text: 'Тактическая разметка Naviga',
        ),
      );
    } catch (e) {
      _showError('Ошибка экспорта разметки: $e');
    }
  }

  Future<void> _importMarkup() async {
    try {
      // Вызов нативного системного окна выбора файла (Android/iOS)
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any);
      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;
        // Парсим JSON из выбранного файла обратно в объекты TacticalElement
        final importedElements = await DrawingStorage().parseImportFile(path);
        
        // Защита от битых или пустых файлов
        if (importedElements.isEmpty) {
          _showError('Файл пуст или имеет неверный формат.');
          return;
        }
        // Если данные валидны, передаем управление диалогу слияния (Merge)
        _showMergeDialog(importedElements);
      }
    } catch (e) {
      _showError('Ошибка импорта: $e');
    }
  }

  void _showMergeDialog(List<TacticalElement> importedElements) {
    // Подсчитываем статистику полученных объектов для отображения оператору
    int points = importedElements.whereType<TacticalPoint>().length;
    int lines = importedElements.whereType<TacticalLine>().length;

    showDialog(
      context: context,
      barrierDismissible: false, // Запрещаем закрытие окна кликом мимо него, чтобы предотвратить потерю фокуса
      builder: (BuildContext ctx) {
        final colorScheme = Theme.of(context).colorScheme;
        return AlertDialog(
          title: const Text('Получена Разметка'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Объектов: Точек ($points), Линий ($lines)', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text('Как применить эти данные к вашей карте?'),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsOverflowDirection: VerticalDirection.down,
          actions: [
            // Кнопка 1: Полная замена текущей разметки на импортированную
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  DrawingManager().clearTacticalMarkup(); // Очистка старых данных
                  DrawingManager().importElements(importedElements, replace: false); // Интеграция новых
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Данные ЗАМЕНЕНЫ')));
                  setState(() {}); // Принудительное обновление счетчиков на экране
                },
                icon: const Icon(Icons.warning_amber_rounded),
                label: const Text('ЗАМЕНИТЬ СТАРУЮ РАЗМЕТКУ'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.errorContainer, 
                  foregroundColor: colorScheme.onErrorContainer
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Кнопка 2: Добавление импортированной разметки к уже существующей (без удаления)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  DrawingManager().importElements(importedElements, replace: false); // Просто добавляем в массив
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Данные ДОБАВЛЕНЫ')));
                  setState(() {}); // Принудительное обновление счетчиков на экране
                },
                icon: const Icon(Icons.library_add),
                label: const Text('ДОБАВИТЬ К СУЩЕСТВУЮЩЕЙ'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primaryContainer, 
                  foregroundColor: colorScheme.onPrimaryContainer
                ),
              ),
            ),
            // Кнопка 3: Отмена операции
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('ОТМЕНА', style: TextStyle(color: Colors.grey)),
            ),
          ],
        );
      },
    );
  }

  void _confirmClearMarkup() {
    // Диалоговое окно безопасности (Safe Delete) для защиты от случайного нажатия
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удаление разметки', style: TextStyle(color: Colors.red)),
        content: const Text('Вы уверены, что хотите полностью удалить все нарисованные точки и линии? Отменить это действие невозможно.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('ОТМЕНА')),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              DrawingManager().clearTacticalMarkup(); // Полная очистка массива в менеджере
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Тактическая разметка полностью удалена.')));
              setState(() {}); // Перерисовка интерфейса, чтобы счетчики сбросились в 0
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('УДАЛИТЬ ВСЁ'),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // ОФФЛАЙН КАРТЫ (ЭКСПОРТ/ИМПОРТ v9.0.1 API)
  // ==========================================================
  Future<void> _exportMapCache() async {
    // Включаем лоадер, так как экспорт базы данных ObjectBox может быть долгим
    setState(() {
      _isMapTransferring = true;
      _mapTransferStatus = 'Формирование архива карт (это может занять время)...';
    });
    
    try {
      final tempDir = await getTemporaryDirectory();
      // Определяем жесткий путь и имя для файла экспорта
      final file = File('${tempDir.path}/naviga_maps.fmtc');
      // Если файл от предыдущего экспорта остался, удаляем его во избежание конфликтов
      if (await file.exists()) {
        await file.delete();
      }

      // API v9.0.1: Экспорт через RootExternal. Метод формирует бинарный .fmtc архив из магазина NavigaStore
      await FMTCRoot.external(pathToArchive: file.path).export(
        storeNames: ['NavigaStore'],
      );

      // Обновляем статус: архив готов, вызывается системное окно
      setState(() {
        _mapTransferStatus = 'Передача файла операционной системе...';
      });

      // Передаем сформированный бинарник в системный Share-хаб
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'application/octet-stream')],
          text: 'Экспортированный кэш оффлайн-карт Naviga',
        ),
      );
    } catch (e) {
      _showError('Ошибка экспорта кэша карт: $e');
    } finally {
      // Гарантированно отключаем лоадер, даже если произошла ошибка или пользователь отменил Share
      if (mounted) {
        setState(() {
          _isMapTransferring = false;
          _mapTransferStatus = '';
        });
      }
    }
  }

  Future<void> _importMapCache() async {
    try {
      // Открываем файловый менеджер для выбора .fmtc архива
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any);
      if (!mounted) return;
      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;

        // Диалог подтверждения, объясняющий оператору механику слияния
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Импорт оффлайн-карт'),
            content: const Text('Выбранные карты будут добавлены к вашей текущей базе. Существующие тайлы дублироваться не будут. Начать импорт?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('ОТМЕНА'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.blue),
                child: const Text('ИМПОРТИРОВАТЬ'),
              ),
            ],
          ),
        );
        if (!mounted) return;

        if (confirm != true) return;

        // Включаем лоадер, операция слияния баз ObjectBox на диске блокирующая
        setState(() {
          _isMapTransferring = true;
          _mapTransferStatus = 'Интеграция новых тайлов в базу данных...';
        });

        // API v9.0.1: Импорт через RootExternal. 
        // Важно: strategy = merge гарантирует, что уже имеющиеся у оператора карты не будут стерты,
        // новые тайлы аккуратно добавятся, а пересекающиеся (по координатам X,Y,Z) обновятся.
        await FMTCRoot.external(pathToArchive: path)
            .import(storeNames: ['NavigaStore'],
            strategy: ImportConflictStrategy.merge).complete;

        // ЭТОТ КУСОК РЕШАЕТ ПРОБЛЕМУ:
        // Принудительно сбрасываем инстанс магазина, чтобы он 
        // перечитал данные с диска при следующем обращении к stats
        // await FMTCStore('NavigaStore').manage.reset();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Импорт оффлайн-карт успешно завершен.'))
          );
          setState(() {}); // Обновление дисковой статистики на UI
        }
      }
    } catch (e) {
      _showError('Ошибка импорта кэша карт: $e');
    } finally {
      // Отключение лоадера
      if (mounted) {
        setState(() {
          _isMapTransferring = false;
          _mapTransferStatus = '';
        });
      }
    }
  }

  Future<String> _getCacheSize() async {
    try {
      // Запрашиваем размер базы данных в килобайтах через API статистики FMTC
      final sizeInKiB = await FMTCStore('NavigaStore').stats.size;
      final sizeInMB = sizeInKiB / 1024;
      return '${sizeInMB.toStringAsFixed(2)} МБ';
    } catch (e) {
      return 'Размер неизвестен';
    }
  }

  void _confirmClearCache() {
    // Диалог безопасного удаления кэша тайлов
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Очистка кэша карт', style: TextStyle(color: Colors.red)),
        content: const Text('Это удалит ВСЕ скачанные фрагменты оффлайн-карт и выделенные регионы с устройства.\n\nПродолжить?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('ОТМЕНА')),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                final store = FMTCStore('NavigaStore');
                // Удаляем базу полностью с жесткого диска
                await store.manage.delete();
                // И сразу создаем пустую, чтобы следующие вызовы не упали с ошибкой "Магазин не найден"
                await store.manage.create();
                // Так как кэша больше нет, рамки выделения тоже теряют смысл - удаляем их из разметки
                DrawingManager().clearRegions();
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Кэш карт успешно очищен.')));
                  setState(() {}); // Перерасчет статистики (размер должен стать ~0.00 МБ)
                }
              } catch (e) {
                _showError('Ошибка при очистке кэша: $e');
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('ОЧИСТИТЬ КЭШ'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // ==========================================================
  // UI СБОРКА
  // ==========================================================
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // Синхронный пересчет элементов разметки для актуального отображения на карточках
    final elements = DrawingManager().elements;
    final pointsCount = elements.whereType<TacticalPoint>().length;
    final linesCount = elements.whereType<TacticalLine>().length;
    final regionsCount = elements.whereType<TacticalRegion>().length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Данные и Обмен'),
        backgroundColor: colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          // Карточка №1: Управление тактическими точками и линиями
          _buildActionCard(
            context,
            title: 'Тактическая Разметка',
            subtitle: 'Импорт, Экспорт и удаление нарисованных точек и линий (маршрутов).',
            statsText: 'Точек: $pointsCount  |  Линий: $linesCount',
            icon: Icons.edit_location_alt,
            onSend: _exportMarkup,
            onLoad: _importMarkup,
            onClear: _confirmClearMarkup,
            clearText: 'ОЧИСТИТЬ ВСЮ РАЗМЕТКУ',
          ),
          const SizedBox(height: 24),
          // Асинхронный билдер для получения веса кэша тайлов с диска
          FutureBuilder<String>(
            future: _getCacheSize(),
            builder: (context, snapshot) {
              final sizeText = snapshot.connectionState == ConnectionState.waiting 
                  ? 'Вычисление...' 
                  : (snapshot.data ?? 'Неизвестно');
              
              // Карточка №2: Управление базой данных FMTC (Тайлы OSM)
              return _buildActionCard(
                context,
                title: 'Оффлайн Карты (Кэш)',
                subtitle: 'Управление массивом скачанных географических тайлов.',
                statsText: 'Выделено регионов: $regionsCount\nОбъем кэша на диске: $sizeText',
                icon: Icons.map_outlined,
                onSend: _exportMapCache,
                onLoad: _importMapCache,
                onClear: _confirmClearCache,
                clearText: 'ОЧИСТИТЬ ВЕСЬ КЭШ КАРТ',
                isLoading: _isMapTransferring,       // Блокировка кнопок во время экспорта/импорта
                loadingStatus: _mapTransferStatus,   // Текст бегущей строки
              );
            },
          ),
        ],
      ),
    );
  }

  // Универсальный виджет (шаблон) для карточек управления данными
  Widget _buildActionCard(BuildContext context, {
    required String title,
    required String subtitle,
    required String statsText,
    required IconData icon,
    required VoidCallback onSend,
    required VoidCallback onLoad,
    required VoidCallback onClear,
    required String clearText,
    bool isLoading = false,
    String loadingStatus = '',
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Заголовок и иконка
            Row(
              children: [
                Icon(icon, color: colorScheme.primary, size: 28),
                const SizedBox(width: 12),
                Expanded(child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
              ],
            ),
            const SizedBox(height: 8),
            // Статистика (Количество, Размер)
            Text(statsText, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colorScheme.secondary)),
            const SizedBox(height: 8),
            // Описание карточки
            Text(subtitle, style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant)),
            const Divider(height: 24),
            
            // Если карточка заблокирована (идет долгий процесс передачи/записи файлов)
            if (isLoading) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: 8),
              Text(
                loadingStatus, 
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ] else ...[
              // Рабочее состояние: Кнопки действий
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onSend,
                      icon: const Icon(Icons.send_rounded, size: 20),
                      label: const Text('ЭКСПОРТ'),
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onLoad,
                      icon: const Icon(Icons.download_rounded, size: 20),
                      label: const Text('ИМПОРТ'),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Кнопка деструктивного действия (окрашена в красный/сигнальный цвет)
              OutlinedButton.icon(
                onPressed: onClear, 
                icon: const Icon(Icons.delete_forever),
                label: Text(clearText),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.error,
                  side: BorderSide(color: colorScheme.error.withValues(alpha: 0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}