import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/dialouge.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart'; // ✅ LessonText helper

const Color mainConceptColor = Color.fromARGB(255, 255, 109, 12);
const Color keyConceptGreen = Color.fromARGB(255, 0, 163, 54);
const double maxTextWidth = 350;
const double secondLineSize = 20.5;
const FontWeight secondLineWeight = FontWeight.w800;

/// ✅ Timing variables (all in ms)
const int timeBeforeFullOpacity = 600;
const int durationFullOpacity = 1000;
const int fadeTime = 800;

int get totalCycleMs => timeBeforeFullOpacity + durationFullOpacity + fadeTime;

const int staggerMs = 400;
const int delayBetweenMs = 2000;

const double computerHeight = 200;
const Offset computerOffset = Offset(70, 40);

final List<Map<String, Offset>> itemTrajectories = [
  {"begin": const Offset(0, 0), "end": const Offset(1, 2.2)}, // voice
  {"begin": const Offset(0, 0), "end": const Offset(-1, 2.1)}, // notebook
  {"begin": const Offset(0, 0), "end": const Offset(1.4, 1)}, // tabular
  {"begin": const Offset(0, 0), "end": const Offset(0, 1)}, // recording
  {"begin": const Offset(0, 0), "end": const Offset(-1.5, 1)}, // car
];

class LessonStepZero extends StatefulWidget {
  const LessonStepZero({super.key});

  @override
  State<LessonStepZero> createState() => _LessonStepZeroState();
}

class _LessonStepZeroState extends State<LessonStepZero>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _fadeAnimations;
  late final List<Animation<Offset>> _moveAnimations;

  final List<String> _dataImages = [
    "assets/images/voice.png",
    "assets/images/notebook.png",
    "assets/images/tabular.png",
    "assets/images/recording.png",
    "assets/images/car.jpg",
  ];

  final List<Offset> _itemOffsets = [
    const Offset(-100, 0),
    const Offset(100, 0),
    const Offset(-120, 100),
    const Offset(0, 100),
    const Offset(120, 100),
  ];

  final List<Size> _itemSizes = [
    const Size(70, 70),
    const Size(70, 70),
    const Size(70, 70),
    const Size(70, 70),
    const Size(70, 70),
  ];

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(
      _dataImages.length,
      (i) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: totalCycleMs),
      ),
    );

    _fadeAnimations = _controllers.map((controller) {
      return TweenSequence([
        TweenSequenceItem(
          tween: Tween<double>(begin: 0, end: 1)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: timeBeforeFullOpacity.toDouble(),
        ),
        TweenSequenceItem(
          tween: ConstantTween<double>(1),
          weight: durationFullOpacity.toDouble(),
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: 1, end: 0)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: fadeTime.toDouble(),
        ),
      ]).animate(controller);
    }).toList();

    _moveAnimations = List.generate(_controllers.length, (i) {
      final begin = itemTrajectories[i]["begin"]!;
      final end = itemTrajectories[i]["end"]!;
      return Tween<Offset>(begin: begin, end: end).animate(
        CurvedAnimation(parent: _controllers[i], curve: Curves.easeIn),
      );
    });

    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * staggerMs), () {
        if (mounted) _startLoop(i);
      });
    }
  }

  void _startLoop(int i) {
    _controllers[i].forward().whenComplete(() async {
      await Future.delayed(const Duration(milliseconds: delayBetweenMs));
      if (mounted) {
        _controllers[i].reset();
        _startLoop(i);
      }
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            SizedBox(
              height: 350,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Positioned(
                    bottom: computerOffset.dy,
                    left: computerOffset.dx,
                    child: Image.asset(
                      "assets/images/computer.png",
                      height: computerHeight,
                    ),
                  ),
                  for (int i = 0; i < _dataImages.length; i++)
                    Positioned(
                      left: MediaQuery.of(context).size.width / 2 +
                          _itemOffsets[i].dx -
                          _itemSizes[i].width / 2 -
                          30,
                      top: _itemOffsets[i].dy,
                      child: _buildAnimatedItem(i),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 0),

            /// ✅ Dialogue sequence pages
            DialogueBox(
              width: 320,
              content: [
                // 1) "Welcome to Lesson 1"
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LessonText.sentence(
                      _lw("Welcome to Lesson 1", size: 28),
                    ),
                  ],
                ),

                // 2) "This is the beginning of your AI Journey"
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LessonText.sentence(
                      _lw("This is the beginning of your AI Journey", size: 24),
                    ),
                  ],
                ),

                // 3) "We will now learn the most foundational concept in AI"
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LessonText.sentence(
                      _lw("We will now learn the most foundational concept in AI",
                          size: 22),
                    ),
                  ],
                ),

                // 4) "The world of Data"
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LessonText.sentence(
                      _lw("The world of Data", size: 26),
                    ),
                  ],
                ),

                // 5) Now display the original "What is Data?" block — END
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LessonText.sentence([
                      LessonText.word("So what", Colors.black87, fontSize: 30),
                      LessonText.word("is", Colors.black87, fontSize: 30),
                      LessonText.word("Data?", mainConceptColor, fontSize: 30),
                    ]),
                    const SizedBox(height: 12),
                    LessonText.sentence([
                      const Padding(
                        padding: EdgeInsets.only(top: 3, right: 1),
                        child: Icon(Icons.arrow_forward_rounded,
                            size: 26, color: Colors.black54),
                      ),
                      LessonText.word("Data", mainConceptColor,
                          fontSize: secondLineSize,
                          fontWeight: FontWeight.w800),
                      LessonText.word("is", Colors.black87,
                          fontSize: secondLineSize,
                          fontWeight: secondLineWeight),
                      LessonText.word("the", Colors.black87,
                          fontSize: secondLineSize,
                          fontWeight: secondLineWeight),
                      LessonText.word("information", keyConceptGreen,
                          fontSize: secondLineSize,
                          fontWeight: FontWeight.w800),
                      LessonText.word("we", Colors.black87,
                          fontSize: secondLineSize,
                          fontWeight: secondLineWeight),
                      LessonText.word("feed", Colors.black87,
                          fontSize: secondLineSize,
                          fontWeight: secondLineWeight),
                      LessonText.word("into", Colors.black87,
                          fontSize: secondLineSize,
                          fontWeight: secondLineWeight),
                      LessonText.word("a", Colors.black87,
                          fontSize: secondLineSize,
                          fontWeight: secondLineWeight),
                      LessonText.word("computer.", Colors.black87,
                          fontSize: secondLineSize,
                          fontWeight: secondLineWeight),
                    ]),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the animated floaters
  Widget _buildAnimatedItem(int index) {
    final size = _itemSizes[index];

    return SizedBox(
      width: size.width,
      height: size.height,
      child: AnimatedBuilder(
        animation: _controllers[index],
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimations[index].value,
            child: FractionalTranslation(
              translation: _moveAnimations[index].value,
              child: child,
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black26),
          ),
          child: Image.asset(
            _dataImages[index],
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  /// 🔹 Helper: convert a plain sentence into LessonText.word widgets
  List<Widget> _lw(
    String text, {
    double size = 20,
    Color color = Colors.black87,
    FontWeight weight = secondLineWeight,
  }) {
    return text
        .split(' ')
        .map((w) =>
            LessonText.word(w, color, fontSize: size, fontWeight: weight))
        .toList();
  }
}
