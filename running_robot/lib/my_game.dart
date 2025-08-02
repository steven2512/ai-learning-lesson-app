import 'dart:async';
import 'package:flame/events.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/background.dart';
import 'package:running_robot/game_state.dart';
import 'package:running_robot/ground.dart';
import 'package:running_robot/obstacles/duck_obstacle.dart';
import 'package:running_robot/obstacles/jump_obstacle.dart';
import 'package:running_robot/characters/robot.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:running_robot/text_objects/1/main_text.dart';

enum GamePhase {
  intro, // showing text and gestures
  waitingForSwipe,
  fisrtRun,
  firstTutorial,
  secondRun,
  secondTutorial,
  thirdRun, // normal gameplay
  paused,
}

class MyGame extends FlameGame with PanDetector {
  //current phase
  GamePhase phase = GamePhase.intro;

  late Background background;
  late Robot robot;
  late JumpObstacle smallFence;
  late DuckObstacle bird;
  late Ground ground;
  int failCount = 0;
  late TextComponent mainText;
  final GameState gameState = GameState();
  late JumpObstacle currentColliedJumpObstacles;
  bool useFancyDuck = false;

  bool colliedJumpObstacles = false;
  bool colliedDuckObstacles = false;
  bool colliedRainObstacles = false;

  List<JumpObstacle> allJumpObstacles = [];
  List<DuckObstacle> allDuckObstacles = [];
  // List<FallObstacles> allFallObstacles = [];

  Vector2? dragStart;
  Vector2? dragLast;

  @override
  FutureOr<void> onLoad() async {
    background = Background(backgroundSize: Vector2(size.x, size.y));
    ground = Ground(
      dimensions: Vector2(size.x, size.y),
    );

    // Robot no longer takes gameState
    robot = Robot(
      initialPosition: Vector2(size.x / 2, size.y / 2),
      gamePhase: phase,
    );

    // Jump obstacle
    smallFence = JumpObstacle(
      initialPosition: Vector2(size.x + 200, size.y / 1.797),
      picturePath: 'fence.png',
      obstacleSize: Vector2.all(75),
      gamePhase: phase,
    );
    allJumpObstacles.add(smallFence);

    // Duck obstacle
    bird = DuckObstacle(
      initialPosition: Vector2(size.x + 1000, size.y / 2.5),
      gamePhase: phase,
    );
    allDuckObstacles.add(bird);

    //Main Text on top of Level
    mainText = MainText(
      dimensions: Vector2(size.x, size.y),
    );

    add(background);
    add(ground);
    add(robot);
    add(mainText);
    for (var obstacle in allJumpObstacles) {
      add(obstacle);
    }
    for (var obstacle in allDuckObstacles) {
      add(obstacle);
    }
  }

  // ---- Pause & Resume methods ----
  void pauseAllObstacles() {
    for (var x in allJumpObstacles) {
      x.isPaused = true;
    }
    for (var x in allDuckObstacles) {
      x.isPaused = true;
    }
    // for (var x in allFallObstacles) {
    //   x.isPaused = true;
    // }
  }

  void resumeAllObstacles() {
    for (var x in allJumpObstacles) {
      x.isPaused = false;
    }
    for (var x in allDuckObstacles) {
      x.isPaused = false;
    }
    // for (var x in allFallObstacles) {
    //   x.isPaused = false;
    // }
  }

  void pauseAllJumpObstacles() {
    for (var obstacle in allJumpObstacles) {
      obstacle.isPaused = true;
    }
  }

  void pauseAllDuckObstacles() {
    for (var obstacle in allDuckObstacles) {
      obstacle.isPaused = true;
    }
  }

  // void pauseAllFallObstacles() {
  //   for (var obstacle in allFallObstacles) {
  //     obstacle.isPaused = true;
  //   }
  // }

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

    switch (phase) {
      case GamePhase.intro:
        // TODO: Handle intro swipes (currently do nothing)
        break;

      case GamePhase.waitingForSwipe:
        // TODO: Handle waiting for swipe to start
        if (delta.x > 20 && delta.x.abs() > delta.y.abs()) {
          resumeAllObstacles();
          robot.resume();
          phase = GamePhase.fisrtRun; // move into first run when swipe right
        }
        break;

      case GamePhase.fisrtRun:
        // TODO: Handle swipes during the first run
        break;

      case GamePhase.firstTutorial:
        // TODO: Handle swipes during the first tutorial
        break;

      case GamePhase.secondRun:
        // TODO: Handle swipes during the second run
        break;

      case GamePhase.secondTutorial:
        // TODO: Handle swipes during the second tutorial
        break;

      case GamePhase.thirdRun:
        // TODO: Normal gameplay swipe logic
        if (delta.y < -20 && delta.y.abs() > delta.x.abs()) {
          if (!robot.isDucking && !robot.isNormalDucking) robot.jump();
        } else if (delta.y > 20 && delta.y.abs() > delta.x.abs()) {
          if (useFancyDuck) {
            robot.fancyDuck();
          } else {
            robot.normalDuck();
          }
        } else if (delta.x < -20 && delta.x.abs() > delta.y.abs()) {
          robot.stop();
          pauseAllJumpObstacles();
        } else if (delta.x > 20 && delta.x.abs() > delta.y.abs()) {
          robot.resume();
          resumeAllObstacles();
        }
        break;

      case GamePhase.paused:
        // TODO: Maybe handle unpausing
        break;
    }

    dragStart = null;
    dragLast = null;
  }
}
