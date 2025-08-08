// lesson_progress_bar.dart
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:running_robot/events/event_type.dart';

class LessonProgressBar extends PositionComponent {
  // ───────── VISUAL TUNING (Duolingo/Brilliant vibe) ─────────
  // Smaller length, thicker height, full pill radius
  static const double _width = 279; // CHANGED: shorter
  static const double _height = 20; // CHANGED: thicker
  static const double _radius = _height / 2; // CHANGED: pill

  // Track "glass" base (we'll apply opacity dynamically for initial vs active)
  static const Color _trackBase = Color(0xFFFFFFFF); // CHANGED: white glass
  static const double _trackAlphaInitial =
      0.35; // CHANGED: almost transparent on initial
  static const double _trackAlphaActive =
      0.55; // CHANGED: a bit more visible after progress

  // Border is very subtle; Brilliant-ish crisp but quiet
  static const Color _borderColor = Color(0xFF0F172A); // slate-esque
  static const double _borderAlpha = 0.10; // CHANGED: very light stroke

  // Fill: bright Duo green, softened; we also drop alpha on initial to feel airy
  static const Color _fillStart = Color(0xFF00E676); // bright green
  static const Color _fillEnd = Color(0xFF00C853); // deeper green
  static const double _fillAlphaInitial = 0.65; // CHANGED: softer when initial
  static const double _fillAlphaActive = 0.95;

  // A faint outer glow when active, keeps it friendly and modern
  static const double _glowAlpha = 0.18; // CHANGED

  // Step animation
  static const double _stepDuration = 0.50; // seconds per stage
  EventProgressBar currentEvent = EventProgressBar.initial;

  // ───────── State ─────────
  final int totalStages;
  int _stage = 0;
  double _progress = 0.0; // 0..1
  double _from = 0.0, _to = 0.0;
  double _t = 0.0;
  bool _animating = false;

  LessonProgressBar({
    required Vector2 position,
    required int stages,
  }) : totalStages = stages.clamp(1, 999999),
       super(
         position: position,
         size: Vector2(_width, _height),
         anchor: Anchor.topCenter,
       );

  // ───────── Events API ─────────
  void switchPhase(EventProgressBar phase) {
    switch (phase) {
      case EventProgressBar.initial:
        _reset();
        break;
      case EventProgressBar.proceed:
        _proceed();
        break;
      case EventProgressBar.finish:
        _finish();
        break;
    }
  }

  // ───────── Internal actions ─────────
  void _reset() {
    currentEvent = EventProgressBar.initial;
    _stage = 0;
    _animating = false;
    _t = 0;
    _from = _to = _progress = 0.0;
  }

  void _proceed() {
    if (_stage >= totalStages) return;
    _stage += 1;
    _goToStage(_stage);
    currentEvent = EventProgressBar.proceed;
  }

  void _finish() {
    _stage = totalStages;
    _goToStage(_stage);
    currentEvent = EventProgressBar.finish;
  }

  void _goToStage(int stage) {
    _from = _progress;
    _to = (stage / totalStages).clamp(0.0, 1.0);
    _t = 0;
    _animating = true;
  }

  // Ease-out cubic
  static double _easeOut(double x) {
    final p = 1 - x;
    return 1 - p * p * p;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_animating) return;

    _t += dt;
    final u = (_t / _stepDuration).clamp(0.0, 1.0);
    final e = _easeOut(u);
    _progress = _from + (_to - _from) * e;

    if (u >= 1.0) {
      _progress = _to;
      _animating = false;
      currentEvent = EventProgressBar.initial; // back to idle look
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(_radius));

    // Decide "initial vs active" presentation
    final bool isInitialLook =
        currentEvent == EventProgressBar.initial && _progress <= 0.0001;
    final double trackAlpha = isInitialLook
        ? _trackAlphaInitial
        : _trackAlphaActive;
    final double fillAlpha = isInitialLook
        ? _fillAlphaInitial
        : _fillAlphaActive;

    // ── TRACK: frosted glass (vertical subtle gradient, semi-transparent)
    final trackPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          _trackBase.withOpacity(trackAlpha + 0.08), // top slight highlight
          _trackBase.withOpacity(trackAlpha), // bottom
        ],
      ).createShader(rect);
    canvas.drawRRect(rrect, trackPaint);

    // ── BORDER: very faint crisp outline
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = _borderColor.withOpacity(_borderAlpha);
    canvas.drawRRect(rrect, borderPaint);

    // ── STAGE MARKS: tiny separators (only if a reasonable number of stages)
    if (totalStages > 1 && totalStages <= 12) {
      final sepPaint = Paint()
        ..strokeWidth = 1
        ..color = _borderColor.withOpacity(0.10);
      final double stepW = size.x / totalStages;
      for (int i = 1; i < totalStages; i++) {
        final x = stepW * i;
        canvas.drawLine(Offset(x, 4), Offset(x, size.y - 4), sepPaint);
      }
    }

    // ── FILL
    final fillW = (size.x * _progress).clamp(0.0, size.x);
    if (fillW > 0) {
      final dynR = fillW < _radius * 2 ? fillW / 2 : _radius;
      final fillRect = Rect.fromLTWH(0, 0, fillW, size.y);
      final fillRRect = RRect.fromRectAndRadius(
        fillRect,
        Radius.circular(dynR),
      );

      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            _fillStart.withOpacity(fillAlpha),
            _fillEnd.withOpacity(fillAlpha),
          ],
        ).createShader(fillRect);
      canvas.drawRRect(fillRRect, fillPaint);

      // Subtle top gloss on fill (keeps it lively without plastic look)
      final glossRect = Rect.fromLTWH(0, 0, fillW, size.y * 0.52);
      final glossPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withOpacity(isInitialLook ? 0.14 : 0.10),
            Colors.white.withOpacity(0.00),
          ],
        ).createShader(glossRect);
      canvas.drawRRect(
        RRect.fromRectAndRadius(glossRect, Radius.circular(dynR)),
        glossPaint,
      );

      // Faint inner edge for definition
      final innerEdge = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = Colors.black.withOpacity(0.05);
      canvas.drawRRect(fillRRect.deflate(0.4), innerEdge);

      // Soft outer glow when active (accent, Duo-like friendliness)
      if (!isInitialLook) {
        final glowPaint = Paint()
          ..color = _fillEnd.withOpacity(_glowAlpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);
        canvas.save();
        canvas.clipRRect(rrect); // keep glow within pill
        canvas.drawRRect(fillRRect, glowPaint);
        canvas.restore();
      }
    }
  }

  // ───────── Helpers ─────────
  int get currentStage => _stage;
  double get progress => _progress;
}
