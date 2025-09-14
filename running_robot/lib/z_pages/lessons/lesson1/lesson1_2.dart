// FILE: lib/z_pages/lessons/lesson1/lesson_step_one.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';

const Color mainConceptColor = Color.fromARGB(255, 255, 109, 12);
const Color keyConceptGreen = Color.fromARGB(255, 0, 163, 54);
const double secondLineSize = 20.5;
const FontWeight secondLineWeight = FontWeight.w800;

/// ✅ Timing variables (all in ms)
const int timeBeforeFullOpacity = 1000; // fade in
const int durationFullOpacity = 1000; // hold full opacity
const int fadeTime = 800; // fade out

int get totalCycleMs => timeBeforeFullOpacity + durationFullOpacity + fadeTime;

// ⭐ NEW: delay before first animation starts
const int timeBeforeFirstAnimation = 500;

const int staggerMs = 0; // was 400
const int delayBetweenMs = 1000; // extra pause before repeating loop

const double computerHeight = 200;
const Offset computerOffset = Offset(70, 40);

final List<Map<String, Offset>> itemTrajectories = [
  {"begin": Offset(0, 0), "end": Offset(1, 2.2)}, // voice
  {"begin": Offset(0, 0), "end": Offset(-1, 2.1)}, // notebook
  {"begin": Offset(0, 0), "end": Offset(1.4, 1)}, // tabular
  {"begin": Offset(0, 0), "end": Offset(0, 1)}, // recording
  {"begin": Offset(0, 0), "end": Offset(-1.5, 1)}, // car
];

class LessonStepOne extends StatefulWidget {
  const LessonStepOne({super.key});

  @override
  State<LessonStepOne> createState() => _LessonStepOneState();
}

class _LessonStepOneState extends State<LessonStepOne>
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
    Offset(-100, 0), // voice
    Offset(100, 0), // notebook
    Offset(-120, 100), // tabular
    Offset(0, 100), // recording
    Offset(120, 100), // car
  ];

  final List<Size> _itemSizes = [
    Size(70, 70),
    Size(70, 70),
    Size(70, 70),
    Size(70, 70),
    Size(70, 70),
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

    // ⭐ NEW: apply global delay before animations start
    Future.delayed(Duration(milliseconds: timeBeforeFirstAnimation), () {
      for (int i = 0; i < _controllers.length; i++) {
        Future.delayed(Duration(milliseconds: i * staggerMs), () {
          if (mounted) _startLoop(i);
        });
      }
    });
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// ✅ Custom tight box centered on screen
            const SizedBox(height: 10),
            TightCenterBox(
              children: [
                LessonText.word("Data", mainConceptColor,
                    fontSize: 24, fontWeight: FontWeight.w800),
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: LessonText.word("→", Colors.black87,
                      fontSize: 24, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 6),
                LessonText.word("Computer", keyConceptGreen,
                    fontSize: 24, fontWeight: FontWeight.w800),
              ],
            ),

            /// ✅ Animation zone
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
          ],
        ),
      ),
    );
  }

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
}

/// 🔹 Clean tight box (always centers text, no extra padding conflicts)
class TightCenterBox extends StatelessWidget {
  final List<Widget> children;

  const TightCenterBox({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.only(right: 8, left: 15, top: 7, bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
          border:
              Border.all(color: const Color.fromARGB(171, 0, 0, 0), width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: children,
        ),
      ),
    );
  }
}
