import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// MCQBox: holds optional question + answers
class MCQBox extends StatelessWidget {
  final dynamic question; // ✅ String OR Widget
  final List<dynamic> answers; // ✅ List<String> OR List<Widget>
  final int correctAnswer;
  final void Function(int index, bool isCorrect)? onAnswerTap;

  // Box styling
  final double width;
  final double height;
  final List<double> padding;
  final Color colorFill;
  final Color answerFill;
  final double borderRadius;

  // Question text styling
  final double letterSpacing;
  final WrapAlignment alignment;
  final FontWeight fontWeight;
  final double fontSize;
  final Color textColor;

  // Answer text overrides (legacy)
  final FontWeight? answerFontWeight;
  final double? answerFontSize;
  final Color? answerTextColor;
  final double? answerLetterSpacing;
  final TextAlign? answerAlignment;

  // Flags
  final bool defaultAnimation;
  final bool lockCorrectAnswer;

  // NEW: style selector — 0 = legacy vertical, 1 = 2×2 grid
  final int style; // NEW

  const MCQBox({
    super.key,
    this.question,
    required this.answers,
    required this.correctAnswer,
    this.onAnswerTap,
    this.width = double.infinity,
    this.height = 300,
    this.padding = const [16, 12, 8, 16, 16, 16],
    this.colorFill = Colors.white,
    this.answerFill = const Color(0xFFE0E0E0),
    this.borderRadius = 16,
    this.letterSpacing = 0.2,
    this.alignment = WrapAlignment.start,
    this.fontWeight = FontWeight.w600,
    this.fontSize = 18,
    this.textColor = Colors.black87,
    this.answerFontWeight,
    this.answerFontSize,
    this.answerTextColor,
    this.answerLetterSpacing,
    this.answerAlignment,
    this.defaultAnimation = true,
    this.lockCorrectAnswer = false,
    this.style = 0, // NEW: default legacy
  });

  @override
  Widget build(BuildContext context) {
    // Normalize question
    Widget? questionWidget;
    if (question is String) {
      questionWidget = Text(
        question,
        style: GoogleFonts.lato(
          fontSize: fontSize,
          fontWeight: fontWeight,
          letterSpacing: letterSpacing,
          color: textColor,
        ),
        textAlign: TextAlign.left,
      );
    } else if (question is Widget) {
      questionWidget = question as Widget;
    }

    // Normalize answers
    final normalizedAnswers = answers.map<Widget>((a) {
      if (a is String) {
        return Text(
          a,
          textAlign: answerAlignment ?? TextAlign.left,
          style: GoogleFonts.lato(
            fontSize: answerFontSize ?? 16,
            fontWeight: answerFontWeight ?? FontWeight.w500,
            letterSpacing: answerLetterSpacing ?? 0.2,
            color: answerTextColor ?? Colors.black87,
          ),
        );
      } else if (a is Widget) {
        return a;
      }
      throw ArgumentError("Answer must be String or Widget");
    }).toList();

    return Container(
      width: width,
      padding: EdgeInsets.only(
        top: padding[0],
        left: padding[3],
        right: padding[4],
        bottom: padding[5],
      ),
      decoration: BoxDecoration(
        color: colorFill,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: Colors.black26, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (questionWidget != null) ...[
            questionWidget,
            SizedBox(height: padding[1]),
          ],
          MCQAnswers(
            answers: normalizedAnswers,
            correctAnswer: correctAnswer,
            onAnswerTap: onAnswerTap,
            gapBetween: padding[2],
            borderRadius: borderRadius,
            answerFill: answerFill,
            defaultAnimation: defaultAnimation,
            lockCorrectAnswer: lockCorrectAnswer,
            style: style, // NEW: pass through
            width: double.infinity, // keep filling the container
            height: 50, // same default height per-tile (grid uses this too)
          ),
        ],
      ),
    );
  }
}

/// MCQAnswers: renders list of answers with optional default animation
class MCQAnswers extends StatefulWidget {
  final List<Widget> answers;
  final int correctAnswer;
  final void Function(int index, bool isCorrect)? onAnswerTap;

  final double width;
  final double height; // per-tile height
  final double gapBetween;
  final double borderRadius;
  final Color answerFill;

  final bool defaultAnimation;
  final bool lockCorrectAnswer;

  // NEW: style selector — 0 = legacy vertical, 1 = 2×2 grid
  final int style; // NEW

