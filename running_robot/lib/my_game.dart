import 'dart:async';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:running_robot/obstacles/bird.dart';
import 'package:running_robot/obstacles/fence.dart';
import 'package:running_robot/obstacles/superclass/animated_mover.dart';
import 'package:running_robot/static/background.dart';
import 'package:running_robot/static/ground.dart';
import 'package:running_robot/static/cloud.dart';
import 'package:running_robot/obstacles/superclass/vertical.dart';
import 'package:running_robot/obstacles/superclass/horizontal.dart';
import 'package:running_robot/characters/robot.dart';
import 'package:running_robot/texts/main_text.dart';
import 'package:running_robot/texts/lessons/lesson1_text.dart';
import 'package:running_robot/obstacles/rain.dart';
import 'package:running_robot/Events/event_bus.dart';

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
  int failCount = 0;

  bool colliedJumpObstacles = false;
  bool colliedRainObstacles = false;

  Vector2? dragStart;
  Vector2? dragLast;

  @override
  FutureOr<void> onLoad() async {
    //Background
    final background = Background(backgroundSize: Vector2(size.x, size.y));

    //Ground
    final ground = Ground(dimensions: Vector2(size.x, size.y));

    //Set absolute ground
    final groundY = ground.topY;

    //Robot
    final robot = Robot(
      initialPosition: Vector2(size.x / 2, size.y / 2),
    );

    //Fence
    final fence = Fence(
      initialPosition: Vector2(size.x + 200, groundY - 36),
      picturePath: 'fence.png',
      size: Vector2(70, 70),
      velocity: Vector2(-200, 0),
    );

    // Bird
    final bird = Bird(
      framePaths: [
        'bird1.png',
        'bird2.png',
        'bird3.png',
        'bird4.png',
      ],
      startPosition: Vector2(800, 350),
      endPosition: Vector2(-100, 350),
      velocity: Vector2(-150, 0),
      customSize: Vector2.all(50), // make it a big bird
    );

    //Text
    final mainText = MainText(
      dimensions: Vector2(size.x, size.y),
      sequence: introText,
    );

    //Cloud
    final cloud = Cloud(
      position: Vector2(size.x / 2, 220), // top-center of screen
    );

    //Rain
    final rainFall = Rain.generateRain(
      count: 30,
      startAreaTopLeft: Vector2(size.x / 3, 200),
      startAreaBottomRight: Vector2(size.x * 2 / 3, 280),
      endPosition: Vector2(size.x / 2, groundY),
      minSpeed: 100,
      maxSpeed: 250,
    );

    addAll(rainFall);

    //Add all objects
    add(background);
    add(ground);
    add(robot);
    add(cloud);
    add(fence);
    add(bird);
    addAll(rainFall);
    add(mainText);
  }

  // void pauseAllObstacles() {
  //   for (var x in allJumpObstacles) x.isPaused = true;
  //   for (var x in allDuckObstacles) x.isPaused = true;
  //   for (var x in allFallObstacles) x.isPaused = true;
  // }

  // void resumeAllObstacles() {
  //   for (var x in allJumpObstacles) x.isPaused = false;
  //   for (var x in allDuckObstacles) x.isPaused = false;
  //   for (var x in allFallObstacles) x.isPaused = false;
  // }

  // void pauseAllJumpObstacles() {
  //   for (var obstacle in allJumpObstacles) {
  //     obstacle.isPaused = true;
  //   }
  // }

  // void pauseAllDuckObstacles() {
  //   for (var obstacle in allDuckObstacles) {
  //     obstacle.isPaused = true;
  //   }
  // }

  // void pauseAllFallObstacles() {
  //   for (var obstacle in allFallObstacles) {
  //     obstacle.isPaused = true;
  //   }
  // }

  // void resumeAllFallObstacles() {
  //   for (var obstacle in allFallObstacles) {
  //     obstacle.isPaused = false;
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
