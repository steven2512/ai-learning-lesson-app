// pause_button.dart
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:running_robot/events/event_type.dart';

class PauseButton extends PositionComponent
    with TapCallbacks, HasGameRef<FlameGame> {
  // ───────── Transparent interior ─────────
  static const double _defaultDiameter = 34;
  static const double _borderAlpha = 0.03;
  static const double _shadowAlpha = 0.02; // CHANGED: use with drawShadow
  static const double _haloAlpha = 0.035;

  static const Color _border = Color(0xFF0F172A);
  static const Color _iconColor = Color(0xFF111827);

  bool _paused;
  bool _pressed = false;
  bool _visible = true;

  EventButton currentEvent = EventButton.unpressed;

  final VoidCallback? onPause;
  final VoidCallback? onResume;

  PauseButton({
    required Vector2 position,
    double diameter = _defaultDiameter,
    bool startPaused = false,
    this.onPause,
    this.onResume,
  }) : _paused = startPaused,
       super(
         position: position,
         size: Vector2.all(diameter),
         anchor: Anchor.topRight,
         priority: 10000,
       );

  @override
  Future<void> onLoad() async {
    if (_paused) onPause?.call();
  }

  void switchPhase(EventButton event) {
    currentEvent = event;
    switch (event) {
      case EventButton.unpressed:
        _pressed = false;
        break;
      case EventButton.pressed:
        break;
      case EventButton.hold:
        break;
    }
  }

  void trigger() => _toggle();

  void setPaused(bool v) {
    if (_paused == v) return;
    _paused = v;
    if (_paused) {
      onPause?.call();
    } else {
      onResume?.call();
    }
  }

  void _toggle() => setPaused(!_paused);

  // ───────── Input ─────────
  @override
  void onTapDown(TapDownEvent event) {
    _pressed = true;
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    _pressed = false;
  }

  @override
  void onTapUp(TapUpEvent event) {
    _pressed = false;
    _toggle();
  }

  // ───────── Render ─────────
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (!_visible) return;

    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final r = size.x / 2;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(r));

    // ✅ SHADOW WITHOUT FILL: drawShadow paints only outside the shape
    // (Your previous blurred fill was tinting the inside.)
    final path = Path()..addRRect(rrect); // CHANGED
    canvas.save(); // CHANGED
    canvas.translate(0, 1); // CHANGED
    canvas.drawShadow(
      // CHANGED
      path,
      Colors.black.withOpacity(_shadowAlpha),
      2.5, // elevation; tweak to taste
      false,
    );
    canvas.restore(); // CHANGED

    // NO FILL: keep interior fully transparent

    // Whisper-thin border
    final border = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = _border.withOpacity(_borderAlpha);
    canvas.drawRRect(rrect, border);

    // Airy outer halo
    final halo = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = _border.withOpacity(_haloAlpha);
    canvas.drawRRect(rrect.inflate(1.0), halo);

    // Icon on transparent background
    _paused ? _drawPlayIcon(canvas, 0.58) : _drawPauseIcon(canvas, 0.56);
  }

  void _drawPauseIcon(Canvas canvas, double alpha) {
    final paint = Paint()..color = _iconColor.withOpacity(alpha);
    final w = size.x, h = size.y;
    final barW = w * 0.10;
    final gap = w * 0.10;
    final barH = h * 0.40;
    final top = (h - barH) / 2;
    final left1 = (w - (barW * 2 + gap)) / 2;
    final left2 = left1 + barW + gap;
    final r = Radius.circular(barW / 2);

    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(left1, top, barW, barH), r),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(left2, top, barW, barH), r),
      paint,
    );
  }

  void _drawPlayIcon(Canvas canvas, double alpha) {
    final paint = Paint()..color = _iconColor.withOpacity(alpha);
    final w = size.x, h = size.y;
    final triW = w * 0.34;
    final triH = h * 0.40;
    final cx = w / 2 - w * 0.02, cy = h / 2;

    final path = Path()
      ..moveTo(cx - triW / 2, cy - triH / 2)
      ..lineTo(cx - triW / 2, cy + triH / 2)
      ..lineTo(cx + triW / 2, cy)
      ..close();
    canvas.drawPath(path, paint);
  }
}
