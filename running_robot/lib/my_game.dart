import 'dart:async';
import 'package:flame/events.dart';
import 'package:running_robot/background.dart';
import 'package:running_robot/game_state.dart';
import 'package:running_robot/ground.dart';
import 'package:running_robot/obstacles/bird.dart';
import 'package:running_robot/obstacles/jump_obstacle.dart';
import 'package:running_robot/characters/robot.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class MyGame extends FlameGame with PanDetector {
  late Background background;

  //Character and obstcles
  late Robot robot;
  late JumpObstacle smallFence;
  late Bird bird;
  late Ground ground;
  int failCount = 0;
  late TextComponent failText;
  final GameState gameState = GameState(); // NEW
  late JumpObstacle currentColliedJumpObstacles;
  bool useFancyDuck = false;

  //Check collisons flags
  bool colliedJumpObstacles = false;
  bool colliedDuckObstacles = false;
  bool colliedRainObstacles = false;

  //Motions dector
  Vector2? dragStart;
  Vector2? dragLast;
  List<JumpObstacle> allJumpObstacles = [];

  @override
  FutureOr<void> onLoad() async {
    background = Background(backgroundSize: Vector2(size.x, size.y));
    ground = Ground(
      dimensions: Vector2(size.x, size.y),
      gameState: gameState,
    );

    //Main Character (robot)
    robot = Robot(
      initialPosition: Vector2(size.x / 2, size.y / 2),
      gameState: gameState,
    );

    //Fence Obstacle (to jump over)
    smallFence = JumpObstacle(
      initialPosition: Vector2(size.x + 200, size.y / 1.797),
      gameState: gameState,
      picturePath: 'fence.png',
      obstacleSize: Vector2.all(75),
    );
    allJumpObstacles.add(smallFence);

    //Bird Obstacle
    bird = Bird(
      initialPosition: Vector2(size.x + 1000, size.y / 2.5),
      gameState: gameState,
    );

    //Text
    failText = TextComponent(
      text: "Fail Count: $failCount",
      position: Vector2(size.x / 2 - 60, size.y / 4.5),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
        ),
      ),
    );

    //Add all objects to screen
    add(background);
    add(ground);
    add(robot);
    add(bird);
    allJumpObstacles.forEach((x) => add(x));
    add(failText);
  }

  void incrementFail() {
    failCount++;
    failText.text = "Fail Count: $failCount";
  }

  @override
  void update(double dt) {
    super.update(dt);

    // if (gameState.isStopped) return;

    // Jump Obstacle detection
    // for (var i = 0; i < allJumpObstacles.length; i++) {
    //   if (robot.toRect().overlaps(allJumpObstacles[i].toRect())) {
    //     currentColliedJumpObstacles = allJumpObstacles[i];
    //     colliedJumpObstacles = true;
    //     if (robot.isJumping) {
    //       robot.trip();
    //       break;
    //     }
    //   }
    // }

    // // Handle fail conditions
    // if (colliedJumpObstacles && !robot.isTriping) {
    //   incrementFail();
    //   pauseEngine();
    // } else if (colliedJumpObstacles &&
    //     robot.isTriping &&
    //     currentColliedJumpObstacles.x <= -50) {
    //   incrementFail();
    //   pauseEngine();
    // }
  }

  @override
  void onPanStart(DragStartInfo info) {
    dragStart = info.eventPosition.global;
    dragLast = dragStart;
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    dragLast = info.eventPosition.global;
  }

  @override
  void onPanEnd(DragEndInfo info) {
    if (dragStart == null || dragLast == null) return;
    final delta = dragLast! - dragStart!;

    // Swipe up = jump
    if (delta.y < -20 && delta.y.abs() > delta.x.abs()) {
      if (!robot.isDucking && !robot.isNormalDucking) robot.jump();
    }
    // Swipe down = duck (choose normal or fancy)
    else if (delta.y > 20 && delta.y.abs() > delta.x.abs()) {
      if (useFancyDuck) {
        robot.fancyDuck();
      } else {
        robot.normalDuck();
      }
    }
    // Swipe left / right — unchanged …
    else if (delta.x < -20 && delta.x.abs() > delta.y.abs()) {
      robot.stop();
    } else if (delta.x > 20 && delta.x.abs() > delta.y.abs()) {
      robot.resume(lagWorld: true);
    }

    dragStart = null;
    dragLast = null;
  }
}
