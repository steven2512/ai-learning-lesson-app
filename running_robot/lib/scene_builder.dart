import 'dart:async';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' hide CloseButton;

// Components from your project
import 'package:running_robot/static/background.dart';
import 'package:running_robot/static/ground.dart';
import 'package:running_robot/characters/robot.dart';
import 'package:running_robot/obstacles/fence.dart';
import 'package:running_robot/texts/arrow.dart';
import 'package:running_robot/obstacles/bird.dart';
import 'package:running_robot/obstacles/cloud.dart';
import 'package:running_robot/obstacles/rain.dart';
import 'package:running_robot/decorations/progress_bar.dart';
import 'package:running_robot/decorations/pause.dart';
import 'package:running_robot/texts/mcq.dart';
import 'package:running_robot/texts/text_box.dart';
import 'package:running_robot/texts/lessons/lesson1_text.dart';

class SceneBuildResult {
  final Background background;
  final Ground ground;
  final Robot robot;
  final Fence barell;
  final Bird bird;
  final FancyTextBox introTextBox;
  final FancyTextBox firstRunTextBox;
  final LessonProgressBar progressBar;
  final PauseButton pauseButton;
  final Cloud cloudRain;
  final List<Cloud> clouds;
  final List<Rain> rainFall;
  final Arrow arrowDown;
  final McqBox mcqFirstRun;

  /// Components to add to the game in the correct draw order.
  final List<Component> components;

  SceneBuildResult({
    required this.background,
    required this.ground,
    required this.robot,
    required this.barell,
    required this.bird,
    required this.introTextBox,
    required this.firstRunTextBox,
    required this.progressBar,
    required this.pauseButton,
    required this.cloudRain,
    required this.clouds,
    required this.rainFall,
    required this.arrowDown,
    required this.mcqFirstRun,
    required this.components,
  });
}

class SceneBuilder {
  final Vector2 gameSize;

  SceneBuilder(this.gameSize);

