/*
 * Файл: drawing_toolbar.dart
 * Версия: 1.36.15
 * Описание: Компактная анимированная горизонтальная панель инструментов (Pill-shaped Toolbar).
 * Изменения: Полный переход на тему оформления (colorScheme) для поддержки корректного отображения в тёмной теме.
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
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      height: 48.0,
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.95),
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: colorScheme.brightness == Brightness.dark ? Colors.black45 : Colors.black26, 
            blurRadius: 6, 
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: isExpanded ? _buildExpandedToolbar(context) : _buildCollapsedButton(context),
    );
  }

  // Свернутое состояние (кнопка Edit) с учётом темы
  Widget _buildCollapsedButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return IconButton(
      icon: Icon(Icons.edit, color: colorScheme.onSurface),
      onPressed: () => onToolSelected(DrawingTool.select),
      tooltip: 'Режим редактирования',
    );
  }

  // Развернутое состояние с динамическими цветами темы
  Widget _buildExpandedToolbar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 4),
        _buildToolBtn(context, DrawingTool.select, Icons.near_me, 'Выбор'),
        _buildToolBtn(context, DrawingTool.point, Icons.location_on, 'Точка'),
        _buildToolBtn(context, DrawingTool.line, Icons.timeline, 'Линия'),
        _buildToolBtn(context, DrawingTool.eraser, Icons.auto_delete, 'Удалить'),
        
        // Вертикальный разделитель адаптивного цвета
        Container(
          height: 24,
          width: 1,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          color: colorScheme.outlineVariant,
        ),
        
        IconButton(
          icon: const Icon(Icons.close, color: Colors.red),
          onPressed: () => onToolSelected(DrawingTool.view),
          tooltip: 'Выход',
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildToolBtn(BuildContext context, DrawingTool tool, IconData icon, String tooltip) {
    final isSelected = activeTool == tool;
    final colorScheme = Theme.of(context).colorScheme;
    return IconButton(
      icon: Icon(
        icon, 
        color: isSelected ? colorScheme.primary : colorScheme.onSurface,
      ),
      onPressed: () => onToolSelected(tool),
      tooltip: tooltip,
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(),
    );
  }
}