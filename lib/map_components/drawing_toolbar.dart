/*
 * Файл: drawing_toolbar.dart
 * Версия: 1.36.0
 * Описание: Панель инструментов для тактической разметки.
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
    if (activeTool == DrawingTool.view) {
      return FloatingActionButton(
        onPressed: () => onToolSelected(DrawingTool.select),
        child: const Icon(Icons.edit),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildBtn(DrawingTool.select, Icons.near_me, 'Select'),
          _buildBtn(DrawingTool.point, Icons.location_on, 'Point'),
          _buildBtn(DrawingTool.line, Icons.timeline, 'Line'),
          _buildBtn(DrawingTool.eraser, Icons.auto_delete, 'Eraser'),
          const Divider(),
          _buildBtn(DrawingTool.view, Icons.close, 'Exit'),
        ],
      ),
    );
  }

  Widget _buildBtn(DrawingTool tool, IconData icon, String tooltip) {
    final isSelected = activeTool == tool;
    return IconButton(
      icon: Icon(icon, color: isSelected ? Colors.blue : null),
      onPressed: () => onToolSelected(tool),
      tooltip: tooltip,
    );
  }
}