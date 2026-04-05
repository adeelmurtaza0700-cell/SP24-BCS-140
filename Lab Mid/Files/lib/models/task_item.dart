import 'dart:convert';

enum RepeatType { none, daily, weekly }

enum TaskPriority { low, medium, high }

class SubtaskItem {
  const SubtaskItem({
    required this.title,
    this.isDone = false,
  });

  final String title;
  final bool isDone;

  SubtaskItem copyWith({
    String? title,
    bool? isDone,
  }) {
    return SubtaskItem(
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'isDone': isDone,
    };
  }

  factory SubtaskItem.fromMap(Map<String, dynamic> map) {
    return SubtaskItem(
      title: map['title'] as String? ?? '',
      isDone: map['isDone'] as bool? ?? false,
    );
  }
}

class TaskItem {
  const TaskItem({
    this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.category,
    required this.priority,
    required this.repeatType,
    required this.repeatDays,
    required this.subtasks,
    required this.reminderMinutes,
    this.isCompleted = false,
    this.completedAt,
  });

  final int? id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String category;
  final TaskPriority priority;
  final RepeatType repeatType;
  final List<int> repeatDays;
  final List<SubtaskItem> subtasks;
  final int reminderMinutes;
  final bool isCompleted;
  final DateTime? completedAt;

  double get progress {
    if (subtasks.isEmpty) {
      return isCompleted ? 1 : 0;
    }

    final done = subtasks.where((item) => item.isDone).length;
    return done / subtasks.length;
  }

  bool get isRepeating => repeatType != RepeatType.none;

  TaskItem copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? dueDate,
    String? category,
    TaskPriority? priority,
    RepeatType? repeatType,
    List<int>? repeatDays,
    List<SubtaskItem>? subtasks,
    int? reminderMinutes,
    bool? isCompleted,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      repeatType: repeatType ?? this.repeatType,
      repeatDays: repeatDays ?? this.repeatDays,
      subtasks: subtasks ?? this.subtasks,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: clearCompletedAt ? null : completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'category': category,
      'priority': priority.name,
      'repeatType': repeatType.name,
      'repeatDays': repeatDays.join(','),
      'subtasks': jsonEncode(subtasks.map((item) => item.toMap()).toList()),
      'reminderMinutes': reminderMinutes,
      'isCompleted': isCompleted ? 1 : 0,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory TaskItem.fromMap(Map<String, dynamic> map) {
    final subtasksText = map['subtasks'] as String? ?? '[]';
    final decodedSubtasks = (jsonDecode(subtasksText) as List<dynamic>)
        .map((item) => SubtaskItem.fromMap(item as Map<String, dynamic>))
        .toList();
    final repeatDaysText = map['repeatDays'] as String? ?? '';

    return TaskItem(
      id: map['id'] as int?,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      dueDate: DateTime.parse(map['dueDate'] as String),
      category: map['category'] as String? ?? 'General',
      priority: TaskPriority.values.firstWhere(
        (value) => value.name == map['priority'],
        orElse: () => TaskPriority.medium,
      ),
      repeatType: RepeatType.values.firstWhere(
        (value) => value.name == map['repeatType'],
        orElse: () => RepeatType.none,
      ),
      repeatDays: repeatDaysText.isEmpty
          ? const []
          : repeatDaysText
                .split(',')
                .where((item) => item.isNotEmpty)
                .map(int.parse)
                .toList(),
      subtasks: decodedSubtasks,
      reminderMinutes: map['reminderMinutes'] as int? ?? 30,
      isCompleted: (map['isCompleted'] as int? ?? 0) == 1,
      completedAt: map['completedAt'] == null
          ? null
          : DateTime.tryParse(map['completedAt'] as String),
    );
  }
}
