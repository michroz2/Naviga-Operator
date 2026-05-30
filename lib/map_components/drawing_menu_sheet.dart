/*
 * Файл: drawing_menu_sheet.dart
 * Версия: 1.39.9
 * Изменения: Интегрирована поддержка редактирования свойств регионов (цвет рамки, толщина, название). Инфо-окно адаптировано для отображения параметров TacticalRegion.
 */

import 'package:flutter/material.dart';
import 'drawing_models.dart';
import 'drawing_manager.dart';
import 'tactical_icon_manager.dart';

class DrawingMenuSheet extends StatefulWidget {
  final TacticalElement? existingElement;
  final TacticalType targetType;

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
    '#FF0000', '#0000FF', '#008000', '#FFA500', '#000000', '#FFFFFF',
    '#FFFF00', '#800080', '#00FFFF', '#FF00FF', '#8B4513', '#808080'
  ];

  @override
  void initState() {
    super.initState();
    final manager = DrawingManager();
    final el = widget.existingElement;

    String defaultLabel = '';
    if (el == null) {
      if (widget.targetType == TacticalType.point) {
        defaultLabel = 'Точка-${manager.getNextPointNumber()}';
      } else if (widget.targetType == TacticalType.line) {
        defaultLabel = 'Линия-${manager.getNextLineNumber()}';
      } else {
        defaultLabel = 'Регион';
      }
    }

    _labelController = TextEditingController(text: el?.label ?? defaultLabel);
    _descController = TextEditingController(text: el?.description ?? '');

    if (el == null) {
      _labelController.selection = TextSelection(baseOffset: 0, extentOffset: _labelController.text.length);
    }

    if (widget.targetType == TacticalType.point) {
      if (el is TacticalPoint) {
        _currentColorHex = el.colorHex;
        _currentIconKey = el.iconKey;
      } else {
        _currentColorHex = manager.lastPointColorHex;
        _currentIconKey = manager.lastPointIconKey;
      }
      _currentLineWidth = 4.0;
    } else if (widget.targetType == TacticalType.line) {
      if (el is TacticalLine) {
        _currentColorHex = el.colorHex;
        _currentLineWidth = el.width;
      } else {
        _currentColorHex = manager.lastLineColorHex;
        _currentLineWidth = manager.lastLineWidth;
      }
      _currentIconKey = 'pin';
    } else if (widget.targetType == TacticalType.region) {
      // ИЗМЕНЕНИЕ: Инициализация полей для региона (рамка трактуется как линия)
      if (el is TacticalRegion) {
        _currentColorHex = el.colorHex;
        _currentLineWidth = el.borderWidth;
      } else {
        _currentColorHex = '#2196F3';
        _currentLineWidth = 3.0;
      }
      _currentIconKey = 'map';
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
      if (widget.targetType == TacticalType.point) {_labelController.text = 'Точка';}
      else if (widget.targetType == TacticalType.line) {_labelController.text = 'Линия';}
      else {_labelController.text = 'Регион';}
    }

    if (widget.targetType == TacticalType.point) {
      DrawingManager().promoteIcon(_currentIconKey);
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
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final colorScheme = Theme.of(context).colorScheme;
    
    final sortedIcons = DrawingManager().sortedIcons;

    return Padding(
      padding: EdgeInsets.only(
        left: 16.0, right: 16.0, top: 16.0, bottom: bottomInset + 16.0,
      ),
      child: SingleChildScrollView(
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
              decoration: const InputDecoration(labelText: 'Название (Label)', border: OutlineInputBorder(), isDense: true),
              autofocus: widget.existingElement == null,
            ),
            const SizedBox(height: 12),
            
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Описание (опционально)', border: OutlineInputBorder(), isDense: true),
              maxLines: 1,
            ),
            const SizedBox(height: 16),
            
            const Text('Цвет:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            
            Wrap(
              spacing: 10, runSpacing: 10, alignment: WrapAlignment.start,
              children: _palette.map((hex) {
                final color = Color(int.parse(hex.replaceFirst('#', '0xFF')));
                final isSelected = _currentColorHex == hex;
                final bool showBorder = hex == '#FFFFFF' && colorScheme.brightness == Brightness.light;

                return GestureDetector(
                  onTap: () => setState(() => _currentColorHex = hex),
                  child: Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: color, shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? colorScheme.primary : (showBorder ? colorScheme.outline : Colors.transparent),
                        width: isSelected ? 3 : 1,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            
            if (isPoint) ...[
              const SizedBox(height: 16),
              const Text('Иконка:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6, crossAxisSpacing: 14, mainAxisSpacing: 10),
                itemCount: sortedIcons.length,
                itemBuilder: (context, index) {
                  final iconItem = sortedIcons[index];
                  final isSelected = _currentIconKey == iconItem.key;
                  return GestureDetector(
                    onTap: () => setState(() => _currentIconKey = iconItem.key),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? colorScheme.primaryContainer : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isSelected ? colorScheme.primary : Colors.transparent),
                      ),
                      child: Icon(iconItem.data, color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurface),
                    ),
                  );
                },
              ),
            ],

            if (!isPoint) ...[
              const SizedBox(height: 16),
              Text(widget.targetType == TacticalType.region ? 'Толщина рамки: ${_currentLineWidth.toStringAsFixed(1)}' : 'Толщина линии: ${_currentLineWidth.toStringAsFixed(1)}', 
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
                TextButton(onPressed: () => Navigator.of(context).pop(null), child: const Text('Отмена')),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _save, child: const Text('Сохранить')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DrawingInfoSheet extends StatelessWidget {
  final TacticalElement element;

  const DrawingInfoSheet({super.key, required this.element});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = Color(int.parse(element.colorHex.replaceFirst('#', '0xFF')));
    
    // ИЗМЕНЕНИЕ: Настройка иконки окна для регионов
    IconData icon;
    if (element is TacticalPoint) {
      icon = TacticalIconManager.getIconData((element as TacticalPoint).iconKey);
    } else if (element is TacticalRegion) {
      icon = Icons.map_outlined;
    } else {
      icon = Icons.timeline;
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(width: 40, height: 5, decoration: BoxDecoration(color: colorScheme.outlineVariant, borderRadius: BorderRadius.circular(10))),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  element.label,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Divider(height: 30),
          Row(
            children: [
              Icon(Icons.info_outline, color: colorScheme.primary, size: 20),
              const SizedBox(width: 12),
              Text('Описание:', style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            element.description.isNotEmpty ? element.description : 'Нет описания',
            style: TextStyle(
              fontSize: 16, 
              fontWeight: element.description.isNotEmpty ? FontWeight.bold : FontWeight.normal,
              fontStyle: element.description.isNotEmpty ? FontStyle.normal : FontStyle.italic,
              color: element.description.isNotEmpty ? colorScheme.onSurface : colorScheme.onSurfaceVariant
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}