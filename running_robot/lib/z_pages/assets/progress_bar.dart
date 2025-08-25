/// FILE: lib/ui/widgets/progress_bar.dart
import 'package:flutter/material.dart';

/// Slim rounded progress bar with a small thumb.
/// Usage: ProgressBar(progress: 0.66)
class ProgressBar extends StatelessWidget {
  final double progress; // 0.0 - 1.0

  const ProgressBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    const double height = 12;
    const double radius = 12;
    const double dot = 8;

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        double left = (w * progress.clamp(0.0, 1.0)) - (dot / 2);
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
                    color: const Color(0xFFFAC515), // warm yellow
                    borderRadius: BorderRadius.circular(radius),
                  ),
                ),
              ),
              // Thumb
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
