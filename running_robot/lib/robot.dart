import 'dart:async';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Robot extends SpriteComponent {
  ///Represents a robot object (character)
  //Later on velocity changes when Flame calls update -> position of Robot changes
  Vector2 velocity = Vector2.zero();
  Vector2 initialPosition;
  final double gravity = 800;
  final double resistance = -50;
  bool isOnGround = true;
  bool isTriping = false;
  bool isJumping = false;

  //Constructor
  Robot({required this.initialPosition})
    : super(
        size: Vector2.all(100),
        paint: Paint()..color = Colors.blue,
        anchor: Anchor.center,
      ) {
    position = initialPosition.clone();
  }

  void resetPosition() {
    position.setFrom(initialPosition);
  }

  void trip() {
    isJumping = false;
    isTriping = true;
    velocity = Vector2.zero();
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

    //Add gravity if we accelerate upwards + falling down
    if (isJumping || isTriping) {
      // Always apply gravity when in the air or tripping
      velocity.y += gravity * dt;
      position += velocity * dt;
    }
    if (isTriping) {
      angle += 5 * dt;
    }

    //Readjust position to the Ground when
    //falling down past the initialPoint
    if (position.y >= initialPosition.y) {
      isJumping = false;
      isTriping = false;
      velocity.y = 0;
      position.y = initialPosition.y;
    }
  }
}
