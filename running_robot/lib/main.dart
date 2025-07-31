import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    //As soon as GameWidget obj is created, Flame will repeatedly runs game.update() 60 times per minute
    //So everything that is added on Load will constantly be updated
    GameWidget(
      game: EmptyGame(),
    ),
  );
}

class EmptyGame extends FlameGame with TapDetector {
  late Robot robot;

  @override
  FutureOr<void> onLoad() async {
    //square object
    robot = Robot(Vector2(size.x / 2 - 50, size.y / 2 - 50));
    //change pos of object to middle of screen

    //add Robot obj on screen
    add(robot);
  }

  @override
  void onTap() {
    robot.velocity.y = -250;
  }
}

class Robot extends RectangleComponent {
  //Later on velocity changes when Flame calls update -> position of Robot changes
  Vector2 velocity = Vector2.zero();
  Vector2 initialPosition;
  Robot(this.initialPosition)
    : super(
        size: Vector2.all(100),
        paint: Paint()..color = Colors.blue,
      ) {
    position = initialPosition.clone();
  }

  //Called 60 times per second
  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
    if (position.y <= initialPosition.y - 100) {
      velocity.y = 250;
    } else if (position.y > initialPosition.y && velocity.y > 0) {
      position.y = initialPosition.y;
      velocity.y = 0;
    }
  }
}
