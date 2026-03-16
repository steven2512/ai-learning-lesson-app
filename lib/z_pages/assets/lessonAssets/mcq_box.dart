import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/auth/start_button.dart';

/// MCQBox: holds optional question + answers
/// LEGACY: single-answer flow is unchanged.
/// NEW: set [multipleOption: true] and provide [correctAnswers] + [onSubmitAnswers]
///      to enable multi-select with a Submit button.
/// - In multiple mode, per-tile taps toggle selection only (no legacy callback).
/// - Pressing Submit triggers [onSubmitAnswers(selectedIndices, allCorrect)].
/// - After a perfect submit in multiple mode, interaction is frozen (like single).
class MCQBox extends StatelessWidget {
  final dynamic question; // ✅ String OR Widget
  final List<dynamic> answers; // ✅ List<String> OR List<Widget>

  // LEGACY single-answer
  final int correctAnswer;

  // NEW: multiple-answer list (required iff multipleOption == true)
  final List<int>? correctAnswers; // NEW

  // LEGACY per-tile callback (single mode only)
  final void Function(int index, bool isCorrect)? onAnswerTap;

  // NEW: submit callback (multiple mode only)
  final void Function(List<int> indices, bool allCorrect)?
      onSubmitAnswers; // NEW

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
  final bool
      lockCorrectAnswer; // kept for legacy; multi now freezes on perfect regardless

  // 0 = legacy vertical, 1 = 2×N grid (even number allowed)
  final int style;

  // NEW: multi-select toggle
  final bool multipleOption; // NEW
  final String submitLabel; // NEW: button text

  const MCQBox({
    super.key,
    this.question,
    required this.answers,
    required this.correctAnswer, // required to preserve legacy signature
    this.correctAnswers, // NEW
    this.onAnswerTap,
    this.onSubmitAnswers, // NEW
    this.width = double.infinity,
    this.height = 300,
    this.padding = const [16, 12, 8, 16, 16, 16],
    this.colorFill = Colors.white,
    this.answerFill = const Color.fromARGB(255, 255, 255, 255),
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
    this.style = 0,
    this.multipleOption = false, // NEW: default OFF → legacy untouched
    this.submitLabel = "Submit", // NEW
  });

  @override
  Widget build(BuildContext context) {
    assert(() {
      if (multipleOption) {
        assert(
          correctAnswers != null && correctAnswers!.isNotEmpty,
          'When multipleOption is true, correctAnswers must be a non-empty list.',
        );
      }
      if (style == 1) {
        assert(
          answers.length.isEven,
          'style: 1 requires an even number of answers (2, 4, 6, etc).',
        );
      }
      return true;
    }());

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

    assert(
      !multipleOption
          ? (correctAnswer >= 0 && correctAnswer < normalizedAnswers.length)
          : correctAnswers!
              .every((i) => i >= 0 && i < normalizedAnswers.length),
      'Correct answer index/indices out of range.',
    );

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
            // LEGACY
            correctAnswer: correctAnswer,
            onAnswerTap: onAnswerTap,

            // NEW
            multipleOption: multipleOption,
            correctAnswers: correctAnswers,
            onSubmitAnswers: onSubmitAnswers,
            submitLabel: submitLabel,

            gapBetween: padding[2],
            borderRadius: borderRadius,
            answerFill: answerFill,
            defaultAnimation: defaultAnimation,
            lockCorrectAnswer: lockCorrectAnswer,
            style: style,
            width: double.infinity,
            height: 50,
          ),
        ],
      ),
    );
  }
}

/// MCQAnswers: renders list of answers with optional default animation
class MCQAnswers extends StatefulWidget {
  final List<Widget> answers;

  // LEGACY single-answer
  final int correctAnswer;
  final void Function(int index, bool isCorrect)? onAnswerTap;

  // NEW multiple-answer
  final bool multipleOption; // NEW
  final List<int>? correctAnswers; // NEW
  final void Function(List<int> indices, bool allCorrect)?
      onSubmitAnswers; // NEW
  final String submitLabel; // NEW

  final double width;
  final double height; // per-tile height
  final double gapBetween;
  final double borderRadius;
  final Color answerFill;

  final bool defaultAnimation;
  final bool lockCorrectAnswer;

  // 0 = vertical, 1 = 2×N grid
  final int style;

