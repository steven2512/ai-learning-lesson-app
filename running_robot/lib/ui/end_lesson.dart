// lib/ui/end_lesson.dart
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart' hide IconButton;
import 'package:running_robot/accessories/decorations/fancy_box.dart';
import 'package:running_robot/accessories/decorations/progress_bar.dart';
import 'package:running_robot/accessories/decorations/stars.dart';
import 'package:running_robot/accessories/events/event_type.dart';
import 'package:running_robot/accessories/static/background.dart';
import 'package:running_robot/accessories/buttons/generic_button.dart';
import 'package:running_robot/accessories/buttons/icon_button.dart';
import 'package:running_robot/accessories/texts/text_box.dart';

class EndLessonPage extends FlameGame {
  final VoidCallback onRepeat;
  final VoidCallback onNext;
  final VoidCallback onMainMenu;

  late Background background;
  late Star star1;
  late Star star2;
  late Star star3;
  late GenericButton nextLessonButton;
  late IconButton returnButton;
  late SpriteComponent robot;
  late FancyTextBox textBox;
  late LessonProgressBar progressBar;

  EndLessonPage({
    required this.onRepeat,
    required this.onNext,
    required this.onMainMenu,
  });

  @override
  Future<void> onLoad() async {
    background = Background(
      backgroundSize: Vector2(size.x, size.y),
      colors: [const Color.fromARGB(255, 255, 255, 255)],
    );

    nextLessonButton = GenericButton(
      position: Vector2(size.x / 2, size.y - 80),
      anchor: Anchor.center,
      buttonSize: Vector2(350, 60),
      padding: const [5, 10, 5, 10],
      content: "Next Lesson",
      boxColor: const Color.fromARGB(255, 136, 32, 255),
      boxOpacity: 1,
      fontSize: 22,
      fontWeight: FontWeight.w800,
      fontColor: Colors.white,
      borderRadius: 30,
    )..switchPhase(EventHorizontalObstacle.startMoving);

    returnButton = IconButton<void>(
      position: Vector2(40, 80),
      size: Vector2(30, 25),
      anchor: Anchor.center,
      iconPath: 'x_icon.png',
      tint: Colors.black87,
      onPressed: (_) => onMainMenu(),
    )..show();

    // ---------- centered row of three with even spacing ----------
    final Vector2 boxSize = Vector2(110, 96);
    const double preferredGap = 18.0;
    const double sideMargin = 24.0;
    final double y = size.y / 2 + 100;

    double gap = preferredGap;
    final double maxRowWidth = size.x - 2 * sideMargin;
    double rowWidth = boxSize.x * 3 + gap * 2;
    if (rowWidth > maxRowWidth) {
      gap = ((maxRowWidth - boxSize.x * 3) / 2).clamp(8.0, preferredGap);
      rowWidth = boxSize.x * 3 + gap * 2;
    }

    final double firstCenterX = size.x / 2 - rowWidth / 2 + boxSize.x / 2;
    final double secondCenterX = firstCenterX + boxSize.x + gap;
    final double thirdCenterX = secondCenterX + boxSize.x + gap;

    // LEFT: TOTAL XP
    final xpBox = FancyBox(
      position: Vector2(firstCenterX, y),
      anchor: Anchor.center,
      boxSize: boxSize,
      titleText: 'Total XP',
      mainContent: '82',
      fillColors: [Colors.orange, Colors.orange.shade300, Colors.orange],
      fontSizes: const [12, 24, 24],
      fontColors: [Colors.white, Colors.black87, Colors.orange],
      bannerTextAnchor: Anchor.center,
      insideTextAnchor: Anchor.center,
      iconData: Icons.local_fire_department,
      borderThickness: 2.0,
      borderRadius: 16.0,
      letterSpacing: 0.2,
    )..switchPhase(EventHorizontalObstacle.startMoving);

    // MIDDLE: PROGRESS  (moved here)
    final progressBox = FancyBox(
      position: Vector2(secondCenterX, y),
      anchor: Anchor.center,
      boxSize: boxSize,
      titleText: 'Progress',
      mainContent: '33%',
      fillColors: const [
        Color.fromARGB(255, 25, 179, 20),
        Color.fromARGB(255, 25, 179, 20),
        Color.fromARGB(255, 25, 179, 20),
      ],
      fontSizes: const [12, 24, 24],
      fontColors: const [
        Colors.white,
        Colors.black87,
        Color.fromARGB(255, 10, 240, 2),
      ],
      bannerTextAnchor: Anchor.center,
      insideTextAnchor: Anchor.center,
      iconData: Icons.track_changes,
      borderThickness: 2.0,
      borderRadius: 16.0,
      letterSpacing: 0.2,
    )..switchPhase(EventHorizontalObstacle.startMoving);

    // RIGHT: (replace "Streak" with longer label) -> DAILY STREAK
    final streakBox = FancyBox(
      position: Vector2(thirdCenterX, y),
      anchor: Anchor.center,
      boxSize: boxSize,
      titleText: 'Streak', // longer label for nicer pill
      mainContent: '1',
      fillColors: const [
        Color.fromARGB(255, 0, 157, 255),
        Color.fromARGB(255, 0, 85, 255),
        Color.fromARGB(255, 0, 157, 255),
      ],
      fontSizes: const [12, 24, 24],
      fontColors: const [
        Colors.white,
        Colors.black87,
        Color.fromARGB(255, 0, 60, 255),
      ],
      bannerTextAnchor: Anchor.center,
      insideTextAnchor: Anchor.center,
      iconData: Icons.bolt_rounded, // clearer “streak” symbol
      borderThickness: 2.0,
      borderRadius: 16.0,
      letterSpacing: 0.2,
    )..switchPhase(EventHorizontalObstacle.startMoving);

    robot = SpriteComponent(
      sprite: await Sprite.load('blue_robot.png'),
      size: Vector2.all(350),
      position: Vector2(size.x / 2, 360),
      anchor: Anchor.center,
    );

    textBox = FancyTextBox(
      position: Vector2(size.x / 2, 200),
      anchor: Anchor.center,
      sequence: ['Great Work!'],
      fadeDuration: 0,
      fontSize: 30,
      letterSpacing: 0.5,
      fontWeight: FontWeight.w700,
      maxWidth: 300,
    );

    progressBar = LessonProgressBar(
      position: Vector2(size.x / 2, 70),
      stages: 3,
    );
    textBox.switchPhase(EventText.showText);
    add(background);
    add(nextLessonButton);
    add(returnButton);
    addAll([xpBox, progressBox, streakBox]);
    add(robot);
    add(textBox);
    add(progressBar);

    progressBar.switchPhase(EventProgressBar.proceed);
  }
}
