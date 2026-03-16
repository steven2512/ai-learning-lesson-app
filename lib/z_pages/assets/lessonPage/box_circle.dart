// FILE: lib/z_pages/assets/lessonPage/boxWithCircle.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/z_pages/assets/mainMenu/circle_progress.dart';

class BoxWithCircle extends StatelessWidget {
  // Content
  final String title;
  final String? subtitle;
  final Color textColor;

  // Circle
  final double percent; // 0–1
  final bool locked;
  final Widget? center;
  final double circleSize;
  final double strokeWidth;
  final Color progressColor;
  final Color trackColor;

  // Card visuals
  final Color backgroundColor;
  final Gradient? backgroundGradient;
  final double radius;
  final EdgeInsets padding;
  final double gap;

  // Actions
  final VoidCallback onTap; // tap whole card
  final VoidCallback onGo; // right arrow button

  const BoxWithCircle({
    super.key,
    required this.title,
    required this.onTap,
    required this.onGo,
    this.subtitle,
    this.textColor = Colors.white,
    this.percent = 0,
    this.locked = false,
    this.center,
    this.circleSize = 68,
    this.strokeWidth = 8,
    this.progressColor = Colors.green,
    this.trackColor = const Color(0xFFE5E7EB),
    this.backgroundColor = Colors.black,
    this.backgroundGradient,
    this.radius = 16,
    this.padding = const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    this.gap = 16,
  });

  @override
  Widget build(BuildContext context) {
    final minH = circleSize + padding.vertical;

    final card = Container(
      constraints: BoxConstraints(minHeight: minH),
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundGradient == null ? backgroundColor : null,
        gradient: backgroundGradient,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [
          BoxShadow(
              color: Color(0x1F000000), blurRadius: 12, offset: Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: circleSize,
            height: circleSize,
            child: CircleProgress(
              percent: percent,
              size: circleSize,
              strokeWidth: strokeWidth,
              progressColor: progressColor,
              trackColor: trackColor,
              locked: locked,
              center: center ??
                  Icon(
                    locked ? Icons.lock_rounded : Icons.bolt_rounded,
                    size: circleSize * 0.45,
                    color: locked ? Colors.white70 : Colors.white,
                  ),
              onTap: locked ? () {} : onTap,
            ),
          ),
          SizedBox(width: gap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.lato(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: textColor.withOpacity(locked ? 0.7 : 1),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: GoogleFonts.lato(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textColor.withOpacity(0.8),
                      height: 1.2,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Opacity(
            opacity: locked ? 0.5 : 1,
            child: InkWell(
              onTap: locked ? null : onGo,
              customBorder: const CircleBorder(),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.18),
                  border: Border.all(color: Colors.white.withOpacity(0.35)),
                ),
                child: const Icon(Icons.arrow_forward_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: locked ? null : onTap,
        borderRadius: BorderRadius.circular(radius),
        child: card,
      ),
    );
  }
}
