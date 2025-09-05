// lib/characters/robot.dart — FULL FILE (electric kept; copy/paste)

import 'dart:math' as math;
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:running_robot/game/characters/diziness.dart';
import 'package:running_robot/game/characters/electric.dart';
import 'package:running_robot/game/events/event_type.dart';
import 'package:running_robot/game/obstacles/bird.dart';
import 'package:running_robot/game/obstacles/fence.dart';
import 'package:running_robot/game/obstacles/rain.dart';

class Robot extends PositionComponent with CollisionCallbacks {
  EventRobot currentEvent = EventRobot.idle;
  final double groundY;

  // ────────── CONFIG ──────────
  static const double _bodyBaseY = 42;
  static const double _duckOffset = 20;
  static const double _duckDown = 0.2;
  static const double _duckHold = 1.0;
  static const double _duckUp = 0.2;

  final Vector2 initialPosition;

  // Fall
  final double gravity = 480;
  final double airDrag = 0.88;
  final double vTerminal = 620;

  // Bounce
  final double bounceE = 0.64;
  final double minBounceSpeed = 28;

  // Spin
  final double angularDampAir = 0.988;
  final double angularDampHit = 0.90;

  // Settle
  final double settleBias = 4.1;
  final double angularDampSettle = 0.978;

  // Legacy settle helpers (some kept/repurposed)
  final double pivotEarlyTouchPx = 6.0;
  final double _yLockRate = 42.0;
  final double _angleLockRate = 14.0;

  final double _finalSnapEps = 0.0015;
  final double _pivotFadeBias = 0.24;
  final double _yEndRate = 18.0;
  final double _angleEndRate = 10.0;
  final double _biasStillEps = 0.07;

  Vector2 velocity = Vector2.zero();

  // Timers
  double duckTimer = 0;
  double trackTimer = 0;
  int trackFrame = 0;

  // Sprites
  late Sprite _track1, _track2;
  late SpriteComponent body, leftTrack, rightTrack;

  // Misc
  double _angleDelta = 0;
  bool pauseTracks = true;

  // Trip state
  bool _settling = false;

  bool electrocuted = false;

  bool isHurt = false;

  // Contact points (legacy cache; kept for debugging/consistency)
  List<Vector2> _contactPts = [];

  // Pivot (legacy)
  Vector2? _pivotLocal;
  bool _hasPivot = false;

  double _settleFloorY = double.negativeInfinity;

  // Electrocute
  double _electroElapsed = 0.0;
  final double _electroDuration = 2;

  // HURT
  double _hurtElapsed = 0.0;
  int _hurtPhase = 0; // 0:down,1:wiggle,2:hold,3:stand
  final double _hurtDownOffset = 10.0;
  final double _hurtDownDur = 0.35;
  final double _hurtMaxRad = math.pi / 36; // ~5°
  final double _hurtHoldDuration = 3.0;
  final double _hurtStandDur = 0.6;
  final double _hurtWiggleHz = 3.0;
  final double _hurtWiggleCycles = 3.5;
  double _hurtHoldElapsed = 0.0;
  double _hurtWiggleElapsed = 0.0;
  bool _hurtStandingUp = false;

  // Trip goal (final angle target)
  double? _tripGoal; // face-down/head-on-ground target

  Robot({required this.initialPosition, required this.groundY})
      : super(size: Vector2.all(50), anchor: Anchor.center) {
    position = initialPosition.clone();
  }

  @override
  Future<void> onLoad() async {
    _track1 = await Sprite.load('tracks_long1.png');
    _track2 = await Sprite.load('tracks_long2.png');

    body = SpriteComponent()
      ..sprite = await Sprite.load('robot_yellowBody.png')
      ..anchor = Anchor.center
      ..size = Vector2(100, 90)
      ..position = Vector2(20, _bodyBaseY);

    leftTrack = SpriteComponent()
      ..sprite = _track1
      ..anchor = Anchor.center
      ..size = Vector2(70, 60)
      ..position = Vector2(-11, 84);

    rightTrack = SpriteComponent()
      ..sprite = _track1
      ..anchor = Anchor.center
      ..size = Vector2(60, 60)
      ..position = Vector2(64, 84);

    add(rightTrack);
    add(body);
    add(leftTrack);
    add(
      RectangleHitbox(
        size: Vector2(96, 72),
        position: Vector2(20, _bodyBaseY),
        anchor: Anchor.center,
      )
        ..collisionType = CollisionType.active
        ..renderShape = false,
    );

    _buildContactPoints();
  }

