// lib/ui/main_menu.dart
import 'package:flutter/material.dart';
import 'package:running_robot/accessories/buttons/avatar.dart'; // <-- Your ProfileAvatar

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
          // Background
          const Positioned.fill(child: ColoredBox(color: Colors.white)),

          // Avatar at x=100, y=50
          Positioned(
            left: 18,
            top: 60,
            child: ProfileAvatar(
              size: 55,
              image: const AssetImage("assets/images/default_avatar.png"),
              onPressed: () {
                print("Avatar tapped!");
              },
              fillColor: const Color.fromARGB(255, 228, 228, 228),
            ),
          ),
        ],
      ),
    );
  }
}
