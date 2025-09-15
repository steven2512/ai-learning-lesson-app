// lib/z_pages/lessons/LessonTzhee/lesson3_4_quantitative.dart
// ✅ LessonStepFour — Quantitative (numbers) definition

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';

const Color mainConceptColor = Color.fromARGB(255, 255, 109, 12);
const Color keyConceptGreen = Color.fromARGB(255, 0, 163, 54);
const double lesson3FontSize = 20;

class QuanIntro extends StatelessWidget {
  const QuanIntro({super.key});

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
                  LessonText.word("is", Colors.black87,
                      fontSize: lesson3FontSize),
                  LessonText.word("expressed", Colors.black87,
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

          // ========== Quantitative Image ==========
          LessonText.box(
            child: Center(
              child: Image.asset(
                "assets/images/quantitative.png",
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
