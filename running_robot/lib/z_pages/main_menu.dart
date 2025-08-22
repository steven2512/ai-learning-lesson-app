// lib/ui/main_menu.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/ui/buttons/avatar.dart';

/// MainMenuPage — plain StatefulWidget, white background.
class MainMenuPage extends StatefulWidget {
  const MainMenuPage({super.key});

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
  /// NEW — Main content with scribble + box
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
          SvgPicture.asset(
            "assets/images/scribble_green.svg",
            height: 45,
            width: 1050, // control horizontal length
            fit: BoxFit.fitWidth, // stretch across the width
            alignment: Alignment.topLeft,
          ),

          const SizedBox(height: 17),

          // ---- MAIN TEAL BOX ----
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
                        onPressed: () {
                          print("Continue Lesson tapped!");
                        },
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
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 0),

                // ---------------- RIGHT SIDE ----------------
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
        ],
      ),
    );
  }
}
