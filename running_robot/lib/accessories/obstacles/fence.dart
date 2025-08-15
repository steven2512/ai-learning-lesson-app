// fence.dart — FULL FILE (tips fully to the ground, grounded while rotating)
import 'dart:async';
import 'dart:math' as math;
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:running_robot/lessons/lesson_one.dart';
import 'package:running_robot/accessories/obstacles/superclass/simple_mover.dart';
import 'package:running_robot/accessories/events/event_type.dart';
import 'package:running_robot/accessories/characters/robot.dart';

class Fence extends SimpleMover
    with CollisionCallbacks, HasGameReference<LessonOne> {
  EventHorizontalObstacle currentEvent = EventHorizontalObstacle.stopMoving;

  final Vector2 velocity;
  final double resetXThreshold = -50;
  final double groundY;
  bool isPaused = false;

  // ────────── Tip-over state ──────────
  bool _tipping = false;
  bool _tipped = false;
  // angular motion
  double _ang = 0.0; // radians
  double _angVel = 0.0; // rad/s
  double _angAcc = 9.0; // rad/s^2 (gravitational “pull”)
  double _angVelMax = 5.5; // cap
  static const double _tipTarget = math.pi / 2 - 0.02; // ~88.9°, lies flat
  // contact geometry
  late final List<Vector2> _contactPts; // local corners (anchor-aware)
  bool _contactsBuilt = false;

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
    // Keep whatever anchor SimpleMover sets (likely center). Geometry uses anchor dynamically.
    _buildContactPoints();
  }

  // Trigger tip when touching the robot
  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (!_tipping && !_tipped && other is Robot) {
      _tipping = true;
      _ang = angle; // start from current
      _angVel = 0.0;
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
        break;
      case EventHorizontalObstacle.startMoving:
        move();
        break;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Keep sliding horizontally per phase
    if (currentEvent == EventHorizontalObstacle.startMoving) {
      position += velocity * dt;
    }

    if (_tipping && !_tipped) {
      // basic tip physics
      _angVel = (_angVel + _angAcc * dt).clamp(-_angVelMax, _angVelMax);
      _ang += _angVel * dt;
      if (_ang >= _tipTarget) {
        _ang = _tipTarget;
        _tipping = false;
        _tipped = true;
        _angVel = 0.0;
      }

      // set visual angle
      angle = _ang;

      // solve Y so lowest rotated point sits on ground
      final centerAtTouch = groundY - _lowestLocalY(angle);
      position.y = centerAtTouch;
    } else if (_tipped) {
      // Locked in fallen pose: ensure it stays perfectly grounded
      angle = _tipTarget;
      position.y = groundY - _lowestLocalY(angle);
    }

    // Recycle off-screen
    if (position.x <= resetXThreshold) {
      resetPosition();
      // reset tip state so next spawn is upright
      _tipping = false;
      _tipped = false;
      _ang = 0.0;
      _angVel = 0.0;
      angle = 0.0;
      // rebuild contacts if size/anchor changed (defensive)
      _buildContactPoints();
      // also ensure Y is reasonable after reset (in case caller places us near ground)
      position.y = groundY - _lowestLocalY(angle);
    }
  }

  // ────────── Geometry helpers (anchor-aware, like Robot) ──────────
  void _buildContactPoints() {
    // Build once (unless size/anchor changes)
    final origin = (anchor.toVector2()..multiply(size));
    double hw = size.x / 2, hh = size.y / 2;

    // Build as if center-origin around the sprite's local center, but offset
    // by the component anchor so it's valid for any anchor.
    // These are local points relative to the component's origin (0,0).
    _contactPts = [
      // body corners in local coords:
      // (We position corners relative to the sprite's visual center,
      // then shift them so (0,0) is at the component origin defined by anchor)
      Vector2(-hw + (size.x / 2 - origin.x), -hh + (size.y / 2 - origin.y)),
      Vector2(hw + (size.x / 2 - origin.x), -hh + (size.y / 2 - origin.y)),
      Vector2(hw + (size.x / 2 - origin.x), hh + (size.y / 2 - origin.y)),
      Vector2(-hw + (size.x / 2 - origin.x), hh + (size.y / 2 - origin.y)),
    ];
    _contactsBuilt = true;
  }

  double _lowestLocalY(double a) {
    if (!_contactsBuilt) _buildContactPoints();
    final sinA = math.sin(a), cosA = math.cos(a);
    double lowest = -double.infinity;
    for (final p in _contactPts) {
      final y = p.x * sinA + p.y * cosA; // rotate around component origin
      if (y > lowest) lowest = y;
    }
    return lowest;
  }

  void reset() {
    // Phase & flags
    currentEvent = EventHorizontalObstacle.stopMoving;
    isPaused = false;

    // Tip-over state
    _tipping = false;
    _tipped = false;
    _ang = 0.0;
    _angVel = 0.0;
    angle = 0.0;

    // Position back to spawn, then snap to ground for upright pose
    resetPosition(); // from SimpleMover
    _buildContactPoints(); // defensive (in case size/anchor changed)
    position.y = groundY - _lowestLocalY(angle);
  }
}
