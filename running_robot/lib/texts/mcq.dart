import 'dart:math' as math;
import 'dart:async'; // [EXISTS]
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/events/event_type.dart';

class McqBox extends PositionComponent implements OpacityProvider {
  // ── data
  final List<String> questions;
  final List<String> answers;
  final int correctAnswerIndex;

  // ── layout
  final Vector2 outerBoxSize;
  final Vector2 innerBoxSize;
  final List<String> alignments; // [question, answers, (optional) explanation]
  final List<double> padding; // [topBottom, qToOptions, between, left, right]
  final double borderRadius;

  // ── style
  final List<double> opacities; // [outer, inner, selected]
  final List<Color> textColors; // [question, answer]
  final List<Color> fillColors; // [outer, inner, correct, wrong]
  final List<double> textSizes; // [question, answer]

  // ── callbacks
  final List<VoidCallback>? callbacks; // [onCorrect, onWrong]
  final double showDuration;
  final double hideDuration;

  // optional explanations [0]=correct text, [1]=wrong text
  final List<String>? answerExplanations;

  // explanation style overrides
  final double? explanationFontSize;
  final FontWeight? explanationFontWeight;
  final FontStyle? explanationFontStyle;
  final double? explanationLetterSpacing;
  final Color? explanationColor;
  final TextStyle? explanationTextStyle;

  // keep selected color visible for N seconds
  final double selectedHoldSeconds;

  // [ADDED] optional extra callback when user clicks the top-right close “X”
  // This is called IN ADDITION to closing (after the box is told to close).
  final VoidCallback? onClosePressed; // [ADDED]

  // ── state
  int? _selected;
  bool _acceptInput = false;

  double _opacity = 0.0; // start hidden
  @override
  double get opacity => _opacity;
  @override
  set opacity(double v) => _opacity = v.clamp(0.0, 1.0);

  EventHorizontalObstacle currentEvent = EventHorizontalObstacle.stopMoving;
  OpacityEffect? _fadeFx;

  bool get _hidden =>
      currentEvent == EventHorizontalObstacle.stopMoving && opacity <= 0.00001;

  bool _showingExplanation = false;
  String? _explanationText;

  _CloseXButton? _closeBtn;

  McqBox({
    required this.questions,
    required this.answers,
    required this.correctAnswerIndex,
    required this.outerBoxSize,
    required this.innerBoxSize,
    required this.alignments, // [question, answers, explanation?]
    required this.padding,
    required this.borderRadius,
    required Anchor anchor,
    required Vector2 position,
    required this.opacities,
    required this.textColors,
    required this.fillColors,
    required this.textSizes,
    this.callbacks,
    required this.showDuration,
    required this.hideDuration,
    this.answerExplanations,

    // explanation style overrides (all optional)
    this.explanationFontSize,
    this.explanationFontWeight,
    this.explanationFontStyle,
    this.explanationLetterSpacing,
    this.explanationColor,
    this.explanationTextStyle,

    this.selectedHoldSeconds = 1.0,

    this.onClosePressed, // [ADDED]
  }) : assert(
         alignments.length >= 2,
         '`alignments` must have at least two entries: [question, answers], plus optional [explanation]',
       ),
       assert(
         answerExplanations == null ||
             (answerExplanations.length >= 2 &&
                 answerExplanations[0].isNotEmpty &&
                 answerExplanations[1].isNotEmpty),
         '`answerExplanations` must have 2 non-empty strings [correct, wrong] if provided',
       ),
       super(size: outerBoxSize, anchor: anchor, position: position) {
    opacity = 0.0;
    scale = Vector2.all(1.0);
    currentEvent = EventHorizontalObstacle.stopMoving;
  }

  // ── helpers
  Anchor _hAnchor(String a, {bool top = true}) {
    switch (a.toLowerCase()) {
      case 'center':
        return top ? Anchor.topCenter : Anchor.center;
      case 'right':
        return top ? Anchor.topRight : Anchor.centerRight;
      default:
        return top ? Anchor.topLeft : Anchor.centerLeft;
    }
  }

  Vector2 _optionTextPos(String a, Vector2 boxSize, double pad) {
    switch (a.toLowerCase()) {
      case 'center':
        return Vector2(boxSize.x / 2, boxSize.y / 2);
      case 'right':
        return Vector2(boxSize.x - pad, boxSize.y / 2);
      default:
        return Vector2(pad, boxSize.y / 2);
    }
  }

  TextAlign _textAlignOf(String a, {TextAlign fallback = TextAlign.center}) {
    switch (a.toLowerCase()) {
      case 'left':
        return TextAlign.left;
      case 'right':
        return TextAlign.right;
      case 'center':
      default:
        return fallback;
    }
  }

  Color _outerColor() => fillColors[0].withOpacity(opacities[0]);
  Color _innerColor() => fillColors[1].withOpacity(opacities[1]);
  Color _correctColor() => fillColors[2].withOpacity(opacities[2]);
  Color _wrongColor() => fillColors[3].withOpacity(opacities[2]);

  static const double _lh = 1.25;
  static const double _innerTextPad = 14;

