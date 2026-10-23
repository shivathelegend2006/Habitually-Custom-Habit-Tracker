import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/habit_list_notifier.dart';
import 'intensity_slider.dart';

/// Full-screen blurred overlay enabling rapid swipe-based batch logging across all habits
/// without needing to navigate back and forth on the main screen.
class BatchLogOverlay extends ConsumerStatefulWidget {
  final List<HabitViewState> habits;
  final int initialIndex;

  const BatchLogOverlay({
    super.key,
    required this.habits,
    this.initialIndex = 0,
  });

  static Future<void> show(
    BuildContext context,
    List<HabitViewState> habits, {
    int initialIndex = 0,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'BatchLog',
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 250),
      transitionBuilder: (context, anim, secondaryAnim, child) {
        return FadeTransition(
          opacity: anim,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(
              CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        );
      },
      pageBuilder: (context, anim, secondaryAnim) {
        return BatchLogOverlay(
          habits: habits,
          initialIndex: initialIndex,
        );
      },
    );
  }

  @override
  ConsumerState<BatchLogOverlay> createState() => _BatchLogOverlayState();
}

class _BatchLogOverlayState extends ConsumerState<BatchLogOverlay> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(
      initialPage: widget.initialIndex,
      viewportFraction: 0.88,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Color _parseHexColor(String hex) {
    try {
      final buffer = StringBuffer();
      if (hex.length == 6 || hex.length == 7) buffer.write('ff');
      buffer.write(hex.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return const Color(0xFF4E95FF);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch latest state to update cards live upon logging
    final habitsAsync = ref.watch(habitListProvider);
    final activeHabits = habitsAsync.value ?? widget.habits;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // Top Bar with Close button and indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'QUICK LOG FLOW',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2.0,
                          ),
                        ),
                        Text(
                          'Swipe to switch habits (${_currentIndex + 1} of ${activeHabits.length})',
                          style: const TextStyle(color: Colors.white38, fontSize: 11),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 24),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // Page indicator dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(activeHabits.length, (index) {
                  final isSelected = index == _currentIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    width: isSelected ? 22 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.white24,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 32),

              // Swipeable Card Deck
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: activeHabits.length,
                  onPageChanged: (index) {
                    setState(() => _currentIndex = index);
                  },
                  itemBuilder: (context, index) {
                    final habitState = activeHabits[index];
                    final habitColor = _parseHexColor(habitState.habit.colorCode);
                    final isCompleted = habitState.isCompletedToday;
                    final initialIntensity = habitState.todayLog?.intensity ?? 5;

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161822).withOpacity(0.92),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: isCompleted
                              ? habitColor.withOpacity(0.6)
                              : Colors.white.withOpacity(0.08),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: isCompleted
                                  ? habitColor.withOpacity(0.2)
                                  : Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                                  color: isCompleted ? habitColor : Colors.white38,
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isCompleted ? 'LOGGED TODAY' : 'PENDING TODAY',
                                  style: TextStyle(
                                    color: isCompleted ? habitColor : Colors.white54,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Habit Title
                          Text(
                            habitState.habit.name.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Streak
                          Text(
                            '🔥 ${habitState.currentStreak} Day Streak',
                            style: TextStyle(
                              color: habitColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const Spacer(),

                          const Text(
                            'Drag slider to set intensity (1-10):',
                            style: TextStyle(color: Colors.white54, fontSize: 13),
                          ),
                          const SizedBox(height: 16),

                          // Intensity Slider
                          IntensitySlider(
                            initialValue: initialIntensity,
                            activeColor: habitColor,
                            onChanged: (val) {},
                            onCompleted: (val) async {
                              await ref
                                  .read(habitListProvider.notifier)
                                  .toggleDailyLog(habitState.habit.id!, val);

                              // Auto-advance to next habit if not the last one
                              if (index < activeHabits.length - 1) {
                                await Future.delayed(const Duration(milliseconds: 300));
                                if (mounted) {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.easeInOutCubic,
                                  );
                                }
                              }
                            },
                          ),

                          const Spacer(),
                          const Text(
                            'Release finger to save & auto-advance',
                            style: TextStyle(color: Colors.white24, fontSize: 11),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
