// FILE: lib/z_pages/main_menu_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/core/app_router.dart';
import 'package:running_robot/core/widgets.dart'; // ✅ use central screen size
import 'package:running_robot/z_pages/assets/mainMenu/box_with_progress.dart';
import 'package:running_robot/z_pages/assets/mainMenu/header_greeting.dart';
import 'package:running_robot/z_pages/assets/mainMenu/simple_box.dart';
import 'package:running_robot/z_pages/assets/mainMenu/weekly_streak.dart';

/// =========================
/// COLORS — edit here
/// =========================
const box1Color = Color(0xFF00796B); // Teal hero (unchanged)
const box2Color = Color.fromARGB(255, 47, 51, 73); // clean steel blue
const box3Color = Color.fromARGB(255, 192, 91, 91); // polished plum
const onDarkText = Colors.white; // White text on the dark cards

class MainMenuPage extends StatefulWidget {
  final void Function(AppRoute) onNavigate;

  const MainMenuPage({super.key, required this.onNavigate});

  @override
  State<MainMenuPage> createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {
  @override
  Widget build(BuildContext context) {
    // ✅ ScreenSize already initialized in MyApp.build
    final screenHeight = ScreenSize.height;
    final screenWidth = ScreenSize.width;
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
          const HeaderGreeting(),
          _buildMainContent(
            boxHeight1: boxHeight1,
            boxHeight2: boxHeight2,
            sectionSpacing: sectionSpacing,
            streakSpacing: streakSpacing,
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() => const Positioned.fill(
        child: ColoredBox(color: Colors.white),
      );

  Widget _buildMainContent({
    required double boxHeight1,
    required double boxHeight2,
    required double sectionSpacing,
    required double streakSpacing,
  }) =>
      Positioned(
        top: 130,
        left: 30,
        right: 30,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WeeklyStreak(
              streakCount: 1,
              states: const [
                StreakDayState.missed,
                StreakDayState.missed,
                StreakDayState.missed,
                StreakDayState.missed,
                StreakDayState.missed,
                StreakDayState.todayPending,
                StreakDayState.missed,
              ],
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
                title: "Introduction to Artificial Intelligence",
                buttonText: "Start Lesson",
                buttonIcon: Icons.arrow_forward_rounded,
                onPressed: () => widget.onNavigate(const RouteLesson(1)),
                imageAsset: "assets/images/chat_bot_1.png",
                imageAspectRatio: 0.92,
                decoration: BoxDecoration(
                  color: box1Color,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                textColor: onDarkText,
                percent: 0,
                maxTextWidth: 200,
              ),
            ),

            SizedBox(height: sectionSpacing),

            // === Exercises ===
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

            // ====== CARD 2: MINI GAMES ======
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
        ),
      );
}
