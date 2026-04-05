import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/task_item.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    tz.initializeTimeZones();
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(settings);

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
    _initialized = true;
  }

  Future<void> syncTaskReminder(
    TaskItem task,
    String soundKey,
  ) async {
    if (!_initialized || task.id == null) {
      return;
    }

    await cancelTaskReminder(task.id!);
    if (task.isCompleted) {
      return;
    }

    final reminderAt = task.dueDate.subtract(
      Duration(minutes: task.reminderMinutes),
    );
    if (reminderAt.isBefore(DateTime.now())) {
      return;
    }

    final sound = switch (soundKey) {
      'calm_ping' => const RawResourceAndroidNotificationSound('calm_ping'),
      'bright_chime' =>
        const RawResourceAndroidNotificationSound('bright_chime'),
      _ => null,
    };

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'taskflow_reminders',
        'Task Reminders',
        channelDescription: 'Task due date reminders',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        sound: sound,
      ),
    );

    await _plugin.zonedSchedule(
      task.id!,
      'Upcoming task: ${task.title}',
      'Due at ${_formatTime(task.dueDate)} in ${task.category}',
      tz.TZDateTime.from(reminderAt.toUtc(), tz.UTC),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelTaskReminder(int id) {
    return _plugin.cancel(id);
  }

  String _formatTime(DateTime value) {
    final hour = value.hour == 0 ? 12 : (value.hour > 12 ? value.hour - 12 : value.hour);
    final minutes = value.minute.toString().padLeft(2, '0');
    final suffix = value.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minutes $suffix';
  }
}
