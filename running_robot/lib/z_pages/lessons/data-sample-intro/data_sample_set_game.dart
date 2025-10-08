// FILE: lib/z_pages/lessons/data-sample-intro/data_sample_set_game.dart
import 'package:flutter/material.dart';
import 'package:running_robot/z_pages/mini-games/match_game.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';

class DataSampleSetGame extends StatelessWidget {
  final VoidCallback? onStepCompleted;
  const DataSampleSetGame({super.key, this.onStepCompleted});

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double w = constraints.maxWidth.clamp(320.0, 860.0);
          final double h = (screenH * 0.5).clamp(320.0, 560.0);

          // LEFT column (images)
          final groupA = <Widget>[
            Image.asset("assets/images/house1.png",
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.image_not_supported, size: 40)),
            Image.asset("assets/images/cat1.jpg",
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.image_not_supported, size: 40)),
            Image.asset("assets/images/car.jpg",
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.image_not_supported, size: 40)),
          ];

          // RIGHT column (datasets) — deliberately mixed order
          final groupB = const <Widget>[
            Text("Dataset of cars"),
            Text("Dataset of animals"),
            Text("Dataset of houses"),
          ];

          // Correct pairs — matches based on shuffled right side
          final correctPairs = <int, int>{
            0: 2, // house1 → houses
            1: 1, // cat1 → animals
            2: 0, // car → cars
          };

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🟧 Lesson header
              LessonText.box(
                margin: const EdgeInsets.only(bottom: 18),
                padding: const EdgeInsets.all(14),
                child: LessonText.sentence([
                  LessonText.word("Match", Colors.black87, fontSize: 22),
                  LessonText.word(
                    "Data Samples",
                    const Color(0xFFE91E63), // pink
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                  LessonText.word("with", Colors.black87, fontSize: 22),
                  LessonText.word("their", Colors.black87, fontSize: 22),
                  LessonText.word(
                    "Dataset",
                    const Color(0xFFFF6D00), // orange
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ]),
              ),

              // 🎮 Matching game
              // 🎮 Matching game
              Center(
                child: GestureDetector(
                  // Prevent vertical drags inside game from bubbling to the ScrollView
                  onVerticalDragDown: (_) {}, // absorb drag
                  onVerticalDragUpdate: (_) {}, // absorb drag
                  behavior: HitTestBehavior.opaque,
                  child: MatchingGame(
                    width: w,
                    height: h,
                    groupA: groupA,
                    groupB: groupB,
                    correctPairs: correctPairs,
                    enforceOneToOne: false,
                    onChanged: (_) {},
                    onCompleted: onStepCompleted,
                  ),
                ),
              ),

              const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }
}