  FutureOr<SceneBuildResult> build() {
    // Background + Ground
    final background = Background(
      backgroundSize: Vector2(gameSize.x, gameSize.y),
    );

    final ground = Ground(dimensions: Vector2(gameSize.x, gameSize.y));
    final groundY = ground.topY;

    // Robot
    final robot = Robot(
      initialPosition: Vector2(gameSize.x / 2, gameSize.y / 2),
      groundY: groundY,
    );

    // Fence (barrel)
    final barell = Fence(
      initialPosition: Vector2(gameSize.x + 200, groundY - 45),
      picturePath: 'barrell_red.png',
      groundY: groundY,
      size: Vector2(90, 90),
      velocity: Vector2(-70, 0),
    );

    // Arrow
    final arrowDown = Arrow(
      imageFile: 'down_arrow.png',
      position: Vector2(gameSize.x / 2 - 18, gameSize.y - 560),
      size: Vector2(35, 54),
    );

    // Bird
    final bird = Bird(
      framePaths: [
        'bat.png',
        'bat_hang.png',
        'bat_fly.png',
      ],
      startPosition: Vector2(gameSize.x + 100, 450),
      endPosition: Vector2(-100, 450),
      velocity: Vector2(-80, 0),
      customSize: Vector2(80, 50),
    );

    // Main storytelling text boxes
    final introTextBox = FancyTextBox(
      sequence: introText,
      interval: 4.5,
      fadeDuration: 0.5,
      position: Vector2(gameSize.x / 2, gameSize.y / 3),
      anchor: Anchor.center,
      fontSize: 25,
      letterSpacing: 0.5,
      fontWeight: FontWeight.w800,
      maxWidth: 350,
    );

    final firstRunTextBox = FancyTextBox(
      sequence: firstRunText,
      durations: [3, 3, 3, 3, 5],
      intervals: [0, 3, 8, 4, 2],
      fadeDuration: 0.5,
      position: Vector2(gameSize.x / 2, gameSize.y / 3),
      anchor: Anchor.center,
      fontSize: 25,
      letterSpacing: 0.5,
      fontWeight: FontWeight.w800,
      maxWidth: 350,
    );

    // MCQ
    late final McqBox mcqFirstRun;
    mcqFirstRun = McqBox(
      questions: ['Why do you think Robo failed?'],
      answers: [
        'Robo is not intelligent enough',
        'Robo has not learned this course',
      ],
      answerExplanations: [
        'Corrects',
        """❌ Not exactly. Robo just hasn’t been trained on this task yet.\n\n⇒ Without examples and feedback, even a smart system is guessing.""",
      ],
      correctAnswerIndex: 1,
      outerBoxSize: Vector2(320, 183),
      innerBoxSize: Vector2(255, 45),
      alignments: [
        'center',
        'center',
        'left',
      ], // question, answers, explanation
      padding: [18, 17, 10, 16, 16],
      borderRadius: 24,
      anchor: Anchor.center,
      opacities: [0.7, 1.0, 1.0], // outer, inner, selected
      textColors: [Colors.white, Colors.white], // question, answer
      fillColors: [
        Colors.black, // outer
        const Color(0xFF757575), // inner
        const Color(0xFF00B530), // select correct
        const Color(0xFFE53935), // select wrong
      ],
      position: Vector2(gameSize.x / 2, gameSize.y - 600),
      textSizes: [20, 15],
      showDuration: 1,
      hideDuration: 1,
      explanationFontSize: 18,
      explanationFontWeight: FontWeight.w600,
      explanationFontStyle: FontStyle.italic,
    );

    // Clouds and Rain
    final cloudRain = Cloud(
      initialPosition: Vector2(gameSize.x + 300, 220),
      picturePath: 'cloud_grey.png',
      stretchY: 1.5,
      stretchX: 1.5,
      velocity: Vector2(-70, 0),
    );

    final clouds = <Cloud>[
      Cloud(
        initialPosition: Vector2(gameSize.x + 150, 320),
        picturePath: 'cloud_shape4_4.png',
        stretchY: 0.7,
        velocity: Vector2(-100, 0),
        randomizeRest: true,
        opacity: 0.2,
      ),
      Cloud(
        initialPosition: Vector2(gameSize.x + 300, 360),
        picturePath: 'cloud_shape3_5.png',
        stretchY: 0.7,
        velocity: Vector2(-90, 0),
        randomizeRest: true,
        opacity: 0.3,
      ),
    ];

    final rainFall = Rain.generateRain(
      count: 70,
      startAreaTopLeft: Vector2(gameSize.x / 3, 200),
      startAreaBottomRight: Vector2(gameSize.x * 2 / 3, 280),
      endPosition: Vector2(gameSize.x / 2, groundY),
      minSpeed: 150,
      maxSpeed: 300,
      cloud: cloudRain,
    );

    // UI bits
    final progressBar = LessonProgressBar(
      position: Vector2(gameSize.x / 2, 80),
      stages: 3,
    );

    final pauseButton = PauseButton(position: Vector2(gameSize.x - 18, 75.5));

    // Add order (draw order) preserved
    final components = <Component>[
      background,
      ground,
      progressBar,
      arrowDown,
      pauseButton,
      ...clouds,
      robot,
      cloudRain,
      ...rainFall,
      barell,
      bird,
      introTextBox,
      firstRunTextBox,
      mcqFirstRun,
    ];

    return SceneBuildResult(
      background: background,
      ground: ground,
      robot: robot,
      barell: barell,
      bird: bird,
      introTextBox: introTextBox,
      firstRunTextBox: firstRunTextBox,
      progressBar: progressBar,
      pauseButton: pauseButton,
      cloudRain: cloudRain,
      clouds: clouds,
      rainFall: rainFall,
      arrowDown: arrowDown,
      mcqFirstRun: mcqFirstRun,
      components: components,
    );
  }
}
