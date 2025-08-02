// Robot.dart
import 'dart:async';
import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:running_robot/game_state.dart';

class Robot extends PositionComponent {
  // ──────────────────────────────────────────────────────────────────────────────
  // BASIC FIELDS (unchanged)
  // ──────────────────────────────────────────────────────────────────────────────
  final Vector2 initialPosition;
  final double gravity = 800;
  final GameState gameState;

  Vector2 velocity = Vector2.zero();

  bool isTriping = false;
  bool isJumping = false;
  bool isStopping = false;
  bool isDucking = false;

  double angleChange = 0;
  double duckTimer = 0.0;

  // Ducking parameters
  final double stopPause = 1.0;
  final double duckDuration = 1.0;
  final double holdTime = 2.7;

  // Track animation
  bool pauseTracks = false;
  double trackAnimationTimer = 0.0;
  int trackFrame = 0;
  late Sprite track1;
  late Sprite track2;

  late SpriteComponent body;
  late SpriteComponent leftTrack;
  late SpriteComponent rightTrack;

  // ──────────────────────────────────────────────────────────────────────────────
  // NEW: world-resume delay
  // ──────────────────────────────────────────────────────────────────────────────
  static const double _worldLag = 0.08; // 50 ms
  double _worldLagTimer = 0.0; // counts down each frame

  Robot({required this.initialPosition, required this.gameState})
    : super(size: Vector2.all(50), anchor: Anchor.center) {
    position = initialPosition.clone();
  }

  // ──────────────────────────────────────────────────────────────────────────────
  // Asset loading (unchanged)
  // ──────────────────────────────────────────────────────────────────────────────
  @override
  Future<void> onLoad() async {
    track1 = await Sprite.load('tracks_long1.png');
    track2 = await Sprite.load('tracks_long2.png');

    body = SpriteComponent()
      ..sprite = await Sprite.load('robot_yellowBody.png')
      ..anchor = Anchor.center
      ..size = Vector2(100, 90)
      ..position = Vector2(20, 42);

    leftTrack = SpriteComponent()
      ..sprite = track1
      ..anchor = Anchor.center
      ..size = Vector2(70, 60)
      ..position = Vector2(-11, 84);

    rightTrack = SpriteComponent()
      ..sprite = track1
      ..anchor = Anchor.center
      ..size = Vector2(60, 60)
      ..position = Vector2(64, 84);

    add(rightTrack);
    add(body);
    add(leftTrack);
  }

  // ──────────────────────────────────────────────────────────────────────────────
  // PUBLIC API – jump / trip / duck / stop / resume
  // ──────────────────────────────────────────────────────────────────────────────
  void reset() {
    isJumping = false;
    isTriping = false;
    position.setFrom(initialPosition);
    body.position.y = 42;
    velocity.setZero();
    angle = 0;
    angleChange = 0;
  }

  void trip() {
    isJumping = false;
    isTriping = true;
    angleChange = 3;
  }

  void jump() {
    velocity.y = -500;
    isJumping = true;
  }

  /// Called from `MyGame` on swipe-down
  void duck() {
    if (isDucking) return;

    isDucking = true;

    // Stop everything *immediately*
    _stopWorldAndWheels();

    duckTimer =
        stopPause +
        duckDuration +
        stopPause +
        holdTime +
        stopPause +
        duckDuration +
        stopPause;
  }

  /// Wheels + world stop together
  void _stopWorldAndWheels() {
    isStopping = true;
    pauseTracks = true;
    gameState.isStopped = true;
    _worldLagTimer = 0.0; // cancel any pending resume
  }

  /// Wheels start now – world resumes after a short lag
  void _resumeWheelsThenWorld() {
    pauseTracks = false;
    isStopping = false;
    _worldLagTimer = _worldLag; // keep world frozen for 50 ms longer
  }

  // ──────────────────────────────────────────────────────────────────────────────
  // MAIN UPDATE LOOP
  // ──────────────────────────────────────────────────────────────────────────────
  @override
  void update(double dt) {
    super.update(dt);

    // Handle “world catches up” delay
    if (_worldLagTimer > 0) {
      _worldLagTimer -= dt;
      if (_worldLagTimer <= 0) {
        gameState.isStopped = false; // let the scenery move
      }
    }

    // If the world is frozen AND we’re not in a duck-sequence AND no lag pending,
    // skip physics/animation work this frame.
    if (gameState.isStopped && !isDucking && _worldLagTimer <= 0) return;

    _updatePhysics(dt);
    _updateDucking(dt);
    _updateTrackAnimation(dt);
  }