  const MCQAnswers({
    super.key,
    required this.answers,
    required this.correctAnswer,
    this.onAnswerTap,

    // NEW
    this.multipleOption = false,
    this.correctAnswers,
    this.onSubmitAnswers,
    this.submitLabel = "Submit",
    this.width = double.infinity,
    this.height = 50,
    this.gapBetween = 8,
    this.borderRadius = 12,
    this.answerFill = const Color(0xFFE0E0E0),
    this.defaultAnimation = true,
    this.lockCorrectAnswer = false,
    this.style = 0,
  });

  @override
  State<MCQAnswers> createState() => _MCQAnswersState();
}

class _MCQAnswersState extends State<MCQAnswers> {
  // LEGACY single-select
  int? selectedIndex;
  bool correctLocked = false;

  // NEW: multiple-select state
  final Set<int> _selected = <int>{}; // ⚠️ multiple mode
  bool _submitted = false; // ⚠️ multiple mode
  bool _lockedAfterPerfect = false; // ⚠️ multi: freeze after perfect
  bool _lastAllCorrect = false; // remember last submit result

  bool get _isInteractionLocked {
    if (!widget.multipleOption) {
      return (widget.lockCorrectAnswer && correctLocked);
    }
    // Freeze after perfect submit OR after an incorrect submit until "Try Again"
    return _lockedAfterPerfect || (_submitted && !_lastAllCorrect);
  }

  @override
  Widget build(BuildContext context) {
    assert(() {
      if (widget.style == 1) {
        assert(
          widget.answers.length.isEven,
          'style: 1 requires an even number of answers (2, 4, 6, etc).',
        );
      }
      return true;
    }());

    final body = _answersBody();

    if (!widget.multipleOption) {
      return body;
    }

    // MULTIPLE: answers + Submit/Try Again button
    final bool showTryAgain = (_submitted && !_lastAllCorrect);
    final String btnLabel = showTryAgain ? "Try Again" : widget.submitLabel;
    final Color ctaColor = showTryAgain
        ? const Color(0xFFEF4444) // red for Try Again
        : const Color(0xFF22C55E); // appealing green for Submit

    // ---------- TWEAK: require at least N selections before enabling Submit ----------
    final int requiredSelections = widget.correctAnswers?.length ?? 0; // TWEAK
    final bool hasEnoughSelections =
        _selected.length >= requiredSelections; // TWEAK

    // Enable: when selecting before first submit, or when in Try Again mode
    final bool enableButton = showTryAgain
        ? true
        : (hasEnoughSelections && !_isInteractionLocked); // TWEAK
    // -------------------------------------------------------------------------------

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        body,
        const SizedBox(height: 15), // gap between answers and button
        IgnorePointer(
          ignoring: !enableButton,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 180),
            opacity: enableButton ? 1.0 : 0.5,
            child: PillCta(
              label: btnLabel,
              onTap: showTryAgain ? _resetForRetry : _submitMulti,
              color: ctaColor,
              expand: true,
              height: 44,
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }

  void _handleTapSingle(int index) {
    // If already frozen after correct -> ignore all taps
    if (widget.lockCorrectAnswer && correctLocked) return;

    final isCorrect = index == widget.correctAnswer;
    setState(() {
      selectedIndex = index;
      // ✅ Freeze future taps if correct answer selected
      if (widget.lockCorrectAnswer && isCorrect) {
        correctLocked = true;
      }
    });

    // ✅ Trigger the callback once; further taps are ignored due to freeze
    widget.onAnswerTap?.call(index, isCorrect);
  }

  void _toggleMulti(int index) {
    if (_isInteractionLocked) return; // 🔒 block toggles when frozen
    setState(() {
      _submitted = false; // resets colors & button to "Submit"
      if (_selected.contains(index)) {
        _selected.remove(index);
      } else {
        _selected.add(index);
      }
    });
  }

  void _submitMulti() {
    if (_isInteractionLocked) return; // 🔒 block taps when frozen

    final correctSet = widget.correctAnswers!.toSet();

    // ---------- SAFETY: don't submit unless we have enough selections ----------
    if (_selected.length < correctSet.length) {
      // Optional: you can add a small shake/feedback here if desired.
      return;
    }
    // --------------------------------------------------------------------------

    final allCorrect = _selected.length == correctSet.length &&
        _selected.difference(correctSet).isEmpty;

    setState(() {
      _submitted = true;
      _lastAllCorrect = allCorrect;
      if (allCorrect) {
        _lockedAfterPerfect = true; // 🔒 freeze after perfect submit
      }
    });

    widget.onSubmitAnswers?.call(_selected.toList()..sort(), allCorrect);
  }

  void _resetForRetry() {
    // Called when pressing "Try Again": unlock, clear selection & visuals
    setState(() {
      _selected.clear();
      _submitted = false;
      _lastAllCorrect = false;
      // _lockedAfterPerfect remains false (it is only set on perfect submit)
    });
  }

  Widget _tileContainer({
    required bool selected,
    required bool correctForThisIndex,
    required bool showCorrectnessNow,
    required double width,
    required double height,
    required Widget child,
  }) {
    // Determine colors per mode/state while preserving legacy visuals.
    Color bg;
    Color border;
    bool showCheckIcon = false;

    if (!widget.multipleOption) {
      // LEGACY (unchanged)
      final isSelected = selected;
      final isCorrect = correctForThisIndex;
      bg = isSelected
          ? (isCorrect ? Colors.green.shade200 : Colors.red.shade200)
          : widget.answerFill;
      border =
          isSelected ? (isCorrect ? Colors.green : Colors.red) : Colors.black26;
      showCheckIcon = isSelected && isCorrect;
    } else {
      // MULTIPLE:
      // - Before submit: inner background is ALWAYS WHITE; selected shows blue border.
      // - After submit: correct selected = green; wrong selected = red; unselected = neutral.
      if (!showCorrectnessNow) {
        bg = Colors.white; // keep inner white before submit
        border = selected ? Colors.blue : Colors.black26;
        showCheckIcon = false;
      } else {
        if (selected && correctForThisIndex) {
          bg = Colors.green.shade200;
          border = Colors.green;
          showCheckIcon = true;
        } else if (selected && !correctForThisIndex) {
          bg = Colors.red.shade200;
          border = Colors.red;
          showCheckIcon = false;
        } else {
          // Not selected after submit
          bg = widget.answerFill;
          border = Colors.black26;
          showCheckIcon = false;
        }
      }
    }

    final box = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        color: bg,
        border: Border.all(
          color: border,
          width: (widget.multipleOption && !showCorrectnessNow && selected)
              ? 2
              : (selected ? 2 : 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: child),
          if (showCheckIcon)
            const Icon(Icons.check_circle, color: Colors.green, size: 22),
        ],
      ),
    );

