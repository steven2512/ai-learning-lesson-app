// lib/ui/main_menu.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // ← ADDED
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
          _buildTextBox(), // ← Inserted here
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
      left: 86, // placed next to avatar
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
              height: 0.9, // ↓ tighter line height
            ),
          ),
          Text(
            "Steven Duong",
            style: GoogleFonts.lato(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.black, // ↓ tighter line height
            ),
          ),
        ],
      ),
    );
  }
}
