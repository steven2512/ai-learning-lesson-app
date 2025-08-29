// FILE: lib/z_pages/assets/lessonPage/lesson_box.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LessonBox extends StatelessWidget {
  final String pictureLink;
  final String lessonTitle; // e.g. "Lesson 1.0 — Number Relationships"
  final String buttonText;
  final VoidCallback onNavigate;

  // Box size
  final double width;
  final double height;

  // Image sizing
  final double? imageHeight; // absolute override
  final double
      imageHeightFactor; // fraction of box height if imageHeight is null

  // Styling
  final Color buttonColor;
  final Color boxFill;
  final List<Color> textColors; // [titleColor, buttonTextColor]
  final List<double> fontSizes; // [title, button]
  final List<double> letterSpacings; // [title, button]
  final List<FontWeight> fontWeights; // [title, button]

  const LessonBox({
    super.key,
    required this.pictureLink,
    required this.lessonTitle,
    required this.buttonText,
    required this.onNavigate,
    this.width = 320,
    this.height = 340,
    this.imageHeight,
    this.imageHeightFactor = 0.28,
    this.buttonColor = Colors.black,
    this.boxFill = Colors.white,
    this.textColors = const [Colors.black, Colors.white],
    this.fontSizes = const [16, 15],
    this.letterSpacings = const [0.15, 0.1],
    this.fontWeights = const [
      FontWeight.w700, // lesson title bigger & bolder
      FontWeight.w600, // button
    ],
  });

  @override
  Widget build(BuildContext context) {
    final double resolvedImageHeight =
        imageHeight ?? (height * imageHeightFactor);

    return SizedBox(
      width: width,
      height: height,
      child: Container(
        decoration: BoxDecoration(
          color: boxFill,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 4),
            )
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top image
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: SizedBox(
                height: resolvedImageHeight,
                width: double.infinity,
                child: Image.asset(
                  pictureLink,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Lesson title
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 0),
              child: Text(
                lessonTitle,
                style: GoogleFonts.lato(
                  fontSize: fontSizes[0],
                  fontWeight: fontWeights[0],
                  letterSpacing: letterSpacings[0],
                  color: textColors[0],
                ),
              ),
            ),

            const Spacer(),

            // Continue / Start button
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onNavigate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    buttonText,
                    style: GoogleFonts.lato(
                      fontSize: fontSizes[1],
                      fontWeight: fontWeights[1],
                      letterSpacing: letterSpacings[1],
                      color: textColors[1],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
