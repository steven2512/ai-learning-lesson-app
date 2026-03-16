// lib/z_pages/lessons/LessonTzhee/lesson3_8_qualitative.dart
// ✅ LessonStepEight — Qualitative actions + examples (same box style as quantitative)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';

const Color mainConceptColor = Color.fromARGB(255, 255, 109, 12);
const Color keyConceptPurple = Color.fromARGB(255, 130, 59, 207);
const double lesson3FontSize = 20;

class QualExample extends StatelessWidget {
  const QualExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ========== Group / Sort Box ==========

          // ========== Examples Box (same as quantitative) ==========
          LessonText.box(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LessonText.sentence([
                  LessonText.word("Examples of", Colors.black, fontSize: 20),
                  LessonText.word(
                    "Qualitative Data",
                    keyConceptPurple,
                    fontSize: 20,
                  ),
                ]),
                const SizedBox(height: 15),
                const _ChipWrap(items: [
                  "Eye Color",
                  "Fruit Type",
                  "Favorite Subject",
                  "Country",
                  "Mood",
                  "Music Genre",
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Small helpers ----------
class _ChipWrap extends StatelessWidget {
  final List<String> items; // Just labels
  const _ChipWrap({required this.items});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 10,
      children: items
          .map(
            (label) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
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
              child: LessonText.word(
                label,
                Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w800,
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
                            "🚫",
                            style: GoogleFonts.lato(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.red,
                            ),
                          )
                        : Icon(a.icon, size: 32, color: keyConceptPurple),
                    const SizedBox(height: 6),
                    Text(
                      a.label,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                          fontSize: 14, fontWeight: FontWeight.w800),
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
