import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/events/event_type.dart';

class McqBox extends PositionComponent implements OpacityProvider {
  // data
  final List<String> questions;
  final List<String> answers;
  final int correctAnswerIndex;

  // layout
  final Vector2 outerBoxSize;
  final Vector2 innerBoxSize;

  /// alignments: [question, answers, (optional) explanation]
  final List<String> alignments; // [question, answers, explanation?]
  final List<double> padding; // [topBottom, qToOptions, between, left, right]
  final double borderRadius;

  // style
  final List<double> opacities; // [outer, inner, selected]
  final List<Color> textColors; // [question, answer]
  final List<Color> fillColors; // [outer, inner, correct, wrong]
  final List<double> textSizes; // [question, answer]

  // callbacks (optional)
  final List<VoidCallback>? callbacks; // [onCorrect, onWrong]

  // animation config
  final double showDuration;
  final double hideDuration;

  // optional explanations [0]=correct text, [1]=wrong text
  final List<String>? answerExplanations;

  // --- NEW: optional styling overrides for explanation text ---
  final double? explanationFontSize;
  final FontWeight? explanationFontWeight;
  final FontStyle? explanationFontStyle; // e.g., FontStyle.italic
  final double? explanationLetterSpacing;
  final Color? explanationColor;

  /// If provided, this takes precedence over the fields above.
  final TextStyle? explanationTextStyle;

  // state
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

  // explanation mode
  bool _showingExplanation = false;
  String? _explanationText;

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

    // NEW: explanation style overrides (all optional)
    this.explanationFontSize,
    this.explanationFontWeight,
    this.explanationFontStyle,
    this.explanationLetterSpacing,
    this.explanationColor,
    this.explanationTextStyle,
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

  // Helpers
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

  void _enterStart() {
    _acceptInput = false;
    _selected = null;
    _showingExplanation = false;
    _explanationText = null;

    removeAll(children.toList());
    _buildQuestionAndOptions();

    _killFade();
    final dur = (showDuration.isFinite && showDuration > 0.05)
        ? showDuration
        : 0.35;
    _fadeFx = OpacityEffect.to(
      1.0,
      EffectController(duration: dur, curve: Curves.easeOutCubic),
      onComplete: () {
        _acceptInput = true;
      },
    );
    add(_fadeFx!);
  }

  void _enterStop() {
    _acceptInput = false;
    _killFade();
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
    super.render(canvas);

    // Explanation: align using alignments[2] if provided; else center (legacy)
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

      // Clip to padded content area
      final Rect clipRect = Rect.fromLTWH(
        contentLeft,
        contentTop,
        contentWidth,
        contentHeight,
      );
      canvas.save();
      canvas.clipRect(clipRect);

      // Local origin = top-left of the content area
      canvas.translate(contentLeft, contentTop);

      final String explainAlignStr = (alignments.length >= 3)
          ? alignments[2]
          : 'center';
      final TextAlign explainAlign = _textAlignOf(explainAlignStr);

      // --- Build the explanation TextStyle with overrides (or full override) ---
      final TextStyle effectiveStyle =
          explanationTextStyle ??
          GoogleFonts.lato(
            fontSize: explanationFontSize ?? textSizes[0],
            color: explanationColor ?? textColors[0],
            fontWeight: explanationFontWeight ?? FontWeight.w700,
            fontStyle:
                explanationFontStyle ??
                FontStyle.normal, // set to FontStyle.italic for italics
            letterSpacing: explanationLetterSpacing,
          );

      final painter = TextPainter(
        text: TextSpan(text: _explanationText, style: effectiveStyle),
        textAlign: explainAlign,
        textDirection: TextDirection.ltr,
      );

      // Lock layout width to contentWidth so alignment is exact within the box
      painter.layout(minWidth: contentWidth, maxWidth: contentWidth);

      final double contentH = painter.height;
      final double dy = (contentHeight - contentH) / 2.0; // vertical center
      painter.paint(
        canvas,
        Offset(0, dy), // x at 0; TextAlign handles left/center/right
      );
      canvas.restore();
    }
  }

  Future<void> dismissAfter(Duration d) async {
    await Future.delayed(d);
    switchPhase(EventHorizontalObstacle.stopMoving);
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
      removeAll(children.whereType<_Option>().toList());
      removeAll(
        children.whereType<TextComponent>().toList(),
      ); // remove question
      _showingExplanation = true;
      _explanationText = isCorrect
          ? answerExplanations![0]
          : answerExplanations![1];
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

// ---------------------------------------------------------------

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
