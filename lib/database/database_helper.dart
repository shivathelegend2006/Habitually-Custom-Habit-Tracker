import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/habit.dart';
import '../models/daily_log.dart';

class DatabaseHelper {
  static const String _databaseName = 'habit_tracker.db';
  static const int _databaseVersion = 1;

  // Table names
  static const String tableHabits = 'habits';
  static const String tableDailyLogs = 'daily_logs';

  // Singleton instance
  DatabaseHelper._init();
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
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
        created_at TEXT NOT NULL
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

    // Create index on foreign key and date for query optimization
    await db.execute('''
      CREATE INDEX idx_daily_logs_habit_id ON $tableDailyLogs (habit_id);
    ''');
    await db.execute('''
      CREATE INDEX idx_daily_logs_date ON $tableDailyLogs (log_date);
    ''');
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

  /// Fetches all active (non-archived) habits ordered by creation date descending.
  Future<List<Habit>> fetchActiveHabits() async {
    final db = await database;
    final result = await db.query(
      tableHabits,
      where: 'is_archived = ?',
      whereArgs: [0],
      orderBy: 'created_at DESC',
    );

    return result.map((map) => Habit.fromMap(map)).toList();
  }

  // ---------------------------------------------------------------------------
  // DailyLog Operations
  // ---------------------------------------------------------------------------

  /// Inserts or updates a daily log for a given habit.
  /// Defaults to [ConflictAlgorithm.replace] to respect UNIQUE(habit_id, log_date)
  /// allowing users to update their daily entry.
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

  /// Fetches all daily logs for a specific habit, ordered chronologically descending.
  Future<List<DailyLog>> fetchLogsForHabit(int habitId) async {
    final db = await database;
    final result = await db.query(
      tableDailyLogs,
      where: 'habit_id = ?',
      whereArgs: [habitId],
      orderBy: 'log_date DESC',
    );

    return result.map((map) => DailyLog.fromMap(map)).toList();
  }

  /// Closes the database instance.
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
