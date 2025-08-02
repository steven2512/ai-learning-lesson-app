import 'dart:async';
import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:running_robot/game_state.dart';

class Robot extends PositionComponent {
  // ────────── CONFIG ──────────
  static const double _bodyBaseY = 42; // standing Y of the body sprite
  static const double _duckOffset = 20; // pixels the body travels down
  static const double _normalDown = 0.25; // slide-down time  (s)
  static const double _normalHold = 1.60; // stay-low time    (s)
  static const double _normalUp = 0.25; // rise-up time     (s)

  // Fancy-duck timings
  final double stopPause = 1.0; // wheels/world pause at each step
  final double duckDur = 1.0; // down / up duration
  final double holdFancy = 2.7; // stay-low in fancy mode
  static const double _worldLag = 0.08; // wheels resume, world 80 ms later

  // ────────── STATE ──────────
  final Vector2 initialPosition;
  final double gravity = 800;
  final GameState gameState;

  Vector2 velocity = Vector2.zero();

  bool isJumping = false;
  bool isTriping = false;

  // Fancy duck
  bool isDucking = false;
  double duckTimer = 0;

  // Normal duck
  bool isNormalDucking = false;
  double normalDuckTimer = 0;

  // Track animation
  bool pauseTracks = false;
  double trackTimer = 0;
  int trackFrame = 0;
  late Sprite _track1, _track2;

  // Sprites
  late SpriteComponent body, leftTrack, rightTrack;

  // Misc
  bool _isStoppingWorld = false;
  double _worldLagTimer = 0;
  double _angleDelta = 0;

  Robot({required this.initialPosition, required this.gameState})
    : super(size: Vector2.all(50), anchor: Anchor.center) {
    position = initialPosition.clone();
  }

  // ────────── LOAD ──────────
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

  // ────────── PUBLIC ACTIONS ──────────
  void jump() {
    if (isDucking || isNormalDucking) return;
    velocity.y = -500;
    isJumping = true;
  }

  void fancyDuck() {
    if (isDucking || isNormalDucking) return;
    isDucking = true;
    _pauseWorldAndTracks();
    duckTimer =
        stopPause +
        duckDur +
        stopPause +
        holdFancy +
        stopPause +
        duckDur +
        stopPause;
  }

  void normalDuck() {
    if (isDucking || isNormalDucking) return;
    isNormalDucking = true;
    normalDuckTimer = _normalDown + _normalHold + _normalUp;
  }

  void stop() => _pauseWorldAndTracks();
  void resume({bool lagWorld = false}) {
    pauseTracks = false;
    _isStoppingWorld = false;
    if (lagWorld) {
      _worldLagTimer = _worldLag;
    } else {
      gameState.isStopped = false;
      _worldLagTimer = 0;
    }
  }

  void trip() {
    isJumping = false;
    isTriping = true;
    _angleDelta = 3;
  }

  // ────────── UPDATE ──────────
  @override
  void update(double dt) {
    super.update(dt);

    // Handle delayed world-resume
    if (_worldLagTimer > 0) {
      _worldLagTimer -= dt;
      if (_worldLagTimer <= 0) gameState.isStopped = false;
    }

    // Skip scenery when frozen (fancy duck only)
    if (gameState.isStopped && !isDucking && _worldLagTimer <= 0) return;

    _updateFancyDuck(dt);
    _updateNormalDuck(dt);
    _updatePhysics(dt);
    _updateTracks(dt);
  }

