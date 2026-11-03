import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'main_screen.dart';

/// Tier metadata representing the 5 discrete intensity levels.
class IntensityTier {
  final int level;
  final String title;
  final String descriptor;

  const IntensityTier({
    required this.level,
    required this.title,
    required this.descriptor,
  });
}

const List<IntensityTier> kIntensityTiers = [
  IntensityTier(
    level: 5,
    title: 'Deep',
    descriptor: 'Long & fully focused',
  ),
  IntensityTier(
    level: 4,
    title: 'High',
    descriptor: 'Meaningful & steady',
  ),
  IntensityTier(
    level: 3,
    title: 'Moderate',
    descriptor: 'A good, solid session',
  ),
  IntensityTier(
    level: 2,
    title: 'Light',
    descriptor: 'Short but intentional',
  ),
  IntensityTier(
    level: 1,
    title: 'Minimal',
    descriptor: 'Just showed up',
  ),
];

/// A living, animated fluid liquid capsule that features an oscillating wave meniscus,
/// rising micro-bubbles, a specular light crest, and interactive drag/slosh physics.
class FluidLiquidCapsule extends StatefulWidget {
  final double width;
  final double height;
  final int level; // 1..5
  final Color color;
  final ValueChanged<int> onLevelChanged;

  const FluidLiquidCapsule({
    super.key,
    required this.width,
    required this.height,
    required this.level,
    required this.color,
    required this.onLevelChanged,
  });

  @override
  State<FluidLiquidCapsule> createState() => _FluidLiquidCapsuleState();
}

