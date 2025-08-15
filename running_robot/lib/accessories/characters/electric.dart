// lib/effects/electric.dart — FULL FILE (copy/paste)

import 'dart:math' as math;
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:running_robot/accessories/events/event_type.dart';

/// Electric: elegant, animated lightning/sizzle line.
/// Start/stop via EventHorizontalObstacle events.
class Electric extends PositionComponent {
  // ────────── Style ──────────
  static const Color _coreColor = Color(0xFFFFFFFF); // white core
  static const Color _glowColor = Color(0xFF00E5FF); // vibrant cyan
  static const double _coreWidth = 2.0; // CHANGED: slightly thinner
  static const double _glowWidthMul = 2.9; // CHANGED: narrower glow
  static const double _glowSigma = 6.0; // CHANGED: softer blur

  // ────────── Shape/Anim ──────────
  static const int _segments = 26;
  static const int _strands = 2; // CHANGED: slimmer look
  static const double _amplitude = 9.0; // CHANGED: narrower wiggle
  static const double _speed = 6.0;
  static const double _freq = 0.55;
  static const double _jitter = 0.7; // CHANGED: calmer micro-noise

  // CHANGED: stronger bow for rounder wrap (0..1 of height)
  static const double _bowFrac = 0.58;

  // ────────── State ──────────
  EventHorizontalObstacle currentEvent = EventHorizontalObstacle.stopMoving;
  bool _active = false;
  double _t = 0.0;

  // CHANGED: per-instance variation so multiple waves don’t coincide
  final int seedOffset; // CHANGED
  final List<double> _phase; // CHANGED
  final List<double> _seed; // CHANGED

  // Paints (cached)
  late final Paint _corePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = _coreWidth
    ..strokeCap = StrokeCap.round
    ..color = _coreColor;

  late final Paint _glowPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = _coreWidth * _glowWidthMul
    ..strokeCap = StrokeCap.round
    ..color = _glowColor
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, _glowSigma);

  Electric({
    required Vector2 size,
    Vector2? position,
    double? angle,
    Anchor anchor = Anchor.center,
    this.seedOffset = 0, // CHANGED
  }) : _phase = List<double>.generate(
         // CHANGED
         _segments + 1,
         (i) => math.Random(i * 997 + seedOffset).nextDouble() * math.pi * 2,
       ),
       _seed = List<double>.generate(
         // CHANGED
         _segments + 1,
         (i) => math.Random(73 * i + 11 + seedOffset * 31).nextDouble() * 10.0,
       ) {
    this.size = size;
    this.position = position ?? Vector2.zero();
    if (angle != null) this.angle = angle;
    this.anchor = anchor;
  }

  /// Convenience: stretch/rotate to connect two points in world coords.
  void setFromTo(Vector2 from, Vector2 to) {
    position = from.clone();
    final d = to - from;
    size = Vector2(d.length, size.y == 0 ? _amplitude * 4 : size.y);
    angle = math.atan2(d.y, d.x);
    anchor = Anchor.centerLeft;
  }

  // Start/stop controller
  void switchPhase(EventHorizontalObstacle evt) {
    currentEvent = evt;
    switch (currentEvent) {
      case EventHorizontalObstacle.startMoving:
        _active = true;
        break;
      case EventHorizontalObstacle.stopMoving:
        _active = false;
        break;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_active) _t += dt;
  }

  @override
  void render(Canvas canvas) {
    if (!_active) return;

    final flicker = 0.85 + 0.15 * math.sin(_t * 12.0);
    _glowPaint.color = _glowColor.withOpacity(flicker.clamp(0.0, 0.7));
    _corePaint.color = _coreColor.withOpacity(flicker.clamp(0.0, 0.7));

    for (int s = 0; s < _strands; s++) {
      final Path p = _buildStrand(s, height: size.y);
      canvas.drawPath(p, _glowPaint);
      canvas.drawPath(p, _corePaint);
    }
  }

  Path _buildStrand(int strand, {required double height}) {
    final Path path = Path();
    final double midY = height * 0.5;
    final double amp = _amplitude * (1.0 - 0.25 * strand);
    final double len = size.x;
    path.moveTo(0, midY);

    for (int i = 1; i <= _segments; i++) {
      final double t = i / _segments;
      final double x = t * len;

      // Rounder wrap (two humps)
      final double bowAmp = height * _bowFrac * (1.0 - 0.22 * strand);
      final double humps = (math.sin(2 * math.pi * t).abs() - 0.5) * 2.0;
      final double bow = bowAmp * humps;

      final double base =
          amp *
          (0.70 * math.sin((_freq * i) + _t * _speed + _phase[i]) +
              0.30 *
                  math.sin(
                    (_freq * 2.3 * i) -
                        _t * (_speed * 1.7) +
                        _phase[_segments - i],
                  ));

      final double jitter =
          (_jitter * 2.0) *
          math.sin(_seed[i] + _t * (_speed * 9.0) + i * 0.37 + strand * 1.9);

      final double y = midY + bow + base + jitter * (1.0 - t * 0.15);
      path.lineTo(x, y);
    }
    return path;
  }

  // ────────── RESET (simple assignments only) ──────────
  void reset() {
    currentEvent = EventHorizontalObstacle.stopMoving;
    _active = false;
    _t = 0.0;
    // Paint colors will be reassigned on next render when active.
  }
}
