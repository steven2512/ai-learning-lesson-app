import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/core/widgets.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart'; // ✅ central LessonText here
import 'package:running_robot/z_pages/assets/lessonAssets/mcq_box.dart';

/// ─────────────────────────────────────────────────────────
/// 📏 Screen globals (so we don’t repeat everywhere)
/// ─────────────────────────────────────────────────────────
final double screenH = ScreenSize.height;
final double screenW = ScreenSize.width;

/// 🔹 Max width is now adaptive to screen
/// Phones: ~85% of width
/// Tablets: cap at 500dp
final double maxTextWidth = screenW < 600 ? screenW * 0.85 : 500;

const Color mainConceptColor = Color.fromARGB(255, 255, 109, 12);

/// 🔧 Bounce globals
const int bounceNo = 4;
const Duration timeBeforeRepeatAnimation = Duration(seconds: 2);

/// Quiz item model
class _QuizItem {
  final String? image; // nullable to allow animated quiz
  final String question;
  final List<String> answers;
  final int correctIndex;

  const _QuizItem({
    this.image,
    required this.question,
    required this.answers,
    required this.correctIndex,
  });
}

const double correctTextSize = 20;

class DataTypeQuiz extends StatefulWidget {
  final int quizIndex;
  final void Function(int quizIndex) onQuizCompleted;

  const DataTypeQuiz({
    super.key,
    required this.quizIndex,
    required this.onQuizCompleted,
  });

  static int get quizCount => _quizItems.length;

  // 🔧 Quiz data
  static const List<_QuizItem> _quizItems = [
    _QuizItem(
      image: "assets/images/notebook.png",
      question: "What is this data?",
      answers: ["Text", "Audio"],
      correctIndex: 0,
    ),
    _QuizItem(
      image: "assets/images/car.jpg",
      question: "What is this data?",
      answers: ["Image", "Sound"],
      correctIndex: 0,
    ),
    _QuizItem(
      image: "assets/images/voice.png",
      question: "What is this data?",
      answers: ["Text", "Audio"],
      correctIndex: 1,
    ),
    _QuizItem(
      image: "assets/images/tabular.png",
      question: "What is this data?",
      answers: ["Video", "Table"],
      correctIndex: 1,
    ),
    _QuizItem(
      image: null, // handled with animation
      question: "What is this data?",
      answers: ["Video", "Table"],
      correctIndex: 0,
    ),
  ];