class _FluidLiquidCapsuleState extends State<FluidLiquidCapsule>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _surgeController;
  late Animation<double> _surgeAnimation;
  double _animatedHeightRatio = 0.6;

  @override
  void initState() {
    super.initState();
    _animatedHeightRatio = widget.level / 5.0;

    // Slow, meditative fluid breathing oscillation (luxury cadence)
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    )..repeat();

    // Smooth viscous surge damping (gentle fluid settling, no cartoon bounce)
    _surgeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _surgeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _surgeController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void didUpdateWidget(covariant FluidLiquidCapsule oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.level != widget.level) {
      _surgeController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    _surgeController.dispose();
    super.dispose();
  }

  void _handleVerticalPosition(double localY) {
    final clampedRatio = (1.0 - (localY / widget.height)).clamp(0.0, 1.0);
    final newLevel = (clampedRatio * 5).ceil().clamp(1, 5);
    if (newLevel != widget.level) {
      HapticFeedback.selectionClick();
      widget.onLevelChanged(newLevel);
    }
  }

  @override
  Widget build(BuildContext context) {
    final targetRatio = widget.level / 5.0;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragUpdate: (details) => _handleVerticalPosition(details.localPosition.dy),
      onTapDown: (details) => _handleVerticalPosition(details.localPosition.dy),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: _animatedHeightRatio, end: targetRatio),
        duration: const Duration(milliseconds: 460),
        curve: Curves.easeOutQuart,
        builder: (context, fillRatio, child) {
          return AnimatedBuilder(
            animation: Listenable.merge([_waveController, _surgeAnimation]),
            builder: (context, _) {
              return CustomPaint(
                size: Size(widget.width, widget.height),
                painter: _LiquidPainter(
                  fillRatio: fillRatio,
                  wavePhase: _waveController.value * 2 * pi,
                  surgeValue: _surgeAnimation.value,
                  color: widget.color,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Custom painter rendering a silky-smooth, luxury fluid meniscus inside smoked crystal glass
class _LiquidPainter extends CustomPainter {
  final double fillRatio; // 0.0 .. 1.0
  final double wavePhase;
  final double surgeValue;
  final Color color;

  _LiquidPainter({
    required this.fillRatio,
    required this.wavePhase,
    required this.surgeValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(size.width / 2));

    // 1. Outer smoked glass cylinder well
    final wellPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF14151C).withOpacity(0.88),
          const Color(0xFF0C0D12).withOpacity(0.92),
        ],
      ).createShader(rect)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rrect, wellPaint);

    // Save layer to clip all fluid geometry cleanly inside the glass capsule
    canvas.save();
    canvas.clipRRect(rrect);

    // 2. Liquid Surface Height & Gentle Organic Wave Calculations
    final liquidHeight = (size.height * fillRatio).clamp(8.0, size.height);
    final liquidBaseY = size.height - liquidHeight;

    // Whisper wave amplitude: ultra-subtle, organic (max ~1.8px) with viscous surge decay
    final surgeInertia = (1.0 - surgeValue).clamp(0.0, 1.0);
    final waveAmplitude = 1.1 + (surgeInertia * 0.9);

    final wavePath = Path();
    wavePath.moveTo(0, size.height);
    wavePath.lineTo(0, liquidBaseY);

    const steps = 40;
    for (int i = 0; i <= steps; i++) {
      final x = size.width * (i / steps);
      final normX = i / steps;

      // Natural meniscus: subtle surface tension lift at glass boundaries + dual harmonic breathing
      final edgeLift = (normX - 0.5) * (normX - 0.5) * 1.2;
      final harmonic = sin(wavePhase + (normX * pi)) * waveAmplitude +
          cos((wavePhase * 0.7) + (normX * 2 * pi)) * (waveAmplitude * 0.4);

      final y = (liquidBaseY - edgeLift + harmonic).clamp(0.0, size.height);
      wavePath.lineTo(x, y);
    }

    wavePath.lineTo(size.width, size.height);
    wavePath.close();

    // 3. Liquid Body Fill: Rich, deep volumetric shader
    final liquidShaderRect = Rect.fromLTWH(0, liquidBaseY - 4, size.width, liquidHeight + 8);
    final liquidGradient = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [
        color.withOpacity(0.85),
        color.withOpacity(0.98),
        Color.lerp(color, Colors.white, 0.20)!,
      ],
      stops: const [0.0, 0.65, 1.0],
    );

    final liquidPaint = Paint()
      ..shader = liquidGradient.createShader(liquidShaderRect)
      ..style = PaintingStyle.fill;

    canvas.drawPath(wavePath, liquidPaint);

    // 4. Subtle Volumetric Fluid Bloom (Internal depth light)
    final internalGlowPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment(0.0, ((liquidBaseY + (liquidHeight * 0.3)) / size.height * 2) - 1.0),
        radius: 0.65,
        colors: [
          color.withOpacity(0.35),
          Colors.transparent,
        ],
      ).createShader(rect)
      ..style = PaintingStyle.fill;
    canvas.drawPath(wavePath, internalGlowPaint);

    // 5. Specular Meniscus Light Ribbon (Soft, elegant light shimmer on fluid crest)
    final crestPath = Path();
    for (int i = 0; i <= steps; i++) {
      final x = size.width * (i / steps);
      final normX = i / steps;
      final edgeLift = (normX - 0.5) * (normX - 0.5) * 1.2;
      final harmonic = sin(wavePhase + (normX * pi)) * waveAmplitude +
          cos((wavePhase * 0.7) + (normX * 2 * pi)) * (waveAmplitude * 0.4);
      final y = (liquidBaseY - edgeLift + harmonic).clamp(0.0, size.height);

      if (i == 0) {
        crestPath.moveTo(x, y);
      } else {
        crestPath.lineTo(x, y);
      }
    }

    // Soft ambient glow behind meniscus
    final crestGlowPaint = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
    canvas.drawPath(crestPath, crestGlowPaint);

    // Crisp specular edge ribbon with tapered horizontal fade
    final crestPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.white.withOpacity(0.08),
          Colors.white.withOpacity(0.75),
          Colors.white.withOpacity(0.08),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, liquidBaseY - 2, size.width, 4))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(crestPath, crestPaint);

    // 6. Cylindrical Crystal Glare (Delicate vertical reflection along left edge)
    final glassGlareRect = Rect.fromLTWH(3.5, 6, size.width * 0.18, size.height - 12);
    final glassGlarePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.white.withOpacity(0.20),
          Colors.white.withOpacity(0.03),
          Colors.transparent,
        ],
      ).createShader(glassGlareRect)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(glassGlareRect, const Radius.circular(4)),
      glassGlarePaint,
    );

    canvas.restore(); // End clipping

    // 7. Outer Glass Rim Border (Minimal hairline border)
    final rimPaint = Paint()
      ..color = Colors.white.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(rrect, rimPaint);

    // 8. Soft, serene outer aura emanating from the liquid
    final bloomPaint = Paint()
      ..color = color.withOpacity(0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 8);
    canvas.drawRRect(rrect, bloomPaint);
  }

  @override
  bool shouldRepaint(covariant _LiquidPainter oldDelegate) {
    return oldDelegate.fillRatio != fillRatio ||
        oldDelegate.wavePhase != wavePhase ||
        oldDelegate.surgeValue != surgeValue ||
        oldDelegate.color != color;
  }
}

