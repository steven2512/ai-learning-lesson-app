import 'dart:async';
import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Robot extends PositionComponent {
  Vector2 velocity = Vector2.zero();
  Vector2 initialPosition;
  final double gravity = 800;

  bool isTriping = false;
  bool isJumping = false;
  double angleChange = 0;

  late SpriteComponent body;
  late SpriteComponent leftTrack;
  late SpriteComponent rightTrack;

  // Ducking
  bool isDucking = false;
  double duckTimer = 0.0;
  final double duckDuration = 1.0; // time to move down/up
  final double duckDelay = 1.0; // delay before moving
  final double holdTime = 2.7; // time staying low

  // Track animation
  double trackAnimationTimer = 0.0;
  int trackFrame = 0;
  late Sprite track1;
  late Sprite track2;

  Robot({required this.initialPosition})
    : super(
        size: Vector2.all(50),
        anchor: Anchor.center,
      ) {
    position = initialPosition.clone();
  }

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

  void reset() {
    isJumping = false;
    isTriping = false;
    position.setFrom(initialPosition);
    body.position.y = 42;
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

  void duck() {
    if (isDucking) return;
    isDucking = true;
    duckTimer = duckDelay + duckDuration + holdTime + duckDuration;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Gravity & trip physics
    if (isJumping || isTriping) {
      velocity.y += gravity * dt;
      position += velocity * dt;
    }
    if (isTriping) {
      angle += angleChange * dt;
      angleChange *= 0.99;
    }
    if (position.y >= initialPosition.y) {
      position.y = initialPosition.y;
      if (isTriping) {
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

    // Ducking logic
    if (isDucking) {
      duckTimer -= dt;
      double t =
          (duckDelay + duckDuration + holdTime + duckDuration) - duckTimer;

      if (t <= duckDelay) {
        // Waiting before moving down
        body.position.y = 42;
      } else if (t <= duckDelay + duckDuration) {
        // Moving down
        double progress = (t - duckDelay) / duckDuration;
        double eased = 1 - math.pow(1 - progress, 3).toDouble();
        body.position.y = 42 + 20 * eased;
      } else if (t <= duckDelay + duckDuration + holdTime) {
        // Staying low
        body.position.y = 62;
      } else if (t <= duckDelay + duckDuration + holdTime + duckDuration) {
        // Moving back up
        double progress =
            (t - (duckDelay + duckDuration + holdTime)) / duckDuration;
        double eased = 1 - math.pow(1 - progress, 3).toDouble();
        body.position.y = 62 - 20 * eased;
      }

      if (duckTimer <= 0) {
        isDucking = false;
        body.position.y = 42;
      }
    }

    // Track animation
    if (!isTriping && !isJumping && !isDucking) {
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
}