  /// 🔧 Per-quiz success messages
  static final List<List<Widget>> successMessages = [
    // TEXT
    [
      LessonText.sentence([
        LessonText.word("Correct", Colors.green.shade800,
            fontSize: correctTextSize),
        LessonText.word("🎉", Colors.green.shade800, fontSize: correctTextSize),
      ]),
      LessonText.sentence([
        LessonText.word("Text Examples:", Colors.black87,
            fontWeight: FontWeight.bold, fontSize: 20),
        LessonText.word("Emails,", Colors.blue,
            italic: true, fontSize: correctTextSize),
        LessonText.word("books,", Colors.deepPurple,
            italic: true, fontSize: correctTextSize),
        LessonText.word("documents", Colors.teal,
            italic: true, fontSize: correctTextSize),
      ]),
    ],

    // IMAGE
    [
      LessonText.sentence([
        LessonText.word("Very", Colors.green.shade800,
            fontSize: correctTextSize),
        LessonText.word("Good", Colors.green.shade800,
            fontSize: correctTextSize),
        LessonText.word("🎉", Colors.green.shade800, fontSize: correctTextSize),
      ]),
      LessonText.sentence([
        LessonText.word("Image Examples:", Colors.black87,
            fontWeight: FontWeight.bold, fontSize: 20),
        LessonText.word("Paintings,", Colors.orange,
            italic: true, fontSize: correctTextSize),
        LessonText.word("Medical scans,", Color.fromARGB(255, 107, 0, 195),
            italic: true, fontSize: correctTextSize),
        LessonText.word("satellite images", Colors.blue,
            italic: true, fontSize: correctTextSize),
      ]),
    ],

    // AUDIO
    [
      LessonText.sentence([
        LessonText.word("Excellent", Colors.green.shade800,
            fontSize: correctTextSize),
        LessonText.word("🎉", Colors.green.shade800, fontSize: correctTextSize),
      ]),
      LessonText.sentence([
        LessonText.word("Audio Examples:", Colors.black87,
            fontWeight: FontWeight.bold, fontSize: 20),
        LessonText.word("Music,", Colors.deepPurple,
            italic: true, fontSize: correctTextSize),
        LessonText.word("speech,", Colors.orange,
            italic: true, fontSize: correctTextSize),
        LessonText.word("recordings", Colors.blue,
            italic: true, fontSize: correctTextSize),
      ]),
    ],

    // TABLE
    [
      LessonText.sentence([
        LessonText.word("Correct", Colors.green.shade800,
            fontSize: correctTextSize),
        LessonText.word("🎉", Colors.green.shade800, fontSize: correctTextSize),
      ]),
      LessonText.sentence([
        LessonText.word("Table Examples:", Colors.black87,
            fontWeight: FontWeight.bold, fontSize: 20),
        LessonText.word("Transactions,", Colors.teal,
            italic: true, fontSize: correctTextSize),
        LessonText.word("financial reports,", Colors.orange,
            italic: true, fontSize: correctTextSize),
        LessonText.word("customer data", Colors.blue,
            italic: true, fontSize: correctTextSize),
      ]),
    ],

    // VIDEO
    [
      LessonText.sentence([
        LessonText.word("Excellent", Colors.green.shade800,
            fontSize: correctTextSize),
        LessonText.word("🎉", Colors.green.shade800, fontSize: correctTextSize),
      ]),
      LessonText.sentence([
        LessonText.word("Video Examples:", Colors.black87,
            fontWeight: FontWeight.bold, fontSize: 20),
        LessonText.word("Movies,", Colors.orange,
            italic: true, fontSize: correctTextSize),
        LessonText.word("meeting recordings,", Colors.purple,
            italic: true, fontSize: correctTextSize),
        LessonText.word("animations", Colors.blue,
            italic: true, fontSize: correctTextSize),
      ]),
    ],
  ];

  @override
  State<DataTypeQuiz> createState() => LessonStepOneState();
}

class LessonStepOneState extends State<DataTypeQuiz> {
  bool _answeredCorrect = false;
  bool _triedWrong = false;

  _QuizItem get current => DataTypeQuiz._quizItems[widget.quizIndex];

  void _handleAnswerTap(int selectedIndex) {
    if (selectedIndex == current.correctIndex) {
      setState(() {
        _answeredCorrect = true;
        _triedWrong = false;
      });
      widget.onQuizCompleted(widget.quizIndex);
    } else {
      if (!_answeredCorrect) {
        setState(() => _triedWrong = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> successMsg =
        (widget.quizIndex < DataTypeQuiz.successMessages.length)
            ? DataTypeQuiz.successMessages[widget.quizIndex]
            : [
                LessonText.sentence([
                  LessonText.word("Correct", Colors.green.shade800,
                      fontSize: correctTextSize),
                  LessonText.word("🎉", Colors.green.shade800,
                      fontSize: correctTextSize),
                ])
              ];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            // ✅ Heading
            LessonText.box(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(14),
              child: Center(
                child: LessonText.sentence([
                  LessonText.word("What", Colors.black87, fontSize: 22),
                  LessonText.word("is", Colors.black87, fontSize: 22),
                  LessonText.word("this", Colors.black87, fontSize: 22),
                  LessonText.word("data?", mainConceptColor, fontSize: 22),
                ], alignment: WrapAlignment.center),
              ),
            ),

            // ✅ Display zone
            Container(
              width: double.infinity,
              height: screenH * 0.25,
              margin: const EdgeInsets.only(bottom: 15),
              padding: const EdgeInsets.all(0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black26, width: 1),
              ),
              child: current.image == null
                  ? const ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      child: BouncingBall(),
                    )
                  : (widget.quizIndex == 1) // 👈 wood frame for car.jpg
                      ? _WoodFramedPhoto(imagePath: current.image!)
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            current.image!,
                            fit: BoxFit.contain,
                          ),
                        ),
            ),