/// Dreamy, luminous frosted glass overlay for setting habit intensity.
/// Can be rendered as an in-tree overlay inside MainScreen's Stack or via showGeneralDialog.
class HabitIntensityLogOverlay extends StatefulWidget {
  final List<HabitItem> habits;
  final int initialIndex;
  final String targetDateKey; // 'YYYY-MM-DD'
  final String targetDateDisplay; // e.g. 'Sun, 1 Nov 2026'
  final VoidCallback? onClose;
  final void Function(int newIndex)? onHabitSwiped;
  final void Function(HabitItem habit, int intensity, String? note, String dateKey) onLogSaved;
  final void Function(HabitItem habit, String dateKey)? onLogRemoved;

  const HabitIntensityLogOverlay({
    super.key,
    required this.habits,
    this.initialIndex = 0,
    required this.targetDateKey,
    required this.targetDateDisplay,
    this.onClose,
    this.onHabitSwiped,
    required this.onLogSaved,
    this.onLogRemoved,
  });

  /// Static helper for route-based invocation
  static Future<void> show({
    required BuildContext context,
    required List<HabitItem> habits,
    int initialIndex = 0,
    required String targetDateKey,
    required String targetDateDisplay,
    void Function(int newIndex)? onHabitSwiped,
    required void Function(HabitItem habit, int intensity, String? note, String dateKey) onLogSaved,
    void Function(HabitItem habit, String dateKey)? onLogRemoved,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'IntensityLogOverlay',
      barrierColor: Colors.black.withOpacity(0.30),
      transitionDuration: const Duration(milliseconds: 280),
      transitionBuilder: (context, anim, secondaryAnim, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.94, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
      pageBuilder: (context, anim, secondaryAnim) {
        return HabitIntensityLogOverlay(
          habits: habits,
          initialIndex: initialIndex,
          targetDateKey: targetDateKey,
          targetDateDisplay: targetDateDisplay,
          onClose: () => Navigator.of(context).pop(),
          onHabitSwiped: onHabitSwiped,
          onLogSaved: onLogSaved,
          onLogRemoved: onLogRemoved,
        );
      },
    );
  }

  @override
  State<HabitIntensityLogOverlay> createState() => _HabitIntensityLogOverlayState();
}

class _HabitIntensityLogOverlayState extends State<HabitIntensityLogOverlay> {
  late PageController _pageController;
  late int _currentIndex;
  final Map<int, int> _selectedIntensities = {};
  final Map<int, String> _notes = {};

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.habits.length - 1);
    _pageController = PageController(initialPage: _currentIndex);

