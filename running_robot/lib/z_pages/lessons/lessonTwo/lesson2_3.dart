import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';

const Color mainConceptColor = Color.fromARGB(255, 255, 109, 12);
const Color keyConceptGreen = Color.fromARGB(255, 0, 163, 54);

/// 🔹 Global font sizes
const double globalFontSize = 20;
const double noteTextSize = 17.3; // final note/explanation box

/// 🔹 Animation + layout constants
const Duration typingInterval = Duration(milliseconds: 120);
const Duration cursorBlinkInterval = Duration(milliseconds: 500);
const int maxBufferLength = 400;
const int wrapEvery = 40;
const double containerWidth = 260;
const double containerHeight = 140;
const double overlayOffsetX = 0;
const double overlayOffsetY = -30;

/// ✅ LessonStepTwo widget
class LessonStepTwo extends StatefulWidget {
  final VoidCallback onStarted; // 👈 notifier to parent

  const LessonStepTwo({super.key, required this.onStarted});

  @override
  State<LessonStepTwo> createState() => _LessonStepTwoState();
}

class _LessonStepTwoState extends State<LessonStepTwo> {
  bool _started = false;

  void _handleStartPressed() {
    setState(() => _started = true);
    widget.onStarted(); // 👈 notify parent (LessonTwo) when started
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
            LessonText.box(
              margin: const EdgeInsets.only(top: 10, bottom: 7),
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
            LessonText.box(
              margin: const EdgeInsets.only(bottom: 40),
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

            // ✅ Monitor with overlay
            Center(
              child: SizedBox(
                width: 400,
                height: 300,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    BinaryTypingAnimation(enabled: _started),
                    if (!_started)
                      Transform.translate(
                        offset: Offset(overlayOffsetX, overlayOffsetY),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Click to start program",
                              style: GoogleFonts.lato(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: _handleStartPressed,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: mainConceptColor,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                elevation: 20,
                              ),
                              child: Text(
                                "Start",
                                style: GoogleFonts.lato(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // ✅ Third definition box (note style)
            // LessonText.box(
            //   margin: const EdgeInsets.only(top: 20, bottom: 10),
            //   child: LessonText.sentence([
            //     LessonText.word("These", Colors.black87,
            //         fontSize: noteTextSize),
            //     LessonText.word("0s", keyConceptGreen,
            //         fontSize: noteTextSize, fontWeight: FontWeight.w800),
            //     LessonText.word("and", Colors.black87, fontSize: noteTextSize),
            //     LessonText.word("1s", keyConceptGreen,
            //         fontSize: noteTextSize, fontWeight: FontWeight.w800),
            //     LessonText.word("are", Colors.black87, fontSize: noteTextSize),
            //     LessonText.word("called", Colors.black87,
            //         fontSize: noteTextSize),
            //     LessonText.word("binary", mainConceptColor,
            //         fontSize: noteTextSize,
            //         fontWeight: FontWeight.w800,
            //         italic: true),
            //     LessonText.word("code,", mainConceptColor,
            //         fontSize: noteTextSize,
            //         fontWeight: FontWeight.w800,
            //         italic: true),
            //     LessonText.word("the", Colors.black87, fontSize: noteTextSize),
            //     LessonText.word("fundamental", Colors.black87,
            //         fontSize: noteTextSize),
            //     LessonText.word("language", Colors.black87,
            //         fontSize: noteTextSize),
            //     LessonText.word("of", Colors.black87, fontSize: noteTextSize),
            //     LessonText.word("computers.", keyConceptGreen,
            //         fontSize: noteTextSize, fontWeight: FontWeight.w800),
            //   ]),
            // ),
          ],
        ),
      ),
    );
  }
}

/// ✅ Binary typing animation widget
class BinaryTypingAnimation extends StatefulWidget {
  final bool enabled;
  const BinaryTypingAnimation({super.key, required this.enabled});

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
  void didUpdateWidget(covariant BinaryTypingAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled && !oldWidget.enabled) {
      _startTyping();
      _startCursor(); // 👈 start flicker only after Start pressed
    }
  }

  void _startTyping() {
    _typingTimer = Timer.periodic(typingInterval, (timer) {
      setState(() {
        _binaryText += _rng.nextBool() ? "0" : "1";
        if (_binaryText.replaceAll("\n", "").length % wrapEvery == 0) {
          _binaryText += "\n";
        }
        if (_binaryText.length > maxBufferLength) {
          _binaryText =
              _binaryText.substring(_binaryText.length - maxBufferLength);
        }
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    });
  }

  void _startCursor() {
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
        Image.asset(
          "assets/images/monitor.png",
          width: 400,
          height: 300,
          fit: BoxFit.contain,
        ),
        Positioned(
          top: 50,
          child: SizedBox(
            width: containerWidth,
            height: containerHeight,
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Text(
                // 👇 cursor only visible once enabled
                widget.enabled ? _binaryText + (_showCursor ? "|" : "") : "",
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
