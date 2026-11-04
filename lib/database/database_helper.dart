import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/habit.dart';
import '../models/daily_log.dart';

class DatabaseHelper {
  static const String _databaseName = 'habit_tracker.db';
  static const int _databaseVersion = 2;

  // Table names
  static const String tableHabits = 'habits';
  static const String tableDailyLogs = 'daily_logs';

  // Singleton instance
  DatabaseHelper._init();
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    _database = await _initDB(_databaseName);
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Enforce SQLite foreign key constraints.
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON;');
  }

  /// Execute table schema creation.
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableHabits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        color_code TEXT NOT NULL,
        is_archived INTEGER NOT NULL DEFAULT 0,
        is_paused INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        max_streak INTEGER NOT NULL DEFAULT 0,
        active_days INTEGER NOT NULL DEFAULT 0
      );
    ''');

    await db.execute('''
      CREATE TABLE $tableDailyLogs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        habit_id INTEGER NOT NULL,
        log_date TEXT NOT NULL,
        intensity INTEGER NOT NULL CHECK (intensity >= 1 AND intensity <= 10),
        note TEXT,
        FOREIGN KEY (habit_id) REFERENCES $tableHabits (id) ON DELETE CASCADE,
        UNIQUE (habit_id, log_date)
      );
    ''');

    await db.execute('''
      CREATE INDEX idx_daily_logs_habit_id ON $tableDailyLogs (habit_id);
    ''');
    await db.execute('''
      CREATE INDEX idx_daily_logs_date ON $tableDailyLogs (log_date);
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try {
        await db.execute('ALTER TABLE $tableHabits ADD COLUMN is_paused INTEGER NOT NULL DEFAULT 0;');
      } catch (_) {}
    }
  }

  // ---------------------------------------------------------------------------
  // Habit Operations
  // ---------------------------------------------------------------------------

  /// Inserts a new Habit and returns its generated database ID.
  Future<int> insertHabit(Habit habit) async {
    final db = await database;
    return await db.insert(
      tableHabits,
      habit.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  /// Fetches all active (non-archived) habits ordered by creation date / id.
  Future<List<Habit>> fetchActiveHabits() async {
    final db = await database;
    final result = await db.query(
      tableHabits,
      where: 'is_archived = ?',
      whereArgs: [0],
      orderBy: 'id ASC',
    );

    return result.map((map) => Habit.fromMap(map)).toList();
  }

  /// Updates an entire Habit record in the database.
  Future<int> updateHabit(Habit habit) async {
    final db = await database;
    if (habit.id == null) return 0;
    return await db.update(
      tableHabits,
      habit.toMap(),
      where: 'id = ?',
      whereArgs: [habit.id],
    );
  }

  /// Updates active_days and max_streak for a specific habit.
  Future<int> updateHabitStats({
    required int habitId,
    required int activeDays,
    required int maxStreak,
  }) async {
    final db = await database;
    return await db.update(
      tableHabits,
      {
        'active_days': activeDays,
        'max_streak': maxStreak,
      },
      where: 'id = ?',
      whereArgs: [habitId],
    );
  }

  /// Updates the paused status of a habit.
  Future<int> updateHabitPaused(int habitId, bool isPaused) async {
    final db = await database;
    return await db.update(
      tableHabits,
      {
        'is_paused': isPaused ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [habitId],
    );
  }

  /// Deletes a habit and all associated logs (via CASCADE).
  Future<int> deleteHabit(int id) async {
    final db = await database;
    return await db.delete(
      tableHabits,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ---------------------------------------------------------------------------
  // DailyLog Operations
  // ---------------------------------------------------------------------------

  /// Inserts or updates a daily log for a given habit.
  /// Defaults to [ConflictAlgorithm.replace] to respect UNIQUE(habit_id, log_date)
  Future<int> insertLog(
    DailyLog log, {
    ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.replace,
  }) async {
    final db = await database;
    return await db.insert(
      tableDailyLogs,
      log.toMap(),
      conflictAlgorithm: conflictAlgorithm,
    );
  }

  /// Deletes a daily log for a habit on a specific date.
  Future<int> deleteLog(int habitId, String logDate) async {
    final db = await database;
    return await db.delete(
      tableDailyLogs,
      where: 'habit_id = ? AND log_date = ?',
      whereArgs: [habitId, logDate],
    );
  }

  /// Fetches all daily logs for a specific habit, ordered chronologically ascending.
  Future<List<DailyLog>> fetchLogsForHabit(int habitId) async {
    final db = await database;
    final result = await db.query(
      tableDailyLogs,
      where: 'habit_id = ?',
      whereArgs: [habitId],
      orderBy: 'log_date ASC',
    );

    return result.map((map) => DailyLog.fromMap(map)).toList();
  }

  /// Fetches all daily logs across all habits.
  Future<List<DailyLog>> fetchAllLogs() async {
    final db = await database;
    final result = await db.query(
      tableDailyLogs,
      orderBy: 'log_date ASC',
    );

    return result.map((map) => DailyLog.fromMap(map)).toList();
  }

  /// Completely wipes all data from both habits and daily_logs tables.
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete(tableDailyLogs);
    await db.delete(tableHabits);
  }

  /// Legacy mock purge (deprecated no-op so user habits are never purged).
  Future<void> purgeLegacyMockData() async {
    // No-op: Preserve all user habits and logs regardless of their names.
  }

  /// Closes the database instance.
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
