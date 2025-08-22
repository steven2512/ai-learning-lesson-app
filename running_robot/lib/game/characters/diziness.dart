// lib/effects/diziness.dart — FULL FILE (rings only, with delay + auto-despawn)

import 'dart:math' as math;
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:running_robot/game/events/event_type.dart'; // [ADDED] for currentEvent

class Diziness extends PositionComponent {
  // ───────── Visual config ─────────
  final double _radius; // base X radius of the rings
  final double _gap; // vertical gap between the two rings
  final double _squash; // 0..1, 1 = flat line, 0 = perfect circle
  final double _lineWidth; // ring stroke width
  final double _blurSigma; // glow blur
  final double _speed1; // ring 1 spin
  final double _speed2; // ring 2 spin
  final double _bobAmp; // vertical bob amplitude
  final double _wobbleAmp; // scale wobble amplitude
  final Color _ringColor; // core stroke
  final Color _glowColor; // outer glow

  // ───────── Timing ─────────
  final double delay; // seconds to wait before showing
  final double duration; // seconds to stay visible (then fade out & remove)
  final double _fadeOut; // seconds used for fade-out tail

  // Runtime
  double _clock = 0.0; // total elapsed since spawned
  double _t = 0.0; // animation time (only runs while visible)
  double _a1 = 0.0;
  double _a2 = 0.0;

  // [ADDED] Event state for consistency with the project’s components
  EventHorizontalObstacle currentEvent = EventHorizontalObstacle.stopMoving;

  Diziness({
    required Vector2 position,
    double radius = 38,
    double gap = 12,
    this.delay = 1.5,
    this.duration = 4.0,
  })  : _radius = radius,
        _gap = gap,
        _squash = 0.38,
        _lineWidth = 2.2,
        _blurSigma = 6.0,
        _speed1 = 1.6,
        _speed2 = -2.0,
        _bobAmp = 2.5,
        _wobbleAmp = 0.04,
        _ringColor = const Color.fromARGB(255, 255, 245, 200), // pale gold
        _glowColor = const Color.fromARGB(180, 255, 255, 255), // soft white
        _fadeOut = 0.45, // gentle exit
        super(
          size: Vector2((radius * 2) + 30, (radius * 2) + 30),
          anchor: Anchor.center,
        ) {
    this.position = position;
    currentEvent = EventHorizontalObstacle.stopMoving; // [ADDED] initial state
  }

  bool get _isVisible =>
      _clock >= delay && _clock < delay + duration + _fadeOut;

  // 0..1 overall opacity (handles fade-in-after-delay=instant on, and fade-out)
  double get _alpha {
    if (_clock < delay) return 0.0;
    final tVis = _clock - delay;
    if (tVis < duration) return 1.0;
    final tFade = tVis - duration;
    if (tFade >= _fadeOut) return 0.0;
    return 1.0 - (tFade / _fadeOut);
  }

  @override
  void update(double dt) {
    super.update(dt);

    _clock += dt;

    if (_isVisible) {
      _t += dt;
      _a1 += _speed1 * dt;
      _a2 += _speed2 * dt;
    }

    // Auto-remove after fade-out completes
    if (_clock >= delay + duration + _fadeOut) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final opacity = _alpha;
    if (opacity <= 0) return;

    // Small vertical bob and subtle scale wobble
    final bob = math.sin(_t * 3.2) * _bobAmp;
    final wobble = 1.0 + math.sin(_t * 2.4) * _wobbleAmp;

    // Base radii
    final rx = _radius * wobble;
    final ry = _radius * (1.0 - _squash) * wobble;

    // Paints: soft glow + crisp core, both modulated by opacity
    final glow = Paint()
      ..color = _glowColor.withOpacity(_glowColor.opacity * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = _lineWidth * 2.4
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, _blurSigma);

    final core = Paint()
      ..color = _ringColor.withOpacity(_ringColor.opacity * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = _lineWidth;

    // Ring 1 (upper)
    canvas.save();
    canvas.translate(0, bob - _gap * 0.5);
    canvas.rotate(_a1);
    _drawRing(canvas, rx, ry, glow, core);
    canvas.restore();

    // Ring 2 (lower)
    canvas.save();
    canvas.translate(0, bob + _gap * 0.5);
    canvas.rotate(_a2);
    _drawRing(canvas, rx * 0.9, ry * 0.9, glow, core);
    canvas.restore();
  }

  void _drawRing(Canvas canvas, double rx, double ry, Paint glow, Paint core) {
    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: rx * 2,
      height: ry * 2,
    );
    canvas.drawOval(rect, glow);
    canvas.drawOval(rect, core);
  }

  // [ADDED] Reset all runtime state back to the initial spawn conditions.
  void reset() {
    _clock = 0.0;
    _t = 0.0;
    _a1 = 0.0;
    _a2 = 0.0;
    currentEvent = EventHorizontalObstacle.stopMoving; // most important
    // Note: size/position/anchor/config remain as constructed.
    // If this component had been removed from parent, re-adding is external.
  }
}
