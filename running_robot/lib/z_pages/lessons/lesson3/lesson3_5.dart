// lib/z_pages/lessons/LessonTzhee/lesson3_4_quantitative.dart
// ✅ LessonStepFour — Quantitative (numbers) definition + examples

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';

const Color mainConceptColor = Color.fromARGB(255, 255, 109, 12);
const Color keyConceptGreen = Color.fromARGB(255, 0, 163, 54);
const double lesson3FontSize = 20;

class LessonStepFour extends StatelessWidget {
  const LessonStepFour({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ========== Definition ==========
          LessonText.box(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LessonText.sentence([
                  LessonText.word("What", Colors.black87, fontSize: 30),
                  LessonText.word("is", Colors.black87, fontSize: 30),
                  LessonText.word("Quantitative", mainConceptColor,
                      fontSize: 30),
                  LessonText.word("Data?", Colors.black87, fontSize: 30),
                ]),
                const SizedBox(height: 12),
                LessonText.sentence([
                  LessonText.word("Quantitative", mainConceptColor,
                      fontSize: lesson3FontSize + 1,
                      fontWeight: FontWeight.w900),
                  LessonText.word("data", Colors.black87,
                      fontSize: lesson3FontSize, fontWeight: FontWeight.w800),
                  LessonText.word("is", Colors.black87,
                      fontSize: lesson3FontSize),
                  LessonText.word("information", keyConceptGreen,
                      fontSize: lesson3FontSize, fontWeight: FontWeight.w900),
                  LessonText.word("that", Colors.black87,
                      fontSize: lesson3FontSize),
                  LessonText.word("can be", Colors.black87,
                      fontSize: lesson3FontSize),
                  LessonText.word("shown", Colors.black87,
                      fontSize: lesson3FontSize),
                  LessonText.word("as", Colors.black87,
                      fontSize: lesson3FontSize),
                  LessonText.word("numbers.", Colors.black87,
                      fontSize: lesson3FontSize, fontWeight: FontWeight.w900),
                ]),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ========== Examples ==========
          Text(
            "Examples",
            style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const _ChipWrap(items: ["170 cm", "3 books", "Score 92"]),
        ],
      ),
    );
  }
}

// ---------- Small helpers ----------
class _ChipWrap extends StatelessWidget {
  final List<String> items;
  const _ChipWrap({required this.items});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 10,
      children: items
          .map(
            (t) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.black12),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromARGB(20, 0, 0, 0),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                t,
                style:
                    GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
          )
          .toList(),
    );
  }
}
