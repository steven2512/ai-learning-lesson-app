// FILE: lib/z_pages/main_menu_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/core/app_router.dart';
import 'package:running_robot/core/progression_scope.dart';
import 'package:running_robot/core/loading_skeleton.dart';
import 'package:running_robot/core/widgets.dart'; // ✅ use central screen size
import 'package:running_robot/services/app_progression_controller.dart';
import 'package:running_robot/z_pages/assets/mainMenu/box_with_progress.dart';
import 'package:running_robot/z_pages/assets/mainMenu/circle_progress.dart';
import 'package:running_robot/z_pages/assets/mainMenu/header_greeting.dart';
import 'package:running_robot/z_pages/assets/mainMenu/simple_box.dart';
import 'package:running_robot/z_pages/assets/mainMenu/weekly_streak.dart';

/// =========================
/// COLORS — edit here
/// =========================
const box1Color = Color(0xFF00796B); // original teal hero
const box2Color = Color.fromARGB(255, 47, 51, 73); // clean steel blue
const box3Color = Color.fromARGB(255, 192, 91, 91); // polished plum
const onDarkText = Colors.white; // White text on the dark cards
const bool showMiniGamesCard = false;

class MainMenuPage extends StatefulWidget {
  final void Function(AppRoute) onNavigate;

  const MainMenuPage({super.key, required this.onNavigate});

