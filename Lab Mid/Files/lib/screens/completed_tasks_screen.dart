import 'package:flutter/material.dart';

import '../controllers/task_controller.dart';
import '../models/task_item.dart';
import '../widgets/section_shell.dart';
import '../widgets/task_card.dart';
import '../widgets/task_form_sheet.dart';

class CompletedTasksScreen extends StatelessWidget {
  const CompletedTasksScreen({super.key, required this.controller});

  final TaskController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return SectionShell(
          title: 'Completed Task',
          subtitle: 'Track finished work and keep momentum visible.',
          child: controller.completedTasks.isEmpty
              ? const _CompletedEmpty()
              : ListView.separated(
                  itemCount: controller.completedTasks.length,
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
                  itemBuilder: (context, index) {
                    final task = controller.completedTasks[index];
                    return TaskCard(
                      task: task,
                      onCompleteChanged: (value) =>
                          controller.toggleTaskCompletion(task, value),
                      onDelete: () => controller.deleteTask(task),
                      onEdit: () => _openEditSheet(context, task),
                      onSubtaskChanged: (subtaskIndex, value) =>
                          controller.toggleSubtask(task, subtaskIndex, value),
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

class _CompletedEmpty extends StatelessWidget {
  const _CompletedEmpty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Text(
          'Completed tasks will appear here after you finish them.',
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
