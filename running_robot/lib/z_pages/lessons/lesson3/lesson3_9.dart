// lib/z_pages/lessons/LessonTzhee/lesson3_8_qualitative.dart
// ✅ LessonStepEight — Qualitative actions + examples

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';

const Color mainConceptColor = Color.fromARGB(255, 255, 109, 12);
const Color keyConceptPurple = Color.fromARGB(255, 130, 59, 207);
const double lesson3FontSize = 20;

class LessonStepEight extends StatelessWidget {
  const LessonStepEight({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ========== Group / Sort Box ==========
          LessonText.box(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LessonText.sentence([
                  LessonText.word("You", Colors.black87,
                      fontSize: lesson3FontSize),
                  LessonText.word("can", Colors.black87,
                      fontSize: lesson3FontSize),
                  LessonText.word("group", keyConceptPurple,
                      fontSize: lesson3FontSize, italic: true),
                  LessonText.word("or", Colors.black87,
                      fontSize: lesson3FontSize),
                  LessonText.word("sort", keyConceptPurple,
                      fontSize: lesson3FontSize, italic: true),
                  LessonText.word("it,", Colors.black87,
                      fontSize: lesson3FontSize),
                  LessonText.word("but", Colors.black87,
                      fontSize: lesson3FontSize),
                  LessonText.word("you", Colors.black87,
                      fontSize: lesson3FontSize),
                  LessonText.word("can’t", Colors.red,
                      fontSize: lesson3FontSize),
                  LessonText.word("do", Colors.black87,
                      fontSize: lesson3FontSize),
                  LessonText.word("normal", Colors.black87,
                      fontSize: lesson3FontSize),
                  LessonText.word("math", Colors.black87,
                      fontSize: lesson3FontSize),
                  LessonText.word("on", Colors.black87,
                      fontSize: lesson3FontSize),
                  LessonText.word("it.", Colors.black87,
                      fontSize: lesson3FontSize),
                ]),
                const SizedBox(height: 10),
                const _ActionRow(actions: [
                  _Action(icon: Icons.category, label: "Group"),
                  _Action(icon: Icons.sort, label: "Sort"),
                  _Action.custom(label: "No Math"), // 🚫 math
                ]),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ========== Examples ==========
          Text(
            "Examples",
            style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const _ChipWrap(items: [
            "Eye color",
            "Fruit type",
            "Favorite subject",
            "Country"
          ]),
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