  void _buildQuestionAndOptions() {
    // Question positioning
    final String qAlign = alignments[0];
    final double contentLeft = padding[3];
    final double contentRight = padding[4];
    final double contentWidth = math.max(
      0,
      size.x - contentLeft - contentRight,
    );
    final double topBottom = padding[0];
    final double qHeight = textSizes[0] * _lh;

    final Vector2 qPos;
    final Anchor qAnchor;
    switch (qAlign.toLowerCase()) {
      case 'center':
        qPos = Vector2(size.x / 2, topBottom);
        qAnchor = Anchor.topCenter;
        break;
      case 'right':
        qPos = Vector2(size.x - contentRight, topBottom);
        qAnchor = Anchor.topRight;
        break;
      default:
        qPos = Vector2(contentLeft, topBottom);
        qAnchor = Anchor.topLeft;
    }

    add(
      TextComponent(
        text: questions.join(' '),
        textRenderer: TextPaint(
          style: GoogleFonts.lato(
            fontSize: textSizes[0],
            color: textColors[0],
            fontWeight: FontWeight.w700,
          ),
        ),
        position: qPos,
        anchor: qAnchor,
      ),
    );

    // Options
    final int n = answers.length;
    final double firstOptionsTop = topBottom + qHeight + padding[1];
    final double usableW = contentWidth;
    final double optW = math.min(innerBoxSize.x, usableW);
    final double optH = innerBoxSize.y;
    final double optStartX = contentLeft + (usableW - optW) / 2;

    for (int i = 0; i < n; i++) {
      final y = firstOptionsTop + i * (optH + padding[2]);
      add(
        _Option(
          index: i,
          label: answers[i],
          size: Vector2(optW, optH),
          position: Vector2(optStartX, y),
          radius: math.min(borderRadius, optH / 2),
          baseColor: _innerColor(),
          selectedCorrect: _correctColor(),
          selectedWrong: _wrongColor(),
          textColor: textColors[1],
          textSize: textSizes[1],
          textAnchor: _hAnchor(alignments[1], top: false),
          textPos: _optionTextPos(
            alignments[1],
            Vector2(optW, optH),
            _innerTextPad,
          ),
          onTap: _handleTap,
        ),
      );
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _buildQuestionAndOptions();
  }

  void switchPhase(EventHorizontalObstacle phase) {
    if (phase == currentEvent) return;
    currentEvent = phase;
    if (phase == EventHorizontalObstacle.startMoving) {
      _enterStart();
    } else {
      _enterStop();
    }
  }

  void _killFade() {
    _fadeFx?.removeFromParent();
    _fadeFx = null;
  }

  // utilities for close button lifecycle
  void _addCloseButton() {
    _disposeCloseButton();
    const double pad = 8.0;
    _closeBtn = _CloseXButton(
      size: Vector2(24, 24),
      position: Vector2(size.x - pad, pad),
      anchor: Anchor.topRight,
      onPressed: () {
        // close first
        switchPhase(EventHorizontalObstacle.stopMoving);
        // then external callback (if provided)
        onClosePressed?.call(); // [ADDED]
      },
    );
    add(_closeBtn!);
  }

  void _disposeCloseButton() {
    _closeBtn?.removeFromParent();
    _closeBtn = null;
  }

  void _enterStart() {
    _acceptInput = false;
    _selected = null;
    _showingExplanation = false;
    _explanationText = null;

    _disposeCloseButton();

    removeAll(children.toList());
    _buildQuestionAndOptions();

    _killFade();
    final dur = (showDuration.isFinite && showDuration > 0.05)
        ? showDuration
        : 0.35;
    _fadeFx = OpacityEffect.to(
      1.0,
      EffectController(duration: dur, curve: Curves.easeOutCubic),
      onComplete: () => _acceptInput = true,
    );
    add(_fadeFx!);
  }

  void _enterStop() {
    _acceptInput = false;
    _killFade();

    _disposeCloseButton();

    final dur = (hideDuration.isFinite && hideDuration > 0.05)
        ? hideDuration
        : 0.20;
    _fadeFx = OpacityEffect.to(
      0.0,
      EffectController(duration: dur, curve: Curves.easeInQuad),
    );
    add(_fadeFx!);
  }

  @override
  void renderTree(Canvas canvas) {
    if (_hidden) return;

    if (opacity >= 0.999) {
      super.renderTree(canvas);
      return;
    }
    final paint = Paint()..color = const Color(0xFFFFFFFF).withOpacity(opacity);
    canvas.saveLayer(null, paint);
    super.renderTree(canvas);
    canvas.restore();
  }

  @override
  void render(Canvas canvas) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Radius.circular(borderRadius),
    );
    canvas.drawRRect(rrect, Paint()..color = _outerColor());