            // ✅ MCQ
            MCQBox(
              key: ValueKey(widget.quizIndex),
              answers: current.answers,
              correctAnswer: current.correctIndex,
              width: double.infinity,
              height: 250,
              padding: [16, 15, 10, 16, 16, 16],
              colorFill: Colors.white,
              borderRadius: 12,
              fontSize: 20,
              textColor: Colors.black,
              answerFill: Colors.white,
              answerFontWeight: FontWeight.w500,
              answerFontSize: 18,
              defaultAnimation: true,
              lockCorrectAnswer: true,
              onAnswerTap: (index, _) => _handleAnswerTap(index),
            ),

            const SizedBox(height: 10),

            if (_triedWrong && !_answeredCorrect)
              _feedbackBoxText(
                  "Try Again!", Colors.red.shade50, Colors.red.shade700),

            if (_answeredCorrect)
              _feedbackBoxWidgets(
                successMsg,
                Colors.green.shade50,
                Colors.green.shade700,
              ),
          ],
        ),
      ),
    );
  }

  Widget _feedbackBoxText(String msg, Color bg, Color borderColor) {
    return LessonText.box(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor.withOpacity(0.4), width: 1),
      ),
      child: Text(
        msg,
        textAlign: TextAlign.start,
        style: GoogleFonts.lato(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: borderColor,
        ),
      ),
    );
  }

  Widget _feedbackBoxWidgets(
    List<Widget> msgs,
    Color bg,
    Color borderColor,
  ) {
    return LessonText.box(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor.withOpacity(0.4), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: msgs,
      ),
    );
  }
}

/// 🔥 Animated Bouncing Ball
class BouncingBall extends StatefulWidget {
  const BouncingBall({super.key});

  @override
  State<BouncingBall> createState() => _BouncingBallState();
}