  void _buildContactPoints() {
    final origin = (anchor.toVector2()..multiply(size));
    List<Vector2> rectCorners(SpriteComponent c) {
      final hw = c.size.x / 2, hh = c.size.y / 2;
      final cx = c.position.x - origin.x;
      final cy = c.position.y - origin.y;
      return [
        Vector2(cx - hw, cy - hh),
        Vector2(cx + hw, cy - hh),
        Vector2(cx + hw, cy + hh),
        Vector2(cx - hw, cy + hh),
      ];
    }

    _contactPts = [
      ...rectCorners(body),
      ...rectCorners(leftTrack),
      ...rectCorners(rightTrack),
    ];
  }

  // Rotate 2D vector by angle a (radians)
  Vector2 _rot(Vector2 p, double a) => Vector2(
      p.x * math.cos(a) - p.y * math.sin(a),
      p.x * math.sin(a) + p.y * math.cos(a));

  // Enumerate current corners of all child sprites, including each child’s
  // rotation & scale, in the Robot’s local coordinates (pre-parent rotation).
  Iterable<Vector2> _iterCornersLocalUnparented() sync* {
    final origin = (anchor.toVector2()..multiply(size));
    Vector2 basePos(SpriteComponent c) => c.position - origin;

    Iterable<Vector2> childCorners(SpriteComponent c) sync* {
      final hw = (c.size.x / 2) * c.scale.x;
      final hh = (c.size.y / 2) * c.scale.y;
      final corners = <Vector2>[
        Vector2(-hw, -hh),
        Vector2(hw, -hh),
        Vector2(hw, hh),
        Vector2(-hw, hh),
      ];
      final pos = basePos(c);
      final ang = c.angle;
      if (ang == 0) {
        for (final v in corners) {
          yield v + pos;
        }
      } else {
        for (final v in corners) {
          yield _rot(v, ang) + pos;
        }
      }
    }

    yield* childCorners(body);
    yield* childCorners(leftTrack);
    yield* childCorners(rightTrack);
  }

  // Lowest local Y after applying parent rotation `a`
  double _lowestLocalY(double a) {
    final sinA = math.sin(a), cosA = math.cos(a);
    double lowest = -double.infinity;
    for (final p in _iterCornersLocalUnparented()) {
      final y = p.x * sinA + p.y * cosA;
      if (y > lowest) lowest = y;
    }
    return lowest;
  }

  // Lock pivot among the lowest points (scaled geometry too), choosing right-most in rotated X.
  void _lockPivot(double a) {
    final sinA = math.sin(a), cosA = math.cos(a);

    double lowestY = -double.infinity;
    for (final p in _iterCornersLocalUnparented()) {
      final y = p.x * sinA + p.y * cosA;
      if (y > lowestY) lowestY = y;
    }

    const eps = 3.0;
    Vector2? best;
    double bestX = -double.infinity;

    for (final p in _iterCornersLocalUnparented()) {
      final y = p.x * sinA + p.y * cosA;
      if (lowestY - y <= eps) {
        final x = p.x * cosA - p.y * sinA; // rotated X
        if (x > bestX) {
          bestX = x;
          best = p;
        }
      }
    }

    _pivotLocal = best ?? _iterCornersLocalUnparented().first;
    _hasPivot = true;
  }

  double _nearestPi(double a) {
    final norm = math.atan2(math.sin(a), math.cos(a));
    return norm >= 0 ? math.pi : -math.pi;
  }

  double _ease(double rate, double dt) => 1 - math.exp(-rate * dt);

  double _smoothStep01(double x) {
    final t = x.clamp(0.0, 1.0);
    return t * t * (3 - 2 * t);
  }

