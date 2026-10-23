import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/habit.dart';
import '../models/daily_log.dart';
import '../database/database_helper.dart';
import '../analytics/habit_analytics_engine.dart';

/// Presentation state for a single habit, combining database records
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

/// AsyncNotifier responsible for fetching, aggregating, and mutating habit states.
class HabitListNotifier extends AsyncNotifier<List<HabitViewState>> {
  final DatabaseHelper _db = DatabaseHelper.instance;

  @override
  Future<List<HabitViewState>> build() async {
    return _fetchHabitViewStates();
  }

  /// Internal query to fetch active habits, their logs, and compute their analytics.
  Future<List<HabitViewState>> _fetchHabitViewStates() async {
    final habits = await _db.fetchActiveHabits();
    final today = HabitAnalyticsEngine.normalizeToLocalCalendarMidnight(DateTime.now());

    final List<HabitViewState> viewStates = [];

    for (final habit in habits) {
      if (habit.id == null) continue;

      // 1. Fetch all logs for this habit sorted descending
      final logs = await _db.fetchLogsForHabit(habit.id!);

      // 2. Compute streak metrics via the analytics engine
      final currentStreak = HabitAnalyticsEngine.calculateCurrentStreak(logs);
      final longestStreak = HabitAnalyticsEngine.calculateLongestStreak(logs);

      // 3. Filter logs within the last 30 calendar days [today - 29 days, today]
      final last30DaysLogs = logs.where((log) {
        final logDate = HabitAnalyticsEngine.parseLogDate(log.logDate);
        final daysAgo = today.difference(logDate).inDays;
        return daysAgo >= 0 && daysAgo < 30;
      }).toList();

      viewStates.add(
        HabitViewState(
          habit: habit,
          currentStreak: currentStreak,
          longestStreak: longestStreak,
          last30DaysLogs: last30DaysLogs,
        ),
      );
    }

    return viewStates;
  }

  /// Inserts a log for today (in local IST) into SQLite, then refreshes the state.
  Future<void> toggleDailyLog(int habitId, int intensity) async {
    final todayStr = HabitAnalyticsEngine.todayLogDate();

    final log = DailyLog(
      habitId: habitId,
      logDate: todayStr,
      intensity: intensity,
    );

    // Insert or replace today's log in SQLite
    await _db.insertLog(log);

    // Refresh state using AsyncValue.guard to handle loading and potential errors gracefully
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchHabitViewStates());
  }

  /// Optional convenience method to reload habits manually if needed.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchHabitViewStates());
  }
}

/// Global provider for accessing the habit list view state.
final habitListProvider =
    AsyncNotifierProvider<HabitListNotifier, List<HabitViewState>>(() {
  return HabitListNotifier();
});
