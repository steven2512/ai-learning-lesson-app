import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/mcq_box.dart';

const double maxTextWidth = 350;
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

class LessonStepOne extends StatefulWidget {
  final int quizIndex;
  final void Function(int quizIndex) onQuizCompleted;

  const LessonStepOne({
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
        LessonText.word("Everyday photos,", Colors.orange,
            italic: true, fontSize: correctTextSize),
        LessonText.word(
            "medical scans,", const Color.fromARGB(255, 107, 0, 195),
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
        LessonText.word("YouTube clips,", Colors.purple,
            italic: true, fontSize: correctTextSize),
        LessonText.word("animations", Colors.blue,
            italic: true, fontSize: correctTextSize),
      ]),
    ],
  ];

  @override
  State<LessonStepOne> createState() => LessonStepOneState();
}

class LessonStepOneState extends State<LessonStepOne> {
  bool _answeredCorrect = false;
  bool _triedWrong = false;

  _QuizItem get current => LessonStepOne._quizItems[widget.quizIndex];

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
        (widget.quizIndex < LessonStepOne.successMessages.length)
            ? LessonStepOne.successMessages[widget.quizIndex]
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black26, width: 1),
              ),
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
              height: 250,
              margin: const EdgeInsets.only(bottom: 15),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black26, width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: current.image == null
                    ? const BouncingBall()
                    : Image.asset(current.image!, fit: BoxFit.contain),
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

            const SizedBox(height: 20),

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
    return Container(
      width: double.infinity,
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
    return Container(
      width: double.infinity,
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
  late final Animation<double> _fade;
  late final Animation<double> _bounce;

  static const double _centerY = 60;
  static const double _floorY = 170;
  static const double _ballSize = 80;

  @override
  void initState() {
    super.initState();

    final totalDuration =
        Duration(milliseconds: 600 * bounceNo) + timeBeforeRepeatAnimation;

    _controller = AnimationController(vsync: this, duration: totalDuration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reset();
          _controller.forward();
        }
      });

    // Fade in -> visible -> fade out
    _fade = TweenSequence([
      TweenSequenceItem(
          tween: Tween(begin: 0.0, end: 1.0), weight: 10), // fade in
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 80), // visible
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 0.0), weight: 10), // fade out
    ]).animate(_controller);

    // Bounce sequence (center ↔ floor)
    final List<TweenSequenceItem<double>> sequence = [];
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

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 🔴 Recording icon top-left (always visible)
        Positioned(
          left: 10,
          top: -10,
          child: Image.asset(
            "assets/images/record_icon.png",
            width: 80,
            height: 80,
          ),
        ),

        // 🏀 Basketball bounce + fade
        AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            return Positioned(
              left: (maxTextWidth / 2) - _ballSize / 2,
              top: _bounce.value,
              child: Opacity(
                opacity: _fade.value,
                child: Image.asset(
                  "assets/images/basketball.png",
                  width: _ballSize,
                  height: _ballSize,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
