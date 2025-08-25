/// FILE: lib/ui/widgets/simple_box.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// SimpleBox — reusable card with title, optional small-description,
/// CTA button (text + trailing icon), and an image on the right.
/// Fonts/sizing/letterSpacing intentionally hardcoded with Google Lato.
class SimpleBox extends StatelessWidget {
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
  final Color textColor;

  const SimpleBox({
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
    this.padding = const EdgeInsets.fromLTRB(20, 20, 20, 20),
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: decoration,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // LEFT: text + button
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxTextWidth),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.lato(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    letterSpacing: 0.15,
                    height: 1.1,
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
                  // Put text before icon using the `icon` slot:
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
                  ).copyWith(
                    overlayColor: MaterialStateProperty.resolveWith<Color?>(
                      (states) {
                        if (states.contains(MaterialState.pressed)) {
                          return textColor.withOpacity(0.38);
                        }
                        if (states.contains(MaterialState.hovered)) {
                          return textColor.withOpacity(0.18);
                        }
                        if (states.contains(MaterialState.focused)) {
                          return textColor.withOpacity(0.22);
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 0),

          // RIGHT: image
          Expanded(
            child: AspectRatio(
              aspectRatio: imageAspectRatio,
              child: Image.asset(
                imageAsset,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
