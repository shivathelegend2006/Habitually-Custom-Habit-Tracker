import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/daily_log.dart';
import '../models/habit.dart';
import '../state/habit_list_notifier.dart';
import '../analytics/habit_analytics_engine.dart';

/// Modal bottom sheet debug hatch triggered by long-pressing the massive streak number.
class DebugHatchBottomSheet extends ConsumerStatefulWidget {
  final Habit habit;

  const DebugHatchBottomSheet({
    super.key,
    required this.habit,
  });

  static Future<void> show(BuildContext context, Habit habit) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF14161F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DebugHatchBottomSheet(habit: habit),
    );
  }

  @override
  ConsumerState<DebugHatchBottomSheet> createState() => _DebugHatchBottomSheetState();
}

class _DebugHatchBottomSheetState extends ConsumerState<DebugHatchBottomSheet> {
  late DateTime _selectedDate;
  double _intensity = 7;
  final TextEditingController _noteController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: _parseHexColor(widget.habit.colorCode),
              surface: const Color(0xFF1B1D28),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
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

  Future<void> _saveOverride() async {
    setState(() => _isSaving = true);
    final dateStr = HabitAnalyticsEngine.todayLogDate(_selectedDate);

    // Update in-memory state (bypassing SQLite for web design preview)
    await ref.read(habitListProvider.notifier).overrideLog(
          habitId: widget.habit.id!,
          logDate: dateStr,
          intensity: _intensity.round(),
          note: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
        );

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved override for $dateStr (Intensity: ${_intensity.round()})'),
          backgroundColor: Colors.green.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final habitColor = _parseHexColor(widget.habit.colorCode);
    final dateStr = HabitAnalyticsEngine.todayLogDate(_selectedDate);

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Row(
            children: [
              Icon(Icons.terminal, color: habitColor, size: 20),
              const SizedBox(width: 8),
              const Text(
                'DEBUG HATCH: MANUAL LOG OVERRIDE',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Target Habit: ${widget.habit.name}',
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 20),

          // Date Selector
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E212E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Date: $dateStr',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Icon(Icons.calendar_month, color: Colors.white70, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Intensity Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Override Intensity:',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Text(
                '${_intensity.round()} / 10',
                style: TextStyle(
                  color: habitColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Slider(
            value: _intensity,
            min: 1,
            max: 10,
            divisions: 9,
            activeColor: habitColor,
            inactiveColor: Colors.white12,
            onChanged: (v) => setState(() => _intensity = v),
          ),
          const SizedBox(height: 12),

          // Note input
          TextField(
            controller: _noteController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Optional debug note (e.g. sick day, make-up run)',
              hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
              filled: true,
              fillColor: const Color(0xFF1E212E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 24),

          // Action Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveOverride,
              style: ElevatedButton.styleFrom(
                backgroundColor: habitColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      'COMMIT OVERRIDE TO SQLITE',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
