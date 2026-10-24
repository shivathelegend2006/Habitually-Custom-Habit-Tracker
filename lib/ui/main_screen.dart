import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Habitually... Screen
/// - Native Glowing Mesh Background: Top-left, top-right, and bottom-right glow orbs blended
///   via deep 90px Gaussian blur, dynamically themed to the habit's accent color
/// - Header: Habitually... with "Good evening," and bold, white, larger "Legend!"
/// - Habit Section: Centered clean hero streak number (NO cheap emojis!), letter-spaced label, compact Log button
/// - Calendar: Fixed Mon-Sun weekday bar, month titles between each block of cells,
///   darker unfilled cells, and ZERO borders or shadows anywhere
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Theme Color Tokens
  static const Color scaffoldBg = Color(0xFF151515); // Darkened center #151515
  static const Color cellInactive = Color(0xFF17171A); // Darker, sleek inactive date cells #17171A
  static const Color orangePrimary = Color(0xFFFF7A00); // Primary orange accent #FF7A00
  static const Color orangeMid = Color(0xFFE66E00);
  static const Color orangeDeep = Color(0xFFC75700);
  static const Color richGlow = Color(0xFF8F3D0B); // Rich soft glow #8F3D0B
  static const Color glowCore = Color(0xFFD95000); // Concentrated radiant core for 3D depth
  static const Color surfaceSubtle = Color(0xFF222222); // Subtle surfaces #222222
  static const Color shadowWarm = Color(0xFF321C10); // Warm shadows #321C10

  static const Color textPrimary = Color(0xFFFFFFFF); // White text on completed orange dates
  static const Color textSecondary = Color(0xFF8E8E93); // Crisp legible numbers on darker cells #8E8E93
  static const Color textBrightened = Color(0xFFB5B5BE); // Slightly brightened captions

  int _streakCount = 5;
  bool _isLoggedToday = false;

  // Logged activity dataset (Preserved exactly)
  final Map<String, int> _loggedDates = {
    // October 2026 logs
    '2026-10-03': 9,
    '2026-10-04': 9,
    '2026-10-06': 9,
    '2026-10-08': 6,
    '2026-10-10': 8,
    '2026-10-14': 9,
    '2026-10-15': 7,
    '2026-10-17': 8,
    '2026-10-20': 9,
    '2026-10-23': 8,
    '2026-10-27': 9,
    '2026-10-30': 8,
    '2026-10-31': 10,
    // September logs
    '2026-09-02': 8,
    '2026-09-06': 9,
    '2026-09-10': 7,
    '2026-09-15': 9,
    '2026-09-20': 8,
    '2026-09-25': 9,
    // November logs
    '2026-11-02': 9,
    '2026-11-05': 8,
  };

  String _formatDateKey(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  void _toggleLogToday() {
    HapticFeedback.mediumImpact();
    final todayKey = '2026-10-24';

    setState(() {
      _isLoggedToday = !_isLoggedToday;
      if (_isLoggedToday) {
        _streakCount += 1;
        _loggedDates[todayKey] = 9;
      } else {
        _streakCount -= 1;
        _loggedDates.remove(todayKey);
      }
    });
  }

  String _getMonthName(int month) {
    const names = [
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
    return names[month - 1];
  }

  String _getGreetingPrefix() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning,';
    } else if (hour < 17) {
      return 'Good afternoon,';
    } else {
      return 'Good evening,';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBg,
      body: Stack(
        children: [
          // ===================================================================
          // 1. FULL-SCREEN BASE: Multi-stop atmospheric base with rich depth
          // ===================================================================
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Color(0xFF26150B), // Deep warm amber-black undertone
                    Color(0xFF191514),
                    Color(0xFF141416), // Deep dark center #141416 for contrast
                    Color(0xFF151516),
                    Color(0xFF281409), // Rich warm shadow depth
                  ],
                  stops: [0.0, 0.22, 0.50, 0.78, 1.0],
                ),
              ),
            ),
          ),

          // ===================================================================
          // 2. DIMENSIONAL GLOW MESH: Layered ambient halos + radiant 3D cores
          // ===================================================================

          // Dimension Layer A: Subtle mid-left ambient depth
          Positioned(
            top: 260,
            left: -130,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF5A1E02).withOpacity(0.24),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),

          // Dimension Layer B: Top-Left subtle corner accent
          Positioned(
            top: -90,
            left: -90,
            child: Container(
              width: 310,
              height: 310,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    richGlow.withOpacity(0.40),
                    const Color(0xFF4A1A04).withOpacity(0.12),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.50, 1.0],
                ),
              ),
            ),
          ),

          // Dimension Layer C: Top-Right Wide Ambient Halo
          Positioned(
            top: -140,
            right: -120,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    richGlow.withOpacity(0.55),
                    richGlow.withOpacity(0.24),
                    const Color(0xFF381403).withOpacity(0.06),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.40, 0.70, 1.0],
                ),
              ),
            ),
          ),

          // Dimension Layer D: Top-Right Concentrated Radiant Core (3D volumetric depth)
          Positioned(
            top: -50,
            right: -40,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    glowCore.withOpacity(0.42),
                    richGlow.withOpacity(0.18),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),

          // Dimension Layer E: Bottom-Right Wide Ambient Halo
          Positioned(
            bottom: -150,
            right: -110,
            child: Container(
              width: 480,
              height: 480,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    richGlow.withOpacity(0.65),
                    richGlow.withOpacity(0.30),
                    const Color(0xFF381403).withOpacity(0.08),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.40, 0.70, 1.0],
                ),
              ),
            ),
          ),

          // Dimension Layer F: Bottom-Right Concentrated Radiant Core (3D volumetric depth)
          Positioned(
            bottom: -60,
            right: -30,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    glowCore.withOpacity(0.48),
                    richGlow.withOpacity(0.20),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),

          // High ImageFilter.blur sigma to blend seamlessly with dark center
          Positioned.fill(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 85, sigmaY: 85),
              child: const SizedBox.expand(),
            ),
          ),

          // ===================================================================
          // FOREGROUND UI
          // ===================================================================
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 10),

                      // =======================================================
                      // BRAND & GREETING: "Legend!" bold, white, and a bit bigger
                      // =======================================================
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontFamily: '-apple-system',
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Habit',
                                  style: TextStyle(color: textPrimary),
                                ),
                                TextSpan(
                                  text: 'ually...',
                                  style: TextStyle(color: orangePrimary),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Greeting: Legend alone is bold, white, and bigger
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontFamily: '-apple-system',
                                letterSpacing: -0.2,
                              ),
                              children: [
                                TextSpan(
                                  text: '${_getGreetingPrefix()} ',
                                  style: const TextStyle(
                                    color: textSecondary,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const TextSpan(
                                  text: 'Legend!',
                                  style: TextStyle(
                                    color: textPrimary,
                                    fontSize: 17.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // =======================================================
                      // HABIT SECTION: Chanting, Centered Number (NO emojis!), Log Button
                      // =======================================================
                      Center(
                        child: Column(
                          children: [
                            // Habit Name
                            const Text(
                              'Chanting',
                              style: TextStyle(
                                fontFamily: '-apple-system',
                                color: textPrimary,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 2),

                            // Centered Hero Number (NO cheap emojis)
                            Text(
                              '$_streakCount',
                              style: const TextStyle(
                                fontFamily: '-apple-system',
                                color: orangePrimary,
                                fontSize: 54,
                                height: 1.05,
                                fontWeight: FontWeight.w900,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                            const SizedBox(height: 2),

                            // Clean, understated label (Mixed Case, not all caps)
                            const Text(
                              'Day Streak',
                              style: TextStyle(
                                fontFamily: '-apple-system',
                                color: textBrightened,
                                fontSize: 13.0,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),

                            const SizedBox(height: 14),

                            // Log Today Button: Compact Pill (does NOT stretch edge-to-edge)
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _toggleLogToday,
                                borderRadius: BorderRadius.circular(26),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32.0,
                                    vertical: 12.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _isLoggedToday
                                        ? surfaceSubtle
                                        : orangePrimary,
                                    borderRadius: BorderRadius.circular(26),
                                    border: _isLoggedToday
                                        ? Border.all(
                                            color: orangePrimary.withOpacity(0.5),
                                            width: 1.5,
                                          )
                                        : null,
                                    boxShadow: _isLoggedToday
                                        ? []
                                        : [
                                            BoxShadow(
                                              color: shadowWarm.withOpacity(0.70),
                                              blurRadius: 16,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 19,
                                        height: 19,
                                        decoration: BoxDecoration(
                                          color: _isLoggedToday
                                              ? orangePrimary
                                              : const Color(0xFF141416),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.check_rounded,
                                          size: 13,
                                          color: _isLoggedToday
                                              ? Colors.white
                                              : orangePrimary,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _isLoggedToday ? 'Logged Today' : 'Log Today',
                                        style: TextStyle(
                                          fontFamily: '-apple-system',
                                          color: _isLoggedToday
                                              ? textPrimary
                                              : const Color(0xFF141416),
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 22),

                      // =======================================================
                      // CALENDAR: FIXED Mon-Sun Bar + Scrolling Month Blocks Below
                      // =======================================================

                      // 1. FIXED Mon to Sun Weekday Bar (Pinned, does not scroll away)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: Row(
                          children: const [
                            'Mon',
                            'Tue',
                            'Wed',
                            'Thu',
                            'Fri',
                            'Sat',
                            'Sun'
                          ].map(
                            (day) => Expanded(
                              child: Center(
                                child: Text(
                                  day,
                                  style: const TextStyle(
                                    fontFamily: '-apple-system',
                                    color: Colors.white,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.1,
                                  ),
                                ),
                              ),
                            ),
                          ).toList(),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // 2. Scrolling Months with Month Names between each block of cells
                      Expanded(
                        child: ListView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 100),
                          children: [
                            // --- Block 1: October 2026 ---
                            _buildMonthHeader('October 2026'),
                            const SizedBox(height: 6),
                            _buildMonthGrid(DateTime(2026, 10, 1)),

                            const SizedBox(height: 26),

                            // --- Block 2: November 2026 ---
                            _buildMonthHeader('November 2026'),
                            const SizedBox(height: 6),
                            _buildMonthGrid(DateTime(2026, 11, 1)),

                            const SizedBox(height: 26),

                            // --- Block 3: December 2026 ---
                            _buildMonthHeader('December 2026'),
                            const SizedBox(height: 6),
                            _buildMonthGrid(DateTime(2026, 12, 1)),
                          ],
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
    );
  }

  /// Month name header displayed cleanly between each block of cells.
  Widget _buildMonthHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 3.0, top: 4.0, bottom: 2.0),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: '-apple-system',
          color: textPrimary,
          fontSize: 16.0,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  /// Builds a clean 7-column calendar grid for a given month.
  /// - Non-month lead days are transparent empty spaces so the month starts on the correct weekday!
  /// - Unfilled cells are darker (#161619) with ZERO borders and ZERO shadows!
  /// - Logged cells are solid vibrant habit orange!
  Widget _buildMonthGrid(DateTime monthDate) {
    final daysInMonth = DateTime(monthDate.year, monthDate.month + 1, 0).day;
    final firstWeekday = monthDate.weekday; // 1 = Mon ... 7 = Sun
    final emptyLeadSlots = firstWeekday - 1;

    final totalGridCells = emptyLeadSlots + daysInMonth;
    final totalRows = (totalGridCells / 7).ceil();

    return Column(
      children: List.generate(totalRows, (rowIndex) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Row(
            children: List.generate(7, (colIndex) {
              final cellIndex = (rowIndex * 7) + colIndex;
              final dayNumber = cellIndex - emptyLeadSlots + 1;

              // Lead days (empty transparent slots before 1st of month)
              if (cellIndex < emptyLeadSlots) {
                return const Expanded(
                  child: SizedBox(height: 38),
                );
              }

              // Trailing days (empty transparent slots after last day of month)
              if (dayNumber > daysInMonth) {
                return const Expanded(
                  child: SizedBox(height: 38),
                );
              }

              // Active month day
              final cellDate = DateTime(monthDate.year, monthDate.month, dayNumber);
              final cellKey = _formatDateKey(cellDate);
              final intensity = _loggedDates[cellKey];
              final isToday = cellKey == '2026-10-24';

              Color bgColor = cellInactive; // Inactive date cells #17171A (darker)
              Color textColor = textSecondary; // Inactive date numbers #8E8E93

              if (intensity != null) {
                if (intensity >= 8) {
                  bgColor = orangePrimary;
                  textColor = Colors.white; // White text on completed orange dates
                } else if (intensity >= 6) {
                  bgColor = orangeMid;
                  textColor = Colors.white;
                } else {
                  bgColor = orangeDeep;
                  textColor = Colors.white;
                }
              }

              return Expanded(
                child: _buildFlatCell(
                  day: dayNumber,
                  bgColor: bgColor,
                  textColor: textColor,
                  isLogged: intensity != null,
                  isToday: isToday,
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  /// Flat & Premium date cell:
  /// - Sleek squircle (radius 8.0)
  /// - ZERO borders anywhere
  /// - ZERO shadows anywhere
  /// - Darker unfilled cells (#161619)
  /// - Solid vibrant orange completed
  Widget _buildFlatCell({
    required int day,
    required Color bgColor,
    required Color textColor,
    bool isLogged = false,
    bool isToday = false,
  }) {
    return Container(
      height: 38,
      margin: const EdgeInsets.symmetric(horizontal: 2.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8.0),
        // ZERO border or shadow anywhere as requested
      ),
      child: Center(
        child: Text(
          '$day',
          style: TextStyle(
            fontFamily: '-apple-system',
            color: isToday && !isLogged ? orangePrimary : textColor,
            fontSize: 12,
            fontWeight: isLogged || isToday ? FontWeight.w700 : FontWeight.w500,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }
}
