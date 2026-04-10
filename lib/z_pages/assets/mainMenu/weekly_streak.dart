import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// WeeklyStreak
/// - Top-left header: "8 days streak" with a flame image before the number
/// - Below: 7 flat tokens (Mon..Sun)
///   * done         -> fire icon
///   * missed       -> snowflake
///   * todayPending -> subtle gold dot (pulses)
enum StreakDayState { done, missed, todayPending }

List<StreakDayState> buildWeeklyStreakStates({
  required Set<String> activeDateKeys,
  DateTime? now,
}) {
  final today = now ?? DateTime.now();
  final monday = today.subtract(Duration(days: today.weekday - 1));

  return List<StreakDayState>.generate(7, (index) {
    final date = monday.add(Duration(days: index));
    final key = _dateKey(date);
    final todayKey = _dateKey(today);

    if (activeDateKeys.contains(key)) {
      return StreakDayState.done;
    }
    if (key == todayKey) {
      return StreakDayState.todayPending;
    }
    return StreakDayState.missed;
  });
}

String _dateKey(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

class WeeklyStreak extends StatelessWidget {
  final int streakCount;
  final List<StreakDayState> states; // exactly 7
  final bool startOnMonday;
  final DateTime? now;

  const WeeklyStreak({
    super.key,
    required this.streakCount,
    required this.states,
    this.startOnMonday = true,
    this.now,
  });

  @override
  Widget build(BuildContext context) {
    assert(states.length == 7, 'states must have exactly 7 items');

    final days = startOnMonday
        ? const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
        : const ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final today = now ?? DateTime.now();
    final todayIndex = startOnMonday ? today.weekday - 1 : today.weekday % 7;

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
                  isToday: i == todayIndex,
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
  final bool isToday;

  const _DayToken({
    required this.label,
    required this.state,
    required this.size,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    final double newSize = size * 1.2; // bump up ~20% for bigger boxes

    return SizedBox(
      width: newSize,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              if (isToday)
                Container(
                  width: newSize + 8,
                  height: newSize + 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD84D).withValues(alpha: 0.28),
                        blurRadius: 12,
                        spreadRadius: 1.5,
                      ),
                    ],
                  ),
                ),
              Container(
                width: newSize,
                height: newSize,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: isToday
                      ? Border.all(
                          color: const Color(0xFFFFC72C),
                          width: 2.2,
                        )
                      : null,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
              ),
              if (state == StreakDayState.done)
                const Icon(Icons.bolt_rounded,
                    size: 26, color: Color(0xFF21C55D)) // green lightning
              else if (state == StreakDayState.missed)
                const Icon(Icons.ac_unit_rounded,
                    size: 26, color: Color(0xFF7C8AA6)) // snowflake
              else
                const Icon(Icons.bolt_rounded,
                    size: 26, color: Color(0xFFF5B301)), // gold lightning
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.lato(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.15,
              color: const Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }
}