    // Seed initial intensities from existing logged data or default to Moderate (Level 3)
    for (int i = 0; i < widget.habits.length; i++) {
      final habit = widget.habits[i];
      if (habit.loggedDates.containsKey(widget.targetDateKey)) {
        final rawVal = habit.loggedDates[widget.targetDateKey]!;
        final level = rawVal > 5 ? (rawVal / 2).round().clamp(1, 5) : rawVal.clamp(1, 5);
        _selectedIntensities[i] = level;
      } else {
        _selectedIntensities[i] = 3;
      }
      if (habit.loggedNotes.containsKey(widget.targetDateKey)) {
        _notes[i] = habit.loggedNotes[widget.targetDateKey]!;
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    HapticFeedback.selectionClick();
    widget.onHabitSwiped?.call(index);
  }

  void _setIntensity(int habitIndex, int level) {
    if (_selectedIntensities[habitIndex] != level) {
      HapticFeedback.selectionClick();
      setState(() {
        _selectedIntensities[habitIndex] = level.clamp(1, 5);
      });
    }
  }

  void _dismiss() {
    if (widget.onClose != null) {
      widget.onClose!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  void _commitLog(int habitIndex) {
    HapticFeedback.mediumImpact();
    final habit = widget.habits[habitIndex];
    final intensity = _selectedIntensities[habitIndex] ?? 3;
    final note = _notes[habitIndex];

    widget.onLogSaved(habit, intensity, note, widget.targetDateKey);
    _dismiss();
  }

  void _removeLog(int habitIndex) {
    HapticFeedback.mediumImpact();
    final habit = widget.habits[habitIndex];
    widget.onLogRemoved?.call(habit, widget.targetDateKey);
    _dismiss();
  }

  void _showNoteDialog(int habitIndex) {
    final habit = widget.habits[habitIndex];
    final controller = TextEditingController(text: _notes[habitIndex] ?? '');

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (ctx) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: const Color(0xFF14141B),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white.withOpacity(0.12)),
                  boxShadow: const [
                    BoxShadow(color: Colors.black87, blurRadius: 30, offset: Offset(0, 10)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.edit_note_rounded, color: habit.color, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'Note for ${habit.name}',
                          style: const TextStyle(
                            fontFamily: '-apple-system',
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: controller,
                      maxLines: 3,
                      autofocus: true,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Add reflections, duration, or thoughts...',
                        hintStyle: const TextStyle(color: Color(0xFF6E6E78), fontSize: 13),
                        filled: true,
                        fillColor: const Color(0xFF0F0F14),
                        contentPadding: const EdgeInsets.all(12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: habit.color.withOpacity(0.6)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('Cancel', style: TextStyle(color: Color(0xFF8E8E93))),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: habit.color,
                            foregroundColor: const Color(0xFF0C0C0E),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            elevation: 0,
                          ),
                          onPressed: () {
                            setState(() {
                              _notes[habitIndex] = controller.text.trim();
                            });
                            Navigator.of(ctx).pop();
                          },
                          child: const Text('Save Note', style: TextStyle(fontWeight: FontWeight.w700)),
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

  @override
  Widget build(BuildContext context) {
    if (widget.habits.isEmpty) {
      return const SizedBox.shrink();
    }

    final currentHabit = widget.habits[_currentIndex];

    // High-performance authentic Gaussian blur canvas
    return BackdropFilter(
      filter: ui.ImageFilter.blur(sigmaX: 30, sigmaY: 30),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Translucent dark veil (allowing glowing background elements to diffuse naturally)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.38),
            ),
          ),

          // Luminous organic radial bloom emanating in the active habit's color
          Positioned(
            top: 100,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    currentHabit.color.withOpacity(0.24),
                    currentHabit.color.withOpacity(0.07),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main Interactive Foreground
          Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Column(
                children: [
                  // Swipeable Carousel containing the Frosted Glass Console for each habit
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: widget.habits.length,
                      onPageChanged: _onPageChanged,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final habit = widget.habits[index];
                        final intensity = _selectedIntensities[index] ?? 3;
                        final hasNote = (_notes[index] ?? '').isNotEmpty;

                        return Center(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 358),
                              child: _buildLogConsole(
                                habitIndex: index,
                                habit: habit,
                                currentIntensity: intensity,
                                hasNote: hasNote,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Bottom Habit Anchor with Title, Stats, and Swipe Navigation Dots
                  _buildBottomAnchor(currentHabit),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The Sculpted Frosted Glass Console (NO harsh black box - ethereal, translucent glass)
  Widget _buildLogConsole({
    required int habitIndex,
    required HabitItem habit,
    required int currentIntensity,
    required bool hasNote,
  }) {
    final activeTier = kIntensityTiers.firstWhere(
      (t) => t.level == currentIntensity,
      orElse: () => kIntensityTiers[2],
    );

    final bool isAlreadyLogged = habit.loggedDates.containsKey(widget.targetDateKey);
    final now = DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30));
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    final bool isToday = widget.targetDateKey == '$y-$m-$d';

    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF181822).withOpacity(0.68),
                const Color(0xFF101017).withOpacity(0.78),
              ],
            ),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: Colors.white.withOpacity(0.14),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.40),
                blurRadius: 36,
                offset: const Offset(0, 16),
              ),
              BoxShadow(
                color: habit.color.withOpacity(0.12),
                blurRadius: 28,
                spreadRadius: -4,
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Bar: Dismiss (✕) on Left, Centered Ritual Emblem with soft radiant bloom
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: _dismiss,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Color(0xFF8E8E93),
                        size: 18,
                      ),
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: habit.color.withOpacity(0.45),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.spa_rounded,
                      color: habit.color,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 32),
                ],
              ),

