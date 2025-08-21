// lib/ui/end_lesson.dart
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart' hide IconButton;
import 'package:running_robot/accessories/decorations/fancy_box.dart';
import 'package:running_robot/accessories/decorations/progress_bar.dart';
import 'package:running_robot/accessories/events/event_type.dart';
import 'package:running_robot/accessories/static/background.dart';
import 'package:running_robot/accessories/buttons/generic_button.dart';
import 'package:running_robot/accessories/buttons/icon_button.dart';
import 'package:running_robot/accessories/texts/text_box.dart';

/// EndLessonPage
/// - Layout/positions are fixed (hard-coded).
/// - Inputs you can customize:
///   xp, streak, progressPercent, stageProgress=[current, total], topText, illustrationPath.
/// - ProgressBar behavior:
///   Pre-fill (current-1) before adding, then animate 1 fill after adding.
class EndLessonPage extends FlameGame {
  // ---- Callbacks ----
  final VoidCallback onRepeat;
  final VoidCallback onNext;
  final VoidCallback onMainMenu;

  // ---- Customizable inputs ----
  final int xp; // left box
  final int streak; // right box
  final int progressPercent; // middle box (0..100)
  /// Pair: [current, total]
  final List<int>
      stageProgress; // e.g. [2,5] => pre-fill 1, animate 1 after add
  final String topText; // top headline
  final String? illustrationPath; // image asset path

  // ---- Internals ----
  late Background background;
  late GenericButton nextLessonButton;
  late IconButton returnButton;
  late FancyTextBox textBox;
  late LessonProgressBar progressBar;

  EndLessonPage({
    required this.onRepeat,
    required this.onNext,
    required this.onMainMenu,
    required this.xp,
    required this.streak,
    required this.progressPercent,
    required this.stageProgress, // [current, total]
    required this.topText,
    this.illustrationPath,
  });
  // In class LessonOne extends FlameGame ...
  @override
  Color backgroundColor() => const Color(0xFFFFFFFF);
  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // // -------- Background (always behind) --------
    // background = Background(
    //   backgroundSize: Vector2(size.x, size.y),
    //   colors: const [Color.fromARGB(255, 255, 255, 255)],
    // )..priority = -100;

    // -------- Next button --------
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
      onPressed: (_) => onNext(),
    )..switchPhase(EventHorizontalObstacle.startMoving);

    // -------- Close/X button --------
    returnButton = IconButton<void>(
      position: Vector2(40, 80),
      size: Vector2(30, 25),
      anchor: Anchor.center,
      iconPath: 'x_icon.png',
      tint: Colors.black87,
      onPressed: (_) => onMainMenu(),
    )..show();

    // -------- Top text --------
    textBox = FancyTextBox(
      position: Vector2(size.x / 2, 200),
      anchor: Anchor.center,
      sequence: [topText],
      fadeDuration: 0,
      fontSize: 30,
      letterSpacing: 0.5,
      fontWeight: FontWeight.w700,
      maxWidth: 300,
    )..switchPhase(EventText.showText);

    // -------- Illustration (fixed size/pos) --------
    if (illustrationPath != null && illustrationPath!.isNotEmpty) {
      final sprite = await Sprite.load(illustrationPath!);
      add(
        SpriteComponent(
          sprite: sprite,
          size: Vector2.all(400),
          position: Vector2(size.x / 2, 360),
          anchor: Anchor.center,
        ),
      );
    }

    // -------- Progress bar (prefill current-1, then animate 1) --------
    final int total = (stageProgress.length > 1 ? stageProgress[1] : 1).clamp(
      1,
      1000,
    );
    final int currentRaw = (stageProgress.isNotEmpty ? stageProgress[0] : 0);
    final int current = currentRaw.clamp(0, total);

    progressBar = LessonProgressBar(
      position: Vector2(size.x / 2, 70),
      stages: total,
    );

    // Pre-fill (current - 1) BEFORE adding (instant state).
    final int prefillCount = (current - 1).clamp(0, total);
    for (int i = 0; i < prefillCount; i++) {
      progressBar.switchPhase(EventProgressBar.proceed);
    }

    // Now add to scene…
    add(progressBar);

    // …then animate ONE more fill if current > 0.
    if (current > 0) {
      progressBar.switchPhase(EventProgressBar.proceed);
    }

    // -------- Three FancyBoxes (layout fixed) --------
    final Vector2 boxSize = Vector2(110, 96);
    const double preferredGap = 18.0;
    const double sideMargin = 24.0;
    final double y = size.y / 2 + 110;

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
      mainContent: '$xp',
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

    // MIDDLE: PROGRESS %
    final progressBox = FancyBox(
      position: Vector2(secondCenterX, y),
      anchor: Anchor.center,
      boxSize: boxSize,
      titleText: 'Progress',
      mainContent: '${progressPercent.clamp(0, 100)}%',
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

    // RIGHT: DAILY STREAK
    final streakBox = FancyBox(
      position: Vector2(thirdCenterX, y),
      anchor: Anchor.center,
      boxSize: boxSize,
      titleText: 'Streak',
      mainContent: '$streak',
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
      iconData: Icons.bolt_rounded,
      borderThickness: 2.0,
      borderRadius: 16.0,
      letterSpacing: 0.2,
    )..switchPhase(EventHorizontalObstacle.startMoving);

    // Draw order
    // add(background);
    add(nextLessonButton);
    add(returnButton);
    addAll([xpBox, progressBox, streakBox]);
    add(textBox);
  }
}
