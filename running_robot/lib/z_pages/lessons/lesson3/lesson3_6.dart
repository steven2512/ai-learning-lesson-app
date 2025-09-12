// lib/z_pages/lessons/LessonTzhee/lesson3_5_quantitative.dart
// ✅ LessonStepFive — Quantitative actions (measure, math, compare)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';

const Color mainConceptColor = Color.fromARGB(255, 255, 109, 12);
const Color keyConceptGreen = Color.fromARGB(255, 0, 163, 54);
const double lesson3FontSize = 20;

class LessonStepFive extends StatelessWidget {
  const LessonStepFive({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ========== Math Box ==========
          LessonText.box(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LessonText.sentence([
                  LessonText.word("You", Colors.black87,
                      fontSize: lesson3FontSize),
                  LessonText.word("can", Colors.black87,
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
        ],
      ),
    );
  }
}

// ---------- Small helpers ----------
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