              const SizedBox(height: 8),

              // Title & Subtitle
              Text(
                isToday ? 'Log Today' : 'Log Practice',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: '-apple-system',
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                isToday
                    ? 'How intense was your practice today?'
                    : 'How intense was your practice?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: '-apple-system',
                  color: Color(0xFF8E8E93),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 18),

              // Central Intensity Console: Tooltip + Fluid Liquid Wave Capsule + Minimalist Tiers
              _buildIntensityConsole(
                habitIndex: habitIndex,
                habitColor: habit.color,
                currentIntensity: currentIntensity,
                activeTier: activeTier,
              ),

              const SizedBox(height: 18),

              // Secondary Controls: Date Pill & Note Pill
              Row(
                children: [
                  // Date Pill (Date alone, cleanly styled, zero useless dropdown arrows)
                  Expanded(
                    child: Container(
                      height: 46,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161620).withOpacity(0.60),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white.withOpacity(0.08)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 14, color: Color(0xFF8E8E93)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.targetDateDisplay,
                              style: const TextStyle(
                                fontFamily: '-apple-system',
                                color: Colors.white,
                                fontSize: 12.0,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Note Pill
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showNoteDialog(habitIndex),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        height: 46,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: hasNote
                              ? habit.color.withOpacity(0.15)
                              : const Color(0xFF161620).withOpacity(0.60),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: hasNote
                                ? habit.color.withOpacity(0.50)
                                : Colors.white.withOpacity(0.08),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit_note_rounded,
                              size: 17,
                              color: hasNote ? habit.color : const Color(0xFF8E8E93),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                hasNote ? (_notes[habitIndex] ?? 'Note Added') : 'Add a note',
                                style: TextStyle(
                                  fontFamily: '-apple-system',
                                  color: hasNote ? Colors.white : const Color(0xFF8E8E93),
                                  fontSize: 12.0,
                                  fontWeight: hasNote ? FontWeight.w600 : FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Primary CTA Button: [ ✓ Log Intensity ] / [ ✓ Update Intensity ]
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _commitLog(habitIndex),
                  borderRadius: BorderRadius.circular(26),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 48,
                    decoration: BoxDecoration(
                      color: habit.color,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: habit.color.withOpacity(0.40),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF0C0C0E),
                          size: 19,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isToday
                              ? (isAlreadyLogged ? 'Update Today' : 'Log Today')
                              : (isAlreadyLogged ? 'Update Day' : 'Log Day'),
                          style: const TextStyle(
                            fontFamily: '-apple-system',
                            color: Color(0xFF0C0C0E),
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

              // Remove Marking Button (Displayed when this date has a recorded intensity)
              if (isAlreadyLogged) ...[
                const SizedBox(height: 8),
                Center(
                  child: TextButton.icon(
                    onPressed: () => _removeLog(habitIndex),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: const Icon(
                      Icons.remove_circle_outline_rounded,
                      size: 15,
                      color: Color(0xFFEF4444),
                    ),
                    label: const Text(
                      'Remove Marking for this Day',
                      style: TextStyle(
                        fontFamily: '-apple-system',
                        color: Color(0xFFEF4444),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Central console containing the floating tooltip, living fluid liquid wave capsule, and 5 tiers
  Widget _buildIntensityConsole({
    required int habitIndex,
    required Color habitColor,
    required int currentIntensity,
    required IntensityTier activeTier,
  }) {
    const double sliderHeight = 216.0;
    const double sliderWidth = 56.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left: Floating Tooltip with Arrow Pointer (Zero Overflows guaranteed)
        SizedBox(
          width: 72,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2A).withOpacity(0.75),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$currentIntensity',
                        style: TextStyle(
                          fontFamily: '-apple-system',
                          color: habitColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                      ),
                      Text(
                        activeTier.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: '-apple-system',
                          color: Color(0xFFD4D4D8),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 2),
                Icon(
                  Icons.play_arrow_rounded,
                  color: habitColor.withOpacity(0.85),
                  size: 13,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 10),

        // Center: LIVING FLUID LIQUID CAPSULE (Wave Meniscus, Bubbles & Slosh Physics)
        FluidLiquidCapsule(
          width: sliderWidth,
          height: sliderHeight,
          level: currentIntensity,
          color: habitColor,
          onLevelChanged: (newLevel) => _setIntensity(habitIndex, newLevel),
        ),

        const SizedBox(width: 14),

        // Right: 5 Discrete Tiers List (PURE TYPOGRAPHIC LUXURY - NO ICONS)
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: kIntensityTiers.map((tier) {
              final isSelected = tier.level == currentIntensity;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.5),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _setIntensity(habitIndex, tier.level),
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected ? habitColor.withOpacity(0.18) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? habitColor.withOpacity(0.42) : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            '${tier.level}',
                            style: TextStyle(
                              fontFamily: '-apple-system',
                              color: isSelected ? habitColor : const Color(0xFF71717A),
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tier.title,
                                  style: TextStyle(
                                    fontFamily: '-apple-system',
                                    color: isSelected ? Colors.white : const Color(0xFFD4D4D8),
                                    fontSize: 13.5,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  tier.descriptor,
                                  style: TextStyle(
                                    fontFamily: '-apple-system',
                                    color: isSelected ? const Color(0xFFA1A1AA) : const Color(0xFF6E6E78),
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w400,
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
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// Bottom Anchor displaying the Habit Name, Active Days, Best Streak, and Page Indicators
  Widget _buildBottomAnchor(HabitItem habit) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Habit Title with Navigation Arrows
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFF8E8E93), size: 14),
                onPressed: _currentIndex > 0
                    ? () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeOutCubic,
                        );
                      }
                    : null,
                splashRadius: 16,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 12),
              Text(
                habit.name,
                style: const TextStyle(
                  fontFamily: '-apple-system',
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF8E8E93), size: 14),
                onPressed: _currentIndex < widget.habits.length - 1
                    ? () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeOutCubic,
                        );
                      }
                    : null,
                splashRadius: 16,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 3),

          // Active Days & Streak Stat (Streak count number matches habit accent color)
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${habit.activeDays}',
                  style: TextStyle(
                    color: habit.color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: ' Active ${habit.activeDays == 1 ? 'Day' : 'Days'} · Best ',
                  style: const TextStyle(color: Color(0xFF8E8E93)),
                ),
                TextSpan(
                  text: '${habit.maxStreak}d',
                  style: TextStyle(
                    color: habit.color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            style: const TextStyle(
              fontFamily: '-apple-system',
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),

          // Page Indicator Dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.habits.length, (i) {
              final isCurrent = i == _currentIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isCurrent ? 14 : 5,
                height: 5,
                decoration: BoxDecoration(
                  color: isCurrent ? habit.color : Colors.white.withOpacity(0.20),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
          const SizedBox(height: 4),
          const Text(
            'Swipe left or right to log other habits',
            style: TextStyle(
              fontFamily: '-apple-system',
              color: Color(0xFF5E5E68),
              fontSize: 10.5,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
