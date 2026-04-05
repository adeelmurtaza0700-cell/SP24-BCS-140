import 'package:flutter/material.dart';

import '../controllers/task_controller.dart';
import '../models/task_item.dart';
import '../widgets/section_shell.dart';
import '../widgets/summary_header.dart';
import '../widgets/task_card.dart';
import '../widgets/task_form_sheet.dart';

class TodayTasksScreen extends StatelessWidget {
  const TodayTasksScreen({
    super.key,
    required this.controller,
    this.onTaskCompleted,
  });

  final TaskController controller;
  final VoidCallback? onTaskCompleted;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final todayTasks = controller.todayTasks;
        final upcomingTasks = controller.activeTasks
            .where((task) => !_isSameDay(task.dueDate, DateTime.now()))
            .toList();

        return SectionShell(
          title: 'Today Task',
          subtitle:
              'See what is due today first, with upcoming active tasks just below.',
          header: SummaryHeader(controller: controller),
          child: controller.activeTasks.isEmpty
              ? const _EmptyState(
                  title: 'No active tasks',
                  message:
                      'Create a task, set reminders, and it will appear here right away.',
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
                  children: [
                    _TaskSectionLabel(
                      title: 'Due Today',
                      count: todayTasks.length,
                    ),
                    const SizedBox(height: 12),
                    if (todayTasks.isEmpty)
                      const _InlineEmptyState(
                        message: 'No tasks are due today.',
                      )
                    else
                      ..._buildTaskCards(context, todayTasks),
                    const SizedBox(height: 24),
                    _TaskSectionLabel(
                      title: 'Upcoming Tasks',
                      count: upcomingTasks.length,
                    ),
                    const SizedBox(height: 12),
                    if (upcomingTasks.isEmpty)
                      const _InlineEmptyState(
                        message: 'Future active tasks will appear here.',
                      )
                    else
                      ..._buildTaskCards(context, upcomingTasks),
                  ],
                ),
        );
      },
    );
  }

  List<Widget> _buildTaskCards(BuildContext context, List<TaskItem> tasks) {
    return [
      for (var index = 0; index < tasks.length; index++) ...[
        TaskCard(
          task: tasks[index],
          onCompleteChanged: (value) async {
            await controller.toggleTaskCompletion(tasks[index], value);
            if (value) {
              onTaskCompleted?.call();
            }
          },
          onDelete: () => controller.deleteTask(tasks[index]),
          onEdit: () => _openEditSheet(context, tasks[index]),
          onSubtaskChanged: (subtaskIndex, value) async {
            final subtasks = [...tasks[index].subtasks];
            subtasks[subtaskIndex] = subtasks[subtaskIndex].copyWith(
              isDone: value,
            );
            final allDone =
                subtasks.isNotEmpty && subtasks.every((item) => item.isDone);
            await controller.toggleSubtask(tasks[index], subtaskIndex, value);
            if (allDone) {
              onTaskCompleted?.call();
            }
          },
        ),
        if (index != tasks.length - 1) const SizedBox(height: 16),
      ],
    ];
  }

  bool _isSameDay(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }

  Future<void> _openEditSheet(BuildContext context, TaskItem task) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TaskFormSheet(
        task: task,
        onSubmit: (updatedTask) async {
          await controller.updateTask(updatedTask);
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }
}

class _TaskSectionLabel extends StatelessWidget {
  const _TaskSectionLabel({
    required this.title,
    required this.count,
  });

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Text(
          '$count',
          style: textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _InlineEmptyState extends StatelessWidget {
  const _InlineEmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wb_sunny_outlined,
              size: 58,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 14),
            Text(title, style: textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              message,
              style: textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
