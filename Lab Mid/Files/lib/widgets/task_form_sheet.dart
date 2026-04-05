import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/task_item.dart';

class TaskFormSheet extends StatefulWidget {
  const TaskFormSheet({
    super.key,
    required this.onSubmit,
    this.task,
  });

  final TaskItem? task;
  final ValueChanged<TaskItem> onSubmit;

  @override
  State<TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends State<TaskFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _subtaskController = TextEditingController();

  late DateTime _dueDate;
  late TaskPriority _priority;
  late RepeatType _repeatType;
  late int _reminderMinutes;
  late final Set<int> _repeatDays;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _titleController.text = task?.title ?? '';
    _descriptionController.text = task?.description ?? '';
    _categoryController.text = task?.category ?? 'General';
    _subtaskController.text = task == null
        ? ''
        : task.subtasks.map((item) => item.title).join(', ');
    _dueDate = task?.dueDate ?? DateTime.now().add(const Duration(hours: 2));
    _priority = task?.priority ?? TaskPriority.medium;
    _repeatType = task?.repeatType ?? RepeatType.none;
    _reminderMinutes = task?.reminderMinutes ?? 30;
    _repeatDays = {...?task?.repeatDays};
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _subtaskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.task == null ? 'Create Task' : 'Update Task',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 28,
                      ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Title is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _subtaskController,
                  decoration: const InputDecoration(
                    labelText: 'Subtasks (comma separated)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isCompact = constraints.maxWidth < 430;
                    final priorityField = DropdownButtonFormField<TaskPriority>(
                      initialValue: _priority,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Priority',
                        border: OutlineInputBorder(),
                      ),
                      items: TaskPriority.values
                          .map(
                            (priority) => DropdownMenuItem(
                              value: priority,
                              child: Text(priority.name.toUpperCase()),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setState(() {
                          _priority = value;
                        });
                      },
                    );
                    final reminderField = DropdownButtonFormField<int>(
                      initialValue: _reminderMinutes,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Reminder',
                        border: OutlineInputBorder(),
                      ),
                      items: const [10, 30, 60, 120]
                          .map(
                            (minutes) => DropdownMenuItem(
                              value: minutes,
                              child: Text(
                                '$minutes min',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setState(() {
                          _reminderMinutes = value;
                        });
                      },
                    );

                    if (isCompact) {
                      return Column(
                        children: [
                          priorityField,
                          const SizedBox(height: 12),
                          reminderField,
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(child: priorityField),
                        const SizedBox(width: 12),
                        Expanded(child: reminderField),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  title: const Text('Due Date & Time'),
                  subtitle: Text(
                    DateFormat('EEE, dd MMM yyyy - hh:mm a').format(_dueDate),
                  ),
                  trailing: const Icon(Icons.calendar_month_rounded),
                  onTap: _pickDueDate,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<RepeatType>(
                  initialValue: _repeatType,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Repeat',
                    border: OutlineInputBorder(),
                  ),
                  items: RepeatType.values
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.name.toUpperCase()),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    setState(() {
                      _repeatType = value;
                    });
                  },
                ),
                if (_repeatType == RepeatType.weekly) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(7, (index) {
                      final weekday = index + 1;
                      final labels = [
                        'Mon',
                        'Tue',
                        'Wed',
                        'Thu',
                        'Fri',
                        'Sat',
                        'Sun',
                      ];
                      final selected = _repeatDays.contains(weekday);
                      return FilterChip(
                        label: Text(labels[index]),
                        selected: selected,
                        onSelected: (value) {
                          setState(() {
                            if (value) {
                              _repeatDays.add(weekday);
                            } else {
                              _repeatDays.remove(weekday);
                            }
                          });
                        },
                      );
                    }),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.save_outlined),
                    label: Text(
                      widget.task == null ? 'Add Task' : 'Save Changes',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDueDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (pickedDate == null || !mounted) {
      return;
    }

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dueDate),
    );
    if (pickedTime == null) {
      return;
    }

    setState(() {
      _dueDate = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final subtasks = _subtaskController.text
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .map((item) => SubtaskItem(title: item))
        .toList();

    final repeatDays = _repeatType == RepeatType.weekly
        ? (_repeatDays.isEmpty ? {_dueDate.weekday} : _repeatDays)
        : <int>{};

    final task = TaskItem(
      id: widget.task?.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      dueDate: _dueDate,
      category: _categoryController.text.trim().isEmpty
          ? 'General'
          : _categoryController.text.trim(),
      priority: _priority,
      repeatType: _repeatType,
      repeatDays: repeatDays.toList()..sort(),
      subtasks: _mergeSubtasks(subtasks),
      reminderMinutes: _reminderMinutes,
      isCompleted: widget.task?.isCompleted ?? false,
      completedAt: widget.task?.completedAt,
    );

    widget.onSubmit(task);
  }

  List<SubtaskItem> _mergeSubtasks(List<SubtaskItem> subtasks) {
    if (widget.task == null) {
      return subtasks;
    }

    final existing = widget.task!.subtasks;
    return subtasks.map((item) {
      for (final subtask in existing) {
        if (subtask.title == item.title) {
          return subtask;
        }
      }
      return item;
    }).toList();
  }
}
