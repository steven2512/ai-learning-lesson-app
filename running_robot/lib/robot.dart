import 'dart:async';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Robot extends SpriteComponent {
  // Physics
  final double gravity = 800;
  final Vector2 velocity = Vector2.zero();
  final Vector2 initialPosition;

  // States
  bool isTripping = false;
  bool isJumping = false;
  int extraFrames = 0;
  double angleChange = 0;

  Robot({required this.initialPosition})
    : super(
        size: Vector2.all(100),
        paint: Paint()..color = Colors.blue,
        anchor: Anchor.center,
      ) {
    position = initialPosition.clone();
  }

  @override
  FutureOr<void> onLoad() async {
    sprite = await Sprite.load('robot_yellowDamage1.png');
  }

  void reset() {
    isJumping = false;
    isTripping = false;
    angle = 0;
    velocity.setZero();
    position.setFrom(initialPosition);
  }

  void trip() {
    isJumping = false;
    isTripping = true;
    angleChange = 5;
    extraFrames = 30;
  }

  void jump() {
    if (!isJumping && !isTripping) {
      velocity.y = -500;
      isJumping = true;
    }
  }

  void handleGroundCollision() {
    position.y = initialPosition.y;

    if (isTripping) {
      velocity.setZero();
      angleChange = 0;
      isTripping = false;
    } else {
      reset();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Gravity and movement
    if (isJumping || isTripping) {
      velocity.y += gravity * dt;
      position += velocity * dt;
    }

    // Rotation while tripping
    if (isTripping) {
      angle += angleChange * dt;
      angleChange *= 0.98;
    }

    // Ground check
    final groundY = initialPosition.y;
    final clearance = isTripping ? (size.length / 2 - size.y / 2) : 0;

    if (position.y >= groundY - clearance) {
      position.y = groundY - clearance;

      if (isTripping) {
        if (velocity.y.abs() > 200 && extraFrames > 0) {
          // Bounce
          velocity.y = -velocity.y * 0.5;
          extraFrames--;
        } else {
          // Slow stop without snapping upright
          velocity.y = 0;
          angleChange *= 0.9;
          angle += angleChange * dt;

          extraFrames--;
          if (extraFrames <= -15) {
            isTripping = false;
            isJumping = false;
            velocity.setZero();
          }
        }
      } else {
        reset();
      }
    }
  }
}
