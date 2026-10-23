import 'package:flutter/material.dart';
import '../models/daily_log.dart';
import '../analytics/habit_analytics_engine.dart';

/// A vertical scrolling heatmap grid inspired by GitHub/LeetCode contribution charts.
/// Organized into 7 columns (Mon - Sun) scrolling vertically down through time.
class HeatmapGrid extends StatelessWidget {
  final List<DailyLog> logs;
  final Color activeColor;
  final int numberOfWeeks;

  const HeatmapGrid({
    super.key,
    required this.logs,
    required this.activeColor,
    this.numberOfWeeks = 16, // 16 weeks ~ 112 days
  });

  @override
  Widget build(BuildContext context) {
    // Index logs by date string YYYY-MM-DD for O(1) lookup
    final logMap = <String, DailyLog>{};
    for (final log in logs) {
      logMap[log.logDate] = log;
    }

    final now = DateTime.now();
    final todayStr = HabitAnalyticsEngine.todayLogDate(now);

    // Compute start day: Monday of the earliest week in the range
    final totalDays = numberOfWeeks * 7;
    // Align today to Sunday of the current week to have full weeks
    final daysUntilEndOfWeek = 7 - now.weekday; // 1 = Mon ... 7 = Sun
    final endCalendarDate = now.add(Duration(days: daysUntilEndOfWeek));
    final startDate = endCalendarDate.subtract(Duration(days: totalDays - 1));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Heatmap Header & Legend
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ACTIVITY CANVAS',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              Row(
                children: [
                  const Text('Less ', style: TextStyle(color: Colors.white30, fontSize: 10)),
                  _legendBox(Colors.white.withOpacity(0.06)),
                  _legendBox(activeColor.withOpacity(0.25)),
                  _legendBox(activeColor.withOpacity(0.55)),
                  _legendBox(activeColor.withOpacity(0.85)),
                  _legendBox(activeColor),
                  const Text(' More', style: TextStyle(color: Colors.white30, fontSize: 10)),
                ],
              ),
            ],
          ),
        ),

        // Day of week headers: M T W T F S S
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((day) {
              return Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // Heatmap Grid
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
            physics: const BouncingScrollPhysics(),
            itemCount: numberOfWeeks,
            itemBuilder: (context, weekIndex) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (dayIndex) {
                    final dayOffset = (weekIndex * 7) + dayIndex;
                    final cellDate = startDate.add(Duration(days: dayOffset));
                    final cellDateStr = HabitAnalyticsEngine.todayLogDate(cellDate);

                    final isFuture = cellDate.isAfter(now);
                    final isToday = cellDateStr == todayStr;
                    final log = logMap[cellDateStr];

                    return Expanded(
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: _HeatmapCell(
                          dateStr: cellDateStr,
                          log: log,
                          isToday: isToday,
                          isFuture: isFuture,
                          activeColor: activeColor,
                        ),
                      ),
                    );
                  }),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _legendBox(Color color) {
    return Container(
      width: 10,
      height: 10,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _HeatmapCell extends StatelessWidget {
  final String dateStr;
  final DailyLog? log;
  final bool isToday;
  final bool isFuture;
  final Color activeColor;

  const _HeatmapCell({
    required this.dateStr,
    required this.log,
    required this.isToday,
    required this.isFuture,
    required this.activeColor,
  });

  Color _resolveCellColor() {
    if (isFuture) return Colors.transparent;
    if (log == null) return const Color(0xFF191C26);

    final intensity = log!.intensity;
    if (intensity <= 3) return activeColor.withOpacity(0.25);
    if (intensity <= 6) return activeColor.withOpacity(0.55);
    if (intensity <= 9) return activeColor.withOpacity(0.85);
    return activeColor; // Intensity 10
  }

  @override
  Widget build(BuildContext context) {
    final cellColor = _resolveCellColor();

    return GestureDetector(
      onTap: () {
        if (isFuture) return;
        final message = log != null
            ? '$dateStr: Intensity ${log!.intensity}/10'
            : '$dateStr: No activity';
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(2.5),
        decoration: BoxDecoration(
          color: cellColor,
          borderRadius: BorderRadius.circular(5.0),
          border: isToday
              ? Border.all(
                  color: Colors.white,
                  width: 1.5,
                )
              : null,
          boxShadow: (log != null && log!.intensity >= 8)
              ? [
                  BoxShadow(
                    color: activeColor.withOpacity(0.4),
                    blurRadius: 4,
                    spreadRadius: 0.5,
                  )
                ]
              : null,
        ),
      ),
    );
  }
}
