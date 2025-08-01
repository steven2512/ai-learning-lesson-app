import 'dart:async';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Robot extends SpriteComponent {
  ///Represents a robot object (character)
  //Later on velocity changes when Flame calls update -> position of Robot changes
  Vector2 velocity = Vector2.zero();
  Vector2 initialPosition;
  final double gravity = 800;
  bool isTriping = false;
  bool isJumping = false;
  int extraFrames = 0;
  double angleChange = 0;

  //Constructor
  Robot({required this.initialPosition})
    : super(
        size: Vector2.all(100),
        paint: Paint()..color = Colors.blue,
        anchor: Anchor.center,
      ) {
    position = initialPosition.clone();
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

  @override
  FutureOr<void> onLoad() async {
    sprite = await Sprite.load('robot_yellowDamage1.png');
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
  }
}