  // ──────────────────────────────────────────────────────────────────────────────
  // PHYSICS (unchanged from your version)
  // ──────────────────────────────────────────────────────────────────────────────
  void _updatePhysics(double dt) {
    if (isJumping || isTriping) {
      velocity.y += gravity * dt;
      position += velocity * dt;
    }

    if (isTriping) {
      angle += angleChange * dt;
      angleChange *= 0.99;
    }

    // Land on ground
    if (position.y >= initialPosition.y) {
      position.y = initialPosition.y;

      if (isTriping) {
        // Bounce a bit when tripping
        if (velocity.y.abs() > 100) {
          velocity.y = -velocity.y * 0.6;
          angleChange *= 0.9;
        } else {
          reset();
        }
      } else {
        reset();
      }
    }
  }
  // ──────────────────────────────────────────────────────────────────────────────
  // COMPATIBILITY HELPERS (restore old API)
  // ──────────────────────────────────────────────────────────────────────────────

  /// Freeze wheels **and** scenery immediately (same as the old stop()).
  void stop() => _stopWorldAndWheels();

  /// Spin the wheels again.
  /// By default the scenery un-freezes **immediately** (no lag), which is
  /// what you want for the normal swipe-right gesture.
  /// If you need the 50 ms delayed resume (only used inside the duck
  /// animation) call: `robot.resume(lagWorld: true)`.
  void resume({bool lagWorld = false}) {
    pauseTracks = false;
    isStopping = false;
    if (lagWorld) {
      _worldLagTimer = _worldLag; // wheels now, world after 50 ms
    } else {
      gameState.isStopped = false; // wheels + world right away
      _worldLagTimer = 0.0;
    }
  }

  // ──────────────────────────────────────────────────────────────────────────────
  // DUCK-SEQUENCE, now with the exact timing requested
  // ──────────────────────────────────────────────────────────────────────────────
  void _updateDucking(double dt) {
    if (!isDucking) return;

    duckTimer -= dt;

    final total =
        stopPause +
        duckDuration +
        stopPause +
        holdTime +
        stopPause +
        duckDuration +
        stopPause;
    final t = total - duckTimer;

    // Phase markers
    final p1 = stopPause; // wheels & world STOP
    final p2 = p1 + duckDuration; // move down (still stopped)
    final p3 = p2 + stopPause; // low pause  (still stopped)
    final p4 = p3 + holdTime; // wheels RUN – world resumes after 50 ms
    final p5 = p4 + stopPause; // wheels stop again – world STOP
    final p6 = p5 + duckDuration; // move back up (still stopped)
    final p7 = p6 + stopPause; // pause fully up (still stopped)

    // ────── 1) PRE-DUCK PAUSE (STOP) ──────
    if (t <= p1) {
      _stopWorldAndWheels();
      body.position.y = 42;
    }
    // ────── 2) MOVE DOWN (STOP) ──────
    else if (t <= p2) {
      final prog = (t - p1) / duckDuration;
      final eased = 1 - math.pow(1 - prog, 3).toDouble();
      body.position.y = 42 + 20 * eased; // slide down 20 px
      // wheels & world remain stopped
    }
    // ────── 3) LOW PAUSE (STOP) ──────
    else if (t <= p3) {
      _stopWorldAndWheels();
      body.position.y = 62;
    }
    // ────── 4) HOLD LOW – WHEELS RUN, WORLD LAGS 50 ms ──────
    else if (t <= p4) {
      body.position.y = 62;
      if (pauseTracks) _resumeWheelsThenWorld(); // only once
    }
    // ────── 5) SECOND STOP BEFORE RISE ──────
    else if (t <= p5) {
      _stopWorldAndWheels();
      body.position.y = 62;
    }
    // ────── 6) MOVE BACK UP (STOP) ──────
    else if (t <= p6) {
      final prog = (t - p5) / duckDuration;
      final eased = 1 - math.pow(1 - prog, 3).toDouble();
      body.position.y = 62 - 20 * eased; // slide back up
      // wheels & world remain stopped
    }
    // ────── 7) TOP PAUSE (STOP) ──────
    else if (t <= p7) {
      _stopWorldAndWheels();
      body.position.y = 42;
    }

    // ────── 8) SEQUENCE COMPLETE – WHEELS RUN, WORLD LAGS 50 ms ──────
    if (duckTimer <= 0) {
      isDucking = false;
      _resumeWheelsThenWorld(); // wheels first, world 50 ms later
      body.position.y = 42;
    }
  }

  // ──────────────────────────────────────────────────────────────────────────────
  // TRACK ANIMATION (unchanged)
  // ──────────────────────────────────────────────────────────────────────────────
  void _updateTrackAnimation(double dt) {
    if (isTriping || isJumping || pauseTracks) return;

    trackAnimationTimer += dt;
    if (trackAnimationTimer > 0.1) {
      trackAnimationTimer = 0;
      trackFrame = (trackFrame + 1) % 2;
      final currentSprite = (trackFrame == 0) ? track1 : track2;
      leftTrack.sprite = currentSprite;
      rightTrack.sprite = currentSprite;
    }
  }
}
