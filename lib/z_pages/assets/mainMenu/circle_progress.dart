import 'package:flutter/material.dart';

class CircleProgress extends StatelessWidget {
  final double percent; // 0.0 -> 1.0
  final double size;
  final double strokeWidth;
  final Color progressColor;
  final Color trackColor;
  final Widget center;
  final VoidCallback onTap;

  /// 👇 New: locked state
  final bool locked;

  const CircleProgress({
    super.key,
    required this.percent,
    required this.center,
    required this.onTap,
    this.size = 100,
    this.strokeWidth = 8,
    this.progressColor = Colors.green,
    this.trackColor = const Color(0xFFE5E7EB), // light gray
    this.locked = false,
  });

  @override
  Widget build(BuildContext context) {
    final double clamped = percent.clamp(0.0, 1.0);

    return GestureDetector(
      onTap: locked ? null : onTap, // disable tap if locked
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // background track
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                value: 1,
                strokeWidth: strokeWidth,
                valueColor: AlwaysStoppedAnimation<Color>(
                  locked ? Colors.grey.shade400 : trackColor,
                ),
              ),
            ),
            // foreground progress
            if (!locked)
              SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: clamped,
                  strokeWidth: strokeWidth,
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  backgroundColor: Colors.transparent,
                ),
              ),
            // center widget
            locked
                ? Icon(Icons.lock_rounded,
                    size: size * 0.35, color: Colors.grey.shade600)
                : center,
          ],
        ),
      ),
    );
  }
}
