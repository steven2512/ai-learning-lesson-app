// lib/z_pages/lessons/LessonTzhee/lesson3_4_quantitative.dart
// ✅ LessonStepFour — Quantitative (numbers)
// UPDATE: Middle box now shows + - × ÷ together and is labeled "Math".

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

          const SizedBox(height: 14),

          // ========== Math Box with 3 simple actions ==========
          LessonText.box(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LessonText.sentence([
                  LessonText.word("You", Colors.black87,
                      fontSize: lesson3FontSize),
                  LessonText.word("can", Colors.black87,
                      fontSize: lesson3FontSize),
                  LessonText.word("also", Colors.black87,
                      fontSize: lesson3FontSize),
                  LessonText.word("measure", keyConceptGreen,
                      fontSize: lesson3FontSize,
                      fontWeight: FontWeight.w900,
                      italic: true),
                  LessonText.word("and", Colors.black87,
                      fontSize: lesson3FontSize),
                  LessonText.word("calculate", keyConceptGreen,
                      fontSize: lesson3FontSize,
                      fontWeight: FontWeight.w900,
                      italic: true),
                  LessonText.word("with it.", Colors.black87,
                      fontSize: lesson3FontSize),
                ]),
                const SizedBox(height: 10),
                const _ActionRow(actions: [
                  _Action(icon: Icons.straighten, label: "Measure"),
                  _Action.custom(label: "Math"), // Custom box for + - × ÷
                  _Action(icon: Icons.compare_arrows, label: "Compare"),
                ]),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ========== 3 Examples ==========
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
                      offset: Offset(0, 2)),
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

class _Action {
  final IconData? icon;
  final String label;
  final bool isCustom;

  const _Action({this.icon, required this.label}) : isCustom = false;
  const _Action.custom({required this.label})
      : icon = null,
        isCustom = true;
}

class _ActionRow extends StatelessWidget {
  final List<_Action> actions;
  const _ActionRow({required this.actions});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: actions
          .map(
            (a) => Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 250, 250, 250),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.black12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    a.isCustom
                        ? Text(
                            "+ − × ÷",
                            style: GoogleFonts.lato(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: keyConceptGreen,
                            ),
                          )
                        : Icon(a.icon, size: 32, color: keyConceptGreen),
                    const SizedBox(height: 6),
                    Text(
                      a.label,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                          fontSize: 14, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
