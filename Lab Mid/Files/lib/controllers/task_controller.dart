import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../models/app_settings.dart';
import '../models/task_item.dart';
import '../services/database_service.dart';
import '../services/export_service.dart';
import '../services/notification_service.dart';
import '../services/settings_service.dart';

class TaskController extends ChangeNotifier {
  final DatabaseService _database = DatabaseService.instance;
  final SettingsService _settingsService = SettingsService.instance;
  final NotificationService _notificationService = NotificationService.instance;
  final ExportService _exportService = ExportService.instance;

  List<TaskItem> _tasks = const [];
  AppSettings _settings = AppSettings.defaults();

  List<TaskItem> get tasks => _tasks;
  AppSettings get settings => _settings;

  @visibleForTesting
  void debugSetTasks(List<TaskItem> tasks) {
    _tasks = List<TaskItem>.from(tasks);
  }

  Future<void> initialize() async {
    _settings = await _settingsService.load();
    await _notificationService.initialize();
    await refreshTasks();
  }

  List<TaskItem> get todayTasks {
    final now = DateTime.now();
    return _tasks.where((task) {
      return !task.isCompleted &&
          !task.isRepeating &&
          task.dueDate.year == now.year &&
          task.dueDate.month == now.month &&
          task.dueDate.day == now.day;
    }).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  List<TaskItem> get activeTasks => _tasks
      .where((task) => !task.isCompleted && !task.isRepeating)
      .toList()
    ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

  List<TaskItem> get completedTasks {
    final completed = _tasks.where((task) => task.isCompleted).toList();
    completed.sort((a, b) {
      final left = a.completedAt ?? a.dueDate;
      final right = b.completedAt ?? b.dueDate;
      return right.compareTo(left);
    });
    return completed;
  }

  List<TaskItem> get repeatedTasks => _tasks
      .where((task) => task.isRepeating && !task.isCompleted)
      .toList();

  int get completionRate {
    if (_tasks.isEmpty) {
      return 0;
    }

    final completed = _tasks.where((task) => task.isCompleted).length;
    return ((completed / _tasks.length) * 100).round();
  }

  int get streakCount {
    final completedDates = completedTasks
        .map((task) => task.completedAt)
        .whereType<DateTime>()
        .map((date) => DateTime(date.year, date.month, date.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    var streak = 0;
    var cursor = DateTime.now();
    while (completedDates.contains(DateTime(cursor.year, cursor.month, cursor.day))) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return streak;
  }

  Future<void> refreshTasks() async {
    _tasks = await _database.fetchTasks();
    await _normalizeRepeatedTasks();

    for (final task in _tasks.where((task) => !task.isCompleted)) {
      await _notificationService.syncTaskReminder(
        task,
        _settings.notificationSound,
      );
    }

    notifyListeners();
  }

  Future<void> addTask(TaskItem task) async {
    final id = await _database.insertTask(task);
    final savedTask = task.copyWith(id: id);
    await _notificationService.syncTaskReminder(
      savedTask,
      _settings.notificationSound,
    );
    await refreshTasks();
  }

  Future<void> updateTask(TaskItem task) async {
    await _database.updateTask(task);
    if (task.id != null) {
      await _notificationService.syncTaskReminder(
        task,
        _settings.notificationSound,
      );
    }
    await refreshTasks();
  }

  Future<void> deleteTask(TaskItem task) async {
    if (task.id == null) {
      return;
    }

    await _notificationService.cancelTaskReminder(task.id!);
    await _database.deleteTask(task.id!);
    await refreshTasks();
  }

  Future<void> toggleTaskCompletion(TaskItem task, bool isDone) async {
    final updated = task.copyWith(
      isCompleted: isDone,
      completedAt: isDone ? DateTime.now() : null,
      clearCompletedAt: !isDone,
      subtasks: task.subtasks
          .map((item) => item.copyWith(isDone: isDone))
          .toList(),
    );
    await updateTask(updated);
  }

  Future<void> toggleSubtask(TaskItem task, int index, bool isDone) async {
    final subtasks = [...task.subtasks];
    subtasks[index] = subtasks[index].copyWith(isDone: isDone);
    final allDone = subtasks.isNotEmpty && subtasks.every((item) => item.isDone);
    await updateTask(
      task.copyWith(
        subtasks: subtasks,
        isCompleted: allDone,
        completedAt: allDone ? DateTime.now() : null,
        clearCompletedAt: !allDone,
      ),
    );
  }

  Future<void> updateSettings(AppSettings settings) async {
    _settings = settings;
    await _settingsService.save(settings);

    for (final task in _tasks.where((task) => !task.isCompleted)) {
      await _notificationService.syncTaskReminder(
        task,
        _settings.notificationSound,
      );
    }

    notifyListeners();
  }

  Future<void> exportCsv() async {
    final file = await _exportService.exportCsv(_tasks);
    await _exportService.shareFile(file, 'TaskFlow CSV export');
  }

  Future<void> exportPdf() async {
    final file = await _exportService.exportPdf(_tasks);
    await _exportService.shareFile(file, 'TaskFlow PDF export');
  }

  Future<void> exportEmail() async {
    await _exportService.emailTasks(_tasks);
  }

  Future<void> _normalizeRepeatedTasks() async {
    final now = DateTime.now();
    var changed = false;
    final normalizedTasks = <TaskItem>[];

    for (final task in _tasks) {
      if (!task.isRepeating || !task.isCompleted) {
        normalizedTasks.add(task);
        continue;
      }

      final nextDue = _nextDueDate(task, now);
      if (nextDue == null) {
        normalizedTasks.add(task);
        continue;
      }

      if (now.isBefore(nextDue)) {
        normalizedTasks.add(task);
        continue;
      }

      final resetTask = task.copyWith(
        dueDate: nextDue,
        isCompleted: false,
        clearCompletedAt: true,
        subtasks: task.subtasks.map((item) => item.copyWith(isDone: false)).toList(),
      );
      await _database.updateTask(resetTask);
      normalizedTasks.add(resetTask);
      changed = true;
    }

    _tasks = changed ? normalizedTasks : _tasks;
    if (changed) {
      _tasks = await _database.fetchTasks();
    }
  }

  DateTime? _nextDueDate(TaskItem task, DateTime now) {
    if (task.repeatType == RepeatType.daily) {
      var cursor = task.dueDate.add(const Duration(days: 1));
      while (cursor.isBefore(now)) {
        cursor = cursor.add(const Duration(days: 1));
      }
      return cursor;
    }

    if (task.repeatType == RepeatType.weekly && task.repeatDays.isNotEmpty) {
      var cursor = task.dueDate.add(const Duration(days: 1));
      for (var i = 0; i < 14; i++) {
        if (task.repeatDays.contains(cursor.weekday) &&
            !cursor.isBefore(DateTime(now.year, now.month, now.day))) {
          return DateTime(
            cursor.year,
            cursor.month,
            cursor.day,
            task.dueDate.hour,
            task.dueDate.minute,
          );
        }
        cursor = cursor.add(const Duration(days: 1));
      }
    }

    return null;
  }
}
