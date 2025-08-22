// lib/ui/main_menu.dart
import 'package:flutter/material.dart';

/// MainMenuPage — plain StatefulWidget, white background, empty content.
/// No FlameGame here.
class MainMenuPage extends StatefulWidget {
  const MainMenuPage({super.key});

  @override
  State<MainMenuPage> createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white, // requirement: white background
      body: SizedBox.shrink(), // "nothing in it"
    );
  }
}
