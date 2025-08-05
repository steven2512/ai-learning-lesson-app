import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:running_robot/Events/event_type.dart';

class Robot extends PositionComponent {
  late String currentEvent = EventRobot.idle;
  // ────────── CONFIG ──────────
  static const double _bodyBaseY = 42;
  static const double _duckOffset = 20;
  static const double _duckDown = 0.2;
  static const double _duckHold = 1.0;
  static const double _duckUp = 0.2;

  final Vector2 initialPosition;
  final double gravity = 800;
  Vector2 velocity = Vector2.zero();

  // Ducking
  double duckTimer = 0;

  // Track animation
  bool pauseTracks = false;
  double trackTimer = 0;
  int trackFrame = 0;
  late Sprite _track1, _track2;

  // Sprites
  late SpriteComponent body, leftTrack, rightTrack;

  // Misc
  double _angleDelta = 0;

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
    velocity.y = -500;
    isJumping = true;
  }

  void duck() {
    isDucking = true;
    duckTimer = _duckDown + _duckHold + _duckUp;
  }

  void stop() => pauseTracks = true;
  void resume() => pauseTracks = false;

  void trip() {
    _angleDelta = 3;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _updateDuck(dt);
    _updatePhysics(dt);
    _updateTracks(dt);
  }

  void _updateDuck(double dt) {
    if (!isDucking) return;

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
      isDucking = false;
      body.position.y = _bodyBaseY;
    }
  }

  void _updatePhysics(double dt) {
    if (isJumping || isTriping) {
      velocity.y += gravity * dt;
      position += velocity * dt;
    }

    if (isTriping) {
      angle += _angleDelta * dt;
      _angleDelta *= 0.99;
    }

    final bool airborne = isJumping || isTriping || velocity.y != 0;

    if (position.y >= initialPosition.y) {
      position.y = initialPosition.y;
      if (airborne) {
        if (isTriping && velocity.y.abs() > 100) {
          velocity.y = -velocity.y * 0.6;
          _angleDelta *= 0.9;
        } else {
          _resetAll();
        }
      } else {
        velocity.y = 0;
      }
    }
  }

  void _updateTracks(double dt) {
    if (isTriping || isJumping || pauseTracks) return;

    trackTimer += dt;
    if (trackTimer > 0.1) {
      trackTimer = 0;
      trackFrame = 1 - trackFrame;
      final sprite = (trackFrame == 0) ? _track1 : _track2;
      leftTrack.sprite = sprite;
      rightTrack.sprite = sprite;
    }
  }

  void _resetAll() {
    isJumping = false;
    isTriping = false;
    isDucking = false;
    velocity.setZero();
    angle = 0;
    body.position.y = _bodyBaseY;
  }
}
