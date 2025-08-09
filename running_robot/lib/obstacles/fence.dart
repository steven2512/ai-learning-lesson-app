// fence.dart — FULL FILE (tips forward on robot collision)
import 'dart:async';
import 'dart:math' as math; // CHANGED
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:running_robot/my_game.dart';
import 'package:running_robot/obstacles/superclass/simple_mover.dart';
import 'package:running_robot/events/event_type.dart';
import 'package:running_robot/characters/robot.dart'; // CHANGED

class Fence extends SimpleMover
    with CollisionCallbacks, HasGameReference<MyGame> {
  EventHorizontalObstacle currentEvent = EventHorizontalObstacle.stopMoving;

  final Vector2 velocity;
  final double resetXThreshold = -50;
  final double groundY;
  bool isPaused = false;

  // ────────── Tip-over state ──────────
  bool _tipping = false; // CHANGED
  bool _tipped = false; // CHANGED
  double _tipT = 0.0; // CHANGED
  static const double _tipDur = 0.70; // CHANGED: total seconds for tip
  static const double _tipTarget =
      1.25; // CHANGED: ~72° forward (flip sign if needed)

  Fence({
    required super.initialPosition,
    required super.picturePath,
    required super.size,
    required this.velocity,
    required this.groundY,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox()..collisionType = CollisionType.passive);
    // NOTE: keeping existing anchor to avoid layout shifts.
  }

  // CHANGED: Trigger tip when touching the robot
  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (!_tipping && !_tipped && other is Robot) {
      _tipping = true;
      _tipT = 0.0;
    }
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
      case EventHorizontalObstacle.startMoving:
        move();
    }
    ;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // CHANGED: tip animation overrides angle, but we still let it slide left.
    if (_tipping && !_tipped) {
      _tipT += dt;
      final t = (_tipT / _tipDur).clamp(0.0, 1.0);
      final eased = _easeOutCubic(t);
      angle = _lerp(0.0, _tipTarget, eased);
      if (t >= 1.0) {
        _tipping = false;
        _tipped = true; // lock in fallen pose
      }
    }

    switch (currentEvent) {
      case EventHorizontalObstacle.startMoving:
        position += velocity * dt; // keep sliding even while tipping
        if (position.x <= resetXThreshold) {
          resetPosition();
          // CHANGED: also clear tip state on recycle so next spawn is upright
          _tipping = false;
          _tipped = false;
          _tipT = 0.0;
          angle = 0.0;
        }
        break;

      case EventHorizontalObstacle.stopMoving:
        // Do nothing
        break;
    }
  }

  // ────────── Helpers ──────────
  double _lerp(double a, double b, double t) => a + (b - a) * t;
  double _easeOutCubic(double t) {
    final u = 1 - t;
    return 1 - u * u * u;
  }
}