    if (widget.defaultAnimation) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          color: bg,
          border: Border.all(
            color: border,
            width: (widget.multipleOption && !showCorrectnessNow && selected)
                ? 2
                : (selected ? 2 : 1),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: child),
            if (showCheckIcon)
              const Icon(Icons.check_circle, color: Colors.green, size: 22),
          ],
        ),
      );
    }
    return box;
  }

  Widget _buildTileSingle(int index, {double? fixedWidth}) {
    final isSelected = index == selectedIndex;
    final isCorrect = index == widget.correctAnswer;

    return GestureDetector(
      onTap: () => _handleTapSingle(index),
      child: _tileContainer(
        selected: isSelected,
        correctForThisIndex: isCorrect,
        showCorrectnessNow: true, // legacy shows correctness immediately
        width: fixedWidth ?? widget.width,
        height: widget.height,
        child: widget.answers[index],
      ),
    );
  }

  Widget _buildTileMulti(int index, {double? fixedWidth}) {
    final correctSet = widget.correctAnswers!.toSet();
    final selected = _selected.contains(index);
    final correctForThisIndex = correctSet.contains(index);

    return GestureDetector(
      onTap: () => _toggleMulti(index),
      child: _tileContainer(
        selected: selected,
        correctForThisIndex: correctForThisIndex,
        showCorrectnessNow: _submitted,
        width: fixedWidth ?? widget.width,
        height: widget.height,
        child: widget.answers[index],
      ),
    );
  }

  Widget _answersBody() {
    final builder = (int i, {double? fixedWidth}) {
      if (widget.multipleOption) {
        return _buildTileMulti(i, fixedWidth: fixedWidth);
      } else {
        return _buildTileSingle(i, fixedWidth: fixedWidth);
      }
    };

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
            child: builder(index),
          );
        }),
      );
    }

    // style == 1 → 2×N grid
    return LayoutBuilder(
      builder: (context, constraints) {
        final available =
            (widget.width.isFinite ? widget.width : constraints.maxWidth);
        final double horizontalGap = widget.gapBetween;
        final double tileWidth = (available - horizontalGap) / 2.0;

        return Wrap(
          spacing: widget.gapBetween,
          runSpacing: widget.gapBetween,
          children: List.generate(widget.answers.length, (i) {
            return SizedBox(
              width: tileWidth,
              height: widget.height,
              child: builder(i, fixedWidth: tileWidth),
            );
          }),
        );
      },
    );
  }
}
