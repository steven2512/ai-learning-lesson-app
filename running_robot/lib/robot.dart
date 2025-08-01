import 'dart:async';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Robot extends PositionComponent {
  ///Represents a robot object (character)
  //Later on velocity changes when Flame calls update -> position of Robot changes
  Vector2 velocity = Vector2.zero();
  Vector2 initialPosition;
  final double gravity = 800;
  bool isTriping = false;
  bool isJumping = false;
  int extraFrames = 0;
  double angleChange = 0;
  late SpriteComponent body;
  late SpriteComponent leftTrack;
  late SpriteComponent rightTrack;
  bool isDucking = false;
  double duckTimer = 0.0;
  final double duckDuration = 0.4; // total time (0.2 down + 0.2 up
  double trackAnimationTimer = 0.0;
  int trackFrame = 0;
  late Sprite track1;
  late Sprite track2;

  //Constructor
  Robot({required this.initialPosition})
    : super(
        size: Vector2.all(50),
        anchor: Anchor.center,
      ) {
    position = initialPosition.clone();
  }

  @override
  Future<void> onLoad() async {
    // Body
    track1 = await Sprite.load('tracks_long1.png');
    track2 = await Sprite.load('tracks_long2.png');
    body = SpriteComponent()
      ..sprite = await Sprite.load('robot_yellowBody.png')
      ..anchor = Anchor.center
      ..size = Vector2(100, 100); // make sure body is 100x100

    // Tracks
    leftTrack = SpriteComponent()
      ..sprite = await Sprite.load('tracks_long1.png')
      ..anchor = Anchor.center
      ..size =
          Vector2(70, 60) // make track visible
      ..position = Vector2(-35, 43); // push far left and down a bit

    rightTrack = SpriteComponent()
      ..sprite = await Sprite.load('tracks_long1.png')
      ..anchor = Anchor.center
      ..size = Vector2(60, 60)
      ..position = Vector2(45, 43); // push far right

    add(rightTrack);
    add(body);
    add(leftTrack);
  }

  void reset() {
    isJumping = false;
    isTriping = false;
    position.setFrom(initialPosition);
  }

  void trip() {
    isJumping = false;
    isTriping = true;
    angleChange = 3;
    extraFrames = 20;
  }

  void jump() {
    velocity.y = -500;
    isJumping = true;
  }

  void duck() {
    if (isDucking) return;
    isDucking = true;
    duckTimer = duckDuration;
  }

  @override
  Rect toRect() {
    return super.toRect();
  }

  //Called 60 times per second
  @override
  void update(double dt) {
    super.update(dt);

    // Apply gravity when in air or tripping
    if (isJumping || isTriping) {
      velocity.y += gravity * dt;
      position += velocity * dt;
    }

    if (isTriping) {
      // Stronger spin
      angle += angleChange * dt;
      angleChange *= 0.99; // slower decay
    }

    // Ground collision (line respected at initialPosition.y)
    if (position.y >= initialPosition.y) {
      position.y = initialPosition.y;

      if (isTriping) {
        // Pronounced bounce
        if (velocity.y.abs() > 100) {
          velocity.y = -velocity.y * 0.6; // stronger rebound
          angleChange *= 0.9; // maintain spin
        } else {
          reset();
        }
      } else {
        reset();
      }
    }
    if (isDucking) {
      duckTimer -= dt;

      // progress goes from 0 → 1 → 0
      double half = duckDuration / 2;
      double t;
      if (duckTimer > half) {
        // going down (first half)
        t = 1 - (duckTimer - half) / half; // 0 to 1
      } else {
        // coming back up (second half)
        t = duckTimer / half; // 1 back to 0
      }

      // interpolate values:
      // scaleY: 1 → 0.7
      double scaleY = 1 - 0.3 * t;
      double offsetY = 10 * t;

      body.scale = Vector2(1.0, scaleY);
      body.position.y = offsetY;

      if (duckTimer <= 0) {
        isDucking = false;
        body.scale = Vector2.all(1.0);
        body.position.y = 0;
      }
    }
    if (!isTriping && !isJumping) {
      trackAnimationTimer += dt;
      if (trackAnimationTimer > 0.1) {
        // change frame every 0.1 sec
        trackAnimationTimer = 0;
        trackFrame = (trackFrame + 1) % 2;
        final currentSprite = (trackFrame == 0) ? track1 : track2;
        leftTrack.sprite = currentSprite;
        rightTrack.sprite = currentSprite;
      }
    }
  }
}
