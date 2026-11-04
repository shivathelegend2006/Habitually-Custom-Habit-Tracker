import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/habit.dart';
import '../models/daily_log.dart';
import '../analytics/habit_analytics_engine.dart';
import '../database/database_helper.dart';

/// Presentation state for a single habit, combining habit info
/// with calculated analytics.
class HabitViewState {
  final Habit habit;
  final int currentStreak;
  final int longestStreak;
  final List<DailyLog> last30DaysLogs;

  const HabitViewState({
    required this.habit,
    required this.currentStreak,
    required this.longestStreak,
    required this.last30DaysLogs,
  });

  /// Helper to check whether this habit has already been logged today (in IST).
  bool get isCompletedToday {
    final today = HabitAnalyticsEngine.todayLogDate();
    return last30DaysLogs.any((log) => log.logDate == today);
  }

  /// Today's log if completed, or null if not yet logged.
  DailyLog? get todayLog {
    final today = HabitAnalyticsEngine.todayLogDate();
    try {
      return last30DaysLogs.firstWhere((log) => log.logDate == today);
    } catch (_) {
      return null;
    }
  }

  HabitViewState copyWith({
    Habit? habit,
    int? currentStreak,
    int? longestStreak,
    List<DailyLog>? last30DaysLogs,
  }) {
    return HabitViewState(
      habit: habit ?? this.habit,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      last30DaysLogs: last30DaysLogs ?? this.last30DaysLogs,
    );
  }
}

/// State notifier maintaining active habits and streak analytics backed by SQLite.
class HabitListNotifier extends AsyncNotifier<List<HabitViewState>> {
  @override
  Future<List<HabitViewState>> build() async {
    return _loadFromDatabase();
  }

  Future<List<HabitViewState>> _loadFromDatabase() async {
    final db = DatabaseHelper.instance;
    final habits = await db.fetchActiveHabits();
    final List<HabitViewState> states = [];

    for (final habit in habits) {
      if (habit.id == null) continue;
      final logs = await db.fetchLogsForHabit(habit.id!);
      final sortedLogs = List<DailyLog>.from(logs)
        ..sort((a, b) => b.logDate.compareTo(a.logDate));

      final currentStreak = HabitAnalyticsEngine.calculateCurrentStreak(sortedLogs);
      final longestStreak = HabitAnalyticsEngine.calculateLongestStreak(sortedLogs);

      states.add(
        HabitViewState(
          habit: habit,
          currentStreak: currentStreak,
          longestStreak: longestStreak > habit.maxStreak ? longestStreak : habit.maxStreak,
          last30DaysLogs: sortedLogs,
        ),
      );
    }
    return states;
  }

  /// Daily log toggle that persists to SQLite and recalculates streaks.
  Future<void> toggleDailyLog(int habitId, int intensity) async {
    final todayStr = HabitAnalyticsEngine.todayLogDate();
    final db = DatabaseHelper.instance;

    await db.insertLog(
      DailyLog(
        habitId: habitId,
        logDate: todayStr,
        intensity: intensity,
      ),
    );

    // Refresh state from SQLite
    state = AsyncValue.data(await _loadFromDatabase());
  }

  /// Manual log override that persists to SQLite.
  Future<void> overrideLog({
    required int habitId,
    required String logDate,
    required int intensity,
    String? note,
  }) async {
    final db = DatabaseHelper.instance;

    await db.insertLog(
      DailyLog(
        habitId: habitId,
        logDate: logDate,
        intensity: intensity,
        note: note,
      ),
    );

    state = AsyncValue.data(await _loadFromDatabase());
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadFromDatabase());
  }
}

/// Global provider for accessing the habit list view state.
final habitListProvider =
    AsyncNotifierProvider<HabitListNotifier, List<HabitViewState>>(() {
  return HabitListNotifier();
});
