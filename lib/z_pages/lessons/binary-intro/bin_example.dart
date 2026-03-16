import 'package:flutter/material.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';

const Color mainConceptColor = Color.fromARGB(255, 255, 109, 12);
const Color keyConceptGreen = Color.fromARGB(255, 0, 163, 54);

const double globalFontSize = 22;

class BinaryExample extends StatelessWidget {
  const BinaryExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Examples box: Blue/Red and Yes/No
            LessonText.box(
              margin: const EdgeInsets.only(bottom: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔹 NEW: Big header "Main Takeaway"
                  LessonText.sentence([
                    LessonText.word("Main", mainConceptColor,
                        fontSize: 30, fontWeight: FontWeight.w900),
                    LessonText.word("Takeaway", mainConceptColor,
                        fontSize: 30, fontWeight: FontWeight.w900),
                  ]),
                  const SizedBox(height: 14),

                  // Original content
                  LessonText.sentence([
                    LessonText.word("Computers", Colors.black87,
                        fontSize: globalFontSize),
                    LessonText.word("use", Colors.black87,
                        fontSize: globalFontSize),
                    LessonText.word("'0'", keyConceptGreen,
                        fontSize: globalFontSize, fontWeight: FontWeight.w800),
                    LessonText.word("and", Colors.black87,
                        fontSize: globalFontSize),
                    LessonText.word("'1',", keyConceptGreen,
                        fontSize: globalFontSize, fontWeight: FontWeight.w800),
                  ]),
                  LessonText.sentence([
                    LessonText.word("but", Colors.black,
                        fontSize: globalFontSize),
                    LessonText.word(
                        "binary", const Color.fromARGB(255, 25, 169, 0),
                        fontSize: globalFontSize),
                    LessonText.word("could also", Colors.black87,
                        fontSize: globalFontSize),
                    LessonText.word("be:", Colors.black87,
                        fontSize: globalFontSize),
                  ]),
                  LessonText.sentence([
                    LessonText.word(
                        "[Blue", const Color.fromARGB(255, 7, 2, 255),
                        fontSize: globalFontSize, italic: true),
                    LessonText.word("and", Colors.black87,
                        fontSize: globalFontSize),
                    LessonText.word(
                        "Red]", const Color.fromARGB(255, 255, 12, 12),
                        fontSize: globalFontSize, italic: true),
                    LessonText.word("or", Colors.black87,
                        fontSize: globalFontSize),
                    LessonText.word("[Yes", keyConceptGreen,
                        fontSize: globalFontSize, italic: true),
                    LessonText.word("and", Colors.black87,
                        fontSize: globalFontSize),
                    LessonText.word(
                        "No]", const Color.fromARGB(255, 157, 0, 205),
                        fontSize: globalFontSize, italic: true),
                  ]),
                ],
              ),
            ),

            // ✅ New box: Other examples of Binary (pill style, vibrant)
            LessonText.box(
              margin: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LessonText.sentence([
                    LessonText.word("More examples of Binary", mainConceptColor,
                        fontSize: globalFontSize, fontWeight: FontWeight.w900),
                  ]),
                  const SizedBox(height: 15),
                  const _ChipWrap(items: [
                    _BinaryPair(
                        "Hot", Color(0xFFFF3B30), "Cold", Color(0xFF007AFF)),
                    _BinaryPair(
                        "Sun", Color(0xFFFFC700), "Moon", Color(0xFF6F42C1)),
                    _BinaryPair(
                        "Open", Color(0xFF34C759), "Closed", Color(0xFFFF9500)),
                    _BinaryPair("...", Colors.grey, "", Colors.transparent),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- Model for colored pairs ----------
class _BinaryPair {
  final String left;
  final Color leftColor;
  final String right;
  final Color rightColor;

  const _BinaryPair(this.left, this.leftColor, this.right, this.rightColor);
}

// ---------- Pill-style helper ----------
class _ChipWrap extends StatelessWidget {
  final List<_BinaryPair> items;
  const _ChipWrap({required this.items});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 10,
      children: items.map((pair) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black12),
            boxShadow: const [
              BoxShadow(
                color: Color.fromARGB(20, 0, 0, 0),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              LessonText.word(pair.left, pair.leftColor,
                  fontSize: 18, fontWeight: FontWeight.w900),
              if (pair.right.isNotEmpty) ...[
                LessonText.word(" / ", Colors.black,
                    fontSize: 18, fontWeight: FontWeight.w700),
                LessonText.word(pair.right, pair.rightColor,
                    fontSize: 18, fontWeight: FontWeight.w900),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }
}
