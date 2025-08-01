import 'dart:async';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Robot extends PositionComponent {
  ///Represents a robot object (character)

  // Physics and state fields
  Vector2 velocity = Vector2.zero(); // Current velocity (x,y)
  Vector2 initialPosition; // Where the robot starts (used to reset)
  final double gravity = 800; // Downward acceleration

  bool isTriping = false; // True when falling/spinning after tripping
  bool isJumping = false; // True when in a jump
  int extraFrames = 0; // Used during trip for extra spin time
  double angleChange = 0; // How fast to spin when tripping

  // Visual components
  late SpriteComponent body; // Robot body sprite
  late SpriteComponent leftTrack; // Left track sprite
  late SpriteComponent rightTrack; // Right track sprite

  // Ducking animation state
  bool isDucking = false;
  double duckTimer = 0.0;
  final double duckDuration = 0.4; // Total time for duck down+up

  // Track animation (flipbook) state
  double trackAnimationTimer = 0.0; // Timer to switch frames
  int trackFrame = 0; // 0 or 1: which frame is shown
  late Sprite track1; // First track frame
  late Sprite track2; // Second track frame

  // Constructor: sets size, anchor and starting position
  Robot({required this.initialPosition})
    : super(
        size: Vector2.all(50),
        anchor: Anchor.center,
      ) {
    position = initialPosition.clone();
  }

  @override
  Future<void> onLoad() async {
    // Load track sprites for animation
    track1 = await Sprite.load('tracks_long1.png');
    track2 = await Sprite.load('tracks_long2.png');

    // Load body sprite
    body = SpriteComponent()
      ..sprite = await Sprite.load('robot_yellowBody.png')
      ..anchor = Anchor.center
      ..size = Vector2(100, 90)
      ..position = Vector2(20, 42); // make sure body is 100x100

    // Create left track component
    leftTrack = SpriteComponent()
      ..sprite = await Sprite.load('tracks_long1.png')
      ..anchor = Anchor.center
      ..size = Vector2(70, 60)
      ..position = Vector2(-13, 84); // offset to the left and down

    // Create right track component
    rightTrack = SpriteComponent()
      ..sprite = await Sprite.load('tracks_long1.png')
      ..anchor = Anchor.center
      ..size = Vector2(60, 60)
      ..position = Vector2(64, 84); // offset to the right and down

    // Add them in order: right track (behind), body, left track (front)
    add(rightTrack);
    add(body);
    add(leftTrack);
  }

  // Reset robot state to initial (used after landing)
  void reset() {
    isJumping = false;
    isTriping = false;
    position.setFrom(initialPosition);
  }

  // Trigger trip state: spinning fall
  void trip() {
    isJumping = false;
    isTriping = true;
    angleChange = 3;
    extraFrames = 20;
  }

  // Trigger jump: set vertical velocity upwards
  void jump() {
    velocity.y = -500;
    isJumping = true;
  }

  // Trigger duck animation
  void duck() {
    if (isDucking) return;
    isDucking = true;
    duckTimer = duckDuration;
  }

  @override
  Rect toRect() {
    return super.toRect();
  }

  // Update called 60x per second
  @override
  void update(double dt) {
    super.update(dt);

    // Apply gravity and position change while jumping or tripping
    if (isJumping || isTriping) {
      velocity.y += gravity * dt;
      position += velocity * dt;
    }

    // Handle tripping spin: increase angle
    if (isTriping) {
      angle += angleChange * dt;
      angleChange *= 0.99; // slow down spin over time
    }

    // Ground collision: stop at initialPosition.y
    if (position.y >= initialPosition.y) {
      position.y = initialPosition.y;

      // Bounce if tripping with high velocity, otherwise reset
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

    // Handle duck animation
    if (isDucking) {
      duckTimer -= dt;

      // progress goes 0 → 1 → 0
      double half = duckDuration / 2;
      double t;
      if (duckTimer > half) {
        // Going down
        t = 1 - (duckTimer - half) / half;
        t = 1 - (1 - t) * (1 - t); // ease-out: quick start, slow finish
      } else {
        // Coming up
        t = duckTimer / half;
        t = t * t; // ease-in: slow start, quick finish
      }

      // Drop the whole robot (simulate suspension compression)
      position.y = initialPosition.y + 8 * t; // 8px downward

      // Slight squash on the body (subtle, mechanical)
      double scaleY = 1 - 0.15 * t; // only 15% squish
      body.scale = Vector2(1.0, scaleY);

      // Tilt the tracks outward for stability
      leftTrack.angle = -0.05 * t; // ~3 degrees
      rightTrack.angle = 0.05 * t;

      // When duck is done, reset everything
      if (duckTimer <= 0) {
        isDucking = false;
        position.y = initialPosition.y;
        body.scale = Vector2.all(1.0);
        leftTrack.angle = 0;
        rightTrack.angle = 0;
      }
    }

    // Animate tracks/wheels when robot is on ground
    //and not tripping/jumping
    if (!isTriping && !isJumping) {
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
