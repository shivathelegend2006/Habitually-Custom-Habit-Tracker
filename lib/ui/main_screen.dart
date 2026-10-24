import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Full production screen featuring the exact architectural palette and a smooth,
/// vertical, scrollable calendar-style heatmap with embedded date numbers.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // ---------------------------------------------------------------------------
  // Design System Palette (Architect's Exact Tokens)
  // ---------------------------------------------------------------------------
  static const Color mainBg = Color(0xFF1A1A1A); // Dark charcoal
  static const Color cardAndHeaderBg = Color(0xFF262626); // Subtle contrast
  static const Color borderAndDivider = Color(0xFF3A3A3A); // Visible borders
  static const Color primaryText = Color(0xFFEDEDED); // Soft white
  static const Color secondaryText = Color(0xFFA1A1AA); // Muted labels

  // Active Habit
  final String _habitName = 'Chanting';
  final Color _habitColor = const Color(0xFFFF7A00); // Habit Orange
  int _streakCount = 5;
  bool _isLoggedToday = false;

  // Mock logged dates (Map of "YYYY-MM-DD" -> intensity 1-10)
  // Initialized directly to avoid LateInitializationError during Hot Reloads
  Map<String, int> _loggedDates = _createInitialMockLogs();

  static Map<String, int> _createInitialMockLogs() {
    final now = DateTime.now();
    final map = <String, int>{};

    String formatKey(DateTime dt) {
      final y = dt.year.toString().padLeft(4, '0');
      final m = dt.month.toString().padLeft(2, '0');
      final d = dt.day.toString().padLeft(2, '0');
      return '$y-$m-$d';
    }

    // 5-day active streak: yesterday back to 4 days ago
    for (int i = 1; i <= 5; i++) {
      final date = now.subtract(Duration(days: i));
      map[formatKey(date)] = 7 + (i % 3); // Intensities: 7, 8, 9
    }

    // Scattered historical logs for previous weeks/months
    for (int i = 7; i <= 60; i += 2) {
      final date = now.subtract(Duration(days: i));
      map[formatKey(date)] = 5 + (i % 5); // Intensities: 5 - 9
    }

    return map;
  }

  @override
  void initState() {
    super.initState();
  }

  String _formatDateKey(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String _getTimeGreetingPrefix() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning, ';
    } else if (hour < 17) {
      return 'Good Afternoon, ';
    } else {
      return 'Good Evening, ';
    }
  }

  void _handleLogToday() {
    HapticFeedback.mediumImpact();
    final todayKey = _formatDateKey(DateTime.now());

    setState(() {
      _isLoggedToday = !_isLoggedToday;
      if (_isLoggedToday) {
        _streakCount += 1;
        _loggedDates[todayKey] = 9; // High intensity log
      } else {
        _streakCount -= 1;
        _loggedDates.remove(todayKey);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // =================================================================
            // 1. Header Layer (~5%) - #262626 with #3A3A3A border
            // =================================================================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              decoration: const BoxDecoration(
                color: cardAndHeaderBg,
                border: Border(
                  bottom: BorderSide(
                    color: borderAndDivider,
                    width: 1.0,
                  ),
                ),
              ),
              child: const Text(
                'Habitually...',
                style: TextStyle(
                  color: primaryText,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),

            // =================================================================
            // 2. Greeting Section: Thin Greeting + Bigger Bolder 'Legend!'
            // =================================================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
              child: Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      fontFamily: 'Georgia',
                      letterSpacing: 0.3,
                    ),
                    children: [
                      TextSpan(
                        text: _getTimeGreetingPrefix(),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w200, // Thin
                          color: secondaryText,
                        ),
                      ),
                      const TextSpan(
                        text: 'Legend!',
                        style: TextStyle(
                          fontSize: 28, // Bigger
                          fontWeight: FontWeight.w800, // Bolder
                          color: primaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // =================================================================
            // 3. Habit Card (~30% Zone)
            // =================================================================
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20.0),
              padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 20.0),
              decoration: BoxDecoration(
                color: cardAndHeaderBg,
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(
                  color: borderAndDivider,
                  width: 1.0,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Habit Name: Soft white, bold, centered
                  Text(
                    _habitName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: primaryText,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Streak Number: Habit Orange
                  Text(
                    '$_streakCount',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _habitColor,
                      fontSize: 52,
                      height: 1.05,
                      fontWeight: FontWeight.w900,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      shadows: [
                        Shadow(
                          color: _habitColor.withOpacity(0.3),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),

                  // Streak label
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.local_fire_department_rounded,
                        color: _habitColor,
                        size: 15,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'DAYS STREAK',
                        style: TextStyle(
                          color: secondaryText,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // "Log Today" Button
                  Center(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _handleLogToday,
                        borderRadius: BorderRadius.circular(25),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28.0,
                            vertical: 11.0,
                          ),
                          decoration: BoxDecoration(
                            color: _isLoggedToday
                                ? _habitColor.withOpacity(0.18)
                                : _habitColor,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: _habitColor,
                              width: 1.5,
                            ),
                            boxShadow: _isLoggedToday
                                ? []
                                : [
                                    BoxShadow(
                                      color: _habitColor.withOpacity(0.35),
                                      blurRadius: 12,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isLoggedToday
                                    ? Icons.check_circle_rounded
                                    : Icons.bolt_rounded,
                                color: _isLoggedToday ? _habitColor : primaryText,
                                size: 17,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _isLoggedToday ? 'Logged Today!' : 'Log Today',
                                style: TextStyle(
                                  color: _isLoggedToday ? _habitColor : primaryText,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // =================================================================
            // 4. Final Piece: Calendar-Style Vertical Heat Map Grid
            // =================================================================
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                decoration: BoxDecoration(
                  color: cardAndHeaderBg,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(22.0)),
                  border: Border.all(
                    color: borderAndDivider,
                    width: 1.0,
                  ),
                ),
                child: Column(
                  children: [
                    // Day of Week Header: Mon, Tue, Wed, Thu, Fri, Sat, Sun
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: borderAndDivider, width: 1.0),
                        ),
                      ),
                      child: Row(
                        children: const ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN']
                            .map(
                              (day) => Expanded(
                                child: Center(
                                  child: Text(
                                    day,
                                    style: const TextStyle(
                                      color: secondaryText,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),

                    // Scrollable Calendar Heat Map (Current & Previous Months)
                    Expanded(
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                        itemCount: 4, // Shows Current Month + past 3 months
                        itemBuilder: (context, monthOffset) {
                          final now = DateTime.now();
                          // Compute month date: offset 0 = current, 1 = last month, etc.
                          final monthDate = DateTime(now.year, now.month - monthOffset, 1);
                          return _buildMonthCalendar(monthDate, now);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a single calendar month with embedded white date numbers and habit color heat shading.
  Widget _buildMonthCalendar(DateTime monthDate, DateTime now) {
    final monthName = _getMonthName(monthDate.month).toUpperCase();
    final year = monthDate.year;

    // Number of days in this month
    final daysInMonth = DateTime(monthDate.year, monthDate.month + 1, 0).day;

    // Weekday of 1st day (1 = Monday ... 7 = Sunday)
    final firstWeekday = monthDate.weekday; // Monday is 1, Sunday is 7
    final emptyLeadSlots = firstWeekday - 1;

    final totalGridCells = emptyLeadSlots + daysInMonth;
    final totalRows = (totalGridCells / 7).ceil();

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month Title
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$monthName $year',
                  style: const TextStyle(
                    color: primaryText,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
                Text(
                  monthOffsetLabel(monthDate, now),
                  style: const TextStyle(
                    color: secondaryText,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // 7-Column Calendar Grid
          Column(
            children: List.generate(totalRows, (rowIndex) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.5),
                child: Row(
                  children: List.generate(7, (colIndex) {
                    final cellIndex = (rowIndex * 7) + colIndex;
                    final dayNumber = cellIndex - emptyLeadSlots + 1;

                    // If lead offset or trailing overflow
                    if (cellIndex < emptyLeadSlots || dayNumber > daysInMonth) {
                      return const Expanded(child: SizedBox(height: 38));
                    }

                    final cellDate = DateTime(monthDate.year, monthDate.month, dayNumber);
                    final cellKey = _formatDateKey(cellDate);
                    final isToday = cellDate.year == now.year &&
                        cellDate.month == now.month &&
                        cellDate.day == now.day;
                    final isFuture = cellDate.isAfter(now);
                    final intensity = _loggedDates[cellKey];

                    return Expanded(
                      child: _buildCalendarDayCell(
                        dayNumber: dayNumber,
                        intensity: intensity,
                        isToday: isToday,
                        isFuture: isFuture,
                      ),
                    );
                  }),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  /// Individual calendar cell with embedded date number and habit color intensity shading.
  Widget _buildCalendarDayCell({
    required int dayNumber,
    required int? intensity,
    required bool isToday,
    required bool isFuture,
  }) {
    // Resolve background color based on habit orange and log intensity
    Color cellBgColor;
    Color cellBorderColor;

    if (intensity != null) {
      if (intensity >= 8) {
        cellBgColor = _habitColor; // Full rich orange
        cellBorderColor = _habitColor;
      } else if (intensity >= 5) {
        cellBgColor = _habitColor.withOpacity(0.65);
        cellBorderColor = _habitColor.withOpacity(0.7);
      } else {
        cellBgColor = _habitColor.withOpacity(0.35);
        cellBorderColor = _habitColor.withOpacity(0.4);
      }
    } else {
      // Unlogged day
      cellBgColor = isFuture ? const Color(0xFF1E1E1E) : const Color(0xFF222222);
      cellBorderColor = borderAndDivider;
    }

    if (isToday) {
      cellBorderColor = primaryText; // Bright highlight for Today
    }

    return Container(
      height: 38,
      margin: const EdgeInsets.symmetric(horizontal: 2.5),
      decoration: BoxDecoration(
        color: cellBgColor,
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(
          color: cellBorderColor,
          width: isToday ? 1.5 : 1.0,
        ),
        boxShadow: (intensity != null && intensity >= 8)
            ? [
                BoxShadow(
                  color: _habitColor.withOpacity(0.35),
                  blurRadius: 6,
                  spreadRadius: 0.5,
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          '$dayNumber',
          style: TextStyle(
            color: isFuture
                ? secondaryText.withOpacity(0.35)
                : (intensity != null && intensity >= 8 ? Colors.white : primaryText),
            fontSize: 11,
            fontWeight: isToday ? FontWeight.w900 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String monthOffsetLabel(DateTime date, DateTime now) {
    if (date.year == now.year && date.month == now.month) return 'Current Month';
    final diff = (now.year - date.year) * 12 + (now.month - date.month);
    return '$diff mo ago';
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }
}
