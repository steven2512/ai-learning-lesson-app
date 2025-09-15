// lib/z_pages/lessons/LessonTzhee/lesson3_5_quantitative.dart
// ✅ LessonStepFive — Quantitative actions (measure, math, compare) + examples

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';

const Color mainConceptColor = Color.fromARGB(255, 255, 109, 12);
const Color keyConceptGreen = Color.fromARGB(255, 0, 163, 54);
const double lesson3FontSize = 20;

class QuanExample extends StatelessWidget {
  const QuanExample({super.key});

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
                  LessonText.word("with", Colors.black87,
                      fontSize: lesson3FontSize),
                  LessonText.word("quantitative data",
                      const Color.fromARGB(221, 255, 115, 0),
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

          // ========== Examples Box ==========
          LessonText.box(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LessonText.sentence([
                  LessonText.word("Examples of", Colors.black, fontSize: 20),
                  LessonText.word(
                    "Quantitative Data",
                    const Color.fromARGB(255, 255, 123, 0),
                    fontSize: 20,
                  ),
                ]),
                const SizedBox(height: 15),
                const _ChipWrap(items: [
                  "Height",
                  "Distance",
                  "Salary",
                  "Population Size",
                  "IQ Score"
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

class _ChipWrap extends StatelessWidget {
  final List<String> items; // Just labels now
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
