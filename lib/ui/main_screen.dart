import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/habit_list_notifier.dart';
import '../database/database_helper.dart';
import '../models/habit.dart';
import 'habit_page.dart';

/// The root presentation screen hosting the habit PageView.
/// Strictly avoids generic AppBars or standard menus.
class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _seedSampleHabits() async {
    final sampleHabits = [
      Habit(
        name: 'Morning Meditation',
        colorCode: '#00E676', // Emerald
        createdAt: DateTime.now(),
      ),
      Habit(
        name: 'Deep Work Session',
        colorCode: '#7C4DFF', // Cyberpunk Purple
        createdAt: DateTime.now(),
      ),
      Habit(
        name: 'Evening Workout',
        colorCode: '#FF5252', // Crimson
        createdAt: DateTime.now(),
      ),
    ];

    for (final habit in sampleHabits) {
      await DatabaseHelper.instance.insertHabit(habit);
    }
    await ref.read(habitListProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final habitsAsync = ref.watch(habitListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0E1015),
      body: SafeArea(
        child: habitsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Colors.white38),
          ),
          error: (error, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'Database Error: $error',
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
          ),
          data: (habits) {
            if (habits.isEmpty) {
              return _buildEmptyState();
            }

            return Stack(
              children: [
                // Horizontal PageView for Swiping between Habits
                PageView.builder(
                  controller: _pageController,
                  itemCount: habits.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    return HabitPage(
                      habitState: habits[index],
                      allHabits: habits,
                      pageIndex: index,
                    );
                  },
                ),

                // Top Minimalist Page Indicator Pill
                Positioned(
                  top: 12,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(habits.length, (index) {
                      final isSelected = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        width: isSelected ? 20.0 : 6.0,
                        height: 5.0,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withOpacity(0.9)
                              : Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1B1D28),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white12),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white70,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'NO ACTIVE HABITS',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 18,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your SQLite habits table is currently empty.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white38, fontSize: 13),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: _seedSampleHabits,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF282C3F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'SEED SAMPLE HABITS (SQLITE)',
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
