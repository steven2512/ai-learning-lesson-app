// ✅ Slide 4 — “There are 2 kinds of labels” + ImageSlider
// Uses your shared ImageSlider exactly like GoodFeaturesExample.
import 'package:flutter/material.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/image_slider.dart';

const Color goalBlue = Color(0xFF1565C0);
const Color dataOrange = Color(0xFFFF6D00);
const Color darkPink = Color(0xFFD81B60);

class LabelKindsSlider extends StatelessWidget {
  final VoidCallback? onStepCompleted;

  const LabelKindsSlider({super.key, this.onStepCompleted});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final sliderHeight = h * 0.33;

    const double padV = 10.0;
    const double padH = 10.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top heading box
          LessonText.box(
            child: LessonText.sentence([
              LessonText.word("There", Colors.black87, fontSize: 24),
              LessonText.word("are", Colors.black87, fontSize: 24),
              LessonText.word("2", Colors.black87, fontSize: 24),
              LessonText.word("kinds", Colors.black87, fontSize: 24),
              LessonText.word("of", Colors.black87, fontSize: 24),
              LessonText.word("labels", goalBlue,
                  fontSize: 24, fontWeight: FontWeight.w900),
            ]),
          ),
          const SizedBox(height: 14),

          // Image slider
          LayoutBuilder(
            builder: (context, constraints) {
              final fullBoxWidth = constraints.maxWidth;
              final sliderWidth = fullBoxWidth - (padH * 2);

              return ImageSlider(
                onFinished: onStepCompleted,
                imagePaths: const [
                  "assets/images/label_def.png",
                  "assets/images/predicted_label.png",
                ],
                width: sliderWidth,
                height: sliderHeight,
                paddings: const [padV, padH, padV, padH],
                imageTag: true,
                imageTagTop: true,
                tagBox: false,
                tagTextColor: Colors.black,
                tagFontSize: 22,

                // ✅ Widget-based image tags (each word separately)
                imageTags: [
                  // --- True Label ---
                  LessonText.sentence([
                    LessonText.word("True", Colors.green,
                        fontWeight: FontWeight.w900),
                    LessonText.word("Label:", Colors.green,
                        fontWeight: FontWeight.w900),
                    LessonText.word("the", Colors.black87),
                    LessonText.word(
                        "correct", const Color.fromARGB(255, 192, 13, 0),
                        fontWeight: FontWeight.w700, italic: true),
                    LessonText.word(
                        "answer", const Color.fromARGB(255, 192, 13, 0),
                        fontWeight: FontWeight.w700, italic: true),
                    LessonText.word("from", Colors.black87),
                    LessonText.word("your", Colors.black87),
                    LessonText.word("data", Colors.black87),
                  ]),

                  // --- Predicted Label ---
                  LessonText.sentence([
                    LessonText.word(
                        "Predicted", Color.fromARGB(255, 91, 5, 240),
                        fontWeight: FontWeight.w900),
                    LessonText.word("Label:", Color.fromARGB(255, 91, 5, 240),
                        fontWeight: FontWeight.w900),
                    LessonText.word("what", Colors.black87),
                    LessonText.word("the", Colors.black87),
                    LessonText.word("AI", Colors.black87),
                    LessonText.word("needs", Colors.black87),
                    LessonText.word("to", Colors.black87),
                    LessonText.word("guess", darkPink,
                        fontWeight: FontWeight.w700, italic: true),
                    LessonText.word("(unknown)", Colors.black87),
                  ]),
                ],
              );
            },
          ),

          const SizedBox(height: 14),
        ],
      ),
    );
  }
}
