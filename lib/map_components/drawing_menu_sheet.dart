/*
 * Файл: drawing_menu_sheet.dart
 * Версия: 1.36.5
 * Описание: Всплывающее окно (BottomSheet) для настройки атрибутов тактических объектов.
 */

import 'package:flutter/material.dart';
import 'drawing_models.dart';
import 'drawing_manager.dart';
import 'tactical_icon_manager.dart';

class DrawingMenuSheet extends StatefulWidget {
  final TacticalElement? existingElement; // Если null - создание нового
  final TacticalType targetType;          // Тип создаваемого объекта

  const DrawingMenuSheet({
    super.key,
    this.existingElement,
    required this.targetType,
  });

  @override
  State<DrawingMenuSheet> createState() => _DrawingMenuSheetState();
}

class _DrawingMenuSheetState extends State<DrawingMenuSheet> {
  late TextEditingController _labelController;
  late TextEditingController _descController;
  
  late String _currentColorHex;
  late String _currentIconKey;
  late double _currentLineWidth;

  final List<String> _palette = [
    '#FF0000', // Красный (Враг/Опасность)
    '#0000FF', // Синий (Свои/Маршрут)
    '#008000', // Зеленый (Безопасно/Лагерь)
    '#FFA500', // Оранжевый (Внимание)
    '#000000', // Черный (Нейтральный)
    '#FFFFFF', // Белый
  ];

  @override
  void initState() {
    super.initState();
    final manager = DrawingManager();

    // Заполнение из существующего объекта ИЛИ из памяти (Sticky attributes)
    final el = widget.existingElement;
    _labelController = TextEditingController(text: el?.label ?? '');
    _descController = TextEditingController(text: el?.description ?? '');

    if (widget.targetType == TacticalType.point) {
      if (el is TacticalPoint) {
        _currentColorHex = el.colorHex;
        _currentIconKey = el.iconKey;
      } else {
        _currentColorHex = manager.lastPointColorHex;
        _currentIconKey = manager.lastPointIconKey;
      }
      _currentLineWidth = 4.0; // Игнорируется для точек
    } else {
      if (el is TacticalLine) {
        _currentColorHex = el.colorHex;
        _currentLineWidth = el.width;
      } else {
        _currentColorHex = manager.lastLineColorHex;
        _currentLineWidth = manager.lastLineWidth;
      }
      _currentIconKey = 'pin'; // Игнорируется для линий
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _save() {
    if (_labelController.text.trim().isEmpty) {
      _labelController.text = widget.targetType == TacticalType.point ? 'Точка' : 'Линия';
    }

    Navigator.of(context).pop({
      'label': _labelController.text.trim(),
      'description': _descController.text.trim(),
      'colorHex': _currentColorHex,
      'iconKey': _currentIconKey,
      'lineWidth': _currentLineWidth,
    });
  }

  @override
  Widget build(BuildContext context) {
    final isPoint = widget.targetType == TacticalType.point;
    
    // Добавляем отступ для клавиатуры
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 16.0, right: 16.0, top: 16.0, bottom: bottomInset + 16.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.existingElement == null 
                ? (isPoint ? 'Новая точка' : 'Новая линия') 
                : 'Редактирование',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          
          TextField(
            controller: _labelController,
            decoration: const InputDecoration(
              labelText: 'Название (Label)',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            autofocus: widget.existingElement == null, // Фокус только при создании
          ),
          const SizedBox(height: 12),
          
          TextField(
            controller: _descController,
            decoration: const InputDecoration(
              labelText: 'Описание (опционально)',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          
          const Text('Цвет:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _palette.map((hex) {
              final color = Color(int.parse(hex.replaceFirst('#', '0xFF')));
              final isSelected = _currentColorHex == hex;
              return GestureDetector(
                onTap: () => setState(() => _currentColorHex = hex),
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey.shade400,
                      width: isSelected ? 3 : 1,
                    ),
                    boxShadow: isSelected ? [const BoxShadow(color: Colors.black26, blurRadius: 4)] : null,
                  ),
                ),
              );
            }).toList(),
          ),
          
          if (isPoint) ...[
            const SizedBox(height: 16),
            const Text('Иконка:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 120, // Фиксированная высота для сетки иконок
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: TacticalIconManager.availableIcons.length,
                itemBuilder: (context, index) {
                  final iconItem = TacticalIconManager.availableIcons[index];
                  final isSelected = _currentIconKey == iconItem.key;
                  return GestureDetector(
                    onTap: () => setState(() => _currentIconKey = iconItem.key),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue.shade100 : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isSelected ? Colors.blue : Colors.transparent),
                      ),
                      child: Icon(iconItem.data, color: isSelected ? Colors.blue : Colors.black87),
                    ),
                  );
                },
              ),
            ),
          ],

          if (!isPoint) ...[
            const SizedBox(height: 16),
            Text('Толщина линии: ${_currentLineWidth.toStringAsFixed(1)}', 
                 style: const TextStyle(fontWeight: FontWeight.bold)),
            Slider(
              value: _currentLineWidth,
              min: 2.0, max: 8.0, divisions: 6,
              onChanged: (val) => setState(() => _currentLineWidth = val),
            ),
          ],

          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(null),
                child: const Text('Отмена'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _save,
                child: const Text('Сохранить'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}