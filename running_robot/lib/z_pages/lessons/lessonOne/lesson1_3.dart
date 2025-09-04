import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color mainConceptColor = Color.fromARGB(255, 255, 109, 12);
const Color keyConceptGreen = Color.fromARGB(255, 0, 163, 54);
const double maxTextWidth = 350;
const double secondLineSize = 20.5;
const FontWeight secondLineWeight = FontWeight.w800;

/// ✅ Timing variables (all in ms)
const int timeBeforeFullOpacity = 600; // fade in
const int durationFullOpacity = 1200; // hold full opacity
const int fadeTime = 600; // fade out

/// ✅ Derived total cycle duration
int get totalCycleMs => timeBeforeFullOpacity + durationFullOpacity + fadeTime;

/// ✅ Stagger and loop controls
const int staggerMs = 400; // delay between items
const int delayBetweenMs = 2000; // extra pause before repeating loop

/// ✅ Computer configuration
const double computerHeight = 200;
const Offset computerOffset = Offset(70, 40);

/// ✅ Global trajectories for each item
/// Each entry has a `begin` and `end` Offset for its movement
final List<Map<String, Offset>> itemTrajectories = [
  {"begin": const Offset(0, 0), "end": const Offset(1, 2.2)}, // voice
  {"begin": const Offset(0, 0), "end": const Offset(-1, 2.1)}, // notebook
  {"begin": const Offset(0, 0), "end": const Offset(1.3, 1.4)}, // tabular
  {"begin": const Offset(0, 0), "end": const Offset(0, 1.3)}, // recording
  {"begin": const Offset(0, 0), "end": const Offset(-1.5, 1.5)}, // car
];

class LessonStepTwo extends StatefulWidget {
  const LessonStepTwo({super.key});

  @override
  State<LessonStepTwo> createState() => _LessonStepTwoState();
}

class _LessonStepTwoState extends State<LessonStepTwo>
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
    const Offset(-100, 0), // voice
    const Offset(100, 0), // notebook
    const Offset(-120, 100), // tabular
    const Offset(0, 100), // recording
    const Offset(120, 100), // car
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
      return Tween<Offset>(
        begin: begin,
        end: end,
      ).animate(CurvedAnimation(
        parent: _controllers[i],
        curve: Curves.easeIn,
      ));
    });

    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * staggerMs), () {
        if (mounted) _startLoop(i);
      });
    }
  }

  void _startLoop(int i) {
    _controllers[i].forward().whenComplete(() async {
      await Future.delayed(Duration(milliseconds: delayBetweenMs));
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
            // ✅ Definition box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 13),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: _boxDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSentence([
                    _word("What", Colors.black87, fontSize: 30),
                    _word("is", Colors.black87, fontSize: 30),
                    _word("Data?", mainConceptColor, fontSize: 30),
                  ]),
                  const SizedBox(height: 12),
                  _buildSentence([
                    const Padding(
                      padding: EdgeInsets.only(top: 3, right: 1),
                      child: Icon(Icons.arrow_forward_rounded,
                          size: 26, color: Colors.black54),
                    ),
                    _word("Data", mainConceptColor,
                        fontSize: secondLineSize, fontWeight: FontWeight.w800),
                    _word("is", Colors.black87,
                        fontSize: secondLineSize, fontWeight: secondLineWeight),
                    _word("the", Colors.black87,
                        fontSize: secondLineSize, fontWeight: secondLineWeight),
                    _word("information", keyConceptGreen,
                        fontSize: secondLineSize, fontWeight: FontWeight.w800),
                    _word("we", Colors.black87,
                        fontSize: secondLineSize, fontWeight: secondLineWeight),
                    _word("feed", Colors.black87,
                        fontSize: secondLineSize, fontWeight: secondLineWeight),
                    _word("into", Colors.black87,
                        fontSize: secondLineSize, fontWeight: secondLineWeight),
                    _word("a", Colors.black87,
                        fontSize: secondLineSize, fontWeight: secondLineWeight),
                    _word("computer.", Colors.black87,
                        fontSize: secondLineSize, fontWeight: secondLineWeight),
                  ]),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // ✅ Animation zone
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
                          30, // adjust for padding
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

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.black26, width: 1),
      boxShadow: const [
        BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
      ],
    );
  }

  static Widget _word(String text, Color color,
      {FontWeight? fontWeight, bool italic = false, double? fontSize}) {
    return Text(
      "$text ",
      style: GoogleFonts.lato(
        fontSize: fontSize ?? 22,
        fontWeight: fontWeight ?? FontWeight.w800,
        fontStyle: italic ? FontStyle.italic : FontStyle.normal,
        color: color,
      ),
    );
  }

  static Widget _buildSentence(List<Widget> words,
      {WrapAlignment alignment = WrapAlignment.start,
      bool constrainWidth = true}) {
    final content = Wrap(alignment: alignment, children: words);
    return constrainWidth
        ? ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: maxTextWidth),
            child: content,
          )
        : Center(child: content);
  }
}
