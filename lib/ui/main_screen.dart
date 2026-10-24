import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Presentation model for a habit in the tracker.
class HabitItem {
  final String id;
  String name;
  Color color;
  int streakCount;
  bool isLoggedToday;
  bool isPaused;
  Map<String, int> loggedDates; // 'YYYY-MM-DD' -> intensity

  HabitItem({
    required this.id,
    required this.name,
    required this.color,
    required this.streakCount,
    required this.isLoggedToday,
    this.isPaused = false,
    required this.loggedDates,
  });
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
        streakCount: 5,
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
        streakCount: 14,
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
        streakCount: 9,
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

  void _toggleLogToday(HabitItem habit) {
    HapticFeedback.mediumImpact();
    final todayKey = '2026-10-24';

    setState(() {
      habit.isLoggedToday = !habit.isLoggedToday;
      if (habit.isLoggedToday) {
        habit.streakCount += 1;
        habit.loggedDates[todayKey] = 9;
      } else {
        habit.streakCount = (habit.streakCount - 1).clamp(0, 9999);
        habit.loggedDates.remove(todayKey);
      }
    });
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
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning,';
    } else if (hour < 17) {
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
                          streakCount: 0,
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

  /// Builds the slide-out Side Panel (Drawer) displaying the full list of habits in their colors
  Widget _buildSidePanel(HabitThemeData currentTheme) {
    return Drawer(
      backgroundColor: const Color(0xFF141417),
      surfaceTintColor: Colors.transparent,
      elevation: 24,
      width: 310,
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Your Habits',
                            style: TextStyle(
                              fontFamily: '-apple-system',
                              color: textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_habits.length} habits active',
                            style: const TextStyle(
                              fontFamily: '-apple-system',
                              color: textSecondary,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: textSecondary, size: 22),
                        onPressed: closeDrawer,
                        splashRadius: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Habit Cards List
                  Expanded(
                    child: _habits.isEmpty
                        ? const Center(
                            child: Text(
                              'No habits yet',
                              style: TextStyle(
                                fontFamily: '-apple-system',
                                color: textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          )
                        : ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            itemCount: _habits.length,
                            separatorBuilder: (context, _) => const SizedBox(height: 10),
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
                                  borderRadius: BorderRadius.circular(16),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isCurrent
                                          ? const Color(0xFF222228)
                                          : const Color(0xFF1A1A1E),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isCurrent
                                            ? habit.color.withOpacity(0.55)
                                            : Colors.white.withOpacity(0.06),
                                        width: 1.2,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        // Color Pill
                                        Container(
                                          width: 10,
                                          height: 38,
                                          decoration: BoxDecoration(
                                            color: habit.color,
                                            borderRadius: BorderRadius.circular(5),
                                            boxShadow: [
                                              BoxShadow(
                                                color: habit.color.withOpacity(0.4),
                                                blurRadius: 8,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),

                                        // Name & Streak
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      habit.name,
                                                      style: const TextStyle(
                                                        fontFamily: '-apple-system',
                                                        color: textPrimary,
                                                        fontSize: 15.0,
                                                        fontWeight: FontWeight.w700,
                                                        letterSpacing: -0.2,
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  if (habit.isPaused) ...[
                                                    const SizedBox(width: 6),
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
                                              const SizedBox(height: 3),
                                              Text(
                                                '${habit.streakCount} day streak',
                                                style: TextStyle(
                                                  fontFamily: '-apple-system',
                                                  color: habit.color,
                                                  fontSize: 12.5,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Delete action button
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFF5E5E68), size: 18),
                                          tooltip: 'Delete habit',
                                          splashRadius: 18,
                                          onPressed: () => _showDeleteConfirmation(index, habit.name),
                                        ),

                                        // Active Indicator Dot
                                        if (isCurrent)
                                          Container(
                                            width: 7,
                                            height: 7,
                                            decoration: BoxDecoration(
                                              color: habit.color,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: habit.color.withOpacity(0.6),
                                                  blurRadius: 6,
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),

                  const SizedBox(height: 12),

                  // '+ Add New Habit' Button
                  ElevatedButton.icon(
                    onPressed: () {
                      closeDrawer();
                      _showAddHabitSheet();
                    },
                    icon: const Icon(Icons.add_rounded, size: 20),
                    label: const Text(
                      'Add New Habit',
                      style: TextStyle(
                        fontFamily: '-apple-system',
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF222228),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: Colors.white.withOpacity(0.12),
                          width: 1,
                        ),
                      ),
                      elevation: 0,
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
                      // PINNED HEADER: [Two-Line Menu Icon] + Brand & Greeting + [+]
                      // -------------------------------------------------------
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Borderless, Circle-less, Box-less Two-Line Menu Icon (blends seamlessly into bg)
                          Padding(
                            padding: const EdgeInsets.only(top: 0.0, right: 10.0),
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
                                    width: 38,
                                    height: 38,
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

                          // Brand & Greeting Column (Aligned directly beside the two lines)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      fontFamily: '-apple-system',
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.4,
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
                                const SizedBox(height: 8), // Shifted down a small unit
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
                          ),

                          // Top-Right '+' Action Button
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _showAddHabitSheet,
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF222226).withOpacity(0.8),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.12),
                                    width: 1.2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.add_rounded,
                                  color: Colors.white,
                                  size: 22,
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

                  // Three Dots (...) Menu Action Button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showPausePrompt(habit),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF222226).withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.08),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.more_horiz_rounded,
                              color: textSecondary,
                              size: 18,
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
                  ),
                ],
              ),
              const SizedBox(height: 2),

              // Centered Hero Number (NO cheap emojis)
              Text(
                '${habit.streakCount}',
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

              // Understated Label (Mixed Case 'Day Streak', NOT all caps)
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
              final isToday = cellKey == '2026-10-24';

              Color bgColor = cellInactive; // Inactive date cells #17171A (darker)
              Color textColor = textSecondary; // Inactive date numbers #8E8E93

              if (intensity != null) {
                bgColor = habit.color; // Dynamic habit accent
                textColor = Colors.white; // White text on completed dates
              }

              return Expanded(
                child: _buildFlatCell(
                  day: dayNumber,
                  bgColor: bgColor,
                  textColor: textColor,
                  habitColor: habit.color,
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
