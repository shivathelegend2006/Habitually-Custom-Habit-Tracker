import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/habit_list_notifier.dart';
import 'intensity_slider.dart';
import 'heatmap_grid.dart';
import 'debug_hatch_sheet.dart';
import 'batch_log_overlay.dart';

/// Single Habit Page adhering strictly to the 30/70 vertical split.
class HabitPage extends ConsumerStatefulWidget {
  final HabitViewState habitState;
  final List<HabitViewState> allHabits;
  final int pageIndex;

  const HabitPage({
    super.key,
    required this.habitState,
    required this.allHabits,
    required this.pageIndex,
  });

  @override
  ConsumerState<HabitPage> createState() => _HabitPageState();
}

class _HabitPageState extends ConsumerState<HabitPage>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Color _parseHexColor(String hex) {
    try {
      final buffer = StringBuffer();
      if (hex.length == 6 || hex.length == 7) buffer.write('ff');
      buffer.write(hex.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return const Color(0xFF00E676);
    }
  }

  void _toggleExpansion() {
    HapticFeedback.selectionClick();
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
    });
  }

  Future<void> _handleSliderComplete(int intensity) async {
    final habitId = widget.habitState.habit.id!;

    // 1. Submit mutation to Riverpod SQLite notifier
    await ref.read(habitListProvider.notifier).toggleDailyLog(habitId, intensity);

    // 2. Collapse slider smoothly back to geometric checkbox
    if (mounted) {
      setState(() {
        _isExpanded = false;
        _animController.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final habitColor = _parseHexColor(widget.habitState.habit.colorCode);
    final isCompleted = widget.habitState.isCompletedToday;
    final currentStreak = widget.habitState.currentStreak;
    final initialIntensity = widget.habitState.todayLog?.intensity ?? 5;

    return Column(
      children: [
        // =====================================================================
        // TOP 30% : ACTION AREA (Flex 3)
        // =====================================================================
        Expanded(
          flex: 3,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Quick Batch Log Flow Pill Button
                GestureDetector(
                  onTap: () {
                    BatchLogOverlay.show(
                      context,
                      widget.allHabits,
                      initialIndex: widget.pageIndex,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.bolt, color: Colors.amber, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'FAST BATCH LOG',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Habit Name
                Text(
                  widget.habitState.habit.name.toUpperCase(),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.5,
                    shadows: [
                      Shadow(
                        color: habitColor.withOpacity(0.6),
                        blurRadius: 14,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),

                // Massive Streak Number (Hidden Debug Hatch on Long Press)
                GestureDetector(
                  onLongPress: () {
                    HapticFeedback.heavyImpact();
                    DebugHatchBottomSheet.show(context, widget.habitState.habit);
                  },
                  child: Column(
                    children: [
                      Text(
                        '$currentStreak',
                        style: TextStyle(
                          color: habitColor,
                          fontSize: 78,
                          height: 1.0,
                          fontWeight: FontWeight.w900,
                          fontFeatures: const [FontFeature.tabularFigures()],
                          shadows: [
                            BoxShadow(
                              color: habitColor.withOpacity(0.4),
                              blurRadius: 28,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.local_fire_department,
                              color: habitColor.withOpacity(0.8), size: 14),
                          const SizedBox(width: 4),
                          Text(
                            'DAY STREAK',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.45),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Geometric Checkbox <--> 1-10 Slider Animated Transition
                _buildExpandableAction(
                  habitColor: habitColor,
                  isCompleted: isCompleted,
                  initialIntensity: initialIntensity,
                ),
              ],
            ),
          ),
        ),

        // Subtle glowing divider
        Container(
          height: 1,
          margin: const EdgeInsets.symmetric(horizontal: 28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                habitColor.withOpacity(0.4),
                Colors.transparent,
              ],
            ),
          ),
        ),

        // =====================================================================
        // BOTTOM 70% : DATA CANVAS (Flex 7)
        // =====================================================================
        Expanded(
          flex: 7,
          child: HeatmapGrid(
            logs: widget.habitState.last30DaysLogs,
            activeColor: habitColor,
            numberOfWeeks: 16,
          ),
        ),
      ],
    );
  }

  /// Builds the geometric checkbox that expands into the custom 1-10 slider.
  Widget _buildExpandableAction({
    required Color habitColor,
    required bool isCompleted,
    required int initialIntensity,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    return AnimatedBuilder(
      animation: _expandAnimation,
      builder: (context, child) {
        // Morph width from 64px (checkbox) to 85% of screen width (slider)
        final currentWidth =
            Tween<double>(begin: 64.0, end: screenWidth * 0.88).evaluate(_expandAnimation);

        return SizedBox(
          width: currentWidth,
          height: 56.0,
          child: _isExpanded
              ? IntensitySlider(
                  initialValue: initialIntensity,
                  activeColor: habitColor,
                  onChanged: (val) {},
                  onCompleted: _handleSliderComplete,
                )
              : _buildGeometricCheckbox(
                  habitColor: habitColor,
                  isCompleted: isCompleted,
                  todayIntensity: widget.habitState.todayLog?.intensity,
                ),
        );
      },
    );
  }

  /// Custom geometric (diamond/squircle) checkbox
  Widget _buildGeometricCheckbox({
    required Color habitColor,
    required bool isCompleted,
    required int? todayIntensity,
  }) {
    return GestureDetector(
      onTap: _toggleExpansion,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: isCompleted ? habitColor : const Color(0xFF1B1D28),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isCompleted ? habitColor : Colors.white24,
            width: 2.0,
          ),
          boxShadow: isCompleted
              ? [
                  BoxShadow(
                    color: habitColor.withOpacity(0.5),
                    blurRadius: 14,
                    spreadRadius: 1,
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 6,
                  )
                ],
        ),
        child: Center(
          child: isCompleted
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_rounded, color: Colors.white, size: 24),
                    if (todayIntensity != null) ...[
                      const SizedBox(width: 2),
                      Text(
                        '$todayIntensity',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                )
              : const Icon(
                  Icons.add_rounded,
                  color: Colors.white70,
                  size: 28,
                ),
        ),
      ),
    );
  }
}