    // draw explanation (if any) BEFORE children so the close button sits on top
    if (_showingExplanation &&
        _explanationText != null &&
        _explanationText!.isNotEmpty) {
      final double topBottom = padding[0];
      final double contentLeft = padding[3];
      final double contentRight = padding[4];

      final double contentWidth = math.max(
        0,
        size.x - contentLeft - contentRight,
      );
      final double contentTop = topBottom;
      final double contentBottom = size.y - topBottom;
      final double contentHeight = math.max(0, contentBottom - contentTop);

      final Rect clipRect = Rect.fromLTWH(
        contentLeft,
        contentTop,
        contentWidth,
        contentHeight,
      );
      canvas.save();
      canvas.clipRect(clipRect);

      canvas.translate(contentLeft, contentTop);

      final String explainAlignStr = (alignments.length >= 3)
          ? alignments[2]
          : 'center';
      final TextAlign explainAlign = _textAlignOf(explainAlignStr);

      final TextStyle effectiveStyle =
          explanationTextStyle ??
          GoogleFonts.lato(
            fontSize: explanationFontSize ?? textSizes[0],
            color: explanationColor ?? textColors[0],
            fontWeight: explanationFontWeight ?? FontWeight.w700,
            fontStyle: explanationFontStyle ?? FontStyle.normal,
            letterSpacing: explanationLetterSpacing,
          );

      final painter = TextPainter(
        text: TextSpan(text: _explanationText, style: effectiveStyle),
        textAlign: explainAlign,
        textDirection: TextDirection.ltr,
      )..layout(minWidth: contentWidth, maxWidth: contentWidth);

      final double dy = (contentHeight - painter.height) / 2.0;
      painter.paint(canvas, Offset(0, dy));
      canvas.restore();
    }

    super.render(canvas);
  }

  Future<void> dismissAfter(Duration d) async {
    await Future.delayed(d);
    switchPhase(EventHorizontalObstacle.stopMoving);
  }

  void _showExplanation(bool isCorrect) {
    removeAll(children.whereType<_Option>().toList());
    removeAll(children.whereType<TextComponent>().toList()); // remove question
    _showingExplanation = true;
    _explanationText = isCorrect
        ? answerExplanations![0]
        : answerExplanations![1];
    _addCloseButton();
  }

  void _handleTap(int index) {
    if (!_acceptInput || _selected != null) return;
    _selected = index;

    for (final o in children.whereType<_Option>()) {
      o.updateSelection(index, correctAnswerIndex);
    }

    final bool isCorrect = index == correctAnswerIndex;

    if (answerExplanations != null && answerExplanations!.length >= 2) {
      _acceptInput = false;

      Future.delayed(
        Duration(milliseconds: (selectedHoldSeconds * 1000).round()),
        () {
          if (parent == null) return;
          if (currentEvent != EventHorizontalObstacle.startMoving) return;
          if (_showingExplanation) return;

          _showExplanation(isCorrect);
        },
      );
      return;
    }

    if (callbacks != null && callbacks!.length >= 2) {
      if (isCorrect) {
        callbacks![0]();
      } else {
        callbacks![1]();
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────────

class _Option extends PositionComponent with TapCallbacks {
  final int index;
  final String label;
  final double radius;
  final Color baseColor, selectedCorrect, selectedWrong;
  final Color textColor;
  final double textSize;
  final Anchor textAnchor;
  final Vector2 textPos;
  final void Function(int index) onTap;

  bool _selected = false;
  bool _isCorrect = false;

  _Option({
    required this.index,
    required this.label,
    required Vector2 size,
    required Vector2 position,
    required this.radius,
    required this.baseColor,
    required this.selectedCorrect,
    required this.selectedWrong,
    required this.textColor,
    required this.textSize,
    required this.textAnchor,
    required this.textPos,
    required this.onTap,
  }) : super(size: size, position: position, anchor: Anchor.topLeft);

  late final TextComponent _text;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _text = TextComponent(
      text: label,
      anchor: textAnchor,
      position: textPos,
      textRenderer: TextPaint(
        style: GoogleFonts.lato(
          fontSize: textSize,
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
    add(_text);
  }

  void updateSelection(int selectedIndex, int correctIndex) {
    _selected = selectedIndex == index;
    _isCorrect = correctIndex == index;
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = _selected
          ? (_isCorrect ? selectedCorrect : selectedWrong)
          : baseColor;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Radius.circular(radius),
    );
    canvas.drawRRect(rrect, paint);
    super.render(canvas);
  }

  @override
  void onTapUp(TapUpEvent event) {
    onTap(index);
    super.onTapUp(event);
  }
}

// ─────────────────────────────────────────────────────────────────
// Minimal Flame close “X” button component.

class _CloseXButton extends PositionComponent with TapCallbacks {
  final VoidCallback onPressed;

  _CloseXButton({
    required Vector2 size,
    required Vector2 position,
    required Anchor anchor,
    required this.onPressed,
  }) : super(size: size, position: position, anchor: anchor);

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final bgPaint = Paint()..color = const Color(0xCC000000);
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      const Radius.circular(8),
    );
    canvas.drawRRect(r, bgPaint);

    final stroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    const double inset = 8;
    canvas.drawLine(
      Offset(inset, inset),
      Offset(size.x - inset, size.y - inset),
      stroke,
    );
    canvas.drawLine(
      Offset(size.x - inset, inset),
      Offset(inset, size.y - inset),
      stroke,
    );
  }

  @override
  void onTapUp(TapUpEvent event) {
    onPressed();
    super.onTapUp(event);
  }
}
