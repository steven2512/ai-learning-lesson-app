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

  // Default animation flag
  final bool defaultAnimation;

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
          ),
        ],
      ),
    );
  }
}

/// MCQAnswers: renders list of answers with optional default animation
class MCQAnswers extends StatefulWidget {
  final List<Widget> answers; // ✅ normalized to Widgets
  final int correctAnswer;
  final void Function(int index, bool isCorrect)? onAnswerTap;

  final double width;
  final double height;
  final double gapBetween;
  final double borderRadius;
  final Color answerFill;

  final bool defaultAnimation;

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
  });

  @override
  State<MCQAnswers> createState() => _MCQAnswersState();
}

class _MCQAnswersState extends State<MCQAnswers> {
  int? selectedIndex;

  void _handleTap(int index) {
    final isCorrect = index == widget.correctAnswer;
    setState(() => selectedIndex = index);
    widget.onAnswerTap?.call(index, isCorrect);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.answers.length, (index) {
        final isSelected = index == selectedIndex;
        final isCorrect = index == widget.correctAnswer;

        return Padding(
          padding: EdgeInsets.only(
            bottom: index == widget.answers.length - 1 ? 0 : widget.gapBetween,
          ),
          child: GestureDetector(
            onTap: () => _handleTap(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              width: widget.width,
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
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: widget.answers[index], // ✅ either styled Text or Widget
            ),
          ),
        );
      }),
    );
  }
}