class _BouncingBallState extends State<BouncingBall>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _bounce;

  double _ballSize = 0;
  double _centerY = 0;
  double _floorY = 0;

  @override
  void initState() {
    super.initState();
    final totalDuration =
        Duration(milliseconds: 600 * bounceNo) + timeBeforeRepeatAnimation;
    _controller = AnimationController(vsync: this, duration: totalDuration)
      ..repeat();
  }

  void _setupAnimation(double containerHeight) {
    _ballSize = containerHeight * 0.32;
    _centerY = containerHeight * 0.24;
    _floorY = containerHeight * 1.07 - _ballSize;

    final sequence = <TweenSequenceItem<double>>[];
    for (int i = 0; i < bounceNo; i++) {
      sequence.addAll([
        TweenSequenceItem(
          tween: Tween(begin: _centerY, end: _floorY)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 50,
        ),
        TweenSequenceItem(
          tween: Tween(begin: _floorY, end: _centerY)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 50,
        ),
      ]);
    }
    _bounce = TweenSequence(sequence).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Always recalc based on parent height
        _setupAnimation(constraints.maxHeight);

        return Stack(
          children: [
            // 🔴 Recording icon
            Positioned(
              left: 10,
              top: -10,
              child: Image.asset(
                "assets/images/record_icon.png",
                width: _ballSize,
                height: _ballSize,
              ),
            ),

            // 🏀 Ball bounce
            AnimatedBuilder(
              animation: _controller,
              builder: (_, __) {
                return Positioned(
                  left: (maxTextWidth - _ballSize) / 2,
                  top: _bounce.value,
                  child: Image.asset(
                    "assets/images/basketball.png",
                    width: _ballSize,
                    height: _ballSize,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

/// (WoodFramedPhoto + Painters remain unchanged…)

/// ─────────────────────────────────────────────────────────
///  WOOD-FRAMED PHOTO (angular + sketchy border + scratches)
/// ─────────────────────────────────────────────────────────
/// ─────────────────────────────────────────────────────────
///  WOOD-FRAMED PHOTO (fills fully, no white gap)
/// ─────────────────────────────────────────────────────────
class _WoodFramedPhoto extends StatelessWidget {
  final String imagePath;
  const _WoodFramedPhoto({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    const double frameRadius = 14;
    const double frameThickness = 16;

    return ClipRRect(
      child: Stack(
        children: [
          // 🍂 Light wood frame
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF7D9B4), Color(0xFFE9BF93)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x1F000000),
                  blurRadius: 4,
                  offset: Offset(1.5, 2.5),
                ),
              ],
            ),
          ),
          const Positioned.fill(
              child: CustomPaint(painter: _WoodTexturePainter())),

          // 📐 Direct photo fill with inner shadow (no white gap)
          Padding(
            padding: const EdgeInsets.all(frameThickness),
            child: Stack(
              children: [
                ClipRRect(
                  // borderRadius: BorderRadius.circular(frameRadius - 4),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
                // inner shadow to make it look under frame
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _InnerShadowPainter(
                        color: Colors.black.withOpacity(0.18),
                        spread: 10,
                      ),
                    ),
                  ),
                ),
                // glare
                const Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _GlassGlarePainter(
                        opacity1: 0.035,
                        opacity2: 0.025,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 🎨 Light wood streaks
class _WoodTexturePainter extends CustomPainter {
  const _WoodTexturePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFCB9E73).withOpacity(0.10)
      ..strokeWidth = 3;
    for (double y = -size.height; y < size.height * 2; y += 44) {
      canvas.drawLine(Offset(-20, y), Offset(size.width + 20, y + 46), paint);
    }
    final knot = Paint()
      ..color = const Color(0xFFB9835A).withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(Offset(size.width * .18, size.height * .28), 10, knot);
    canvas.drawCircle(Offset(size.width * .78, size.height * .66), 8, knot);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 🌫️ Inner shadow
class _InnerShadowPainter extends CustomPainter {
  final Color color;
  final double spread;
  const _InnerShadowPainter({required this.color, this.spread = 12});

  @override
  void paint(Canvas canvas, Size size) {
    _band(canvas, Rect.fromLTWH(0, 0, size.width, spread), Alignment.topCenter,
        Alignment.bottomCenter);
    _band(canvas, Rect.fromLTWH(0, size.height - spread, size.width, spread),
        Alignment.bottomCenter, Alignment.topCenter);
    _band(canvas, Rect.fromLTWH(0, 0, spread, size.height),
        Alignment.centerLeft, Alignment.centerRight);
    _band(canvas, Rect.fromLTWH(size.width - spread, 0, spread, size.height),
        Alignment.centerRight, Alignment.centerLeft);
  }

  void _band(Canvas canvas, Rect rect, Alignment begin, Alignment end) {
    final shader = LinearGradient(
        begin: begin,
        end: end,
        colors: [color, Colors.transparent]).createShader(rect);
    final paint = Paint()..shader = shader;
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// ✨ Glass glare overlay
class _GlassGlarePainter extends CustomPainter {
  final double opacity1;
  final double opacity2;
  const _GlassGlarePainter({this.opacity1 = 0.06, this.opacity2 = 0.04});

  @override
  void paint(Canvas canvas, Size size) {
    final path1 = Path()
      ..moveTo(-size.width * .1, size.height * .15)
      ..lineTo(size.width * .55, -size.height * .2)
      ..lineTo(size.width * 1.1, size.height * .35)
      ..lineTo(size.width * .45, size.height * .7)
      ..close();
    canvas.drawPath(path1, Paint()..color = Colors.white.withOpacity(opacity1));

    final path2 = Path()
      ..moveTo(0, size.height * .6)
      ..lineTo(size.width * .65, size.height * .25)
      ..lineTo(size.width * 1.2, size.height * .8)
      ..lineTo(size.width * .55, size.height * 1.15)
      ..close();
    canvas.drawPath(path2, Paint()..color = Colors.white.withOpacity(opacity2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 🖊️ Sketchy border with vertical scratches
class _SketchyBorderPainter extends CustomPainter {
  final Random _random = Random(42);

  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = Colors.brown.shade700.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width + _random.nextDouble() * 4 - 2, 0);
    path.lineTo(size.width, size.height + _random.nextDouble() * 4 - 2);
    path.lineTo(_random.nextDouble() * 4 - 2, size.height);
    path.close();
    canvas.drawPath(path, borderPaint);

    final scratchPaint = Paint()
      ..color = Colors.brown.shade900.withOpacity(0.5)
      ..strokeWidth = 1.5;
    const scratchLength = 20.0;

    canvas.drawLine(
        const Offset(0, 0), const Offset(0, scratchLength), scratchPaint);
    canvas.drawLine(
        Offset(size.width, 0), Offset(size.width, scratchLength), scratchPaint);
    canvas.drawLine(Offset(0, size.height - scratchLength),
        Offset(0, size.height), scratchPaint);
    canvas.drawLine(Offset(size.width, size.height - scratchLength),
        Offset(size.width, size.height), scratchPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
