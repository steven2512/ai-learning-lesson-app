// cloud.dart
// FULL FILE — non-uniform stretch via stretchX/stretchY (no uniform `scale` anywhere)

// ✅ CHANGED: removed `scale` to avoid confusion.
// ✅ NEW: add `stretchX` and `stretchY` factors with defaults (1.0 = original size).

import 'dart:math';
import 'package:flame/components.dart';
import 'package:running_robot/game/events/event_type.dart';
import 'package:running_robot/game/obstacles/superclass/simple_mover.dart';

class Cloud extends SimpleMover {
  EventHorizontalObstacle currentEvent = EventHorizontalObstacle.stopMoving;

  // ───────── CONFIG ─────────
  // ✅ NEW: base size used only to compute stretched size
  static const double _baseWidth = 80; // <<< NEW
  static const double _baseHeight = 50; // <<< NEW

  final Vector2 velocity;
  final double resetXThreshold = -100;
  bool isPaused = false;

  // Keep a copy of the original spawn to base randomization on
  final Vector2 _spawnOrigin;
  final bool randomizeRest; // parallax-style random respawn
  final _rng = Random();

  double _opacity; // track current opacity for this PNG

  Cloud({
    required Vector2 initialPosition,
    required this.velocity,
    required String picturePath,
    double stretchX = 1.0, // <<< NEW: per-axis stretch (X)
    double stretchY = 1.0, // <<< NEW: per-axis stretch (Y)
    this.randomizeRest = false,
    double opacity = 1.0, // optional opacity (0..1)
  })  : _spawnOrigin = initialPosition.clone(),
        _opacity = opacity,
        super(
          initialPosition: initialPosition,
          picturePath: picturePath,
          // ✅ CHANGED: compute absolute size from per-axis stretch; no `scale` used.
          size: Vector2(_baseWidth * stretchX, _baseHeight * stretchY),
        ) {
    setOpacity(_opacity); // apply initial opacity to PNG paint
  }

  // ✅ FIXED: match HasPaint signature + annotate override, delegate to super
  @override
  void setOpacity(double value, {Object? paintId}) {
    _opacity = value.clamp(0.0, 1.0);
    super.setOpacity(
      _opacity,
      paintId: paintId,
    ); // ensures proper HasPaint behavior
  }

  void move() {
    currentEvent = EventHorizontalObstacle.startMoving;
  }

  void stop() {
    currentEvent = EventHorizontalObstacle.stopMoving;
  }

  void switchPhase(EventHorizontalObstacle phase) {
    switch (phase) {
      case EventHorizontalObstacle.stopMoving:
        stop();
        break;
      case EventHorizontalObstacle.startMoving:
        move();
        break;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    switch (currentEvent) {
      case EventHorizontalObstacle.startMoving:
        position += velocity * dt;

        if (position.x <= resetXThreshold) {
          if (!randomizeRest) {
            // old behavior: simple reset to original X to the right
            resetPosition();
          } else {
            // random respawn for parallax effect
            // X: respawn somewhere to the right of the original
            final double randX = _spawnOrigin.x +
                150 +
                _rng.nextDouble() * 300; // 150..450 px to the right

            // Y: keep height the same as original (lock to spawn Y)
            position.setValues(
              randX,
              _spawnOrigin.y,
            ); // <<< CHANGED: lock Y to original

            // Speed: clamp to a fixed leftward speed
            velocity.x = -70; // <<< CHANGED: cap horizontal speed to -70
          }
        }
        break;

      case EventHorizontalObstacle.stopMoving:
        // no-op while stopped
        break;
    }
  }

  void reset() {
    // Back to spawn state
    currentEvent = EventHorizontalObstacle.stopMoving;
    position = _spawnOrigin.clone();
    isPaused = false;
    angle = 0.0;
  }
}
