// lib/characters/robot.dart — FULL FILE (electric removed; copy/paste)

import 'dart:math' as math;
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:running_robot/characters/electric.dart';
// REMOVED: electric import
import 'package:running_robot/events/event_type.dart';
import 'package:running_robot/my_game.dart';
import 'package:running_robot/obstacles/fence.dart';
import 'package:running_robot/obstacles/rain.dart';

class Robot extends PositionComponent
    with CollisionCallbacks, HasGameRef<MyGame> {
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

  // Right-corner settle helpers
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

  // Contact points (center-relative)
  late final List<Vector2> _contactPts;

  // Pivot (right-most lowest corner) for final settle
  Vector2? _pivotLocal;
  bool _hasPivot = false;

  double _settleFloorY = double.negativeInfinity;

  // ────────── Electrocute state (NEW) ──────────
  double _electroElapsed = 0.0; // NEW
  final double _electroDuration = 2; // NEW (seconds)

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

  double _lowestLocalY(double a) {
    final sinA = math.sin(a), cosA = math.cos(a);
    double lowest = -double.infinity;
    for (final p in _contactPts) {
      final y = p.x * sinA + p.y * cosA;
      if (y > lowest) lowest = y;
    }
    return lowest;
  }

  double _rotY(Vector2 p, double a) => p.x * math.sin(a) + p.y * math.cos(a);

  void _lockPivot(double a) {
    final eps = 3.0;
    final sinA = math.sin(a), cosA = math.cos(a);
    double lowest = -double.infinity;
    for (final p in _contactPts) {
      final y = p.x * sinA + p.y * cosA;
      if (y > lowest) lowest = y;
    }
    Vector2? best;
    double bestX = -double.infinity;
    for (final p in _contactPts) {
      final y = p.x * sinA + p.y * math.cos(a);
      if (lowest - y <= eps && p.x > bestX) {
        best = p;
        bestX = p.x;
      }
    }
    _pivotLocal = best ?? _contactPts.first;
    _hasPivot = true;
  }

  double _nearestPi(double a) {
    final norm = math.atan2(math.sin(a), math.cos(a));
    return norm >= 0 ? math.pi : -math.pi;
  }

  double _ease(double rate, double dt) => 1 - math.exp(-rate * dt);

  double _smoothStep(double edge0, double edge1, double x) {
    final tRaw = ((x - edge0) / (edge1 - edge0)).clamp(0.0, 1.0);
    final double t = (tRaw is double) ? tRaw : (tRaw as num).toDouble();
    return t * t * (3 - 2 * t);
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Fence) trip();
    if (other is Rain) if (!electrocuted) electrocute();
  }

  // ────────── Actions ──────────
  void jump() {
    currentEvent = EventRobot.jump;
    _settling = false;
    _hasPivot = false;
    _settleFloorY = double.negativeInfinity;
    velocity.y = -400;
  }

  void duck() {
    currentEvent = EventRobot.duck;
    duckTimer = _duckDown + _duckHold + _duckUp;
  }

  void trip() {
    currentEvent = EventRobot.trip;
    _angleDelta = 3.6;
    velocity.y = -60;
    pauseTracks = true;
    _settling = false;
    _hasPivot = false;
    _settleFloorY = double.negativeInfinity;
  }

  void stop() {
    pauseTracks = true;
    currentEvent = EventRobot.idle;
  }

  void resume() {
    pauseTracks = false;
    currentEvent = EventRobot.resume;
  }

  // CHANGED: keep a ref so you can stop it later if you want
  Electric? electric1;

  void electrocute() {
    if (!electrocuted) {
      electrocuted = true;
    }
    currentEvent = EventRobot.electrocute;
    _electroElapsed = 0.0; // NEW: reset timer

    // optional: reuse if already exists
    electric1 = Electric(size: Vector2(110, 25), angle: 0.15)
      ..position =
          Vector2(20, 75) // around body center; tweak as needed
      ..anchor = Anchor.center;

    add(electric1 as Component);

    // CHANGED: actually start the sizzle
    electric1?.switchPhase(EventHorizontalObstacle.startMoving);
  }

  // To stop later:
  // _electric?.switchPhase(EventHorizontalObstacle.stopMoving);

  void hurt() {}

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
      // REMOVED: EventRobot.electrocute
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
      // REMOVED: EventRobot.electrocute
      case EventRobot.hurt:
        break;
      case EventRobot.electrocute:
        _updateElectrocuteMotion(dt); // NEW
        break;
    }
  }

  // ────────── Trip Motion
  void _updateTripMotion(double dt) {
    angle += _angleDelta * dt;
    _angleDelta *= angularDampAir;

    _applyGravity(dt);
    _applyAirDrag(dt);
    _clampTerminal();
    _moveRobot(dt);

    final centerAtTouch = groundY - _lowestLocalY(angle);
    if (position.y >= centerAtTouch) {
      position.y = centerAtTouch;

      if (velocity.y.abs() > minBounceSpeed) {
        velocity.y = -velocity.y * bounceE;
        _angleDelta *= angularDampHit;
        _settling = false;
        _hasPivot = false;
        _settleFloorY = double.negativeInfinity;
      } else {
        velocity.y = 0;
        _settling = true;
        if (!_hasPivot) _lockPivot(angle);
      }
    }

    if (_settling) {
      velocity.y = 0;

      final goal = _nearestPi(angle);
      final bias = (goal - angle);

      _angleDelta += bias * settleBias * dt;
      _angleDelta *= angularDampSettle;

      final centerTouch = groundY - _lowestLocalY(angle);
      final pivotTouch = (_hasPivot && _pivotLocal != null)
          ? groundY - _rotY(_pivotLocal!, angle)
          : centerTouch;

      final biasAbs = bias.abs();
      final fade = _smoothStep(0.0, _pivotFadeBias, biasAbs);
      final dynamicOffset = pivotEarlyTouchPx * fade;

      final rawDesiredY = math.max(pivotTouch, centerTouch + dynamicOffset);

      if (_settleFloorY == double.negativeInfinity) {
        _settleFloorY = rawDesiredY;
      } else {
        _settleFloorY = math.max(_settleFloorY, rawDesiredY);
      }

      final endZone = (bias.abs() < _biasStillEps && _angleDelta.abs() < 0.08);

      final yRate = endZone ? _yEndRate : _yLockRate;
      final aY = _ease(yRate, dt);
      if (_settleFloorY > position.y) {
        position.y += (_settleFloorY - position.y) * aY;
      }

      if (endZone) {
        final aAng = _ease(_angleEndRate, dt);
        angle += (goal - angle) * aAng;
        _angleDelta *= 0.92;
      }

      if (endZone &&
          (goal - angle).abs() <= _finalSnapEps &&
          (_settleFloorY - position.y).abs() <= 0.12) {
        _angleDelta = 0.0;
        _settling = false;
        _hasPivot = false;
      }
    }
  }

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
    final targetY = groundY - size.y / 2;
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

  // Gentle electrocute shake that auto-fades and cleans up electricity.
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
      // restore base pose
      body.position.y = _bodyBaseY;
      body.angle = 0;
      body.scale = Vector2.all(1);
      leftTrack.position.y = 84;
      rightTrack.position.y = 84;

      // stop & remove electricity
      electric1?.switchPhase(EventHorizontalObstacle.stopMoving);
      electric1?.removeFromParent();
      electric1 = null;

      // return to idle
      currentEvent = EventRobot.idle;
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
  }
}
