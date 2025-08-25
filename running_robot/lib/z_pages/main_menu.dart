/// FILE: lib/ui/main_menu.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/ui/buttons/avatar.dart';
import 'package:running_robot/core/app_router.dart'; // existing
import 'package:running_robot/z_pages/assets/progress_bar.dart';
import 'package:running_robot/z_pages/assets/simple_box.dart'; // NEW

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

  Widget _buildBackground() {
    return const Positioned.fill(
      child: ColoredBox(color: Colors.white),
    );
  }

  Widget _buildAvatar() {
    return Positioned(
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
  }

  Widget _buildTextBox() {
    return Positioned(
      left: 86,
      top: 67,
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
              letterSpacing: 0.1, // hardcoded tracking
            ),
          ),
          Text(
            "Steven Duong",
            style: GoogleFonts.lato(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.black,
              letterSpacing: 0.2, // hardcoded tracking
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Positioned(
      top: 140,
      left: 30,
      right: 30,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // // Scribble
          // Padding(
          //   padding: const EdgeInsets.only(left: 10),
          //   child: SvgPicture.asset(
          //     "assets/images/scribble_green.svg",
          //     height: 40,
          //     width: 1050, // hardcoded width thingy
          //     fit: BoxFit.fitWidth,
          //     alignment: Alignment.topLeft,
          //   ),
          // ),
          const SizedBox(height: 50),

          // Section title
          Padding(
            padding: const EdgeInsets.only(left: 2),
            child: Text(
              "Learning Hub",
              style: GoogleFonts.lato(
                fontSize: 25,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                letterSpacing: 0.2,
              ),
            ),
          ),
          const SizedBox(height: 5),

          // ================== CARD 1: INTRO TO AI (teal stays) ==================
          SimpleBox(
            title: """Introduction to Artificial Intelligence""",
            buttonText: "Continue Lesson",
            buttonIcon: Icons.arrow_forward_rounded,
            onPressed: () => widget.onNavigate(const RouteLesson1()),
            imageAsset: "assets/images/chat_bot_1.png",
            imageAspectRatio: 0.92,
            decoration: BoxDecoration(
              color: Colors.teal[700],
              borderRadius: BorderRadius.circular(25),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ================== MINI PROGRESS CARD (deep indigo gradient) ==================
          _buildMiniCourseProgressCard(),

          const SizedBox(height: 30),

          // Section title
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

          // ================== CARD 2: DAILY CHALLENGES (rust/amber gradient) ==================
          SimpleBox(
            title: "Daily Challenges",
            description: "A curated 3-minute task to sharpen your instincts.",
            buttonText: "Start Challenge",
            buttonIcon: Icons.arrow_forward_rounded,
            onPressed: () => print("Open Daily Challenges"),
            imageAsset: "assets/images/trophy_people.png",
            imageAspectRatio: 0.90,
            decoration: BoxDecoration(
              // 🎨 UPDATED: warm Rust → Amber gradient to avoid clashing with teal/indigo
              gradient: const LinearGradient(
                colors: [Color(0xFF2A1304), Color(0xFF9A3412)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniCourseProgressCard() {
    const double progress = 0.66;
    const int done = 8;
    const int total = 12;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        // 🎨 UPDATED: cool Deep Indigo gradient so it reads distinct from the teal hero
        gradient: const LinearGradient(
          colors: [Color(0xFF0B1220), Color(0xFF1E40AF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.white12, width: 0.6),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                "Chapter I",
                style: GoogleFonts.lato(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.15,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => print("View all lessons"),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white70,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  minimumSize: const Size(0, 0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "View all lessons",
                      style: GoogleFonts.lato(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.1,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward,
                      size: 18,
                      color: Colors.white70,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$done/$total",
                style: GoogleFonts.lato(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                  letterSpacing: 0.1,
                ),
              ),
              Text(
                "${(progress * 100).round()}%",
                style: GoogleFonts.lato(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white70,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Row(
            children: [
              SizedBox(width: 10),
              Expanded(child: ProgressBar(progress: progress)),
              SizedBox(width: 10),
            ],
          ),
        ],
      ),
    );
  }
}