  @override
  State<MainMenuPage> createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {
  @override
  Widget build(BuildContext context) {
    final progression = ProgressionScope.watch(context);
    final showSkeleton = !progression.hasSnapshot;
    final currentLesson = progression.currentLessonMeta;
    final currentLessonNumber = progression.currentLessonNumber;
    final currentLessonId = currentLesson?.id;
    final lessonButtonText = currentLessonId == null
        ? 'Start Lesson'
        : progression.actionLabelForLesson(
            lessonId: currentLessonId,
            globalLessonNumber: currentLessonNumber,
          );
    final streakStates = buildWeeklyStreakStates(
      dailyStreak: progression.dailyStreak,
      lastDailyLessonDate: progression.lastDailyLessonDate,
    );

    // ✅ ScreenSize already initialized in MyApp.build
    final screenHeight = ScreenSize.height;
    // final pixelRatio = MediaQuery.of(context).devicePixelRatio;

    // // Print device info for debugging
    // debugPrint('📱 Screen size (dp): $screenWidth x ${screenHeight}');
    // debugPrint('🔍 Pixel ratio: $pixelRatio');
    // debugPrint('🖼️ Physical resolution: '
    //     '${(screenWidth * pixelRatio).toInt()} x ${(screenHeight * pixelRatio).toInt()} px');

    // 🔹 Proportional card heights
    final boxHeight1 = screenHeight * 0.23;
    final boxHeight2 = screenHeight * 0.20;
    // 🔹 Shared spacing values
    const sectionSpacing = 12.0;
    const streakSpacing = 20.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _buildBackground(),
          if (showSkeleton) const AppHeaderSkeleton() else const HeaderGreeting(),
          if (showSkeleton)
            _buildSkeletonContent(
              boxHeight1: boxHeight1,
              boxHeight2: boxHeight2,
              streakSpacing: streakSpacing,
            )
          else
            _buildMainContent(
              boxHeight1: boxHeight1,
              boxHeight2: boxHeight2,
              sectionSpacing: sectionSpacing,
              streakSpacing: streakSpacing,
              progression: progression,
              streakStates: streakStates,
              lessonButtonText: lessonButtonText,
              currentLessonTitle: currentLesson?.title ?? 'Introduction to AI',
              currentLessonNumber: currentLessonNumber,
            ),
        ],
      ),
    );
  }

  Widget _buildBackground() => const Positioned.fill(
        child: ColoredBox(color: Colors.white),
      );

  Widget _buildSkeletonContent({
    required double boxHeight1,
    required double boxHeight2,
    required double streakSpacing,
  }) =>
      Positioned(
        top: 130,
        left: 30,
        right: 30,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _WeeklyStreakSkeleton(),
            SizedBox(height: streakSpacing),
            Padding(
              padding: const EdgeInsets.only(left: 2),
              child: Text(
                "Learning Hub",
                style: GoogleFonts.lato(
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            const SizedBox(height: 5),
            _LessonCardSkeleton(height: boxHeight1),
            const SizedBox(height: 14),
            SizedBox(
              height: boxHeight2 * 1.02,
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _MetricRingCardSkeleton(
                      labelWidth: 82,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _MetricRingCardSkeleton(
                      labelWidth: 64,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildMainContent({
    required double boxHeight1,
    required double boxHeight2,
    required double sectionSpacing,
    required double streakSpacing,
    required AppProgressionController progression,
    required List<StreakDayState> streakStates,
    required String lessonButtonText,
    required String currentLessonTitle,
    required int currentLessonNumber,
  }) =>
      Positioned(
        top: 130,
        left: 30,
        right: 30,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WeeklyStreak(
              streakCount: progression.dailyStreak,
              states: streakStates,
              startOnMonday: true,
            ),
            SizedBox(height: streakSpacing),

            // === Learning Hub ===
            Padding(
              padding: const EdgeInsets.only(left: 2),
              child: Text(
                "Learning Hub",
                style: GoogleFonts.lato(
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            const SizedBox(height: 5),

            // ====== CARD 1: INTRO TO AI ======
            SizedBox(
              height: boxHeight1,
              child: BoxWithProgress(
                title: currentLessonTitle,
                description:
                    'Lesson $currentLessonNumber of ${progression.totalLessonCount}',
                buttonText: lessonButtonText,
                buttonIcon: Icons.arrow_forward_rounded,
                onPressed: () => widget.onNavigate(RouteLesson(
                  currentLessonNumber,
                )),
                imageAsset: "assets/images/chat_bot_1.png",
                imageAspectRatio: 0.92,
                decoration: BoxDecoration(
                  color: box1Color,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                textColor: onDarkText,
                percent: progression.courseProgressPercent,
                maxTextWidth: 200,
              ),
            ),
            SizedBox(height: sectionSpacing + 2),
            SizedBox(
              height: boxHeight2 * 1.02,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _MetricRingCard(
                      icon: Icons.menu_book_rounded,
                      label: 'Lessons',
                      ringColor: const Color(0xFF1CB0F6),
                      ringTrackColor: const Color(0xFFE8F1F7),
                      iconColor: const Color(0xFF0284C7),
                      progress: (progression.todayLessonCount / 3).clamp(0.0, 1.0),
                      center: _RingValue(
                        value: progression.todayLessonCount.toString(),
                        caption: 'today',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: const _MetricRingCard(
                      icon: Icons.auto_awesome_rounded,
                      label: 'Level',
                      ringColor: Color(0xFFF59E0B),
                      ringTrackColor: Color(0xFFFFF1D6),
                      iconColor: Color(0xFFF59E0B),
                      progress: 0.62,
                      center: _RingValue(
                        value: '5',
                        caption: 'lvl',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (showMiniGamesCard) ...[
              SizedBox(height: sectionSpacing),
              Padding(
                padding: const EdgeInsets.only(left: 2),
                child: Text(
                  "Exercises",
                  style: GoogleFonts.lato(
                    fontSize: 23,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              SizedBox(
                height: boxHeight2,
                child: SimpleBox(
                  title: "Mini Games (Coming Soon)",
                  description: "Shapren your AI knowledge",
                  buttonText: "Start Challenge",
                  buttonIcon: Icons.arrow_forward_rounded,
                  onPressed: () => debugPrint("Open Daily Challenges"),
                  imageAsset: "assets/images/trophy_people.png",
                  imageAspectRatio: 0.90,
                  decoration: BoxDecoration(
                    color: box3Color,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  textColor: onDarkText,
                ),
              ),
            ],
          ],
        ),
      );
}

class _WeeklyStreakSkeleton extends StatelessWidget {
  const _WeeklyStreakSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            LoadingSkeleton.circle(size: 25),
            SizedBox(width: 8),
            LoadingSkeleton(width: 118, height: 28),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            7,
            (_) => const SizedBox(
              width: 34,
              child: Column(
                children: [
                  LoadingSkeleton(width: 34, height: 34),
                  SizedBox(height: 6),
                  LoadingSkeleton(width: 24, height: 10),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LessonCardSkeleton extends StatelessWidget {
  final double height;

  const _LessonCardSkeleton({
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Stack(
        children: [
          const Positioned(
            left: 0,
            right: 34,
            top: 0,
            child: LoadingSkeleton(height: 13),
          ),
          const Positioned(
            right: 0,
            top: -1,
            child: LoadingSkeleton(width: 34, height: 14),
          ),
          const Positioned(
            left: 0,
            top: 46,
            child: LoadingSkeleton(width: 182, height: 26),
          ),
          const Positioned(
            left: 0,
            top: 82,
            child: LoadingSkeleton(width: 92, height: 14),
          ),
          const Positioned(
            left: 0,
            bottom: 0,
            child: LoadingSkeleton(width: 146, height: 48),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Column(
              children: const [
                LoadingSkeleton.circle(size: 72),
                SizedBox(height: 8),
                LoadingSkeleton(width: 64, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricRingCardSkeleton extends StatelessWidget {
  final double labelWidth;

  const _MetricRingCardSkeleton({
    required this.labelWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 1,
            offset: Offset(0, 1),
          ),
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          LoadingSkeleton(width: labelWidth, height: 30),
          const Spacer(),
          const _RingSkeleton(size: 100),
        ],
      ),
    );
  }
}

class _RingSkeleton extends StatelessWidget {
  final double size;

  const _RingSkeleton({
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFE8EDF3),
                width: 11,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x05000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LoadingSkeleton(width: 28, height: 28),
              SizedBox(height: 6),
              LoadingSkeleton(width: 30, height: 12),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricRingCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final double progress;
  final Color ringColor;
  final Color ringTrackColor;
  final Widget center;
  final Color iconColor;

  const _MetricRingCard({
    required this.icon,
    required this.label,
    required this.progress,
    required this.ringColor,
    required this.ringTrackColor,
    required this.center,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 1,
            offset: Offset(0, 1),
          ),
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 16.1,
                  color: iconColor,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: GoogleFonts.lato(
                    fontSize: 18.3,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.center,
            child: CircleProgress(
              percent: progress,
              size: 100,
              strokeWidth: 11,
              progressColor: ringColor,
              trackColor: ringTrackColor,
              onTap: () {},
              center: center,
            ),
          ),
        ],
      ),
    );
  }
}

class _RingValue extends StatelessWidget {
  final String value;
  final String caption;

  const _RingValue({
    required this.value,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: GoogleFonts.lato(
            fontSize: 28.7,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF0F172A),
            height: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          caption,
          style: GoogleFonts.lato(
            fontSize: 12.4,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }
}
