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
  final List<String> alignments; // [question, answers]
  final List<double> padding; // [topBottom, qToOptions, between, left, right]
  final double borderRadius;

  // style
  final List<double> opacities; // [outer, inner, selected]
  final List<Color> textColors; // [question, answer]
  final List<Color> fillColors; // [outer, inner, correct, wrong]
  final List<double> textSizes; // [question, answer]

  // callbacks
  final List<VoidCallback> callbacks; // [onCorrect, onWrong]

  // animation config
  final double showDuration;
  final double hideDuration;

  // state
  int? _selected;
  bool _acceptInput = false;
  double _opacity = 0.0; // start hidden
  @override
  double get opacity => _opacity;
  @override
  set opacity(double v) => _opacity = v.clamp(0.0, 1.0);

  EventHorizontalObstacle currentEvent = EventHorizontalObstacle.stopMoving;
  double _t = 0.0;

  // CHANGE: single place to decide hidden-ness
  bool get _hidden =>
      currentEvent == EventHorizontalObstacle.stopMoving || opacity <= 0.0001;

  McqBox({
    required this.questions,
    required this.answers,
    required this.correctAnswerIndex,
    required this.outerBoxSize,
    required this.innerBoxSize,
    required this.alignments,
    required this.padding,
    required this.borderRadius,
    required Anchor anchor,
    required Vector2 position,
    required this.opacities,
    required this.textColors,
    required this.fillColors,
    required this.textSizes,
    required this.callbacks,
    required this.showDuration,
    required this.hideDuration,
  }) : super(size: outerBoxSize, anchor: anchor, position: position) {
    opacity = 0.0; // hidden at start
    scale = Vector2.all(1.0);
    currentEvent = EventHorizontalObstacle.stopMoving;
    _enterStop();
  }

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

  Color _outerColor() => fillColors[0].withOpacity(opacities[0]);
  Color _innerColor() => fillColors[1].withOpacity(opacities[1]);
  Color _correctColor() => fillColors[2].withOpacity(opacities[2]);
  Color _wrongColor() => fillColors[3].withOpacity(opacities[2]);

  static const double _lh = 1.25;
  static const double _innerTextPad = 14;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Question
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

  // PHASE ENTRY
  void switchPhase(EventHorizontalObstacle phase) {
    if (phase == currentEvent) return;
    currentEvent = phase;
    if (phase == EventHorizontalObstacle.startMoving) {
      _enterStart();
    } else {
      _enterStop();
    }
  }

  void _enterStart() {
    _acceptInput = false;
    _selected = null;
    _t = 0.0;
    opacity = 0.0;
    scale = Vector2.all(1.06);
  }

  void _enterStop() {
    _acceptInput = false;
    _t = 0.0;
    opacity = 0.0;
    scale = Vector2.all(1.0);
  }

  // UPDATE (state machine)
  @override
  void update(double dt) {
    super.update(dt);
    switch (currentEvent) {
      case EventHorizontalObstacle.stopMoving:
        // stay hidden
        break;
      case EventHorizontalObstacle.startMoving:
        // fade + scale in
        if (opacity < 1.0 || scale.x > 1.0) {
          _t += dt;
          final p = (_t / showDuration).clamp(0.0, 1.0);
          opacity = p;
          scale = Vector2.all(1.06 - 0.06 * p);
          if (p >= 1.0) _acceptInput = true;
        }
        break;
    }
  }

  // CHANGE: block the entire subtree when hidden
  @override
  void renderTree(Canvas canvas) {
    if (_hidden) return; // nothing, including children
    super.renderTree(canvas);
  }

  // (render draws the card when visible; children draw inside)
  @override
  void render(Canvas canvas) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Radius.circular(borderRadius),
    );
    canvas.drawRRect(rrect, Paint()..color = _outerColor());
    super.render(canvas);
  }

  Future<void> dismissAfter(Duration d) async {
    await Future.delayed(d);
    switchPhase(EventHorizontalObstacle.stopMoving);
  }

  void _handleTap(int index) {
    if (!_acceptInput || _selected != null) return;
    _selected = index;
    if (index == correctAnswerIndex) {
      callbacks[0]();
    } else {
      callbacks[1]();
    }
    for (final o in children.whereType<_Option>()) {
      o.updateSelection(index, correctAnswerIndex);
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
