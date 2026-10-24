import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/habit.dart';
import '../models/daily_log.dart';
import '../analytics/habit_analytics_engine.dart';

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

/// In-memory state notifier maintaining active habits, streak analytics,
/// and calendar log history for UI preview.
class HabitListNotifier extends AsyncNotifier<List<HabitViewState>> {
  late List<HabitViewState> _inMemoryHabits;

  @override
  Future<List<HabitViewState>> build() async {
    _inMemoryHabits = _generateMockHabits();
    return _inMemoryHabits;
  }

  /// Generates the initial mock dataset with rich activity history.
  List<HabitViewState> _generateMockHabits() {
    final now = DateTime.now();

    // Habit 1: Morning Meditation (14-day streak, #00E676 Emerald)
    final habit1Logs = <DailyLog>[];
    for (int i = 0; i < 14; i++) {
      final logDay = now.subtract(Duration(days: i));
      habit1Logs.add(
        DailyLog(
          id: 100 + i,
          habitId: 1,
          logDate: HabitAnalyticsEngine.todayLogDate(logDay),
          intensity: 7 + (i % 3),
        ),
      );
    }
    // Older scattered logs for the 16-week heatmap
    for (int i = 16; i <= 110; i += 2) {
      final logDay = now.subtract(Duration(days: i));
      habit1Logs.add(
        DailyLog(
          id: 200 + i,
          habitId: 1,
          logDate: HabitAnalyticsEngine.todayLogDate(logDay),
          intensity: 6 + (i % 5),
        ),
      );
    }

    final habit1 = Habit(
      id: 1,
      name: 'Morning Meditation',
      colorCode: '#00E676', // Emerald
      createdAt: now.subtract(const Duration(days: 120)),
    );

    // Habit 2: Deep Work Session (9-day streak, #7C4DFF Cyberpunk Purple)
    final habit2Logs = <DailyLog>[];
    for (int i = 0; i < 9; i++) {
      final logDay = now.subtract(Duration(days: i));
      habit2Logs.add(
        DailyLog(
          id: 300 + i,
          habitId: 2,
          logDate: HabitAnalyticsEngine.todayLogDate(logDay),
          intensity: 8 + (i % 2),
        ),
      );
    }
    for (int i = 11; i <= 100; i += 3) {
      final logDay = now.subtract(Duration(days: i));
      habit2Logs.add(
        DailyLog(
          id: 400 + i,
          habitId: 2,
          logDate: HabitAnalyticsEngine.todayLogDate(logDay),
          intensity: 7,
        ),
      );
    }

    final habit2 = Habit(
      id: 2,
      name: 'Deep Work Session',
      colorCode: '#7C4DFF', // Cyberpunk Purple
      createdAt: now.subtract(const Duration(days: 120)),
    );

    // Habit 3: Evening Workout (21-day streak, #FF5252 Crimson)
    final habit3Logs = <DailyLog>[];
    for (int i = 0; i < 21; i++) {
      final logDay = now.subtract(Duration(days: i));
      habit3Logs.add(
        DailyLog(
          id: 500 + i,
          habitId: 3,
          logDate: HabitAnalyticsEngine.todayLogDate(logDay),
          intensity: 8 + (i % 3),
        ),
      );
    }
    for (int i = 24; i <= 112; i += 2) {
      final logDay = now.subtract(Duration(days: i));
      habit3Logs.add(
        DailyLog(
          id: 600 + i,
          habitId: 3,
          logDate: HabitAnalyticsEngine.todayLogDate(logDay),
          intensity: 8,
        ),
      );
    }

    final habit3 = Habit(
      id: 3,
      name: 'Evening Workout',
      colorCode: '#FF5252', // Crimson
      createdAt: now.subtract(const Duration(days: 120)),
    );

    return [
      HabitViewState(
        habit: habit1,
        currentStreak: 14,
        longestStreak: 28,
        last30DaysLogs: habit1Logs,
      ),
      HabitViewState(
        habit: habit2,
        currentStreak: 9,
        longestStreak: 18,
        last30DaysLogs: habit2Logs,
      ),
      HabitViewState(
        habit: habit3,
        currentStreak: 21,
        longestStreak: 35,
        last30DaysLogs: habit3Logs,
      ),
    ];
  }

  /// In-memory daily log toggle that updates logs and recalculates streaks.
  Future<void> toggleDailyLog(int habitId, int intensity) async {
    final todayStr = HabitAnalyticsEngine.todayLogDate();

    _inMemoryHabits = _inMemoryHabits.map((habitState) {
      if (habitState.habit.id == habitId) {
        final hasLoggedToday = habitState.last30DaysLogs.any((l) => l.logDate == todayStr);

        List<DailyLog> updatedLogs;
        if (hasLoggedToday) {
          // Update today's entry with new intensity
          updatedLogs = habitState.last30DaysLogs
              .map((l) => l.logDate == todayStr ? l.copyWith(intensity: intensity) : l)
              .toList();
        } else {
          // Prepend today's new entry
          final newLog = DailyLog(
            habitId: habitId,
            logDate: todayStr,
            intensity: intensity,
          );
          updatedLogs = [newLog, ...habitState.last30DaysLogs];
        }

        final newCurrentStreak =
            HabitAnalyticsEngine.calculateCurrentStreak(updatedLogs);
        final newLongest =
            HabitAnalyticsEngine.calculateLongestStreak(updatedLogs);

        return habitState.copyWith(
          currentStreak: newCurrentStreak,
          longestStreak: newLongest > habitState.longestStreak
              ? newLongest
              : habitState.longestStreak,
          last30DaysLogs: updatedLogs,
        );
      }
      return habitState;
    }).toList();

    state = AsyncValue.data(_inMemoryHabits);
  }

  /// In-memory manual override (from Debug Hatch).
  Future<void> overrideLog({
    required int habitId,
    required String logDate,
    required int intensity,
    String? note,
  }) async {
    _inMemoryHabits = _inMemoryHabits.map((habitState) {
      if (habitState.habit.id == habitId) {
        final updatedLogs = habitState.last30DaysLogs
            .where((log) => log.logDate != logDate)
            .toList();

        final newLog = DailyLog(
          habitId: habitId,
          logDate: logDate,
          intensity: intensity,
          note: note,
        );
        updatedLogs.add(newLog);
        updatedLogs.sort((a, b) => b.logDate.compareTo(a.logDate));

        final newCurrentStreak =
            HabitAnalyticsEngine.calculateCurrentStreak(updatedLogs);
        final newLongest =
            HabitAnalyticsEngine.calculateLongestStreak(updatedLogs);

        return habitState.copyWith(
          currentStreak: newCurrentStreak,
          longestStreak: newLongest > habitState.longestStreak
              ? newLongest
              : habitState.longestStreak,
          last30DaysLogs: updatedLogs,
        );
      }
      return habitState;
    }).toList();

    state = AsyncValue.data(_inMemoryHabits);
  }

  Future<void> refresh() async {
    state = AsyncValue.data(_inMemoryHabits);
  }
}

/// Global provider for accessing the habit list view state.
final habitListProvider =
    AsyncNotifierProvider<HabitListNotifier, List<HabitViewState>>(() {
  return HabitListNotifier();
});
