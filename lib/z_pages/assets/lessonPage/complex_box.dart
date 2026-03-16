// FILE: lib/z_pages/assets/lessonPage/complex_box.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ComplexBox extends StatelessWidget {
  final String pictureLink;
  final String lessonTitle;
  final String buttonText;
  final VoidCallback onNavigate;

  // Box size
  final double width;
  final double height;

  // Image sizing
  final double? imageHeight;
  final double imageHeightFactor;

  // Styling
  final List<Color> textColors; // [titleColor, buttonTextColor]
  final List<double> fontSizes; // [title, button]
  final List<double> letterSpacings; // [title, button]
  final List<FontWeight> fontWeights; // [title, button]

  const ComplexBox({
    super.key,
    required this.pictureLink,
    required this.lessonTitle,
    required this.buttonText,
    required this.onNavigate,
    this.width = 320,
    this.height = 340,
    this.imageHeight,
    this.imageHeightFactor = 0.28,
    this.textColors = const [Colors.white, Colors.white],
    this.fontSizes = const [16, 15],
    this.letterSpacings = const [0.3, 0.15],
    this.fontWeights = const [
      FontWeight.w700,
      FontWeight.w600,
    ],
  });

  @override
  Widget build(BuildContext context) {
    final double resolvedImageHeight =
        imageHeight ?? (height * imageHeightFactor);

    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            // Glass blur background
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05), // crystal clear
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.4), // glowing edge
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.25),
                      blurRadius: 25,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),

            // Content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top holographic image
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: SizedBox(
                    height: resolvedImageHeight,
                    width: double.infinity,
                    child: Image.asset(
                      pictureLink,
                      fit: BoxFit.cover,
                      color: Colors.white.withOpacity(0.85), // subtle glow
                      colorBlendMode: BlendMode.srcATop,
                    ),
                  ),
                ),

                // Lesson title
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 14, 12, 0),
                  child: Text(
                    lessonTitle,
                    style: GoogleFonts.orbitron(
                      fontSize: fontSizes[0],
                      fontWeight: fontWeights[0],
                      letterSpacing: letterSpacings[0],
                      color: textColors[0],
                    ),
                  ),
                ),

                const Spacer(),

                // Transparent holographic button
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onNavigate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.08),
                        shadowColor: Colors.white.withOpacity(0.5),
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.white.withOpacity(0.6),
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        buttonText,
                        style: GoogleFonts.orbitron(
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
          ],
        ),
      ),
    );
  }
}
