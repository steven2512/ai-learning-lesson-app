import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';

const Color mainConceptColor = Color.fromARGB(255, 255, 109, 12);
const Color keyConceptGreen = Color.fromARGB(255, 0, 163, 54);

/// 🔹 Global font size
const double globalFontSize = 20;

/// 🔹 Note font size (for smaller explanation text)
const double noteFontSize = 18;

/// 🔹 Global animation controls
const Duration typingInterval = Duration(milliseconds: 120); // speed of typing
const Duration cursorBlinkInterval = Duration(milliseconds: 500); // blink speed
const int maxBufferLength = 400; // keep only last N chars for performance
const int wrapEvery = 40; // insert newline every N chars
const double containerWidth = 260; // overlay width
const double containerHeight = 140; // overlay height

class LessonStepTwo extends StatefulWidget {
  const LessonStepTwo({super.key});

  @override
  State<LessonStepTwo> createState() => _LessonStepTwoState();
}

class _LessonStepTwoState extends State<LessonStepTwo> {
  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.black26, width: 1),
      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 6,
          offset: Offset(0, 3),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ First definition box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 13),
              margin: const EdgeInsets.only(top: 10, bottom: 7),
              decoration: _boxDecoration(),
              child: LessonText.sentence([
                LessonText.word("But", Colors.black87,
                    fontSize: globalFontSize),
                LessonText.word("to", Colors.black87, fontSize: globalFontSize),
                LessonText.word("a", Colors.black87, fontSize: globalFontSize),
                LessonText.word("computer,", mainConceptColor,
                    fontSize: globalFontSize),
                LessonText.word("they", Colors.black87,
                    fontSize: globalFontSize),
                LessonText.word("don't", Colors.black87,
                    fontSize: globalFontSize),
                LessonText.word("directly", Colors.black87,
                    fontSize: globalFontSize),
                LessonText.word("see", keyConceptGreen,
                    fontSize: globalFontSize, fontWeight: FontWeight.w800),
                LessonText.word("a", keyConceptGreen,
                    fontSize: globalFontSize, fontWeight: FontWeight.w800),
                LessonText.word("photo", keyConceptGreen,
                    fontSize: globalFontSize, fontWeight: FontWeight.w800),
                LessonText.word("or", Colors.black87, fontSize: globalFontSize),
                LessonText.word("hear", keyConceptGreen,
                    fontSize: globalFontSize, fontWeight: FontWeight.w800),
                LessonText.word("music.", keyConceptGreen,
                    fontSize: globalFontSize, fontWeight: FontWeight.w800),
              ]),
            ),

            // ✅ Second definition box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 13),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: _boxDecoration(),
              child: LessonText.sentence([
                LessonText.word("To", Colors.black87, fontSize: globalFontSize),
                LessonText.word("them,", Colors.black87,
                    fontSize: globalFontSize),
                LessonText.word("everything", Colors.black87,
                    fontSize: globalFontSize),
                LessonText.word("is", Colors.black87, fontSize: globalFontSize),
                LessonText.word("just", Colors.black87,
                    fontSize: globalFontSize),
                LessonText.word("a", Colors.black87, fontSize: globalFontSize),
                LessonText.word("sequence", mainConceptColor,
                    fontSize: globalFontSize),
                LessonText.word("of", Colors.black87, fontSize: globalFontSize),
                LessonText.word("the", Colors.black87,
                    fontSize: globalFontSize),
                LessonText.word("number", Colors.black87,
                    fontSize: globalFontSize),
                LessonText.word("'0'", keyConceptGreen,
                    fontSize: globalFontSize, fontWeight: FontWeight.w800),
                LessonText.word("and", Colors.black87,
                    fontSize: globalFontSize),
                LessonText.word("'1'.", keyConceptGreen,
                    fontSize: globalFontSize, fontWeight: FontWeight.w800),
              ]),
            ),

            // ✅ Computer typing animation
            Center(
              child: BinaryTypingAnimation(),
            ),

            // ✅ Third definition box (binary code explanation, styled smaller)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 13),
              margin: const EdgeInsets.only(top: 20, bottom: 10),
              decoration: _boxDecoration(),
              child: LessonText.sentence([
                LessonText.word("These", Colors.black87,
                    fontSize: noteFontSize, italic: true),
                LessonText.word("0s", keyConceptGreen,
                    fontSize: noteFontSize,
                    fontWeight: FontWeight.w800,
                    italic: true),
                LessonText.word("and", Colors.black87,
                    fontSize: noteFontSize, italic: true),
                LessonText.word("1s", keyConceptGreen,
                    fontSize: noteFontSize,
                    fontWeight: FontWeight.w800,
                    italic: true),
                LessonText.word("are", Colors.black87,
                    fontSize: noteFontSize, italic: true),
                LessonText.word("called", Colors.black87,
                    fontSize: noteFontSize, italic: true),
                LessonText.word("binary", mainConceptColor,
                    fontSize: noteFontSize,
                    fontWeight: FontWeight.w800,
                    italic: true),
                LessonText.word("code,", mainConceptColor,
                    fontSize: noteFontSize,
                    fontWeight: FontWeight.w800,
                    italic: true),
                LessonText.word("the", Colors.black87,
                    fontSize: noteFontSize, italic: true),
                LessonText.word("fundamental", Colors.black87,
                    fontSize: noteFontSize, italic: true),
                LessonText.word("language", Colors.black87,
                    fontSize: noteFontSize, italic: true),
                LessonText.word("of", Colors.black87,
                    fontSize: noteFontSize, italic: true),
                LessonText.word("computers.", keyConceptGreen,
                    fontSize: noteFontSize,
                    fontWeight: FontWeight.w800,
                    italic: true),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

/// 🔹 Binary typing widget with auto-scroll
class BinaryTypingAnimation extends StatefulWidget {
  const BinaryTypingAnimation({super.key});

  @override
  State<BinaryTypingAnimation> createState() => _BinaryTypingAnimationState();
}

class _BinaryTypingAnimationState extends State<BinaryTypingAnimation> {
  String _binaryText = "";
  bool _showCursor = true;
  final Random _rng = Random();

  Timer? _typingTimer;
  Timer? _cursorTimer;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  void _startTyping() {
    // Start typing
    _typingTimer = Timer.periodic(typingInterval, (timer) {
      setState(() {
        _binaryText += _rng.nextBool() ? "0" : "1";

        // Insert newline every wrapEvery chars
        if (_binaryText.replaceAll("\n", "").length % wrapEvery == 0) {
          _binaryText += "\n";
        }

        // Trim buffer to avoid huge memory use
        if (_binaryText.length > maxBufferLength) {
          _binaryText =
              _binaryText.substring(_binaryText.length - maxBufferLength);
        }
      });

      // Auto-scroll to bottom for rolling effect
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    });

    // Cursor blink
    _cursorTimer = Timer.periodic(cursorBlinkInterval, (timer) {
      setState(() => _showCursor = !_showCursor);
    });
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _cursorTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // 🖥️ Monitor image
        Image.asset(
          "assets/images/monitor.png",
          width: 400,
          height: 300,
          fit: BoxFit.contain,
        ),

        // 💻 Scrolling overlay with binary text
        Positioned(
          top: 50, // adjust to match screen area inside monitor.png
          child: SizedBox(
            width: containerWidth,
            height: containerHeight,
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Text(
                _binaryText + (_showCursor ? "|" : ""),
                style: GoogleFonts.robotoMono(
                  fontSize: 16,
                  color: Colors.greenAccent,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
