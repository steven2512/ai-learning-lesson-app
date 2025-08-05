import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:running_robot/static/background.dart';
import 'package:running_robot/static/ground.dart';
import 'package:running_robot/static/cloud.dart';
import 'package:running_robot/obstacles/duck_obstacle.dart';
import 'package:running_robot/obstacles/fall_obstacle.dart';
import 'package:running_robot/obstacles/jump_obstacle.dart';
import 'package:running_robot/characters/robot.dart';
import 'package:running_robot/texts/main_text.dart';
import 'package:running_robot/texts/lessons/lesson1_text.dart';
import 'package:running_robot/obstacles/rain.dart'; // new import

enum GamePhase {
  intro,
  waitingForSwipe,
  fisrtRun,
  firstTutorial,
  secondRun,
  secondTutorial,
  thirdRun,
  paused,
}

class MyGame extends FlameGame with PanDetector {
  GamePhase phase = GamePhase.intro;

  late Background background;
  late Robot robot;
  late JumpObstacle smallFence;
  late DuckObstacle bird;
  late Ground ground;
  late List<Rain> rainFall;
  int failCount = 0;
  late TextComponent mainText;
  late JumpObstacle currentColliedJumpObstacles;
  bool useFancyDuck = false;

  bool colliedJumpObstacles = false;
  bool colliedDuckObstacles = false;
  bool colliedRainObstacles = false;

  List<JumpObstacle> allJumpObstacles = [];
  List<DuckObstacle> allDuckObstacles = [];
  List<FallObstacle> allFallObstacles = [];

  Vector2? dragStart;
  Vector2? dragLast;

  @override
  FutureOr<void> onLoad() async {
    background = Background(backgroundSize: Vector2(size.x, size.y));
    ground = Ground(dimensions: Vector2(size.x, size.y));
    robot = Robot(
      initialPosition: Vector2(size.x / 2, size.y / 2),
    );

    final fence = JumpObstacle(
      initialPosition: Vector2(size.x + 200, size.y / 1.797),
      picturePath: 'fence.png',
      obstacleSize: Vector2.all(75),
    );
    final bird = DuckObstacle(
      initialPosition: Vector2(size.x + 1000, size.y / 2.5),
    );
    allJumpObstacles.add(fence);
    allDuckObstacles.add(bird);

    final mainText = MainText(
      dimensions: Vector2(size.x, size.y),
      sequence: introText,
    );

    //Generate Rain drops

    rainFall = Rain.generateRain(
      screenSize: size,
      topY: ground.topY,
    );

    //Add all objects
    add(background);
    add(ground);
    add(robot);
    addAll(allJumpObstacles);
    addAll(allDuckObstacles);
    addAll(allFallObstacles);
    add(
      CloudComponent(
        position: Vector2(size.x / 2, 220), // top-center of screen
      ),
    );
    addAll(rainFall);
    add(mainText);
  }

  void pauseAllObstacles() {
    for (var x in allJumpObstacles) x.isPaused = true;
    for (var x in allDuckObstacles) x.isPaused = true;
    for (var x in allFallObstacles) x.isPaused = true;
  }

  void resumeAllObstacles() {
    for (var x in allJumpObstacles) x.isPaused = false;
    for (var x in allDuckObstacles) x.isPaused = false;
    for (var x in allFallObstacles) x.isPaused = false;
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

  void pauseAllFallObstacles() {
    for (var obstacle in allFallObstacles) {
      obstacle.isPaused = true;
    }
  }

  void resumeAllFallObstacles() {
    for (var obstacle in allFallObstacles) {
      obstacle.isPaused = false;
    }
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
    // if (dragStart == null || dragLast == null) return;
    // final delta = dragLast! - dragStart!;

    // switch (phase) {
    //   case GamePhase.intro:
    //     break;
    //   case GamePhase.waitingForSwipe:
    //     if (delta.x > 20 && delta.x.abs() > delta.y.abs()) {
    //       resumeAllObstacles();
    //       robot.resume();
    //       phase = GamePhase.fisrtRun;
    //     }
    //     break;
    //   case GamePhase.fisrtRun:
    //   case GamePhase.firstTutorial:
    //   case GamePhase.secondRun:
    //   case GamePhase.secondTutorial:
    //     break;
    //   case GamePhase.thirdRun:
    //     if (delta.y < -20 && delta.y.abs() > delta.x.abs()) {
    //       if (!robot.isDucking && !robot.isNormalDucking) robot.jump();
    //     } else if (delta.y > 20 && delta.y.abs() > delta.x.abs()) {
    //       if (useFancyDuck) {
    //         robot.fancyDuck();
    //       } else {
    //         robot.normalDuck();
    //       }
    //     } else if (delta.x < -20 && delta.x.abs() > delta.y.abs()) {
    //       robot.stop();
    //       pauseAllJumpObstacles();
    //     } else if (delta.x > 20 && delta.x.abs() > delta.y.abs()) {
    //       robot.resume();
    //       resumeAllObstacles();
    //     }
    //     break;
    //   case GamePhase.paused:
    //     break;
    // }

    // dragStart = null;
    // dragLast = null;
  }
}
