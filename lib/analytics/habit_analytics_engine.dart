import '../models/daily_log.dart';

/// Pure Dart logic engine for habit tracking analytics.
///
/// Assumes all provided [List<DailyLog>] are sorted chronologically descending
/// (newest log at index 0).
class HabitAnalyticsEngine {
  const HabitAnalyticsEngine();

  // ---------------------------------------------------------------------------
  // Date Normalization Helpers
  // ---------------------------------------------------------------------------

  /// Converts any [DateTime] to the device's local timezone (e.g. IST) and extracts
  /// the local calendar day (year, month, day).
  ///
  /// Then anchors it at midnight UTC solely to guarantee that every 24-hour difference
  /// computation (.difference().inDays) is mathematically exact.
  static DateTime normalizeToLocalCalendarMidnight(DateTime dt) {
    final local = dt.toLocal(); // Ensures IST time is respected even if dt is UTC
    return DateTime.utc(local.year, local.month, local.day);
  }

  /// Returns today's date formatted as YYYY-MM-DD according to local time (IST).
  static String todayLogDate([DateTime? referenceDate]) {
    final local = (referenceDate ?? DateTime.now()).toLocal();
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Parses a YYYY-MM-DD string into a midnight calendar date [DateTime].
  static DateTime parseLogDate(String logDate) {
    final parts = logDate.split('-');
    return DateTime.utc(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  /// Calculates the difference in full calendar days between [d1] and [d2] (d1 - d2).
  static int calendarDaysDifference(DateTime d1, DateTime d2) {
    final c1 = normalizeToLocalCalendarMidnight(d1);
    final c2 = normalizeToLocalCalendarMidnight(d2);
    return c1.difference(c2).inDays;
  }

  // ---------------------------------------------------------------------------
  // Analytics Methods
  // ---------------------------------------------------------------------------

  /// Computes the active streak given a chronologically descending list of logs.
  ///
  /// [referenceDate] defaults to [DateTime.now()] if omitted (useful for unit tests).
  ///
  /// Rules:
  /// - If the most recent log is today (diff == 0) or yesterday (diff == 1),
  ///   the streak is alive.
  /// - If the most recent log is 2 or more days ago, the streak is 0.
  /// - Subsequent logs must be exactly 1 calendar day apart to increment the streak.
  static int calculateCurrentStreak(
    List<DailyLog> logs, {
    DateTime? referenceDate,
  }) {
    if (logs.isEmpty) return 0;

    final today = normalizeToLocalCalendarMidnight(referenceDate ?? DateTime.now());
    final mostRecentLogDate = parseLogDate(logs.first.logDate);
    final diffFromToday = today.difference(mostRecentLogDate).inDays;

    // Grace period check: must have logged today (0) or yesterday (1).
    if (diffFromToday > 1 || diffFromToday < 0) {
      // If diffFromToday > 1: Grace period expired.
      // If diffFromToday < 0: Most recent log is in the future relative to referenceDate.
      return 0;
    }

    int streak = 1;
    DateTime previousDate = mostRecentLogDate;

    for (int i = 1; i < logs.length; i++) {
      final currentDate = parseLogDate(logs[i].logDate);
      final gap = previousDate.difference(currentDate).inDays;

      if (gap == 1) {
        streak++;
        previousDate = currentDate;
      } else if (gap == 0) {
        // Defensive check: ignore duplicate dates for the same habit.
        continue;
      } else {
        // Gap > 1 day: streak broken.
        break;
      }
    }

    return streak;
  }

  /// Finds the maximum consecutive day streak across all historical logs.
  static int calculateLongestStreak(List<DailyLog> logs) {
    if (logs.isEmpty) return 0;

    int maxStreak = 1;
    int currentChain = 1;
    DateTime previousDate = parseLogDate(logs.first.logDate);

    for (int i = 1; i < logs.length; i++) {
      final currentDate = parseLogDate(logs[i].logDate);
      final gap = previousDate.difference(currentDate).inDays;

      if (gap == 1) {
        currentChain++;
        if (currentChain > maxStreak) {
          maxStreak = currentChain;
        }
      } else if (gap == 0) {
        // Duplicate date, skip without breaking or incrementing.
        continue;
      } else {
        currentChain = 1;
      }

      previousDate = currentDate;
    }

    return maxStreak;
  }

  /// Calculates the average intensity score (1.0 to 10.0) of logged sessions
  /// within the last 30 calendar days (inclusive of today: 0 <= daysAgo < 30).
  ///
  /// Returns 0.0 if no entries exist within the 30-day window.
  static double calculateThirtyDayIntensityAvg(
    List<DailyLog> logs, {
    DateTime? referenceDate,
  }) {
    if (logs.isEmpty) return 0.0;

    final today = normalizeToLocalCalendarMidnight(referenceDate ?? DateTime.now());
    int totalIntensity = 0;
    int count = 0;

    for (final log in logs) {
      final logDate = parseLogDate(log.logDate);
      final daysAgo = today.difference(logDate).inDays;

      // Check if log falls within the 30 calendar day window [today - 29 days, today].
      if (daysAgo >= 0 && daysAgo < 30) {
        totalIntensity += log.intensity;
        count++;
      } else if (daysAgo >= 30) {
        // Since logs are sorted descending, any subsequent logs are older than 30 days.
        break;
      }
    }

    if (count == 0) return 0.0;
    return totalIntensity / count;
  }
}
