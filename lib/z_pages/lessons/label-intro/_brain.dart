import 'package:flutter/material.dart';
import 'package:running_robot/core/base_lesson_brain.dart';
import 'package:running_robot/core/widgets.dart';
import 'package:running_robot/z_pages/lessons/label-intro/label_quiz.dart';

// Steps
import 'package:running_robot/z_pages/lessons/label-intro/label_quote.dart';
import 'package:running_robot/z_pages/lessons/label-intro/label_dialogue.dart';
import 'package:running_robot/z_pages/lessons/label-intro/label_def.dart';
import 'package:running_robot/z_pages/lessons/label-intro/label_kinds_slider.dart';
import 'package:running_robot/z_pages/lessons/label-intro/label_recap_complete_sample.dart';

final double screenW = ScreenSize.width;
final double screenH = ScreenSize.height;

class LabelIntroBrain extends BaseLessonBrain {
  const LabelIntroBrain({super.key, required super.onNavigate});

  @override
  String get lessonId => "label-intro";

  @override
  State<LabelIntroBrain> createState() => _LabelIntroBrainState();
}

class _LabelIntroBrainState extends BaseLessonBrainState<LabelIntroBrain> {
  bool _didPrecacheAssets = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didPrecacheAssets) return;

    precacheImage(
      const AssetImage("assets/images/mascot_pointing_up.png"),
      context,
    );
    precacheImage(
      const AssetImage("assets/images/label_def.png"),
      context,
    );
    precacheImage(
      const AssetImage("assets/images/predicted_label.png"),
      context,
    );
    precacheImage(
      const AssetImage("assets/images/data_sample.png"),
      context,
    );
    _didPrecacheAssets = true;
  }

  @override
  List<SubLesson> buildSubLessons() => [
        // Slide 1 — Quote (manual)
        SubLesson(
          topOffset: screenH * 0.33,
          mechanic: LessonMechanic.manual,
          build: (_, __) => const LabelQuote(),
        ),

        // Slide 2 — Dialogue (auto)
        SubLesson(
          topOffset: screenH * 0.20,
          mechanic: LessonMechanic.auto,
          build: (done, __) => LabelDialogue(
            onFinished: done,
            onRequestNext: () => goNext(),
          ),
        ),

        // Slide 3 — Definition (manual)
        SubLesson(
          topOffset: screenH * 0.22,
          mechanic: LessonMechanic.manual,
          build: (_, __) => const LabelDefinition(),
        ),

        // Slide 4 — Two kinds of labels + ImageSlider (manual)
        SubLesson(
          topOffset: screenH * 0.23,
          mechanic: LessonMechanic.emit,
          build: (done, reset) => LabelKindsSlider(
            onStepCompleted: () => done(),
          ),
        ),

        // Slide 5 — Recap: Features + Label = Complete Data Sample (manual)
        SubLesson(
          topOffset: screenH * 0.18,
          mechanic: LessonMechanic.emit,
          build: (done, reset) => LabelRecapCompleteSample(
            onStepCompleted: () => done(),
          ),
        ),
        SubLesson(
          topOffset: screenH * 0.18,
          mechanic: LessonMechanic.emit,
          build: (done, reset) => LabelQuiz(
            onCompleted: () => done(),
          ),
        ),
      ];
}
