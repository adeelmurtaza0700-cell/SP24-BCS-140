import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/task_item.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.onCompleteChanged,
    required this.onDelete,
    required this.onEdit,
    required this.onSubtaskChanged,
  });

  final TaskItem task;
  final ValueChanged<bool> onCompleteChanged;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final void Function(int index, bool value) onSubtaskChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        task.description.isEmpty
                            ? 'No description added'
                            : task.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Checkbox(
                  value: task.isCompleted,
                  onChanged: (value) => onCompleteChanged(value ?? false),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _TaskChip(
                  label: task.category,
                  icon: Icons.category_outlined,
                ),
                _TaskChip(
                  label: DateFormat('dd MMM, hh:mm a').format(task.dueDate),
                  icon: Icons.schedule_rounded,
                ),
                _TaskChip(
                  label: task.priority.name.toUpperCase(),
                  icon: Icons.flag_outlined,
                ),
                if (task.isRepeating)
                  _TaskChip(
                    label:
                        task.repeatType == RepeatType.daily ? 'Daily' : 'Weekly',
                    icon: Icons.repeat_rounded,
                  ),
              ],
            ),
            const SizedBox(height: 14),
            LinearProgressIndicator(
              value: task.progress,
              minHeight: 7,
              borderRadius: BorderRadius.circular(999),
            ),
            const SizedBox(height: 8),
            Text(
              '${(task.progress * 100).round()}% progress',
              style: theme.textTheme.bodySmall,
            ),
            if (task.subtasks.isNotEmpty) ...[
              const SizedBox(height: 14),
              ...List.generate(task.subtasks.length, (index) {
                final subtask = task.subtasks[index];
                return CheckboxListTile(
                  value: subtask.isDone,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(subtask.title),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (value) =>
                      onSubtaskChanged(index, value ?? false),
                );
              }),
            ],
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  onPressed: () => _confirmDelete(context),
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete task?'),
          content: Text('Remove "${task.title}" from your task list?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      onDelete();
    }
  }
}

class _TaskChip extends StatelessWidget {
  const _TaskChip({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
    );
  }
}
