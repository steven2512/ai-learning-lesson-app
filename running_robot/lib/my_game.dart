import 'dart:async';
import 'package:running_robot/background.dart';
import 'package:running_robot/obstacle.dart';
import 'package:running_robot/robot.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class MyGame extends FlameGame with TapDetector {
  ///MainGame
  late Background background;
  late Robot robot;
  late Obstacle obstacle1;
  late int failCount = 0;
  late TextComponent failText;

  @override
  FutureOr<void> onLoad() async {
    //main background
    background = Background(
      backgroundSize: Vector2(size.x, size.y),
    );

    //robot (main char)
    robot = Robot(
      initialPosition: Vector2(size.x / 2 - 50, size.y / 2 - 50),
    );

    //obstacle
    obstacle1 = Obstacle(
      initialPosition: Vector2(size.x, size.y / 2),
    );

    //Fail count - Text
    failText = TextComponent(
      text: "Fail Count: $failCount",
      position: Vector2(size.x / 2 - 60, size.y / 4.5),

      textRenderer: TextPaint(
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    );

    //add Objects to screen
    add(background);
    add(robot);
    add(obstacle1);
    add(failText);
  }

  //Increment Fail Attempts when Collison happens
  void incrementFail() {
    failCount++;
    failText.text = "Fail Count: $failCount";
  }

  @override
  void update(double dt) {
    super.update(dt);

    //Collison logic
    if (robot.toRect().overlaps(obstacle1.toRect())) {
      incrementFail();
      robot.fall();

      // robot.position.setFrom(robot.initialPosition);
      // obstacle1.position.setFrom(obstacle1.initialPosition);
      // obstacle1.velocity.x = 0;

      if (failCount == 3) {
        pauseEngine();
        failText.text = "Game Over!";
      }
    }
  }

  @override
  void onTap() {
    robot.velocity.y = -500;
    robot.isOnGround = false;
  }
}
