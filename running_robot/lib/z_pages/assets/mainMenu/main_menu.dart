/// FILE: lib/ui/main_menu.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/z_pages/assets/mainMenu/avatar.dart';
import 'package:running_robot/core/app_router.dart';
import 'package:running_robot/z_pages/assets/mainMenu/bell.dart';
import 'package:running_robot/z_pages/assets/mainMenu/box_with_progress.dart'; // 👈 use new class
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _buildBackground(),
          _buildAvatar(),
          _buildTextBox(),
          _buildMainContent(),
        ],
      ),
    );
  }

  Widget _buildBackground() => const Positioned.fill(
        child: ColoredBox(color: Colors.white),
      );

  Widget _buildAvatar() => Positioned(
        left: 19,
        top: 60,
        child: ProfileAvatar(
          size: 55,
          image: const AssetImage("assets/images/default_avatar.png"),
          imageScale: 1.2,
          onPressed: () => print("Avatar tapped!"),
          fillColor: const Color.fromARGB(255, 228, 228, 228),
        ),
      );

  Widget _buildTextBox() => Positioned(
        left: 86,
        right: 24,
        top: 67,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Good afternoon!",
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
                      height: 0.9,
                      letterSpacing: 0.1,
                    ),
                  ),
                  Text(
                    "Steven Duong",
                    style: GoogleFonts.lato(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.only(top: 3, right: 8),
              child: const Bell(),
            ),
          ],
        ),
      );

  Widget _buildMainContent() => Positioned(
        top: 140,
        left: 30,
        right: 30,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WeeklyStreak(
              streakCount: 8,
              states: const [
                StreakDayState.done,
                StreakDayState.done,
                StreakDayState.missed,
                StreakDayState.todayPending,
                StreakDayState.missed,
                StreakDayState.missed,
                StreakDayState.missed,
              ],
              startOnMonday: true,
            ),
            const SizedBox(height: 20),
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

            // ====== CARD 1: INTRO TO AI (now BoxWithProgress) ======
            BoxWithProgress(
              title: "Introduction to Artificial Intelligence",
              buttonText: "Continue Lesson",
              buttonIcon: Icons.arrow_forward_rounded,
              onPressed: () => widget.onNavigate(const RouteLesson(3)),
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
              percent: 66,
              maxTextWidth: 200, // 👈 new required field
            ),

            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.only(left: 2),
              child: Text(
                "Exercises",
                style: GoogleFonts.lato(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            const SizedBox(height: 5),

            SimpleBox(
              title: "Daily Challenges",
              description: "A curated 3-minute task to sharpen your instincts.",
              buttonText: "Start Challenge",
              buttonIcon: Icons.arrow_forward_rounded,
              onPressed: () => print("Open Daily Challenges"),
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
              textColor: onDarkText, // 👈 optional override
            ),
          ],
        ),
      );
}
