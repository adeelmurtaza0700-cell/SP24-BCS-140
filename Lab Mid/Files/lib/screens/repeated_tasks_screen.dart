import 'package:flutter/material.dart';

import '../controllers/task_controller.dart';
import '../models/task_item.dart';
import '../widgets/section_shell.dart';
import '../widgets/task_card.dart';
import '../widgets/task_form_sheet.dart';

class RepeatedTasksScreen extends StatelessWidget {
  const RepeatedTasksScreen({
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
        return SectionShell(
          title: 'Repeated Task',
          subtitle:
              'Review daily and weekly routines that automatically come back.',
          child: controller.repeatedTasks.isEmpty
              ? const _RepeatedEmpty()
              : ListView.separated(
                  itemCount: controller.repeatedTasks.length,
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
                  itemBuilder: (context, index) {
                    final task = controller.repeatedTasks[index];
                    return TaskCard(
                      task: task,
                      onCompleteChanged: (value) async {
                        await controller.toggleTaskCompletion(task, value);
                        if (value) {
                          onTaskCompleted?.call();
                        }
                      },
                      onDelete: () => controller.deleteTask(task),
                      onEdit: () => _openEditSheet(context, task),
                      onSubtaskChanged: (subtaskIndex, value) async {
                        final subtasks = [...task.subtasks];
                        subtasks[subtaskIndex] = subtasks[subtaskIndex].copyWith(
                          isDone: value,
                        );
                        final allDone =
                            subtasks.isNotEmpty &&
                            subtasks.every((item) => item.isDone);
                        await controller.toggleSubtask(task, subtaskIndex, value);
                        if (allDone) {
                          onTaskCompleted?.call();
                        }
                      },
                    );
                  },
                  separatorBuilder: (_, _) => const SizedBox(height: 16),
                ),
        );
      },
    );
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

class _RepeatedEmpty extends StatelessWidget {
  const _RepeatedEmpty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Text(
          'Daily and weekly repeating tasks will be listed here.',
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
