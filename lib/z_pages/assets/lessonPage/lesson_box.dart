// FILE: lib/z_pages/assets/lessonPage/lesson_box.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LessonBox extends StatelessWidget {
  final String pictureLink;
  final String lessonTitle; // e.g. "Lesson 1.2"
  final String titleText; // e.g. "1.2 Number Relationships"
  final String buttonText;
  final VoidCallback onNavigate;

  final double width;
  final double height;

  final double? imageHeight;
  final double imageHeightFactor;

  final Color buttonColor;
  final Color boxFill;
  final List<Color> textColors;
  final List<double> fontSizes;
  final List<double> letterSpacings;
  final List<FontWeight> fontWeights;

  // 👇 NEW: line spacing for the big title
  final double titleLineHeight;

  const LessonBox({
    super.key,
    required this.pictureLink,
    required this.lessonTitle,
    required this.titleText,
    required this.buttonText,
    required this.onNavigate,
    this.width = 320,
    this.height = 340,
    this.imageHeight,
    this.imageHeightFactor = 0.28,
    this.buttonColor = Colors.black,
    this.boxFill = Colors.white,
    this.textColors = const [Colors.black, Colors.orange, Colors.white],
    this.fontSizes = const [15, 20, 15], // [lessonTitle, titleText, button]
    this.letterSpacings = const [0.15, 0.1, 0.1],
    this.fontWeights = const [
      FontWeight.w600, // lessonTitle
      FontWeight.w700, // titleText
      FontWeight.w600, // button
    ],
    this.titleLineHeight = 1.2, // 👈 default line spacing
  });

  @override
  Widget build(BuildContext context) {
    final double resolvedImageHeight =
        imageHeight ?? (height * imageHeightFactor);

    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: width,
        maxWidth: width,
        minHeight: height,
      ),
      child: IntrinsicHeight(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  boxFill.withOpacity(0.95),
                  boxFill.withOpacity(0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                width: 2,
                color: Colors.white.withOpacity(0.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 12),
                  spreadRadius: -4,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.5),
                  blurRadius: 4,
                  offset: const Offset(-2, -2),
                  spreadRadius: -1,
                ),
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

                // Lesson title (small orange text)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 14, 12, 0),
                  child: Text(
                    lessonTitle,
                    style: GoogleFonts.lato(
                      fontSize: fontSizes[0],
                      fontWeight: fontWeights[0],
                      letterSpacing: letterSpacings[0],
                      color: Colors.orange,
                    ),
                  ),
                ),

                // Title text (big black text)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                  child: Text(
                    titleText,
                    style: GoogleFonts.lato(
                      fontSize: fontSizes[1],
                      fontWeight: fontWeights[1],
                      letterSpacing: letterSpacings[1],
                      height: titleLineHeight, // 👈 custom line spacing
                      color: textColors[0],
                    ),
                  ),
                ),

                const Spacer(),

                // Continue button
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onNavigate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 6,
                        shadowColor: Colors.black.withOpacity(0.3),
                      ),
                      child: Text(
                        buttonText,
                        style: GoogleFonts.lato(
                          fontSize: fontSizes[2],
                          fontWeight: fontWeights[2],
                          letterSpacing: letterSpacings[2],
                          color: textColors[2],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
