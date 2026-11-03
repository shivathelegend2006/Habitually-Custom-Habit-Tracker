import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'habit_intensity_log_overlay.dart';

/// Presentation model for a habit in the tracker.
class HabitItem {
  final String id;
  String name;
  Color color;
  int activeDays; // Count of unique days logged
  int maxStreak; // Longest consecutive streak record
  bool isLoggedToday;
  bool isPaused;
  Map<String, int> loggedDates; // 'YYYY-MM-DD' -> intensity
  Map<String, String> loggedNotes; // 'YYYY-MM-DD' -> note

  HabitItem({
    required this.id,
    required this.name,
    required this.color,
    required this.activeDays,
    required this.maxStreak,
    required this.isLoggedToday,
    this.isPaused = false,
    required this.loggedDates,
    Map<String, String>? loggedNotes,
  }) : loggedNotes = loggedNotes ?? {};
}

/// Dynamic theme tokens computed for any habit color (preset or custom picked).
class HabitThemeData {
  final Color scaffoldBg;
  final Color baseTop;
  final Color baseCenter;
  final Color baseBottom;
  final Color richGlow;
  final Color glowCore;
  final Color accent;
  final Color shadowWarm;
  final Color surfaceSubtle;

  const HabitThemeData({
    required this.scaffoldBg,
    required this.baseTop,
    required this.baseCenter,
    required this.baseBottom,
    required this.richGlow,
    required this.glowCore,
    required this.accent,
    required this.shadowWarm,
    required this.surfaceSubtle,
  });

  /// Factory that produces locked-in design system tokens for presets,
  /// or procedurally derives them for any custom gradient-picked color.
  static HabitThemeData forColor(Color? color) {
    if (color == null) {
      // -----------------------------------------------------------------------
      // Empty State Theme: Moonlight Graphite / Silver
      // -----------------------------------------------------------------------
      return const HabitThemeData(
        scaffoldBg: Color(0xFF141416),
        baseTop: Color(0xFF1E1E22),
        baseCenter: Color(0xFF141416),
        baseBottom: Color(0xFF18181B),
        richGlow: Color(0xFF2D2D36),
        glowCore: Color(0xFF484856),
        accent: Color(0xFFE5E5EA),
        shadowWarm: Color(0xFF08080A),
        surfaceSubtle: Color(0xFF1E1E24),
      );
    }

    final value = color.value;

    // Presets with hand-tuned values
    if (value == 0xFFFF7A00) {
      // Solar Orange
      return const HabitThemeData(
        scaffoldBg: Color(0xFF151515),
        baseTop: Color(0xFF26150B),
        baseCenter: Color(0xFF141416),
        baseBottom: Color(0xFF281409),
        richGlow: Color(0xFF8F3D0B),
        glowCore: Color(0xFFD95000),
        accent: Color(0xFFFF7A00),
        shadowWarm: Color(0xFF321C10),
        surfaceSubtle: Color(0xFF222222),
      );
    } else if (value == 0xFF00D672) {
      // Emerald Mint
      return const HabitThemeData(
        scaffoldBg: Color(0xFF141615),
        baseTop: Color(0xFF072113),
        baseCenter: Color(0xFF141615),
        baseBottom: Color(0xFF062414),
        richGlow: Color(0xFF045228),
        glowCore: Color(0xFF008A46),
        accent: Color(0xFF00D672),
        shadowWarm: Color(0xFF032612),
        surfaceSubtle: Color(0xFF1A241E),
      );
    } else if (value == 0xFF0088FF) {
      // Electric Blue
      return const HabitThemeData(
        scaffoldBg: Color(0xFF141517),
        baseTop: Color(0xFF091726),
        baseCenter: Color(0xFF141517),
        baseBottom: Color(0xFF07192A),
        richGlow: Color(0xFF083366),
        glowCore: Color(0xFF0058BA),
        accent: Color(0xFF0088FF),
        shadowWarm: Color(0xFF041933),
        surfaceSubtle: Color(0xFF1A1F26),
      );
    } else if (value == 0xFFA855F7) {
      // Amethyst Violet
      return const HabitThemeData(
        scaffoldBg: Color(0xFF161417),
        baseTop: Color(0xFF1E0C2B),
        baseCenter: Color(0xFF161417),
        baseBottom: Color(0xFF1E0B2D),
        richGlow: Color(0xFF4A186B),
        glowCore: Color(0xFF7A25BF),
        accent: Color(0xFFA855F7),
        shadowWarm: Color(0xFF210733),
        surfaceSubtle: Color(0xFF221A26),
      );
    } else if (value == 0xFFFFB800) {
      // Warm Amber
      return const HabitThemeData(
        scaffoldBg: Color(0xFF161514),
        baseTop: Color(0xFF261B04),
        baseCenter: Color(0xFF161514),
        baseBottom: Color(0xFF2B1D04),
        richGlow: Color(0xFF734B00),
        glowCore: Color(0xFFC78400),
        accent: Color(0xFFFFB800),
        shadowWarm: Color(0xFF332000),
        surfaceSubtle: Color(0xFF26221A),
      );
    } else if (value == 0xFFFF3B5C) {
      // Rose Coral
      return const HabitThemeData(
        scaffoldBg: Color(0xFF161415),
        baseTop: Color(0xFF280A12),
        baseCenter: Color(0xFF161415),
        baseBottom: Color(0xFF2B0A13),
        richGlow: Color(0xFF6B1123),
        glowCore: Color(0xFFC71E41),
        accent: Color(0xFFFF3B5C),
        shadowWarm: Color(0xFF330510),
        surfaceSubtle: Color(0xFF261A1E),
      );
    }

    // Procedural Theme for ANY arbitrary custom color picked from the gradient spectrum
    final hsv = HSVColor.fromColor(color);
    return HabitThemeData(
      scaffoldBg: const Color(0xFF141416),
      baseTop: HSVColor.fromAHSV(1.0, hsv.hue, (hsv.saturation * 0.7).clamp(0.0, 1.0), 0.15).toColor(),
      baseCenter: const Color(0xFF141416),
      baseBottom: HSVColor.fromAHSV(1.0, hsv.hue, (hsv.saturation * 0.8).clamp(0.0, 1.0), 0.16).toColor(),
      richGlow: HSVColor.fromAHSV(1.0, hsv.hue, (hsv.saturation * 0.9).clamp(0.0, 1.0), 0.38).toColor(),
      glowCore: HSVColor.fromAHSV(1.0, hsv.hue, (hsv.saturation * 0.95).clamp(0.0, 1.0), 0.75).toColor(),
      accent: color,
      shadowWarm: HSVColor.fromAHSV(1.0, hsv.hue, 0.85, 0.18).toColor(),
      surfaceSubtle: const Color(0xFF222224),
    );
  }
}

