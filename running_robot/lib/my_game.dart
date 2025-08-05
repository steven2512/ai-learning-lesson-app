import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:running_robot/obstacles/bird.dart';
import 'package:running_robot/obstacles/fence.dart';
import 'package:running_robot/obstacles/superclass/animated_horizontal.dart';
import 'package:running_robot/static/background.dart';
import 'package:running_robot/static/ground.dart';
import 'package:running_robot/static/cloud.dart';
import 'package:running_robot/obstacles/superclass/vertical.dart';
import 'package:running_robot/obstacles/superclass/horizontal.dart';
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
  late Bird bird;
  late Ground ground;
  late List<Rain> rainFall;
  late Cloud cloud;
  int failCount = 0;
  late TextComponent mainText;
  late HorizontalObstacle currentColliedJumpObstacles;
  bool useFancyDuck = false;
  late double groundY;

  bool colliedJumpObstacles = false;
  bool colliedRainObstacles = false;

  List<HorizontalObstacle> allHorizontalObstacles = [];
  List<AnimatedHorizontalObstacle> allAnimatedHorizontalObstacles = [];
  List<VerticalObstacle> allVerticalObstacles = [];

  Vector2? dragStart;
  Vector2? dragLast;

  @override
  FutureOr<void> onLoad() async {
    //Background
    background = Background(backgroundSize: Vector2(size.x, size.y));

    //Ground
    ground = Ground(dimensions: Vector2(size.x, size.y));

    //Set absolute ground
    groundY = ground.topY;

    //Robot
    robot = Robot(
      initialPosition: Vector2(size.x / 2, size.y / 2),
    );

    //Fence
    final fence = Fence(
      initialPosition: Vector2(size.x + 200, groundY - 36),
      picturePath: 'fence.png',
      size: Vector2(70, 70),
    );

    // Bird
    // Bird
    bird = Bird(
      initialPosition: Vector2(size.x + 1000, size.y / 2.5),
    );
    allHorizontalObstacles.add(fence);
    allAnimatedHorizontalObstacles.add(bird);

    //Text
    final mainText = MainText(
      dimensions: Vector2(size.x, size.y),
      sequence: introText,
    );

    //Cloud
    cloud = Cloud(
      position: Vector2(size.x / 2, 220), // top-center of screen
    );

    //Rain
    rainFall = Rain.generateRain(
      screenSize: size,
      topY: groundY,
    );

    //Add all objects
    add(background);
    add(ground);
    add(robot);
    // add(bird);
    addAll(allHorizontalObstacles);
    addAll(allVerticalObstacles);
    addAll(allAnimatedHorizontalObstacles);
    add(cloud);
    addAll(rainFall as Iterable<Component>);
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
