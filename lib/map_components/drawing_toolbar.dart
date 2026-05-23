/*
 * Файл: drawing_toolbar.dart
 * Версия: 1.36.6
 * Описание: Компактная анимированная горизонтальная панель инструментов (Pill-shaped Toolbar).
 */

import 'package:flutter/material.dart';

enum DrawingTool { view, select, point, line, eraser }

class DrawingToolbar extends StatelessWidget {
  final DrawingTool activeTool;
  final Function(DrawingTool) onToolSelected;

  const DrawingToolbar({
    super.key,
    required this.activeTool,
    required this.onToolSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isExpanded = activeTool != DrawingTool.view;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      height: 48.0, // Фиксированная компактная высота
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.95),
        borderRadius: BorderRadius.circular(24.0), // Форма "таблетки"
        boxShadow: const [
          BoxShadow(
            color: Colors.black26, 
            blurRadius: 6, 
            offset: Offset(0, 2),
          )
        ],
      ),
      // Если свернуто - показываем только кнопку Edit, если развернуто - ряд инструментов
      child: isExpanded ? _buildExpandedToolbar(context) : _buildCollapsedButton(),
    );
  }

  // Свернутое состояние (только одна кнопка)
  Widget _buildCollapsedButton() {
    return IconButton(
      icon: const Icon(Icons.edit, color: Colors.black87),
      onPressed: () => onToolSelected(DrawingTool.select),
      tooltip: 'Режим редактирования',
    );
  }

  // Развернутое состояние (горизонтальный ряд кнопок)
  Widget _buildExpandedToolbar(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min, // Занимает только необходимую ширину
      children: [
        const SizedBox(width: 4), // Небольшой отступ от края
        _buildToolBtn(DrawingTool.select, Icons.near_me, 'Выбор'),
        _buildToolBtn(DrawingTool.point, Icons.location_on, 'Точка'),
        _buildToolBtn(DrawingTool.line, Icons.timeline, 'Линия'),
        _buildToolBtn(DrawingTool.eraser, Icons.auto_delete, 'Удалить'),
        
        // Вертикальный разделитель
        Container(
          height: 24,
          width: 1,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          color: Colors.grey.shade400,
        ),
        
        // Кнопка закрытия
        IconButton(
          icon: const Icon(Icons.close, color: Colors.red),
          onPressed: () => onToolSelected(DrawingTool.view),
          tooltip: 'Выход',
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildToolBtn(DrawingTool tool, IconData icon, String tooltip) {
    final isSelected = activeTool == tool;
    return IconButton(
      icon: Icon(
        icon, 
        color: isSelected ? Colors.blue : Colors.black87,
      ),
      onPressed: () => onToolSelected(tool),
      tooltip: tooltip,
      // Делаем кнопки чуть компактнее
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(),
    );
  }
}
