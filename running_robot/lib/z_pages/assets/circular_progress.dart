// FILE: lib/ui/widgets/circular_progress_badge.dart
import 'package:flutter/material.dart';

class CircularProgressBadge extends StatelessWidget {
  final double progress; // 0.0–1.0
  final double size;
  final Color color;
  final Color backgroundColor;

  const CircularProgressBadge({
    super.key,
    required this.progress,
    this.size = 42,
    this.color = const Color.fromARGB(255, 255, 221, 0),
    this.backgroundColor = const Color.fromARGB(60, 255, 255, 255),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 4,
            valueColor: AlwaysStoppedAnimation(color),
            backgroundColor: backgroundColor,
          ),
          Text(
            "${(progress * 100).toInt()}%",
            style: TextStyle(
              fontSize: size * 0.28,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
