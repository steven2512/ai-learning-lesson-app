import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// BoxWithProgress — Same as SimpleBox, but with a top progress bar + % label.
class BoxWithProgress extends StatelessWidget {
  final String title;
  final String? description;
  final String buttonText;
  final IconData buttonIcon;
  final VoidCallback onPressed;
  final String imageAsset;

  final BoxDecoration decoration;
  final double maxTextWidth;
  final double imageAspectRatio;
  final EdgeInsets padding;
  final EdgeInsets imagePadding;
  final Color textColor;

  /// Progress (0–100)
  final int percent;

  /// Colors & sizing
  final Color progressColor;
  final Color trackColor;
  final double progressThickness;
  final EdgeInsets progressPadding;

  /// Control alignment of text column
  final double leftTextPadding;

  /// NEW: Fixed dimensions
  final double boxWidth;
  final double boxHeight;

  const BoxWithProgress({
    super.key,
    required this.title,
    this.description,
    required this.buttonText,
    required this.buttonIcon,
    required this.onPressed,
    required this.imageAsset,
    required this.decoration,
    this.maxTextWidth = 220,
    this.imageAspectRatio = 0.92,
    this.padding = const EdgeInsets.fromLTRB(20, 20, 10, 20),
    this.imagePadding = EdgeInsets.zero,
    this.textColor = Colors.white,
    required this.percent,
    this.progressColor = const Color.fromARGB(255, 242, 255, 0),
    this.trackColor = const Color.fromARGB(120, 255, 255, 255),
    this.progressThickness = 13,
    this.progressPadding = const EdgeInsets.fromLTRB(20, 20, 30, -3),
    this.leftTextPadding = 0,

    /// Defaults for fixed dimensions
    this.boxWidth = 390,
    this.boxHeight = 190,
  });

  @override
  Widget build(BuildContext context) {
    final int clamped = percent.clamp(0, 100);
    final double p = clamped / 100.0;

    final EdgeInsets contentPad = padding.copyWith(
      top: padding.top +
          progressPadding.top +
          progressThickness +
          progressPadding.bottom,
    );

    return Stack(
      children: [
        Container(
          width: boxWidth, // 👈 fixed width
          height: boxHeight, // 👈 fixed height
          padding: contentPad,
          decoration: decoration,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(left: leftTextPadding),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxTextWidth),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                          letterSpacing: 0.15,
                          height: 1.3,
                        ),
                      ),
                      if (description != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          description!,
                          style: GoogleFonts.lato(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w400,
                            color: textColor.withOpacity(0.72),
                            height: 1.3,
                            letterSpacing: 0.05,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: onPressed,
                        icon: Padding(
                          padding: const EdgeInsets.only(top: 1),
                          child: Text(
                            buttonText,
                            style: GoogleFonts.lato(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.1,
                              color: textColor,
                            ),
                          ),
                        ),
                        label: Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Transform.scale(
                            scaleX: 1.3,
                            child: Icon(buttonIcon, size: 18, color: textColor),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: textColor,
                          side: BorderSide(color: textColor, width: 1.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: imagePadding,
                  child: AspectRatio(
                    aspectRatio: imageAspectRatio,
                    child: Image.asset(imageAsset, fit: BoxFit.contain),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Progress bar
        Positioned(
          left: progressPadding.left,
          right: progressPadding.right,
          top: progressPadding.top,
          child: Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(progressThickness),
                  child: Stack(
                    children: [
                      Container(height: progressThickness, color: trackColor),
                      FractionallySizedBox(
                        widthFactor: p,
                        child: Container(
                          height: progressThickness,
                          color: progressColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                "$clamped%",
                style: GoogleFonts.lato(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
