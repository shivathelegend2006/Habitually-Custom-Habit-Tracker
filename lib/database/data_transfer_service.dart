import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import '../models/daily_log.dart';
import '../analytics/habit_analytics_engine.dart';

class ImportResult {
  final bool success;
  final int habitsCount;
  final int logsCount;
  final String? errorMessage;

  const ImportResult({
    required this.success,
    this.habitsCount = 0,
    this.logsCount = 0,
    this.errorMessage,
  });
}

class DataTransferService {
  static const int currentSchemaVersion = 1;

  /// Sanitizes raw clipboard or file text by stripping markdown fences (```json),
  /// UTF-8 BOM, surrounding chat messages, and smart quotes.
  static String sanitizeJson(String raw) {
    var s = raw.trim();

    // 1. Remove UTF-8 Byte Order Mark (BOM) if present
    if (s.startsWith('\uFEFF')) {
      s = s.substring(1).trim();
    }

    // 2. Extract content between first '{' and last '}'
    final firstBrace = s.indexOf('{');
    final lastBrace = s.lastIndexOf('}');
    if (firstBrace != -1 && lastBrace != -1 && lastBrace >= firstBrace) {
      s = s.substring(firstBrace, lastBrace + 1).trim();
    }

    // 3. Normalize curly / smart quotes to standard ASCII quotes
    s = s
        .replaceAll('“', '"')
        .replaceAll('”', '"')
        .replaceAll('’', "'")
        .replaceAll('‘', "'");

    return s;
  }

  /// Exports all active habits and their daily logs to a clean, formatted JSON string.
  static Future<String> exportToJson() async {
    final dbHelper = DatabaseHelper.instance;
    final habits = await dbHelper.fetchActiveHabits();
    final List<Map<String, dynamic>> habitsExport = [];

    for (final habit in habits) {
      if (habit.id == null) continue;
      final logs = await dbHelper.fetchLogsForHabit(habit.id!);

      final logsExport = logs.map((l) {
        final m = <String, dynamic>{
          'date': l.logDate,
          'intensity': l.intensity,
        };
        if (l.note != null && l.note!.isNotEmpty) {
          m['note'] = l.note;
        }
        return m;
      }).toList();

      habitsExport.add({
        'name': habit.name,
        'color': habit.colorCode,
        'is_paused': habit.isPaused,
        'logs': logsExport,
      });
    }

    final payload = {
      'schema_version': currentSchemaVersion,
      'app': 'Habitually',
      'exported_at': DateTime.now().toUtc().toIso8601String(),
      'habits': habitsExport,
    };

    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  /// Parses and imports a JSON string into SQLite inside an atomic transaction.
  /// If [wipeExisting] is true, purges all current habits and logs first.
  /// If [wipeExisting] is false, smartly merges imported data into existing habits.
  static Future<ImportResult> importFromJson(
    String rawJsonString, {
    bool wipeExisting = true,
  }) async {
    try {
      final sanitized = sanitizeJson(rawJsonString);
      final dynamic decoded = jsonDecode(sanitized);

      if (decoded is! Map<String, dynamic>) {
        return const ImportResult(
          success: false,
          errorMessage: 'Invalid format: Root element must be a JSON object.',
        );
      }

      final habitsList = decoded['habits'];
      if (habitsList is! List || habitsList.isEmpty) {
        return const ImportResult(
          success: false,
          errorMessage: 'Invalid format: "habits" array is missing or empty.',
        );
      }

      final db = await DatabaseHelper.instance.database;
      int importedHabitsCount = 0;
      int importedLogsCount = 0;

      await db.transaction((txn) async {
        if (wipeExisting) {
          await txn.delete(DatabaseHelper.tableDailyLogs);
          await txn.delete(DatabaseHelper.tableHabits);
        }

        for (final item in habitsList) {
          if (item is! Map<String, dynamic>) continue;
          final name = item['name'] as String? ?? 'Untitled Habit';
          final colorCode = item['color'] as String? ?? '#FFFF7A00';
          final isPaused = (item['is_paused'] as bool?) ?? false;

          final logsList = item['logs'];
          final List<DailyLog> logsToInsert = [];

          if (logsList is List) {
            for (final logItem in logsList) {
              if (logItem is! Map<String, dynamic>) continue;
              final dateStr = logItem['date'] as String?;
              final intensity = (logItem['intensity'] as num?)?.toInt() ?? 3;
              final note = logItem['note'] as String?;

              if (dateStr != null && RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(dateStr)) {
                logsToInsert.add(
                  DailyLog(
                    habitId: 0,
                    logDate: dateStr,
                    intensity: intensity.clamp(1, 10),
                    note: note,
                  ),
                );
              }
            }
          }

          // Compute verified streak analytics from imported logs
          final sortedLogs = List<DailyLog>.from(logsToInsert)
            ..sort((a, b) => b.logDate.compareTo(a.logDate));
          final maxStreak = HabitAnalyticsEngine.calculateLongestStreak(sortedLogs);
          final activeDays = sortedLogs.length;

          int habitId;
          bool isNewHabit = false;

          // Check if habit with same name already exists in non-wipe mode
          if (!wipeExisting) {
            final existing = await txn.query(
              DatabaseHelper.tableHabits,
              where: 'name = ? AND is_archived = 0',
              whereArgs: [name],
            );
            if (existing.isNotEmpty) {
              habitId = existing.first['id'] as int;
            } else {
              habitId = await txn.insert(
                DatabaseHelper.tableHabits,
                {
                  'name': name,
                  'color_code': colorCode,
                  'is_archived': 0,
                  'is_paused': isPaused ? 1 : 0,
                  'created_at': DateTime.now().toUtc().toIso8601String(),
                  'max_streak': maxStreak,
                  'active_days': activeDays,
                },
              );
              isNewHabit = true;
            }
          } else {
            habitId = await txn.insert(
              DatabaseHelper.tableHabits,
              {
                'name': name,
                'color_code': colorCode,
                'is_archived': 0,
                'is_paused': isPaused ? 1 : 0,
                'created_at': DateTime.now().toUtc().toIso8601String(),
                'max_streak': maxStreak,
                'active_days': activeDays,
              },
            );
            isNewHabit = true;
          }

          if (isNewHabit) {
            importedHabitsCount++;
          }

          // Insert or update child logs
          for (final log in sortedLogs) {
            await txn.insert(
              DatabaseHelper.tableDailyLogs,
              {
                'habit_id': habitId,
                'log_date': log.logDate,
                'intensity': log.intensity,
                'note': log.note,
              },
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
            importedLogsCount++;
          }

          // In merge mode, recalculate streak & active days from all combined logs
          if (!wipeExisting && !isNewHabit) {
            final allLogsResult = await txn.query(
              DatabaseHelper.tableDailyLogs,
              where: 'habit_id = ?',
              whereArgs: [habitId],
              orderBy: 'log_date DESC',
            );
            final allLogs = allLogsResult.map((m) => DailyLog.fromMap(m)).toList();
            final updatedMaxStreak = HabitAnalyticsEngine.calculateLongestStreak(allLogs);
            final updatedActiveDays = allLogs.length;

            await txn.update(
              DatabaseHelper.tableHabits,
              {
                'max_streak': updatedMaxStreak,
                'active_days': updatedActiveDays,
              },
              where: 'id = ?',
              whereArgs: [habitId],
            );
          }
        }
      });

      return ImportResult(
        success: true,
        habitsCount: importedHabitsCount,
        logsCount: importedLogsCount,
      );
    } catch (e) {
      return ImportResult(
        success: false,
        errorMessage: 'Import failed: $e',
      );
    }
  }
}
