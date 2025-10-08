// FILE: lib/z_pages/lessons/data-sample-intro/data_sample_set_game.dart
import 'package:flutter/material.dart';
import 'package:running_robot/z_pages/mini-games/match_game.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';

class DataSampleSetGame extends StatefulWidget {
  final VoidCallback? onStepCompleted;
  final VoidCallback? onReset;

  const DataSampleSetGame({super.key, this.onStepCompleted, this.onReset});

  @override
  State<DataSampleSetGame> createState() => _DataSampleSetGameState();
}

class _DataSampleSetGameState extends State<DataSampleSetGame> {
  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double w = constraints.maxWidth.clamp(320.0, 860.0);
          final double h = (screenH * 0.5).clamp(320.0, 560.0);

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

          final groupB = const <Widget>[
            Text("Dataset of cars"),
            Text("Dataset of animals"),
            Text("Dataset of houses"),
          ];

          final correctPairs = <int, int>{0: 2, 1: 1, 2: 0};

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onVerticalDragDown: (_) {},
                  onVerticalDragUpdate: (_) {},
                  behavior: HitTestBehavior.opaque,
                  child: MatchingGame(
                    width: w,
                    height: h,
                    groupA: groupA,
                    groupB: groupB,
                    correctPairs: correctPairs,
                    enforceOneToOne: false,
                    onChanged: (_) {},
                    onCompleted: widget.onStepCompleted,
                    onReset: widget.onReset, // 🔗 bubble up

                    titleBuilder: (ctx) => LessonText.box(
                      margin: EdgeInsets.zero,
                      padding: const EdgeInsets.all(14),
                      child: LessonText.sentence([
                        LessonText.word("Match", Colors.black87, fontSize: 22),
                        LessonText.word("Data Samples", const Color(0xFFE91E63),
                            fontSize: 22, fontWeight: FontWeight.w900),
                        LessonText.word("with", Colors.black87, fontSize: 22),
                        LessonText.word("their", Colors.black87, fontSize: 22),
                        LessonText.word("Dataset", const Color(0xFFFF6D00),
                            fontSize: 22, fontWeight: FontWeight.w900),
                      ]),
                    ),
                    titleMargin: const EdgeInsets.only(bottom: 18),
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