/// Main Tracker Screen
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Global key for the Scaffold to control the side panel drawer safely
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Constant Design Tokens
  static const Color cellInactive = Color(0xFF17171A); // Darker inactive date cells
  static const Color textPrimary = Color(0xFFFFFFFF); // White text
  static const Color textSecondary = Color(0xFF8E8E93); // Crisp legible numbers on darker cells
  static const Color textBrightened = Color(0xFFB5B5BE); // Day Streak caption

  // Curated Preset Swatches
  static const List<Color> habitColorPresets = [
    Color(0xFFFF7A00), // Solar Orange
    Color(0xFF00D672), // Emerald Mint
    Color(0xFF0088FF), // Electric Blue
    Color(0xFFA855F7), // Amethyst Violet
    Color(0xFFFFB800), // Warm Amber
    Color(0xFFFF3B5C), // Rose Coral
  ];

  late PageController _pageController;
  int _activeHabitIndex = 0;
  bool _isIntensityOverlayOpen = false;
  String _targetLogDateKey = '';
  String _targetLogDateDisplay = '';

  // Active Habit List (Initialized with 3 sample habits in distinct colors)
  late List<HabitItem> _habits;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // 3 Sample Habits in Vibrant Theme Colors
    _habits = [
      // 1. Chanting (Solar Orange)
      HabitItem(
        id: '1',
        name: 'Chanting',
        color: const Color(0xFFFF7A00),
        activeDays: 13,
        maxStreak: 5,
        isLoggedToday: false,
        isPaused: false,
        loggedDates: {
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
        },
      ),

      // 2. Deep Meditation (Emerald Mint)
      HabitItem(
        id: '2',
        name: 'Deep Meditation',
        color: const Color(0xFF00D672),
        activeDays: 14,
        maxStreak: 14,
        isLoggedToday: false,
        isPaused: false,
        loggedDates: {
          '2026-10-11': 9,
          '2026-10-12': 8,
          '2026-10-13': 9,
          '2026-10-14': 8,
          '2026-10-15': 9,
          '2026-10-16': 9,
          '2026-10-17': 7,
          '2026-10-18': 8,
          '2026-10-19': 9,
          '2026-10-20': 9,
          '2026-10-21': 8,
          '2026-10-22': 9,
          '2026-10-23': 9,
          '2026-10-24': 10,
        },
      ),

      // 3. Cold Shower (Electric Blue)
      HabitItem(
        id: '3',
        name: 'Cold Shower',
        color: const Color(0xFF0088FF),
        activeDays: 9,
        maxStreak: 9,
        isLoggedToday: false,
        isPaused: false,
        loggedDates: {
          '2026-10-16': 8,
          '2026-10-17': 9,
          '2026-10-18': 8,
          '2026-10-19': 9,
          '2026-10-20': 8,
          '2026-10-21': 9,
          '2026-10-22': 7,
          '2026-10-23': 9,
          '2026-10-24': 9,
        },
      ),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _formatDateKey(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static int _calculateMaxStreak(Map<String, int> loggedDates) {
    if (loggedDates.isEmpty) return 0;
    final sortedDates = loggedDates.keys
        .map((k) {
          try {
            return DateTime.parse(k);
          } catch (_) {
            return null;
          }
        })
        .whereType<DateTime>()
        .toList()
      ..sort();
    if (sortedDates.isEmpty) return 0;

    int maxS = 1;
    int currentS = 1;
    for (int i = 1; i < sortedDates.length; i++) {
      final prev = sortedDates[i - 1];
      final curr = sortedDates[i];
      final diff = curr.difference(prev).inDays;
      if (diff == 1) {
        currentS++;
        if (currentS > maxS) maxS = currentS;
      } else if (diff == 0) {
        continue;
      } else {
        currentS = 1;
      }
    }
    return maxS;
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[(month - 1).clamp(0, 11)];
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[(weekday - 1).clamp(0, 6)];
  }

  DateTime get _currentISTTime {
    return DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30));
  }

  String get _currentISTDateKey {
    final now = _currentISTTime;
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String get _currentISTDateDisplay {
    final now = _currentISTTime;
    return '${_getDayName(now.weekday)}, ${now.day} ${_getMonthName(now.month)} ${now.year}';
  }

  /// Opens the in-tree tactile intensity logging overlay with blurred background and swipeable habit carousel
  void _openIntensityLogOverlay(int initialIndex, {String? targetDateKey, String? targetDateDisplay}) {
    if (_habits.isEmpty || initialIndex >= _habits.length) return;
    HapticFeedback.lightImpact();
    setState(() {
      _activeHabitIndex = initialIndex;
      _targetLogDateKey = targetDateKey ?? _currentISTDateKey;
      _targetLogDateDisplay = targetDateDisplay ?? _currentISTDateDisplay;
      _isIntensityOverlayOpen = true;
    });
  }

  void _closeIntensityLogOverlay() {
    setState(() {
      _isIntensityOverlayOpen = false;
    });
  }

  void _toggleLogToday(HabitItem habit) {
    _openIntensityLogOverlay(_activeHabitIndex);
  }

  void _deleteHabit(int index) {
    HapticFeedback.mediumImpact();
    setState(() {
      _habits.removeAt(index);
      if (_habits.isEmpty) {
        _activeHabitIndex = 0;
      } else if (_activeHabitIndex >= _habits.length) {
        _activeHabitIndex = _habits.length - 1;
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients) {
        _pageController.jumpToPage(_activeHabitIndex);
      }
    });
  }

  /// Delete confirmation dialog
  void _showDeleteConfirmation(int index, String name) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.65),
      builder: (ctx) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E24),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.10),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Delete Habit',
                      style: TextStyle(
                        fontFamily: '-apple-system',
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Are you sure you want to delete "$name"?',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: '-apple-system',
                        color: textSecondary,
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: textSecondary,
                              side: BorderSide(
                                color: Colors.white.withOpacity(0.12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              _deleteHabit(index);
                              Navigator.of(ctx).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFDC2626),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: const Text('Delete'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Sleek, artisanal Habit Options Action Sheet (invoked by '...')
  void _showHabitOptions(int index, HabitItem habit) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
              decoration: BoxDecoration(
                color: const Color(0xFF141417),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFF26262B), width: 1),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black87,
                    blurRadius: 36,
                    offset: Offset(0, 16),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Subtle top drag pill
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFF323238),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Habit Title Row with Color Bead
                  Row(
                    children: [
                      Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: habit.color,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: habit.color.withOpacity(0.4),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          habit.name,
                          style: const TextStyle(
                            fontFamily: '-apple-system',
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${habit.activeDays}d active',
                        style: const TextStyle(
                          fontFamily: '-apple-system',
                          color: Color(0xFF8E8E93),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),
                  Container(height: 0.8, color: const Color(0xFF202026)),
                  const SizedBox(height: 6),

                  // Action: Pause / Resume
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.of(sheetCtx).pop();
                        HapticFeedback.mediumImpact();
                        setState(() {
                          habit.isPaused = !habit.isPaused;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        child: Row(
                          children: [
                            Icon(
                              habit.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                              size: 20,
                              color: habit.isPaused ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    habit.isPaused ? 'Resume Habit' : 'Pause Habit',
                                    style: const TextStyle(
                                      fontFamily: '-apple-system',
                                      color: Color(0xFFEDEDED),
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    habit.isPaused
                                        ? 'Restore active streak tracking'
                                        : 'Freeze habit without losing streak',
                                    style: const TextStyle(
                                      fontFamily: '-apple-system',
                                      color: Color(0xFF71717A),
                                      fontSize: 12.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Action: Delete Habit
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.of(sheetCtx).pop();
                        _showDeleteConfirmation(index, habit.name);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.delete_outline_rounded,
                              size: 20,
                              color: Color(0xFFEF4444),
                            ),
                            SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Delete Habit',
                                    style: TextStyle(
                                      fontFamily: '-apple-system',
                                      color: Color(0xFFEF4444),
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Permanently delete habit and history',
                                    style: TextStyle(
                                      fontFamily: '-apple-system',
                                      color: Color(0xFF71717A),
                                      fontSize: 12.0,
                                    ),
                                  ),
                                ],
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
          ),
        );
      },
    );
  }

  /// Prompts confirmation dialog to pause or resume habit when tapping '...'
  void _showPausePrompt(HabitItem habit) {
    HapticFeedback.lightImpact();
    final isCurrentlyPaused = habit.isPaused;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.65),
      builder: (ctx) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E24),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.10),
                    width: 1,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black87,
                      blurRadius: 30,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isCurrentlyPaused
                            ? const Color(0xFF0F2618)
                            : const Color(0xFF2E1C0A),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCurrentlyPaused
                              ? const Color(0xFF10B981).withOpacity(0.4)
                              : const Color(0xFFF59E0B).withOpacity(0.4),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        isCurrentlyPaused
                            ? Icons.play_arrow_rounded
                            : Icons.pause_rounded,
                        color: isCurrentlyPaused
                            ? const Color(0xFF10B981)
                            : const Color(0xFFF59E0B),
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Title
                    Text(
                      isCurrentlyPaused ? 'Resume Habit' : 'Pause Habit',
                      style: const TextStyle(
                        fontFamily: '-apple-system',
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Body Prompt
                    Text(
                      isCurrentlyPaused
                          ? 'Are you sure you want to resume ${habit.name}?'
                          : 'Are you sure you want to pause this habit?',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: '-apple-system',
                        color: textSecondary,
                        fontSize: 13.5,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Actions: "No" & "Yes"
                    Row(
                      children: [
                        // "No" Button
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: textSecondary,
                              side: BorderSide(
                                color: Colors.white.withOpacity(0.12),
                                width: 1,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'No',
                              style: TextStyle(
                                fontFamily: '-apple-system',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // "Yes" Button
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              setState(() {
                                habit.isPaused = !habit.isPaused;
                              });
                              Navigator.of(ctx).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isCurrentlyPaused
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFF59E0B),
                              foregroundColor: const Color(0xFF141416),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Yes',
                              style: TextStyle(
                                fontFamily: '-apple-system',
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getGreetingPrefix() {
    final hour = _currentISTTime.hour;
    if (hour >= 4 && hour < 12) {
      return 'Good morning,';
    } else if (hour >= 12 && hour < 17) {
      return 'Good afternoon,';
    } else {
      return 'Good evening,';
    }
  }

  /// Opens the modern frosted glass Habit Creation Bottom Sheet with
  /// curated swatches AND an interactive 2D gradient custom color spectrum.
  void _showAddHabitSheet() {
    HapticFeedback.lightImpact();
    final textController = TextEditingController();
    Color selectedColor = habitColorPresets[0];
    bool showGradientPicker = false;

    // Gradient picker state
    double pickerHue = 190.0;
    double pickerSaturation = 0.9;
    double pickerValue = 0.95;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF18181C),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black87,
                      blurRadius: 36,
                      offset: Offset(0, -8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Handle Bar
                    Center(
                      child: Container(
                        width: 38,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFF383840),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Sheet Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'New Habit',
                          style: TextStyle(
                            fontFamily: '-apple-system',
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: textSecondary, size: 22),
                          onPressed: () => Navigator.of(context).pop(),
                          splashRadius: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Habit Name Input
                    const Text(
                      'Habit Name',
                      style: TextStyle(
                        fontFamily: '-apple-system',
                        color: textSecondary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: textController,
                      autofocus: true,
                      style: const TextStyle(
                        fontFamily: '-apple-system',
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      cursorColor: selectedColor,
                      decoration: InputDecoration(
                        hintText: 'e.g. Meditation, Workout, Reading',
                        hintStyle: TextStyle(
                          fontFamily: '-apple-system',
                          color: textSecondary.withOpacity(0.6),
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                        filled: true,
                        fillColor: const Color(0xFF222226),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: selectedColor, width: 1.5),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Theme Color Selector Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Theme Color',
                          style: TextStyle(
                            fontFamily: '-apple-system',
                            color: textSecondary,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            setSheetState(() {
                              showGradientPicker = !showGradientPicker;
                            });
                          },
                          child: Text(
                            showGradientPicker ? 'Hide Custom' : 'Custom Gradient',
                            style: TextStyle(
                              fontFamily: '-apple-system',
                              color: selectedColor,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Preset Swatches Row + 7th Rainbow Gradient Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ...habitColorPresets.map((color) {
                          final isSelected = color.value == selectedColor.value;
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setSheetState(() {
                                selectedColor = color;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? Colors.white : Colors.transparent,
                                  width: 2.5,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: color.withOpacity(0.65),
                                          blurRadius: 14,
                                          spreadRadius: 1,
                                        ),
                                      ]
                                    : [],
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                                  : null,
                            ),
                          );
                        }),

                        // 7th: Rainbow Gradient Custom Picker Swatch
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            setSheetState(() {
                              showGradientPicker = !showGradientPicker;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const SweepGradient(
                                colors: [
                                  Color(0xFFFF0055),
                                  Color(0xFFFF7A00),
                                  Color(0xFFFFD600),
                                  Color(0xFF00E676),
                                  Color(0xFF00B0FF),
                                  Color(0xFF7C4DFF),
                                  Color(0xFFFF0055),
                                ],
                              ),
                              border: Border.all(
                                color: showGradientPicker ? Colors.white : Colors.transparent,
                                width: 2.5,
                              ),
                              boxShadow: showGradientPicker
                                  ? [
                                      BoxShadow(
                                        color: selectedColor.withOpacity(0.6),
                                        blurRadius: 14,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Center(
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: showGradientPicker ? selectedColor : const Color(0xFF18181C),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  showGradientPicker ? Icons.check_rounded : Icons.colorize_rounded,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // =========================================================
                    // EXPANDABLE GRADIENT SPECTRUM COLOR PICKER
                    // =========================================================
                    if (showGradientPicker) ...[
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF202026),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.08),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 1. 2D Saturation / Value Gradient Box
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final boxWidth = constraints.maxWidth;
                                  const boxHeight = 110.0;
                                  final pureHueColor = HSVColor.fromAHSV(1.0, pickerHue, 1.0, 1.0).toColor();

                                  return GestureDetector(
                                    onPanDown: (details) {
                                      final localX = details.localPosition.dx.clamp(0.0, boxWidth);
                                      final localY = details.localPosition.dy.clamp(0.0, boxHeight);
                                      setSheetState(() {
                                        pickerSaturation = (localX / boxWidth).clamp(0.05, 1.0);
                                        pickerValue = (1.0 - (localY / boxHeight)).clamp(0.1, 1.0);
                                        selectedColor = HSVColor.fromAHSV(1.0, pickerHue, pickerSaturation, pickerValue).toColor();
                                      });
                                    },
                                    onPanUpdate: (details) {
                                      final localX = details.localPosition.dx.clamp(0.0, boxWidth);
                                      final localY = details.localPosition.dy.clamp(0.0, boxHeight);
                                      setSheetState(() {
                                        pickerSaturation = (localX / boxWidth).clamp(0.05, 1.0);
                                        pickerValue = (1.0 - (localY / boxHeight)).clamp(0.1, 1.0);
                                        selectedColor = HSVColor.fromAHSV(1.0, pickerHue, pickerSaturation, pickerValue).toColor();
                                      });
                                    },
                                    child: Container(
                                      height: boxHeight,
                                      width: boxWidth,
                                      decoration: BoxDecoration(
                                        color: pureHueColor,
                                      ),
                                      child: Stack(
                                        children: [
                                          Positioned.fill(
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.centerLeft,
                                                  end: Alignment.centerRight,
                                                  colors: [Colors.white, Colors.transparent],
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned.fill(
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [Colors.transparent, Colors.black],
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: (pickerSaturation * boxWidth) - 10,
                                            top: ((1.0 - pickerValue) * boxHeight) - 10,
                                            child: Container(
                                              width: 20,
                                              height: 20,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: selectedColor,
                                                border: Border.all(color: Colors.white, width: 2),
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color: Colors.black45,
                                                    blurRadius: 4,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                            const SizedBox(height: 12),

                            // 2. Continuous Rainbow Hue Spectrum Bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final barWidth = constraints.maxWidth;
                                  const barHeight = 22.0;

                                  return GestureDetector(
                                    onPanDown: (details) {
                                      final localX = details.localPosition.dx.clamp(0.0, barWidth);
                                      setSheetState(() {
                                        pickerHue = (localX / barWidth * 360.0).clamp(0.0, 360.0);
                                        selectedColor = HSVColor.fromAHSV(1.0, pickerHue, pickerSaturation, pickerValue).toColor();
                                      });
                                    },
                                    onPanUpdate: (details) {
                                      final localX = details.localPosition.dx.clamp(0.0, barWidth);
                                      setSheetState(() {
                                        pickerHue = (localX / barWidth * 360.0).clamp(0.0, 360.0);
                                        selectedColor = HSVColor.fromAHSV(1.0, pickerHue, pickerSaturation, pickerValue).toColor();
                                      });
                                    },
                                    child: Container(
                                      height: barHeight,
                                      width: barWidth,
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFFFF0000),
                                            Color(0xFFFF7A00),
                                            Color(0xFFFFFF00),
                                            Color(0xFF00FF00),
                                            Color(0xFF00FFFF),
                                            Color(0xFF0000FF),
                                            Color(0xFFFF00FF),
                                            Color(0xFFFF0000),
                                          ],
                                        ),
                                      ),
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            left: (pickerHue / 360.0 * barWidth) - 7,
                                            top: 1,
                                            bottom: 1,
                                            child: Container(
                                              width: 14,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(7),
                                                border: Border.all(color: Colors.black26, width: 1),
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color: Colors.black38,
                                                    blurRadius: 3,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Create Button
                    ElevatedButton(
                      onPressed: () {
                        final name = textController.text.trim();
                        if (name.isEmpty) return;

                        HapticFeedback.mediumImpact();
                        final newHabit = HabitItem(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: name,
                          color: selectedColor,
                          activeDays: 0,
                          maxStreak: 0,
                          isLoggedToday: false,
                          isPaused: false,
                          loggedDates: {},
                        );

                        setState(() {
                          _habits.add(newHabit);
                          _activeHabitIndex = _habits.length - 1;
                        });

                        Navigator.of(context).pop();

                        // Animate PageView to the new habit
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (_pageController.hasClients) {
                            _pageController.animateToPage(
                              _activeHabitIndex,
                              duration: const Duration(milliseconds: 320),
                              curve: Curves.easeOutCubic,
                            );
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedColor,
                        foregroundColor: const Color(0xFF141416),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Create Habit',
                        style: TextStyle(
                          fontFamily: '-apple-system',
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Builds the handcrafted, pure black Side Panel (Drawer) displaying a clean, minimal list of habits
  Widget _buildSidePanel(HabitThemeData currentTheme) {
    return Drawer(
      backgroundColor: const Color(0xFF000000), // Deep handcrafted pure black
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      width: 300,
      child: SafeArea(
        child: Builder(
          builder: (drawerCtx) {
            void closeDrawer() {
              if (Navigator.of(drawerCtx).canPop()) {
                Navigator.of(drawerCtx).pop();
              } else {
                _scaffoldKey.currentState?.closeDrawer();
              }
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Clean Handcrafted Masthead
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            const Text(
                              'Habits',
                              style: TextStyle(
                                fontFamily: '-apple-system',
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${_habits.length}',
                              style: const TextStyle(
                                fontFamily: '-apple-system',
                                color: Color(0xFF6E6E78),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Color(0xFF8E8E93), size: 19),
                          onPressed: closeDrawer,
                          splashRadius: 18,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          tooltip: 'Close',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),
                  Container(height: 0.5, color: const Color(0xFF1E1E22)),
                  const SizedBox(height: 8),

                  // Minimal List View (No bulky card boxes)
                  Expanded(
                    child: _habits.isEmpty
                        ? const Center(
                            child: Text(
                              'No habits yet',
                              style: TextStyle(
                                fontFamily: '-apple-system',
                                color: Color(0xFF6E6E78),
                                fontSize: 13.5,
                              ),
                            ),
                          )
                        : ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            itemCount: _habits.length,
                            separatorBuilder: (context, _) => const SizedBox(height: 4),
                            itemBuilder: (context, index) {
                              final habit = _habits[index];
                              final isCurrent = index == _activeHabitIndex;

                              return Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    closeDrawer();
                                    if (_pageController.hasClients) {
                                      _pageController.animateToPage(
                                        index,
                                        duration: const Duration(milliseconds: 320),
                                        curve: Curves.easeOutCubic,
                                      );
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: isCurrent ? const Color(0xFF121216) : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        // Artisanal Circular Pigment Bead (Replacing generic vertical AI bar)
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: isCurrent ? habit.color : habit.color.withOpacity(0.75),
                                            shape: BoxShape.circle,
                                            boxShadow: isCurrent
                                                ? [
                                                    BoxShadow(
                                                      color: habit.color.withOpacity(0.45),
                                                      blurRadius: 6,
                                                      spreadRadius: 0.5,
                                                    ),
                                                  ]
                                                : null,
                                          ),
                                        ),
                                        const SizedBox(width: 12),

                                        // Habit Name & Metadata (Active Days & Best Streak)
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      habit.name,
                                                      style: TextStyle(
                                                        fontFamily: '-apple-system',
                                                        color: isCurrent ? Colors.white : const Color(0xFFD4D4D8),
                                                        fontSize: 14.5,
                                                        fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                                                        letterSpacing: -0.2,
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  if (habit.isPaused) ...[
                                                    const SizedBox(width: 6),
                                                    const Text(
                                                      'paused',
                                                      style: TextStyle(
                                                        fontFamily: '-apple-system',
                                                        color: Color(0xFFD97706),
                                                        fontSize: 10.5,
                                                        fontStyle: FontStyle.italic,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                              const SizedBox(height: 2.5),
                                              Text.rich(
                                                TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: "${habit.activeDays}",
                                                      style: TextStyle(
                                                        fontFamily: '-apple-system',
                                                        color: habit.color,
                                                        fontSize: 12.0,
                                                        fontWeight: FontWeight.w700,
                                                        fontFeatures: const [FontFeature.tabularFigures()],
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text: " active ${habit.activeDays == 1 ? 'day' : 'days'} · best ",
                                                      style: const TextStyle(
                                                        fontFamily: '-apple-system',
                                                        color: Color(0xFF71717A),
                                                        fontSize: 12.0,
                                                        fontWeight: FontWeight.w400,
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text: "${habit.maxStreak}d",
                                                      style: TextStyle(
                                                        fontFamily: '-apple-system',
                                                        color: habit.color,
                                                        fontSize: 12.0,
                                                        fontWeight: FontWeight.w700,
                                                        fontFeatures: const [FontFeature.tabularFigures()],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Handcrafted borderless three dots (...) options trigger
                                        IconButton(
                                          icon: const Icon(
                                            Icons.more_horiz_rounded,
                                            color: Color(0xFF5E5E68),
                                            size: 19,
                                          ),
                                          tooltip: 'Options',
                                          splashRadius: 16,
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                          onPressed: () => _showHabitOptions(index, habit),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),

                  const SizedBox(height: 8),
                  Container(height: 0.5, color: const Color(0xFF1E1E22)),
                  const SizedBox(height: 8),

                  // Handcrafted '+ New Habit' Row
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        closeDrawer();
                        _showAddHabitSheet();
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                        child: Row(
                          children: const [
                            Icon(Icons.add_rounded, size: 19, color: Color(0xFFA1A1AA)),
                            SizedBox(width: 10),
                            Text(
                              'New Habit',
                              style: TextStyle(
                                fontFamily: '-apple-system',
                                color: Color(0xFFA1A1AA),
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // When on the final page index (which is _habits.length), or when _habits is empty,
    // currentHabit is null, triggering the Moonlight Graphite Empty State Theme!
    final bool isOnEndEmptyPage = _habits.isEmpty || _activeHabitIndex == _habits.length;
    final HabitItem? currentHabit = isOnEndEmptyPage ? null : _habits[_activeHabitIndex];
    final HabitThemeData currentTheme = HabitThemeData.forColor(currentHabit?.color);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: currentTheme.scaffoldBg,
      drawer: _buildSidePanel(currentTheme),
      body: Stack(
        children: [
          // ===================================================================
          // 1. DYNAMIC PROCEDURAL BACKGROUND (Smoothly morphs with theme)
          // ===================================================================
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    currentTheme.baseTop,
                    const Color(0xFF191514),
                    currentTheme.baseCenter,
                    const Color(0xFF151516),
                    currentTheme.baseBottom,
                  ],
                  stops: const [0.0, 0.22, 0.50, 0.78, 1.0],
                ),
              ),
            ),
          ),

          // Layer A: Mid-left ambient depth
          Positioned(
            top: 260,
            left: -130,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    currentTheme.richGlow.withOpacity(0.24),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),

          // Layer B: Top-Left subtle corner accent
          Positioned(
            top: -90,
            left: -90,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              width: 310,
              height: 310,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    currentTheme.richGlow.withOpacity(0.40),
                    currentTheme.richGlow.withOpacity(0.12),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.50, 1.0],
                ),
              ),
            ),
          ),

          // Layer C: Top-Right Wide Ambient Halo
          Positioned(
            top: -140,
            right: -120,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    currentTheme.richGlow.withOpacity(0.55),
                    currentTheme.richGlow.withOpacity(0.24),
                    const Color(0xFF381403).withOpacity(0.06),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.40, 0.70, 1.0],
                ),
              ),
            ),
          ),

          // Layer D: Top-Right Concentrated Radiant Core (3D volumetric depth)
          Positioned(
            top: -50,
            right: -40,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    currentTheme.glowCore.withOpacity(0.42),
                    currentTheme.richGlow.withOpacity(0.18),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),

          // Layer E: Bottom-Right Wide Ambient Halo
          Positioned(
            bottom: -150,
            right: -110,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              width: 480,
              height: 480,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    currentTheme.richGlow.withOpacity(0.65),
                    currentTheme.richGlow.withOpacity(0.30),
                    const Color(0xFF381403).withOpacity(0.08),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.40, 0.70, 1.0],
                ),
              ),
            ),
          ),

          // Layer F: Bottom-Right Concentrated Radiant Core (3D volumetric depth)
          Positioned(
            bottom: -60,
            right: -30,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    currentTheme.glowCore.withOpacity(0.48),
                    currentTheme.richGlow.withOpacity(0.20),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),

          // High 85px Gaussian blur filter to blend seamlessly
          Positioned.fill(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 85, sigmaY: 85),
              child: const SizedBox.expand(),
            ),
          ),

          // ===================================================================
          // 2. FOREGROUND UI (Pinned Header + PageView Carousel)
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

                      // -------------------------------------------------------
                      // PINNED HEADER: [Menu] Habitually... ───────────── [+]
                      //                       Good evening, Legend!
                      // -------------------------------------------------------
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left: Minimalist Two-Line Menu Icon (Cap-height aligned)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0, right: 14.0),
                            child: Builder(
                              builder: (menuCtx) {
                                return GestureDetector(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    try {
                                      Scaffold.of(menuCtx).openDrawer();
                                    } catch (_) {
                                      _scaffoldKey.currentState?.openDrawer();
                                    }
                                  },
                                  behavior: HitTestBehavior.opaque,
                                  child: Container(
                                    width: 28,
                                    height: 24,
                                    alignment: Alignment.centerLeft,
                                    color: Colors.transparent,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Top line (longer)
                                        Container(
                                          width: 20,
                                          height: 2.2,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                        ),
                                        const SizedBox(height: 5.5),
                                        // Bottom line (shorter)
                                        Container(
                                          width: 13,
                                          height: 2.2,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.75),
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          // Left-aligned: Refined Brand & Greeting Column
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontFamily: '-apple-system',
                                      fontSize: 21.0,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.5,
                                      height: 1.15,
                                    ),
                                    children: [
                                      const TextSpan(
                                        text: 'Habit',
                                        style: TextStyle(color: textPrimary),
                                      ),
                                      TextSpan(
                                        text: 'ually...',
                                        style: TextStyle(color: currentTheme.accent),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 3.5),
                                RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      fontFamily: '-apple-system',
                                      fontSize: 13.5,
                                      height: 1.2,
                                      letterSpacing: -0.1,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: '${_getGreetingPrefix()} ',
                                        style: const TextStyle(
                                          color: textSecondary,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      const TextSpan(
                                        text: 'Legend',
                                        style: TextStyle(
                                          color: textPrimary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Right: Minimalist, Borderless, Box-less '+' Action Button (blends into bg)
                          Padding(
                            padding: const EdgeInsets.only(top: 0.0),
                            child: SizedBox(
                              width: 36,
                              height: 36,
                              child: GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  _showAddHabitSheet();
                                },
                                behavior: HitTestBehavior.opaque,
                                child: const Align(
                                  alignment: Alignment.topRight,
                                  child: Icon(
                                    Icons.add_rounded,
                                    color: Colors.white,
                                    size: 26,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // -------------------------------------------------------
                      // MAIN CONTENT: Swipeable PageView (Habits + End Empty Page)
                      // -------------------------------------------------------
                      Expanded(
                        child: _buildHabitsPageView(currentTheme),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ===================================================================
          // 3. IN-TREE INTENSITY LOGGING OVERLAY (Authentic Web Blur & Living Liquid Glass)
          // ===================================================================
          if (_isIntensityOverlayOpen)
            Positioned.fill(
              child: PopScope(
                canPop: false,
                onPopInvokedWithResult: (didPop, result) {
                  if (!didPop) _closeIntensityLogOverlay();
                },
                child: HabitIntensityLogOverlay(
                  habits: _habits,
                  initialIndex: _activeHabitIndex,
                  targetDateKey: _targetLogDateKey,
                  targetDateDisplay: _targetLogDateDisplay,
                  onClose: _closeIntensityLogOverlay,
                  onHabitSwiped: (newIndex) {
                    setState(() {
                      _activeHabitIndex = newIndex;
                    });
                    if (_pageController.hasClients) {
                      _pageController.jumpToPage(newIndex);
                    }
                  },
                  onLogSaved: (habit, intensity, note, dateKey) {
                    setState(() {
                      if (dateKey == _currentISTDateKey) {
                        habit.isLoggedToday = true;
                      }
                      habit.loggedDates[dateKey] = intensity;
                      if (note != null && note.isNotEmpty) {
                        habit.loggedNotes[dateKey] = note;
                      }
                      habit.activeDays = habit.loggedDates.length;
                      final currentMax = _calculateMaxStreak(habit.loggedDates);
                      if (currentMax > habit.maxStreak) {
                        habit.maxStreak = currentMax;
                      }
                    });
                  },
                  onLogRemoved: (habit, dateKey) {
                    setState(() {
                      habit.loggedDates.remove(dateKey);
                      habit.loggedNotes.remove(dateKey);
                      if (dateKey == _currentISTDateKey) {
                        habit.isLoggedToday = false;
                      }
                      habit.activeDays = habit.loggedDates.length;
                      habit.maxStreak = _calculateMaxStreak(habit.loggedDates);
                    });
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ===========================================================================
  // MULTI-HABIT PAGEVIEW (Habits + End Empty State Page)
  // ===========================================================================
  Widget _buildHabitsPageView(HabitThemeData theme) {
    // Total pages = number of habits + 1 (the final add / empty state page)
    final int totalPages = _habits.isEmpty ? 1 : _habits.length + 1;

    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: totalPages,
            onPageChanged: (index) {
              HapticFeedback.selectionClick();
              setState(() {
                _activeHabitIndex = index;
              });
            },
            itemBuilder: (context, index) {
              // If index is within habits, render that habit's full page
              if (index < _habits.length) {
                return _buildHabitPageContent(_habits[index], index);
              }
              // If index is at the end (or habits is empty), render the Empty State page
              return _buildEmptyState(theme);
            },
          ),
        ),

        // Discrete Page Indicator Dots
        if (totalPages > 1) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(totalPages, (dotIndex) {
              final isCurrent = dotIndex == _activeHabitIndex;
              final isEndDot = dotIndex == _habits.length;

              Color dotColor;
              if (isCurrent) {
                dotColor = isEndDot ? const Color(0xFFE5E5EA) : _habits[dotIndex].color;
              } else {
                dotColor = const Color(0xFF383840);
              }

              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isCurrent ? (isEndDot ? 12 : 18) : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: dotColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  // ===========================================================================
  // EMPTY STATE / ADD HABIT PAGE (Shown at 0 habits and at the end of all habits)
  // ===========================================================================
  Widget _buildEmptyState(HabitThemeData theme) {
    return Column(
      children: [
        const Spacer(flex: 1),

        // Hero Title: "Start a new habit today"
        const Text(
          'Start a new habit today',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: '-apple-system',
            color: textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _habits.isEmpty ? 'No active habits yet' : 'Add to your daily rituals',
          style: const TextStyle(
            fontFamily: '-apple-system',
            color: textSecondary,
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 28),

        // Elegant Tactile '+' Button with Soft Moonlight Halo
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _showAddHabitSheet,
            borderRadius: BorderRadius.circular(36),
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF202026),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.18),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.08),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_rounded,
                size: 38,
                color: Colors.white,
              ),
            ),
          ),
        ),

        const SizedBox(height: 14),

        const Text(
          'Tap to create your habit',
          style: TextStyle(
            fontFamily: '-apple-system',
            color: textSecondary,
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
          ),
        ),

        const Spacer(flex: 1),

        // Minimalist Clean Card with Organic Leaf/Seedling Icon & Grounded Message
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
          decoration: BoxDecoration(
            color: const Color(0xFF19191D),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.06),
              width: 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF26262E),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.eco_rounded,
                      size: 18,
                      color: Color(0xFFE5E5EA),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'A little goes a long way.',
                    style: TextStyle(
                      fontFamily: '-apple-system',
                      color: Color(0xFFE5E5EA),
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                "You don't have to change everything today. Just start with one habit.",
                style: TextStyle(
                  fontFamily: '-apple-system',
                  color: textSecondary,
                  fontSize: 13.0,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),

        const Spacer(flex: 2),
      ],
    );
  }

  /// Builds a single Habit page with its habit name, three dots menu with pause prompt,
  /// centered streak, Log Today button, pinned Mon-Sun bar, and dedicated scrolling calendar.
  Widget _buildHabitPageContent(HabitItem habit, int index) {
    final habitTheme = HabitThemeData.forColor(habit.color);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Habit Header & Streak
        Center(
          child: Column(
            children: [
              // Habit Name with simple Three Dots (...) menu button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    habit.name,
                    style: TextStyle(
                      fontFamily: '-apple-system',
                      color: habit.isPaused ? textSecondary : textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Three Dots (...) Menu Action Button - Minimalist & Borderless
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _showHabitOptions(_activeHabitIndex, habit);
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.more_horiz_rounded,
                            color: textSecondary,
                            size: 21,
                          ),
                          if (habit.isPaused) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: const Color(0xFF332008),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: const Color(0xFFD97706).withOpacity(0.5),
                                  width: 0.8,
                                ),
                              ),
                              child: const Text(
                                'Paused',
                                style: TextStyle(
                                  fontFamily: '-apple-system',
                                  color: Color(0xFFF59E0B),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),

              // Centered Hero Number: Active Days (accumulated consistency, not streak penalty)
              Text(
                '${habit.activeDays}',
                style: TextStyle(
                  fontFamily: '-apple-system',
                  color: habit.isPaused ? habit.color.withOpacity(0.55) : habit.color,
                  fontSize: 54,
                  height: 1.05,
                  fontWeight: FontWeight.w900,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 2),

              // Primary Label: Active Days
              const Text(
                'Active Days',
                style: TextStyle(
                  fontFamily: '-apple-system',
                  color: textBrightened,
                  fontSize: 13.0,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 4),

              // Small, Refined Longest Streak Metric (Streak count number matches hero color)
              Text.rich(
                TextSpan(
                  text: 'Longest streak · ',
                  style: const TextStyle(
                    fontFamily: '-apple-system',
                    color: textSecondary,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.1,
                  ),
                  children: [
                    TextSpan(
                      text: '${habit.maxStreak}',
                      style: TextStyle(
                        fontFamily: '-apple-system',
                        color: habit.color,
                        fontSize: 12.0,
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    TextSpan(
                      text: ' ${habit.maxStreak == 1 ? 'day' : 'days'}',
                      style: const TextStyle(
                        fontFamily: '-apple-system',
                        color: textSecondary,
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Log Today Button: Compact Pill
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _toggleLogToday(habit),
                  borderRadius: BorderRadius.circular(26),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32.0,
                      vertical: 12.0,
                    ),
                    decoration: BoxDecoration(
                      color: habit.isLoggedToday ? habitTheme.surfaceSubtle : habit.color,
                      borderRadius: BorderRadius.circular(26),
                      border: habit.isLoggedToday
                          ? Border.all(
                              color: habit.color.withOpacity(0.5),
                              width: 1.5,
                            )
                          : null,
                      boxShadow: habit.isLoggedToday
                          ? []
                          : [
                              BoxShadow(
                                color: habitTheme.shadowWarm.withOpacity(0.70),
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
                            color: habit.isLoggedToday ? habit.color : const Color(0xFF141416),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_rounded,
                            size: 13,
                            color: habit.isLoggedToday ? Colors.white : habit.color,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          habit.isLoggedToday ? 'Logged Today' : 'Log Today',
                          style: TextStyle(
                            fontFamily: '-apple-system',
                            color: habit.isLoggedToday ? textPrimary : const Color(0xFF141416),
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

        const SizedBox(height: 20),

        // Pinned Mon-Sun Weekday Bar (BOLD WHITE)
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

        // Dedicated Scrolling Months for this habit
        Expanded(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 80),
            children: [
              // October 2026
              _buildMonthHeader('October 2026'),
              const SizedBox(height: 6),
              _buildMonthGrid(DateTime(2026, 10, 1), habit),

              const SizedBox(height: 26),

              // November 2026
              _buildMonthHeader('November 2026'),
              const SizedBox(height: 6),
              _buildMonthGrid(DateTime(2026, 11, 1), habit),

              const SizedBox(height: 26),

              // December 2026
              _buildMonthHeader('December 2026'),
              const SizedBox(height: 6),
              _buildMonthGrid(DateTime(2026, 12, 1), habit),
            ],
          ),
        ),
      ],
    );
  }

  /// Month name header displayed cleanly between blocks of cells.
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

  /// 7-column calendar grid for a given month and habit.
  Widget _buildMonthGrid(DateTime monthDate, HabitItem habit) {
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

              // Lead days (empty transparent slots)
              if (cellIndex < emptyLeadSlots) {
                return const Expanded(
                  child: SizedBox(height: 38),
                );
              }

              // Trailing days
              if (dayNumber > daysInMonth) {
                return const Expanded(
                  child: SizedBox(height: 38),
                );
              }

              // Active month day
              final cellDate = DateTime(monthDate.year, monthDate.month, dayNumber);
              final cellKey = _formatDateKey(cellDate);
              final intensity = habit.loggedDates[cellKey];
              final isToday = cellKey == _currentISTDateKey;

              Color bgColor = cellInactive; // Inactive date cells #17171A (darker)
              Color textColor = textSecondary; // Inactive date numbers #8E8E93

              if (intensity != null) {
                final clampedIntensity = intensity > 5 ? (intensity / 2).round().clamp(1, 5) : intensity.clamp(1, 5);
                final double opacity = switch (clampedIntensity) {
                  5 => 1.00,
                  4 => 0.85,
                  3 => 0.70,
                  2 => 0.52,
                  _ => 0.38,
                };
                bgColor = habit.color.withOpacity(opacity);
                textColor = Colors.white; // White text on completed dates
              }

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _openIntensityLogOverlay(
                      _activeHabitIndex,
                      targetDateKey: cellKey,
                      targetDateDisplay: '${_getDayName(cellDate.weekday)}, $dayNumber ${_getMonthName(cellDate.month)} ${cellDate.year}',
                    );
                  },
                  behavior: HitTestBehavior.opaque,
                  child: _buildFlatCell(
                    day: dayNumber,
                    bgColor: bgColor,
                    textColor: textColor,
                    habitColor: habit.color,
                    isLogged: intensity != null,
                    isToday: isToday,
                  ),
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
  /// - Darker unfilled cells (#17171A)
  /// - Solid vibrant habit color completed
  Widget _buildFlatCell({
    required int day,
    required Color bgColor,
    required Color textColor,
    required Color habitColor,
    bool isLogged = false,
    bool isToday = false,
  }) {
    return Container(
      height: 38,
      margin: const EdgeInsets.symmetric(horizontal: 2.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Center(
        child: Text(
          '$day',
          style: TextStyle(
            fontFamily: '-apple-system',
            color: isToday && !isLogged ? habitColor : textColor,
            fontSize: 12,
            fontWeight: isLogged || isToday ? FontWeight.w700 : FontWeight.w500,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }
}