  double _smoothStep(double a, double b, double x) =>
      _smoothStep01(((x - a) / (b - a)).clamp(0.0, 1.0).toDouble());

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Fence) trip();
    if (other is Rain) if (!electrocuted) electrocute();
    if (other is Bird) if (!isHurt) hurt();
  }

  // ────────── Actions ──────────
  void jump() {
    currentEvent = EventRobot.jump;
    _settling = false;
    _hasPivot = false;
    _settleFloorY = double.negativeInfinity;
    velocity.y = -500;
  }

  void duck() {
    currentEvent = EventRobot.duck;
    duckTimer = _duckDown + _duckHold + _duckUp;
  }

  void trip() {
    currentEvent = EventRobot.trip;
    _angleDelta = 3.6; // forward spin impetus
    velocity.y = -60;
    pauseTracks = true;
    _settling = false;
    _hasPivot = false;
    _pivotLocal = null;
    _settleFloorY = double.negativeInfinity;
    _tripGoal = null; // face-down will be set on first lock
  }

  void stop() {
    pauseTracks = true;
    currentEvent = EventRobot.idle;
  }

  void resume() {
    pauseTracks = false;
    currentEvent = EventRobot.resume;
  }

  Electric? electric1;

  void electrocute() {
    if (!electrocuted) {
      electrocuted = true;
    }
    currentEvent = EventRobot.electrocute;
    _electroElapsed = 0.0;

    electric1 = Electric(size: Vector2(110, 25), angle: 0.15)
      ..position = Vector2(20, 75)
      ..anchor = Anchor.center;

    add(electric1 as Component);
    electric1?.switchPhase(EventHorizontalObstacle.startMoving);
  }

  // ────────── HURT (NEW)
  void hurt() {
    if (!isHurt) isHurt = true;
    currentEvent = EventRobot.hurt;
    pauseTracks = true;
    _hurtElapsed = 0.0;
    _hurtHoldElapsed = 0.0;
    _hurtWiggleElapsed = 0.0;
    _hurtStandingUp = false;
    _hurtPhase = 0;
    add(
      Diziness(position: Vector2(70, _bodyBaseY - 5), delay: 1.5, duration: 4.0)
        ..anchor = Anchor.center,
    );
  }

  void switchPhase(EventRobot phase) {
    switch (phase) {
      case EventRobot.jump:
        jump();
        break;
      case EventRobot.duck:
        duck();
        break;
      case EventRobot.idle:
        stop();
        break;
      case EventRobot.resume:
        resume();
        break;
      case EventRobot.trip:
        trip();
        break;
      case EventRobot.hurt:
        hurt();
        break;
      case EventRobot.electrocute:
        electrocute();
        break;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    switch (currentEvent) {
      case EventRobot.idle:
        _updateTracks(dt);
        break;
      case EventRobot.duck:
        _updateDuckMotion(dt);
        _updateTracks(dt);
        break;
      case EventRobot.jump:
        _applyGravity(dt);
        _moveRobot(dt);
        _checkLanding(resetOnLand: true);
        break;
      case EventRobot.trip:
        _updateTripMotion(dt);
        break;
      case EventRobot.resume:
        _resetAll();
        break;
      case EventRobot.hurt:
        _updateHurtMotion(dt);
        break;
      case EventRobot.electrocute:
        _updateElectrocuteMotion(dt);
        break;
    }
  }

  // ────────── helpers for trip/ground clamp
  double _bottomWorldYAt(double a) => position.y + _lowestLocalY(a);

  double _pivotWorldYAt(double a) => (_hasPivot && _pivotLocal != null)
      ? position.y + _rotY(_pivotLocal!, a)
      : _bottomWorldYAt(a);

  void _pinPivotToGround(double a) {
    final pen = _pivotWorldYAt(a) - groundY;
    if (pen >= 0) position.y -= pen; // only move upward; never sink
  }

  void _clampBottomToGround(double a) {
    final pen = _bottomWorldYAt(a) - groundY;
    if (pen >= 0) position.y -= pen;
  }

  // "Head" corner of the body in Robot-local space (front-right)
  Vector2 _bodyHeadCornerLocal() {
    final origin = (anchor.toVector2()..multiply(size));
    final hw = (body.size.x / 2) * body.scale.x;
    final hh = (body.size.y / 2) * body.scale.y;
    final base = body.position - origin;
    final local = Vector2(hw, hh); // bottom-right of the body sprite
    return (body.angle == 0) ? base + local : _rot(local, body.angle) + base;
  }

  double _shortAngleTo(double target) =>
      math.atan2(math.sin(target - angle), math.cos(target - angle));

  // ────────── Trip Motion (forward tumble with pivot roll; finish head-on-ground)
  void _updateTripMotion(double dt) {
    // airborne spin + damping
    angle += _angleDelta * dt;
    _angleDelta *= angularDampAir;

    // gravity + air drag
    velocity.y += gravity * dt;
    final k = math.pow(airDrag, dt).toDouble();
    velocity.y *= k;
    if (velocity.y > vTerminal) velocity.y = vTerminal;

    // integrate position
    position += velocity * dt;

    // First contact via silhouette bottom
    if (!_settling && _bottomWorldYAt(angle) >= groundY) {
      _clampBottomToGround(angle);

      if (velocity.y.abs() > minBounceSpeed) {
        // bounce a bit; keep spinning
        velocity.y = -velocity.y * bounceE;
        _angleDelta *= angularDampHit;
      } else {
        // lock to ground and begin rolling
        velocity.y = 0;
        _settling = true;
        _tripGoal = math.pi / 2; // face-down (head on the ground)
        _hasPivot =
            false; // let _lockPivot choose current lowest (likely wheel)
      }
    }

    if (_settling) {
      // refresh pivot to "roll" across edges
      if (!_hasPivot) _lockPivot(angle);

      // torque toward goal angle
      final bias = _shortAngleTo(_tripGoal!);
      _angleDelta += bias * settleBias * dt;
      _angleDelta *= angularDampSettle;
      angle += _angleDelta * dt;

      // switch pivot to HEAD once it becomes (nearly) the lowest point
      final headLocal = _bodyHeadCornerLocal();
      final headYLocal = _rotY(headLocal, angle);
      final lowestLocal = _lowestLocalY(angle);
      if (headYLocal >= lowestLocal - 0.5) {
        // small epsilon
        _pivotLocal = headLocal;
        _hasPivot = true;
      }

      // keep exact contact; never penetrate ground
      _pinPivotToGround(angle);
      _clampBottomToGround(angle);

      // finish when almost still & at goal
      if (_angleDelta.abs() < 0.02 && bias.abs() < 0.02) {
        angle = _tripGoal!;
        _pivotLocal = headLocal; // ensure head is contact point in final pose
        _hasPivot = true;
        _pinPivotToGround(angle);

        _settling = false;
        currentEvent = EventRobot.idle;
      }
    }
  }

  // Helper for rotated Y of a local point
  double _rotY(Vector2 p, double a) => p.x * math.sin(a) + p.y * math.cos(a);

  // ────────── Physics helpers
  void _applyGravity(double dt) {
    velocity.y += gravity * dt;
  }

  void _applyAirDrag(double dt) {
    final k = math.pow(airDrag, dt).toDouble();
    velocity.y *= k;
  }

  void _clampTerminal() {
    if (velocity.y > vTerminal) velocity.y = vTerminal;
  }

  void _moveRobot(double dt) {
    position += velocity * dt;
  }

  void _checkLanding({bool resetOnLand = false, bool bounceOnLand = false}) {
    final targetY = groundY - _lowestLocalY(angle); // uses scaled silhouette
    if (position.y >= targetY) {
      position.y = targetY;
      if (bounceOnLand && velocity.y.abs() > 100) {
        velocity.y = -velocity.y * 0.6;
        _angleDelta *= 0.9;
      } else if (resetOnLand || bounceOnLand) {
        _resetAll();
      } else {
        velocity.y = 0;
      }
    }
  }

  // ────────── Electrocute motion
  void _updateElectrocuteMotion(double dt) {
    _electroElapsed += dt;
    final double life = (_electroElapsed / _electroDuration).clamp(0.0, 1.0);
    final double fade = (life < 0.8) ? 1.0 : (1.0 - (life - 0.8) / 0.2);
    final double t = _electroElapsed;

    final double ampY = (1.2 + 0.6 * math.sin(t * 9.0)) * fade; // px
    final double ampAng = (0.008 + 0.004 * math.sin(t * 11.0)) * fade; // rad
    final double ampScale = (0.0025 + 0.0015 * math.sin(t * 8.0)) * fade;

    final double oy =
        math.sin(t * 60.0) * ampY + math.sin(t * 37.0) * (ampY * 0.4);
    final double a = math.sin(t * 41.0) * ampAng;
    final double s = 1.0 + math.sin(t * 47.0) * ampScale;

    body.position.y = _bodyBaseY + oy;
    body.angle = a;
    body.scale = Vector2.all(s);

    leftTrack.position.y = 84 + math.sin(t * 52.0) * (0.5 * fade);
    rightTrack.position.y = 84 - math.sin(t * 55.0) * (0.5 * fade);

    if (_electroElapsed >= _electroDuration) {
      body.position.y = _bodyBaseY;
      body.angle = 0;
      body.scale = Vector2.all(1);
      leftTrack.position.y = 84;
      rightTrack.position.y = 84;

      electric1?.switchPhase(EventHorizontalObstacle.stopMoving);
      electric1?.removeFromParent();
      electric1 = null;

      currentEvent = EventRobot.idle;
    }
  }

  // ────────── HURT Motion (NEW)
  void _updateHurtMotion(double dt) {
    if (_hurtPhase == 0) {
      _hurtElapsed += dt;
      final p = (_hurtElapsed / _hurtDownDur).clamp(0.0, 1.0);
      final e = _smoothStep01(p);
      body.position.y = _bodyBaseY + _hurtDownOffset * e;
      if (p >= 1.0) {
        _hurtPhase = 1;
        _hurtElapsed = 0.0;
        _hurtWiggleElapsed = 0.0;
      }
      return;
    }

    if (_hurtPhase == 1) {
      _hurtWiggleElapsed += dt;
      final wiggleTotal = _hurtWiggleCycles / _hurtWiggleHz;
      final t = _hurtWiggleElapsed;
      final a = _hurtMaxRad * math.sin(2 * math.pi * _hurtWiggleHz * t);
      body.angle = a;

      if (t >= wiggleTotal) {
        body.angle = _hurtMaxRad; // rest at +5°
        _hurtPhase = 2;
        _hurtHoldElapsed = 0.0;
      }
      return;
    }

    if (_hurtPhase == 2) {
      _hurtHoldElapsed += dt;
      if (_hurtHoldElapsed >= _hurtHoldDuration) {
        _hurtPhase = 3;
        _hurtElapsed = 0.0;
        _hurtStandingUp = true;
      }
      return;
    }

    if (_hurtPhase == 3 && _hurtStandingUp) {
      _hurtElapsed += dt;
      final p = (_hurtElapsed / _hurtStandDur).clamp(0.0, 1.0);
      final e = _smoothStep01(p);
      body.position.y = _bodyBaseY + _hurtDownOffset * (1.0 - e);
      body.angle = _hurtMaxRad * (1.0 - e);

      if (p >= 1.0) {
        body.position.y = _bodyBaseY;
        body.angle = 0.0;
        currentEvent = EventRobot.resume;
      }
      return;
    }
  }

  // ────────── Duck Motion
  void _updateDuckMotion(double dt) {
    duckTimer -= dt;
    final total = _duckDown + _duckHold + _duckUp;
    final t = total - duckTimer;

    final p1 = _duckDown;
    final p2 = p1 + _duckHold;
    final p3 = p2 + _duckUp;

    if (t <= p1) {
      final prog = (t / _duckDown);
      body.position.y = _bodyBaseY + _duckOffset * math.pow(prog, 2).toDouble();
    } else if (t <= p2) {
      body.position.y = _bodyBaseY + _duckOffset;
    } else if (t <= p3) {
      final prog = (t - p2) / _duckUp;
      body.position.y =
          _bodyBaseY + _duckOffset * (1 - math.pow(prog, 2)).toDouble();
    }

    if (duckTimer <= 0) {
      currentEvent = EventRobot.idle;
      body.position.y = _bodyBaseY;
    }
  }

  // ────────── Tracks
  void _updateTracks(double dt) {
    if (pauseTracks) return;
    trackTimer += dt;
    if (trackTimer > 0.097) {
      trackTimer = 0;
      trackFrame = 1 - trackFrame;
      final sprite = (trackFrame == 0) ? _track1 : _track2;
      leftTrack.sprite = sprite;
      rightTrack.sprite = sprite;
    }
  }

  void _resetAll() {
    currentEvent = EventRobot.idle;
    velocity.setZero();
    angle = 0;
    body.position.y = _bodyBaseY;
    body.angle = 0;
    pauseTracks = false;
    _settling = false;
    _hasPivot = false;
    _settleFloorY = double.negativeInfinity;
    _tripGoal = null;
  }

  // ────────── PUBLIC: Hard reset back to spawn state ──────────
  void reset() {
    currentEvent = EventRobot.idle;
    position = initialPosition.clone();
    angle = 0.0;
    velocity.setZero();
    _angleDelta = 0.0;

    trackTimer = 0.0;
    trackFrame = 0;
    pauseTracks = true;
    leftTrack.sprite = _track1;
    rightTrack.sprite = _track1;

    body.position = Vector2(20, _bodyBaseY);
    body.angle = 0.0;
    body.scale = Vector2.all(1.0);
    leftTrack.position = Vector2(-11, 84);
    rightTrack.position = Vector2(64, 84);

    _settling = false;
    _hasPivot = false;
    _pivotLocal = null;
    _settleFloorY = double.negativeInfinity;

    duckTimer = 0.0;

    electrocuted = false;
    _electroElapsed = 0.0;
    electric1?.switchPhase(EventHorizontalObstacle.stopMoving);
    electric1?.removeFromParent();
    electric1 = null;

    isHurt = false;
    _hurtElapsed = 0.0;
    _hurtPhase = 0;
    _hurtHoldElapsed = 0.0;
    _hurtWiggleElapsed = 0.0;
    _hurtStandingUp = false;

    _tripGoal = null;
  }
}
