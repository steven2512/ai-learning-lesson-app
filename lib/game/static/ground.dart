// ground.dart
// FULL FILE — tiny circular crumbs (1.0–2.2px diameter), faster scroll.
// Two lanes at 2px & 4px below the ground line. Event-driven start/stop.

// <<< CHANGED: switched to circles; smaller; faster; stable lanes

import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:running_robot/game/events/event_type.dart';

class Ground extends PositionComponent {
  // ────────── CONFIG ──────────
  final Vector2 dimensions;

  EventHorizontalObstacle currentEvent = EventHorizontalObstacle.stopMoving;

  // <<< CHANGED: faster base speed
  final double baseSpeed; // px/s

  // <<< NEW: dot counts per lane
  final int lane1Count; // 2px below line
  final int lane2Count; // 4px below line

  // Lanes (keep within ≤5px below horizon)
  static const double _lane1OffsetPx = 2.0; // <<< NEW
  static const double _lane2OffsetPx = 4.0; // <<< NEW

  // Dot size (radius in px) — very small circles
  static const RangeValues _rLane1 = RangeValues(
    0.5,
    0.9,
  ); // 1.0–1.8px diameter
  static const RangeValues _rLane2 = RangeValues(
    0.6,
    1.1,
  ); // 1.2–2.2px diameter

  // Parallax multipliers (lane2 a bit faster)
  static const double _mulLane1 = 0.75; // <<< CHANGED: faster feel
  static const double _mulLane2 = 1.00; // <<< CHANGED

  // Subtle greys (low alpha)
  static const Color _dotBase = Color(0xFF5F6B76);
  static const int _alphaLane1 = 70;
  static const int _alphaLane2 = 90;

  final _rng = Random();
  late final List<_Dot> _dots;

  Ground({
    required this.dimensions,
    this.baseSpeed = 140, // <<< CHANGED: faster motion
    this.lane1Count = 14, // <<< CHANGED: modest amount
    this.lane2Count = 12, // <<< CHANGED
  }) {
    size = dimensions;
    anchor = Anchor.center;
    position = Vector2(dimensions.x / 2, dimensions.y / 2 + 90);
  }

  double get topY => absolutePosition.y;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _initDots(); // <<< NEW
  }

  // <<< NEW: deterministic-looking lanes with random x starts
  void _initDots() {
    final groundY = size.y / 2;
    _dots = [];

    for (var i = 0; i < lane1Count; i++) {
      _dots.add(
        _randDot(
          y: groundY + _lane1OffsetPx,
          rRange: _rLane1,
          speedMul: _mulLane1,
          alpha: _alphaLane1,
        ),
      );
    }
    for (var i = 0; i < lane2Count; i++) {
      _dots.add(
        _randDot(
          y: groundY + _lane2OffsetPx,
          rRange: _rLane2,
          speedMul: _mulLane2,
          alpha: _alphaLane2,
        ),
      );
    }
  }

  _Dot _randDot({
    required double y,
    required RangeValues rRange,
    required double speedMul,
    required int alpha,
  }) {
    final x = _rng.nextDouble() * size.x;
    final r = rRange.start + _rng.nextDouble() * (rRange.end - rRange.start);
    return _Dot(x: x, y: y, r: r, speedMul: speedMul, alpha: alpha);
  }

  // ────────── EVENT API ──────────
  void move() {
    currentEvent = EventHorizontalObstacle.startMoving;
  }

  void stop() {
    currentEvent = EventHorizontalObstacle.stopMoving;
  }

  void switchPhase(EventHorizontalObstacle phase) {
    switch (phase) {
      case EventHorizontalObstacle.startMoving:
        move();
        break;
      case EventHorizontalObstacle.stopMoving:
        stop();
        break;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (currentEvent != EventHorizontalObstacle.startMoving) return;

    for (final d in _dots) {
      d.x -= baseSpeed * d.speedMul * dt;
      if (d.x < -d.r * 2) {
        // respawn just off right edge; keep same lane (y) and radius
        d.x = size.x + _rng.nextDouble() * 80;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final groundY = size.y / 2;

    // Horizon line
    canvas.drawLine(
      Offset(0, groundY),
      Offset(size.x, groundY),
      Paint()
        ..color = const Color(0xFFE4ECF3)
        ..strokeWidth = 2,
    );

    // Ground fill
    canvas.drawRect(
      Rect.fromLTWH(0, groundY, size.x, size.y - groundY),
      Paint()..color = const Color.fromARGB(255, 233, 233, 233),
    );

    // Tiny circular crumbs
    final p = Paint();
    for (final d in _dots) {
      p.color = _dotBase.withAlpha(d.alpha);
      canvas.drawCircle(Offset(d.x, d.y), d.r, p);
    }
  }

  void reset() {
    // Back to initial phase & placement
    currentEvent = EventHorizontalObstacle.stopMoving;
    position.setValues(dimensions.x / 2, dimensions.y / 2 + 90);

    // Re-randomize dot X positions (keep lanes/radii intact) if loaded
    if (isLoaded) {
      for (final d in _dots) {
        d.x = _rng.nextDouble() * size.x;
      }
    }
  }
}

class _Dot {
  _Dot({
    required this.x,
    required this.y,
    required this.r,
    required this.speedMul,
    required this.alpha,
  });

  double x;
  final double y; // lane-locked
  final double r; // radius
  final double speedMul;
  final int alpha;
}
