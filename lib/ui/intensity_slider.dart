import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A custom, haptic-enabled 1-10 discrete intensity slider.
class IntensitySlider extends StatefulWidget {
  final int initialValue;
  final Color activeColor;
  final ValueChanged<int> onChanged;
  final ValueChanged<int> onCompleted;

  const IntensitySlider({
    super.key,
    this.initialValue = 5,
    required this.activeColor,
    required this.onChanged,
    required this.onCompleted,
  });

  @override
  State<IntensitySlider> createState() => _IntensitySliderState();
}

class _IntensitySliderState extends State<IntensitySlider> {
  late double _currentValue;
  late int _lastHapticInt;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue.clamp(1, 10).toDouble();
    _lastHapticInt = _currentValue.round();
  }

  void _handleValueChange(double value) {
    setState(() {
      _currentValue = value;
    });

    final currentInt = value.round();
    if (currentInt != _lastHapticInt) {
      _lastHapticInt = currentInt;
      HapticFeedback.lightImpact();
      widget.onChanged(currentInt);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1D28),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: widget.activeColor.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Current intensity badge
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: widget.activeColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.activeColor.withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Text(
              '${_currentValue.round()}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Slider Track
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: widget.activeColor,
                inactiveTrackColor: Colors.white.withOpacity(0.12),
                trackHeight: 6.0,
                thumbColor: Colors.white,
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 10.0,
                  elevation: 4.0,
                ),
                overlayColor: widget.activeColor.withOpacity(0.2),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
                tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 2.0),
                activeTickMarkColor: Colors.white70,
                inactiveTickMarkColor: Colors.white24,
              ),
              child: Slider(
                value: _currentValue,
                min: 1.0,
                max: 10.0,
                divisions: 9, // Steps: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
                onChanged: _handleValueChange,
                onChangeEnd: (finalValue) {
                  HapticFeedback.mediumImpact();
                  widget.onCompleted(finalValue.round());
                },
              ),
            ),
          ),

          // Helper label
          Padding(
            padding: const EdgeInsets.only(right: 6.0),
            child: Text(
              '10',
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
