// lib/ui/main_menu.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/ui/buttons/avatar.dart';
import 'package:running_robot/core/app_router.dart'; // ✅ needed for AppRoute

/// MainMenuPage — plain StatefulWidget, white background.
class MainMenuPage extends StatefulWidget {
  final void Function(AppRoute) onNavigate; // ✅ existing

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

  // -----------------------------
  // Extracted widgets
  // -----------------------------

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
            ),
          ),
          Text(
            "Steven Duong",
            style: GoogleFonts.lato(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  /// -----------------------------
  /// Main content with scribble + cards
  /// -----------------------------
  Widget _buildMainContent() {
    return Positioned(
      top: 140, // slightly below profile section
      left: 30,
      right: 30,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- SCRIBBLE IMAGE ----
          Container(
            padding: EdgeInsets.only(left: 10),
            child: SvgPicture.asset(
              "assets/images/scribble_green.svg",
              height: 40,
              width: 1050, // control horizontal length
              fit: BoxFit.fitWidth, // stretch across the width
              alignment: Alignment.topLeft,
            ),
          ),

          const SizedBox(height: 10),
          Container(
            padding: EdgeInsets.only(left: 2),
            child: Row(
              children: [
                Text(
                  "Learning Hub",
                  style: GoogleFonts.lato(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: const Color.fromARGB(255, 0, 0, 0),
                      letterSpacing: 0.2),
                ),
              ],
            ),
          ),
          SizedBox(height: 5),
          // ====== CARD 1: CONTINUE LESSON ======
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ---------------- LEFT SIDE ----------------
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 200),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Introduction to Artificial Intelligence",
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ---- TRANSPARENT OUTLINE BUTTON ----
                      OutlinedButton.icon(
                        onPressed: () =>
                            widget.onNavigate(const RouteLesson1()), // ✅ NAV
                        icon: const Text("Continue Lesson"),
                        label: Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Transform.scale(
                            scaleX: 1.3,
                            child: const Icon(
                              Icons.arrow_forward_rounded,
                              size: 18,
                            ),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side:
                              const BorderSide(color: Colors.white, width: 1.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          textStyle: GoogleFonts.lato(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ).copyWith(
                          overlayColor:
                              MaterialStateProperty.resolveWith<Color?>(
                            (states) {
                              if (states.contains(MaterialState.pressed)) {
                                return Colors.white.withOpacity(0.38);
                              }
                              if (states.contains(MaterialState.hovered)) {
                                return Colors.white.withOpacity(0.18);
                              }
                              if (states.contains(MaterialState.focused)) {
                                return Colors.white.withOpacity(0.22);
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 0),

                // ---------------- RIGHT SIDE ----------------
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 0.92, // keeps it square
                    child: Image.asset(
                      "assets/images/chat_bot_1.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
              height: 10), // spacing between the first and middle card

          // ====== CARD 1.5: COURSE PROGRESS (NEW) ======  ✅ NEW BLOCK
          _buildMiniCourseProgressCard(), // ✅ NEW

          const SizedBox(
              height: 20), // spacing between the middle and second card

          // ====== CARD 2: DAILY CHALLENGES (MATCH + DESCRIPTION RESTORED) ======
          Container(
            padding: EdgeInsets.only(left: 2),
            child: Row(
              children: [
                Text(
                  "Exercises",
                  style: GoogleFonts.lato(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: const Color.fromARGB(255, 0, 0, 0),
                      letterSpacing: 0.2),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color.fromARGB(255, 20, 15, 42), Color(0xFF1E293B)],
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ---------------- LEFT SIDE (same layout, with description) ----------------
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 200),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Daily Challenges",
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        // ✅ restored
                        "A curated 3-minute task to sharpen your instincts.",
                        style: GoogleFonts.lato(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w400,
                          color: Colors.white70,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () {
                          // TODO: hook to your route, e.g. widget.onNavigate(const RouteDailyChallenges());
                          print("Open Daily Challenges");
                        },
                        icon: const Text("Start Challenge"),
                        label: Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Transform.scale(
                            scaleX: 1.3,
                            child: const Icon(
                              Icons.arrow_forward_rounded,
                              size: 18,
                            ),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side:
                              const BorderSide(color: Colors.white, width: 1.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          textStyle: GoogleFonts.lato(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ).copyWith(
                          overlayColor:
                              MaterialStateProperty.resolveWith<Color?>(
                            (states) {
                              if (states.contains(MaterialState.pressed)) {
                                return Colors.white.withOpacity(0.38);
                              }
                              if (states.contains(MaterialState.hovered)) {
                                return Colors.white.withOpacity(0.18);
                              }
                              if (states.contains(MaterialState.focused)) {
                                return Colors.white.withOpacity(0.22);
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 0),

                // ---------------- RIGHT SIDE (same structure, new image) ----------------
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 0.90, // same as above
                    child: Image.asset(
                      "assets/images/trophy_people.png", // ✅ use illustration
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          ), // ====== END DAILY CHALLENGES ======
        ],
      ),
    );
  }

  // ====== NEW: Mini progress card widget ======  ✅ NEW
  Widget _buildMiniCourseProgressCard() {
    // Placeholder data — swap with real user data later.
    const double progress = 0.66; // 66%
    const int done = 8; // placeholder
    const int total = 12; // placeholder

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF111827), // slate-900 to match scheme
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
          // Header row: Title + transparent "View all lessons"
          Row(
            children: [
              Text(
                "Chapter I",
                style: GoogleFonts.lato(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              // 🔁 CHANGED: TextButton.icon -> TextButton + Row so icon appears AFTER the text
              TextButton(
                onPressed: () {
                  // TODO: hook to your route
                  print("View all lessons");
                },
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
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward, size: 18),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Numbers row (left: x/y, right: %)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$done/$total",
                style: GoogleFonts.lato(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
              Text(
                "${(progress * 100).round()}%",
                style: GoogleFonts.lato(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white70,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Progress bar with 10px space on each side  ✅ NEW
          Row(
            children: const [
              SizedBox(width: 10),
              Expanded(child: _ProgressBar(progress: progress)),
              SizedBox(width: 10),
            ],
          ),
        ],
      ),
    );
  }
}

// ====== NEW: Slim, rounded progress bar with a small thumb ======  ✅ NEW
class _ProgressBar extends StatelessWidget {
  final double progress; // 0.0 - 1.0

  const _ProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    const double height = 12;
    const double radius = 12;
    const double dot = 8;

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        double left = (w * progress) - (dot / 2);
        if (left < 0) left = 0;
        if (left > w - dot) left = w - dot;

        return SizedBox(
          height: height,
          child: Stack(
            children: [
              // Track
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF374151), // slate-700
                  borderRadius: BorderRadius.circular(radius),
                ),
              ),
              // Fill
              FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        const Color(0xFFFAC515), // warm yellow like screenshot
                    borderRadius: BorderRadius.circular(radius),
                  ),
                ),
              ),
              // Thumb dot
              Positioned(
                left: left,
                top: (height - dot) / 2,
                child: Container(
                  width: dot,
                  height: dot,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(dot / 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black38,
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