  const MCQAnswers({
    super.key,
    required this.answers,
    required this.correctAnswer,
    this.onAnswerTap,
    this.width = double.infinity,
    this.height = 50,
    this.gapBetween = 8,
    this.borderRadius = 12,
    this.answerFill = const Color(0xFFE0E0E0),
    this.defaultAnimation = true,
    this.lockCorrectAnswer = false,
    this.style = 0, // NEW
  }) : assert(
          style == 0 || answers.length == 4,
          'style: 1 requires exactly 4 answers (top-left, top-right, bottom-left, bottom-right).',
        ); // NEW

  @override
  State<MCQAnswers> createState() => _MCQAnswersState();
}

class _MCQAnswersState extends State<MCQAnswers> {
  int? selectedIndex;
  bool correctLocked = false;

  void _handleTap(int index) {
    // ✅ If already locked on correct answer → ignore further taps
    if (widget.lockCorrectAnswer && correctLocked) return;

    final isCorrect = index == widget.correctAnswer;
    setState(() {
      selectedIndex = index;
      if (widget.lockCorrectAnswer && isCorrect) {
        correctLocked = true;
      }
    });

    widget.onAnswerTap?.call(index, isCorrect);
  }

  Widget _buildTile(int index, {double? fixedWidth}) {
    final isSelected = index == selectedIndex;
    final isCorrect = index == widget.correctAnswer;

    final tile = (widget.defaultAnimation)
        ? AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            width: fixedWidth ?? widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              color: isSelected
                  ? (isCorrect ? Colors.green.shade200 : Colors.red.shade200)
                  : widget.answerFill,
              border: Border.all(
                color: isSelected
                    ? (isCorrect ? Colors.green : Colors.red)
                    : Colors.black26,
                width: isSelected ? 2 : 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: widget.answers[index]),
                if (isSelected && isCorrect)
                  const Icon(Icons.check_circle, color: Colors.green, size: 22),
              ],
            ),
          )
        : Container(
            width: fixedWidth ?? widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              color: isSelected
                  ? (isCorrect ? Colors.green.shade200 : Colors.red.shade200)
                  : widget.answerFill,
              border: Border.all(
                color: isSelected
                    ? (isCorrect ? Colors.green : Colors.red)
                    : Colors.black26,
                width: isSelected ? 2 : 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: widget.answers[index]),
                if (isSelected && isCorrect)
                  const Icon(Icons.check_circle, color: Colors.green, size: 22),
              ],
            ),
          );

    return GestureDetector(
      onTap: () => _handleTap(index),
      child: tile,
    );
  }

  @override
  Widget build(BuildContext context) {
    // CHANGED: branch on style
    if (widget.style == 0) {
      // Legacy vertical list
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(widget.answers.length, (index) {
          return Padding(
            padding: EdgeInsets.only(
              bottom:
                  index == widget.answers.length - 1 ? 0 : widget.gapBetween,
            ),
            child: _buildTile(index),
          );
        }),
      );
    }

    // NEW: style == 1 → 2×2 grid (TL, TR, BL, BR)
    // Requires exactly 4 answers (enforced by assert in constructor).
    return LayoutBuilder(
      builder: (context, constraints) {
        // Compute tile width = (availableWidth - horizontalGap) / 2
        final available =
            (widget.width.isFinite ? widget.width : constraints.maxWidth);
        final double horizontalGap = widget.gapBetween;
        final double tileWidth =
            (available - horizontalGap) / 2.0; // for 2 columns

        return Wrap(
          spacing: widget.gapBetween, // horizontal gap between columns
          runSpacing: widget.gapBetween, // vertical gap between rows
          children: [
            // Order: 0=TL, 1=TR, 2=BL, 3=BR
            SizedBox(
                width: tileWidth,
                height: widget.height,
                child: _buildTile(0, fixedWidth: tileWidth)),
            SizedBox(
                width: tileWidth,
                height: widget.height,
                child: _buildTile(1, fixedWidth: tileWidth)),
            SizedBox(
                width: tileWidth,
                height: widget.height,
                child: _buildTile(2, fixedWidth: tileWidth)),
            SizedBox(
                width: tileWidth,
                height: widget.height,
                child: _buildTile(3, fixedWidth: tileWidth)),
          ],
        );
      },
    );
  }
}
