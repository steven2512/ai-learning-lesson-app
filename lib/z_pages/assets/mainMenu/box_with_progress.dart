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
    this.boxHeight = 185,
  });

  @override
  Widget build(BuildContext context) {
    final int clamped = percent.clamp(0, 100);
    final double p = clamped / 100.0;
    const actionTextColor = Colors.white;

    final EdgeInsets contentPad = padding.copyWith(
      top: padding.top +
          progressPadding.top +
          progressThickness +
          progressPadding.bottom,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final resolvedWidth =
            constraints.hasBoundedWidth ? constraints.maxWidth : boxWidth;
        final resolvedHeight =
            constraints.hasBoundedHeight ? constraints.maxHeight : boxHeight;

        return Stack(
          children: [
            Container(
              width: resolvedWidth,
              height: resolvedHeight,
              padding: contentPad,
              decoration: decoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: EdgeInsets.only(left: leftTextPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: maxTextWidth),
                            child: Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.lato(
                                fontSize: 20.5,
                                fontWeight: FontWeight.w800,
                                color: textColor,
                                letterSpacing: 0.15,
                                height: 1.25,
                              ),
                            ),
                          ),
                          if (description != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              description!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.lato(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w400,
                                color: textColor.withValues(alpha: 0.72),
                                height: 1.25,
                                letterSpacing: 0.05,
                              ),
                            ),
                          ],
                          const Spacer(),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: onPressed,
                                borderRadius: BorderRadius.circular(30),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Color(0xFFF89A36),
                                        Color(0xFFE9771A),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: const Color(0xFFFFB85A),
                                      width: 1.1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFE9771A)
                                            .withValues(alpha: 0.34),
                                        blurRadius: 12,
                                        spreadRadius: 0.5,
                                        offset: const Offset(0, 4),
                                      ),
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.10),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                      horizontal: 19,
                                      vertical: 10,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          buttonText,
                                          style: GoogleFonts.lato(
                                            fontSize: 17.9,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.1,
                                            color: actionTextColor,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Transform.scale(
                                          scaleX: 1.2,
                                          child: Icon(
                                            buttonIcon,
                                            size: 22,
                                            color: actionTextColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: imagePadding,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: AspectRatio(
                          aspectRatio: imageAspectRatio,
                          child: Image.asset(imageAsset, fit: BoxFit.contain),
                        ),
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
                          Container(
                              height: progressThickness, color: trackColor),
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
      },
    );
  }
}
