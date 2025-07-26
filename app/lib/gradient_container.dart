import 'package:flutter/material.dart';

class GradientContainer extends StatelessWidget {
  const GradientContainer({super.key});

  @override
  Widget build(BuildContext buildContext) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFEFF4FA), // Top
            Color.fromARGB(
              255,
              243,
              248,
              255,
            ), // Slightly deeper blue for bottom
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Text(
          'Welcome to The Future',
          style: TextStyle(
            color: Color(0xFF1F2933),
            fontSize: 28,
          ),
        ),
      ),
    );
  }
}
