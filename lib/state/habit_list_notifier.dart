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

/// In-memory mock notifier that completely bypasses SQLite for web previewing & UI design.
class HabitListNotifier extends AsyncNotifier<List<HabitViewState>> {
  late List<HabitViewState> _inMemoryHabits;

  @override
  Future<List<HabitViewState>> build() async {
    _inMemoryHabits = _generateMockHabits();
    return _inMemoryHabits;
  }

  /// Generates hardcoded dummy habits with streaks and daily logs for UI preview.
  List<HabitViewState> _generateMockHabits() {
    final now = DateTime.now();

    // Habit 1: Requested 5-day streak habit
    final habit1Logs = <DailyLog>[];
    for (int i = 0; i < 5; i++) {
      final logDay = now.subtract(Duration(days: i));
      habit1Logs.add(
        DailyLog(
          id: 100 + i,
          habitId: 1,
          logDate: HabitAnalyticsEngine.todayLogDate(logDay),
          intensity: 7 + (i % 3), // 7, 8, 9
          note: i == 0 ? 'Felt great today!' : null,
        ),
      );
    }
    // Add some older scattered logs for the 30-day heatmap canvas
    for (int i = 8; i < 28; i += 2) {
      final logDay = now.subtract(Duration(days: i));
      habit1Logs.add(
        DailyLog(
          id: 200 + i,
          habitId: 1,
          logDate: HabitAnalyticsEngine.todayLogDate(logDay),
          intensity: 5 + (i % 5),
        ),
      );
    }

    final habit1 = Habit(
      id: 1,
      name: 'Morning Meditation',
      colorCode: '#00E676', // Emerald
      createdAt: now.subtract(const Duration(days: 30)),
    );

    // Habit 2: Deep Work Session (allows horizontal PageView swiping preview)
    final habit2Logs = <DailyLog>[];
    for (int i = 0; i < 3; i++) {
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
    for (int i = 5; i < 25; i += 3) {
      final logDay = now.subtract(Duration(days: i));
      habit2Logs.add(
        DailyLog(
          id: 400 + i,
          habitId: 2,
          logDate: HabitAnalyticsEngine.todayLogDate(logDay),
          intensity: 6 + (i % 4),
        ),
      );
    }

    final habit2 = Habit(
      id: 2,
      name: 'Deep Work Session',
      colorCode: '#7C4DFF', // Cyberpunk Purple
      createdAt: now.subtract(const Duration(days: 45)),
    );

    // Habit 3: Evening Workout
    final habit3Logs = <DailyLog>[];
    for (int i = 1; i < 9; i++) {
      final logDay = now.subtract(Duration(days: i));
      habit3Logs.add(
        DailyLog(
          id: 500 + i,
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
      createdAt: now.subtract(const Duration(days: 60)),
    );

    return [
      HabitViewState(
        habit: habit1,
        currentStreak: 5, // 5-day active streak
        longestStreak: 12,
        last30DaysLogs: habit1Logs,
      ),
      HabitViewState(
        habit: habit2,
        currentStreak: 3,
        longestStreak: 8,
        last30DaysLogs: habit2Logs,
      ),
      HabitViewState(
        habit: habit3,
        currentStreak: 8,
        longestStreak: 15,
        last30DaysLogs: habit3Logs,
      ),
    ];
  }

  /// In-memory daily log toggle that bypasses SQLite.
  /// Updates the habit's logs and recalculated streaks live in the UI.
  Future<void> toggleDailyLog(int habitId, int intensity) async {
    final todayStr = HabitAnalyticsEngine.todayLogDate();

    _inMemoryHabits = _inMemoryHabits.map((habitState) {
      if (habitState.habit.id == habitId) {
        // Remove existing log for today if any
        final updatedLogs = habitState.last30DaysLogs
            .where((log) => log.logDate != todayStr)
            .toList();

        // Prepend today's new entry
        final newLog = DailyLog(
          habitId: habitId,
          logDate: todayStr,
          intensity: intensity,
        );
        updatedLogs.insert(0, newLog);

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

  /// In-memory manual override (from Debug Hatch) bypassing SQLite.
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

        // Sort descending
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

  /// Refreshes state in memory.
  Future<void> refresh() async {
    state = AsyncValue.data(_inMemoryHabits);
  }
}

/// Global provider for accessing the habit list view state.
final habitListProvider =
    AsyncNotifierProvider<HabitListNotifier, List<HabitViewState>>(() {
  return HabitListNotifier();
});
