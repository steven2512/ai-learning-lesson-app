import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// WeeklyStreak
/// - Top-left header: "8 days streak" with a flame image before the number
/// - Below: 7 flat tokens (Mon..Sun)
///   * done         -> fire icon
///   * missed       -> snowflake
///   * todayPending -> subtle gold dot (pulses)
enum StreakDayState { done, missed, todayPending }

class WeeklyStreak extends StatelessWidget {
  final int streakCount;
  final List<StreakDayState> states; // exactly 7
  final bool startOnMonday;

  const WeeklyStreak({
    super.key,
    required this.streakCount,
    required this.states,
    this.startOnMonday = true,
  });

  @override
  Widget build(BuildContext context) {
    assert(states.length == 7, 'states must have exactly 7 items');

    final days = startOnMonday
        ? const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
        : const ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return LayoutBuilder(
      builder: (context, c) {
        const double gap = 10;
        final double maxW = c.maxWidth;
        final double token = ((maxW - (gap * 6)) / 7).clamp(26, 36);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header: flame image + "8 Streak Days"
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 4),
                // hardcoded flame image (ensure it's listed in pubspec.yaml)
                Image.asset('assets/images/flame.png', width: 25, height: 25),
                const SizedBox(width: 6),
                // keep number and label baseline-aligned with each other
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$streakCount',
                      style: GoogleFonts.lato(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.0,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      streakCount == 1 ? 'Streak Day ' : 'Streak Days ',
                      style: GoogleFonts.lato(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.1,
                        color: const Color(0xFF6B7280), // slate-500
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ── 7 tokens
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (i) {
                return _DayToken(
                  label: days[i],
                  state: states[i],
                  size: token,
                );
              }),
            ),
          ],
        );
      },
    );
  }
}

class _DayToken extends StatelessWidget {
  final String label;
  final StreakDayState state;
  final double size;

  const _DayToken({
    required this.label,
    required this.state,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      child: Column(
        children: [
          // Flat, no border, soft shadow to lift from white
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000), // ~8% black
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
              ),
              if (state == StreakDayState.done)
                const Icon(Icons.local_fire_department_rounded,
                    size: 18, color: Color(0xFFF59E0B)) // gold fire
              else if (state == StreakDayState.missed)
                const Icon(Icons.ac_unit_rounded,
                    size: 18, color: Color(0xFF7C8AA6)) // slate snowflake
              else
                const _TodayPendingDot(size: 6.5), // subtle gold dot
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.lato(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.15,
              color: const Color(0xFF374151), // slate-700
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayPendingDot extends StatefulWidget {
  final double size;
  const _TodayPendingDot({required this.size});

  @override
  State<_TodayPendingDot> createState() => _TodayPendingDotState();
}

class _TodayPendingDotState extends State<_TodayPendingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        final s = 1.0 + (_c.value * 0.06);
        return Transform.scale(
          scale: s,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF5B301), // gold
            ),
          ),
        );
      },
    );
  }
}
