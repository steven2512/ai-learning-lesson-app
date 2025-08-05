import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:running_robot/events/event_type.dart';

class Robot extends PositionComponent {
  EventRobot currentEvent = EventRobot.idle;

  // ────────── CONFIG ──────────
  static const double _bodyBaseY = 42;
  static const double _duckOffset = 20;
  static const double _duckDown = 0.2;
  static const double _duckHold = 1.0;
  static const double _duckUp = 0.2;

  final Vector2 initialPosition;
  final double gravity = 800;
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

  Robot({required this.initialPosition})
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
  }

  void jump() {
    currentEvent = EventRobot.jump;
    velocity.y = -500;
  }

  void duck() {
    currentEvent = EventRobot.duck;
    duckTimer = _duckDown + _duckHold + _duckUp;
  }

  void trip() {
    currentEvent = EventRobot.trip;
    _angleDelta = 3;
  }

  void stop() => pauseTracks = true;
  void resume() => pauseTracks = false;

  @override
  void update(double dt) {
    super.update(dt);

    switch (currentEvent) {
      case EventRobot.idle:
        _updateTracks(dt);
        _resetBodyIfNeeded();
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
        _applyGravity(dt);
        _moveRobot(dt);
        angle += _angleDelta * dt;
        _angleDelta *= 0.99;
        _checkLanding(bounceOnLand: true);
        break;

      case EventRobot.resume:
        resume();
        _resetAll();
        break;
      case EventRobot.stop:
        // 🚫 Do nothing — paused or manually stopped
        break;
    }
  }

  void _applyGravity(double dt) {
    velocity.y += gravity * dt;
  }

  void _moveRobot(double dt) {
    position += velocity * dt;
  }

  void _checkLanding({bool resetOnLand = false, bool bounceOnLand = false}) {
    if (position.y >= initialPosition.y) {
      position.y = initialPosition.y;

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

  void _updateTracks(double dt) {
    if (pauseTracks) return;

    trackTimer += dt;
    if (trackTimer > 0.1) {
      trackTimer = 0;
      trackFrame = 1 - trackFrame;
      final sprite = (trackFrame == 0) ? _track1 : _track2;
      leftTrack.sprite = sprite;
      rightTrack.sprite = sprite;
    }
  }

  void _resetBodyIfNeeded() {
    if (body.position.y != _bodyBaseY) {
      body.position.y = _bodyBaseY;
    }
  }

  void _resetAll() {
    currentEvent = EventRobot.idle;
    velocity.setZero();
    angle = 0;
    body.position.y = _bodyBaseY;
  }
}