  // ────────── INTERNALS ──────────
  /* ---------------- Fancy duck ---------------- */
  void _updateFancyDuck(double dt) {
    if (!isDucking) return;

    duckTimer -= dt;
    final total =
        stopPause +
        duckDur +
        stopPause +
        holdFancy +
        stopPause +
        duckDur +
        stopPause;
    final t = total - duckTimer;

    final p1 = stopPause;
    final p2 = p1 + duckDur;
    final p3 = p2 + stopPause;
    final p4 = p3 + holdFancy;
    final p5 = p4 + stopPause;
    final p6 = p5 + duckDur;
    final p7 = p6 + stopPause;

    if (t <= p1) {
      _pauseWorldAndTracks();
      body.position.y = _bodyBaseY;
    } else if (t <= p2) {
      final prog = (t - p1) / duckDur;
      body.position.y =
          _bodyBaseY + _duckOffset * (1 - math.pow(1 - prog, 3)).toDouble();
    } else if (t <= p3) {
      _pauseWorldAndTracks();
      body.position.y = _bodyBaseY + _duckOffset;
    } else if (t <= p4) {
      body.position.y = _bodyBaseY + _duckOffset;
      if (pauseTracks) _resumeTracksThenWorld();
    } else if (t <= p5) {
      _pauseWorldAndTracks();
      body.position.y = _bodyBaseY + _duckOffset;
    } else if (t <= p6) {
      final prog = (t - p5) / duckDur;
      body.position.y =
          _bodyBaseY +
          _duckOffset -
          _duckOffset * (1 - math.pow(1 - prog, 3)).toDouble();
    } else if (t <= p7) {
      _pauseWorldAndTracks();
      body.position.y = _bodyBaseY;
    }

    if (duckTimer <= 0) {
      isDucking = false;
      _resumeTracksThenWorld();
      body.position.y = _bodyBaseY;
    }
  }

  /* ---------------- Normal duck ---------------- */
  void _updateNormalDuck(double dt) {
    if (!isNormalDucking) return;

    normalDuckTimer -= dt;
    final total = _normalDown + _normalHold + _normalUp;
    final t = total - normalDuckTimer;

    final p1 = _normalDown;
    final p2 = p1 + _normalHold;
    final p3 = p2 + _normalUp;

    if (t <= p1) {
      body.position.y = _bodyBaseY + _duckOffset * (t / _normalDown);
    } else if (t <= p2) {
      body.position.y = _bodyBaseY + _duckOffset;
    } else if (t <= p3) {
      body.position.y =
          _bodyBaseY + _duckOffset - _duckOffset * ((t - p2) / _normalUp);
    }

    if (normalDuckTimer <= 0) {
      isNormalDucking = false;
      body.position.y = _bodyBaseY;
    }
  }

  /* ---------------- Physics / landing ---------------- */
  void _updatePhysics(double dt) {
    // Gravity only when airborne
    if (isJumping || isTriping) {
      velocity.y += gravity * dt;
      position += velocity * dt;
    }

    // Trip spin
    if (isTriping) {
      angle += _angleDelta * dt;
      _angleDelta *= 0.99;
    }

    // Landing check
    final bool airborne = isJumping || isTriping || velocity.y != 0;

    if (position.y >= initialPosition.y) {
      position.y = initialPosition.y;

      if (airborne) {
        // We’ve just landed
        if (isTriping) {
          if (velocity.y.abs() > 100) {
            velocity.y = -velocity.y * 0.6;
            _angleDelta *= 0.9;
          } else {
            _resetAll();
          }
        } else {
          _resetAll(); // landed from a jump
        }
      } else {
        velocity.y = 0; // simply standing
      }
    }
  }

  /* ---------------- Tracks animation ---------------- */
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

  /* ---------------- Helpers ---------------- */
  void _pauseWorldAndTracks() {
    _isStoppingWorld = true;
    pauseTracks = true;
    gameState.isStopped = true;
    _worldLagTimer = 0;
  }

  void _resumeTracksThenWorld() {
    pauseTracks = false;
    _isStoppingWorld = false;
    _worldLagTimer = _worldLag;
  }

  void _resetAll() {
    isJumping = false;
    isTriping = false;
    isDucking = false;
    isNormalDucking = false;
    velocity.setZero();
    angle = 0;
    body.position.y = _bodyBaseY;
  }
}
