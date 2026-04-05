import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/task_item.dart';

class DatabaseService {
  DatabaseService._();

  static final DatabaseService instance = DatabaseService._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    final databasesPath = await getDatabasesPath();
    final path = p.join(databasesPath, 'taskflow.db');
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            dueDate TEXT NOT NULL,
            category TEXT NOT NULL,
            priority TEXT NOT NULL,
            repeatType TEXT NOT NULL,
            repeatDays TEXT NOT NULL,
            subtasks TEXT NOT NULL,
            reminderMinutes INTEGER NOT NULL,
            isCompleted INTEGER NOT NULL,
            completedAt TEXT
          )
        ''');
      },
    );
    return _database!;
  }

  Future<List<TaskItem>> fetchTasks() async {
    final db = await database;
    final rows = await db.query('tasks', orderBy: 'dueDate ASC');
    return rows.map(TaskItem.fromMap).toList();
  }

  Future<int> insertTask(TaskItem task) async {
    final db = await database;
    return db.insert('tasks', task.toMap()..remove('id'));
  }

  Future<void> updateTask(TaskItem task) async {
    final db = await database;
    await db.update(
      'tasks',
      task.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<void> deleteTask(int id) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
}
