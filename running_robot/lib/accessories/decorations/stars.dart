// lib/accessories/decorations/stars.dart
// One-asset star (mold-only). Left→right fill in ~1.0s.

import 'dart:math' as math;
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:running_robot/accessories/events/event_type.dart';

class Star extends PositionComponent {
  final String moldPath;
  // Kept names for compatibility; now used as LEFT/RIGHT colors
  final Color fillTop; // left color
  final Color fillBottom; // right color
  final double angleDeg;

  double value = 0.0;

  // Slower animation: ~1s to full
  static const double _fillDuration = 3.0;
  static const double _finishDuration = 0.45;

  bool _animating = false;
  double _t = 0.0, _start = 0.0, _target = 0.0, _duration = _fillDuration;

  Sprite? _mold;
  EventProgressBar currentEvent = EventProgressBar.initial;

  Star({
    required Vector2 position,
    required Vector2 size,
    this.moldPath = 'star_empty.png',
    this.fillTop = const Color(0xFFFFF08A), // left
    this.fillBottom = const Color(0xFFFFC107), // right
    this.angleDeg = 0,
  }) : super(position: position, size: size, anchor: Anchor.center) {
    angle = angleDeg * math.pi / 180.0;
  }

  @override
  Future<void> onLoad() async {
    _mold = await Sprite.load(moldPath);
  }

  void switchPhase(EventProgressBar phase) {
    currentEvent = phase;
    switch (phase) {
      case EventProgressBar.initial:
        reset();
        break;
      case EventProgressBar.proceed:
        fill();
        break;
      case EventProgressBar.finish:
        finish();
        break;
    }
  }

  // One-time commands; update() drives the motion.
  void fill() {
    _start = value;
    _target = 1.0;
    _duration = _fillDuration;
    _t = 0;
    _animating = true;
  }

  void finish() {
    _start = value;
    _target = 1.0;
    _duration = _finishDuration;
    _t = 0;
    _animating = true;
  }

  void reset() {
    value = 0.0;
    _animating = false;
    _t = 0.0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_animating) {
      _t += dt / _duration;
      final e = _easeOutCubic(_t.clamp(0.0, 1.0));
      value = _start + (_target - _start) * e;
      if (_t >= 1.0) _animating = false;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (_mold == null) return;

    final rect = Rect.fromLTWH(0, 0, size.x, size.y);

    // Draw mold first (keeps soft edges/shadow visible)
    _mold!.renderRect(canvas, rect);

    // Left→Right fill (horizontal clip)
    if (value > 0) {
      final clipW = size.x * value;
      final clipRect = Rect.fromLTWH(0, 0, clipW, size.y);

      canvas.saveLayer(rect, Paint()); // start mask layer
      canvas.save();
      canvas.clipRect(clipRect);

      final gradPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [fillTop, fillBottom], // left → right gradient
        ).createShader(rect);

      canvas.drawRect(rect, gradPaint);
      canvas.restore();

      // Mask to mold alpha
      _mold!.renderRect(
        canvas,
        rect,
        overridePaint: Paint()..blendMode = BlendMode.dstIn,
      );
      canvas.restore(); // end layer
    }
  }

  double _easeOutCubic(double t) {
    final p = 1 - t;
    return 1 - p * p * p;
  }
}
