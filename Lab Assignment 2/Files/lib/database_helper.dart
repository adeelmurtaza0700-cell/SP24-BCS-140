import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/game_result.dart';

class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'number_guessing.db');

    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async => _createSchema(db),
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE game_results ADD COLUMN player_name TEXT DEFAULT "Player"');
          await db.execute('ALTER TABLE game_results ADD COLUMN level TEXT DEFAULT "Normal"');
          await db.execute('ALTER TABLE game_results ADD COLUMN attempt INTEGER DEFAULT 1');
        }
      },
    );
  }

  Future<void> _createSchema(Database db) async {
    await db.execute('''
      CREATE TABLE game_results (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        player_name TEXT NOT NULL,
        level TEXT NOT NULL,
        attempt INTEGER NOT NULL,
        guess INTEGER NOT NULL,
        target INTEGER NOT NULL,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertResult(GameResult result) async {
    final db = await database;
    return db.insert('game_results', result.toMap());
  }

  Future<List<GameResult>> getAllResults() async {
    final db = await database;
    final maps = await db.query('game_results', orderBy: 'id DESC');
    return maps.map(GameResult.fromMap).toList();
  }

  Future<void> clearHistory() async {
    final db = await database;
    await db.delete('game_results');
  }
}
