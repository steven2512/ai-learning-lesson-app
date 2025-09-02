import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart'; // ✅ SVG support
import 'package:running_robot/z_pages/assets/lessonN/icon_button.dart';
import 'package:running_robot/z_pages/assets/lessonN/progress_bar.dart';
import 'package:running_robot/core/app_router.dart';

// ────────── Global Styles ──────────
const Color mainConceptColor = Color.fromARGB(255, 255, 111, 0);
const FontWeight secondLineWeight = FontWeight.w600;
const double maxTextWidth = 350;

class LessonOne extends StatefulWidget {
  final AppNavigate onNavigate;

  const LessonOne({
    super.key,
    required this.onNavigate,
  });

  @override
  State<LessonOne> createState() => _LessonOneState();
}

class _LessonOneState extends State<LessonOne> {
  late IconButtonWidget<void> returnButton;

  @override
  void initState() {
    super.initState();
    returnButton = IconButtonWidget<void>(
      iconPath: 'assets/images/x_icon.png',
      tint: Colors.black87,
      size: 22,
      onPressed: (_) => widget.onNavigate(const RouteMainMenu(tab: 0)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _buildProgressBar(context),
          _buildReturnButton(),
          _buildLessonText(),
        ],
      ),
    );
  }

  // ───────── Helpers ─────────

  Widget _buildProgressBar(BuildContext context) {
    return Positioned(
      top: 90,
      left: MediaQuery.of(context).size.width / 2 - (279 / 2),
      child: LessonProgressBar(
        totalStages: 3,
        currentStage: 0,
      ),
    );
  }

  Widget _buildReturnButton() {
    return Positioned(
      top: 89,
      left: 30,
      child: returnButton,
    );
  }

  Widget _buildLessonText() {
    return Positioned.fill(
      top: 170,
      child: SingleChildScrollView(
        child: Padding(
          padding:
              const EdgeInsets.only(left: 30, right: 30), // ✅ balanced padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSentence([
                _word("What", Colors.black87, fontSize: 30),
                _word("is", Colors.black87, fontSize: 30),
                _word("classification?", mainConceptColor, fontSize: 30),
              ]),
              const SizedBox(height: 12),

              // ✅ Definition line
              _buildSentence([
                Padding(
                  padding: const EdgeInsets.only(top: 3, right: 2),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    size: 26,
                    color: Colors.black54,
                  ),
                ),
                _word("Classification", mainConceptColor,
                    fontWeight: FontWeight.w800),
                _word("is", Colors.black87, fontWeight: secondLineWeight),
                _word("deciding", Colors.black87, fontWeight: secondLineWeight),
                _word("which", Colors.black87, fontWeight: secondLineWeight),
                _word("group", Colors.black87, fontWeight: secondLineWeight),
                _word("something", Colors.black87,
                    fontWeight: secondLineWeight, italic: true),
                _word("belongs", Colors.black87, fontWeight: secondLineWeight),
                _word("to.", Colors.black87, fontWeight: secondLineWeight),
              ]),

              const SizedBox(height: 40),
              _buildSentence([
                _word("Which", Colors.black87, fontSize: 24),
                _word("one", Colors.black87, fontSize: 24),
                _word("is", Colors.black87, fontSize: 24),
                _word("a", Colors.black87, fontSize: 24),
                _word(
                  "dog?",
                  Colors.green,
                  fontWeight: FontWeight.w600,
                  fontSize: 24,
                ),
              ], alignment: WrapAlignment.center, constrainWidth: false),
              const SizedBox(height: 12),
              // ✅ Dog vs Cat row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 🐶 Dog
                  Container(
                    padding: EdgeInsets.zero,
                    child: SizedBox(
                      width: 170,
                      height: 250,
                      child: Container(
                        padding:
                            const EdgeInsets.all(8), // ✅ padding inside frame
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.black26, width: 1),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: Image.asset(
                          'assets/images/dog.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 15), // ✅ spacing

                  // 🐱 Cat
                  SizedBox(
                    width: 165,
                    height: 250,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.black26, width: 1),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: Image.asset(
                        'assets/images/cat.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // ✅ New centered sentence

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // Helper to build a single word with style
  Widget _word(
    String text,
    Color color, {
    FontWeight? fontWeight,
    bool italic = false,
    double? fontSize,
    double? letterSpacing,
  }) {
    return Text(
      "$text ",
      style: GoogleFonts.lato(
        fontSize: fontSize ?? 22,
        letterSpacing: letterSpacing ?? 0.2,
        fontWeight: fontWeight ?? FontWeight.w800,
        fontStyle: italic ? FontStyle.italic : FontStyle.normal,
        color: color,
      ),
    );
  }

  // Helper to build a row of words with max width
// Helper to build a row of words with max width (optional)
  Widget _buildSentence(
    List<Widget> words, {
    WrapAlignment alignment = WrapAlignment.start,
    bool constrainWidth = true, // 👈 new param
  }) {
    final content = Wrap(
      alignment: alignment,
      children: words,
    );

    if (constrainWidth) {
      return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: maxTextWidth),
        child: content,
      );
    } else {
      return Center(child: content); // 👈 full center
    }
  }
}
