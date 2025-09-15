// ✅ LessonStepTwo — types N lines (top-left), pauses (cursor blinks), clears, then shows "COMPLETE"
// EFFECT-ONLY CONTROLS:
// • kCompleteSpeed       -> slows/speeds the "COMPLETE" fade-in only (typing unchanged).
//                          >1.0 = slower, <1.0 = faster (e.g., 1.4 slower, 0.8 faster)
// • kPostTypingHoldMs    -> hold time AFTER typing stops (cursor keeps blinking) BEFORE showing "COMPLETE"
// • kContinueDelayMs     -> extra delay AFTER the COMPLETE fade-in finishes before Continue appears

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';

const Color mainConceptColor = Color.fromARGB(255, 255, 109, 12);
const Color keyConceptGreen = Color.fromARGB(255, 0, 163, 54);

/// 🔹 Typing timings (UNCHANGED) — leave these alone
const Duration typingInterval = Duration(milliseconds: 30);
const Duration cursorBlinkInterval = Duration(milliseconds: 500);

/// 🔹 Typing/layout constants
const int maxBufferLength = 400;
const int wrapEvery = 40;
const int maxLines =
    3; // how many lines to type before pausing & showing COMPLETE
const double containerWidth = 260;
const double containerHeight = 140;
const double overlayOffsetX = 0;
const double overlayOffsetY = -30;

/// ─────────────────────────────────────────────────────────
/// 🔧 EFFECT-ONLY CONTROLS (NEW)
/// ─────────────────────────────────────────────────────────
const double kCompleteSpeed = 2.0; // >1.0 slower fade-in, <1.0 faster
const int kPostTypingHoldMs =
    1500; // hold time (cursor blinks) BEFORE COMPLETE appears
const int kContinueDelayMs =
    00; // delay AFTER COMPLETE finishes before unlocking Continue

// Base COMPLETE fade duration (scaled by kCompleteSpeed)
const Duration _kEffectFadeBase = Duration(milliseconds: 900);

// Scale helper for EFFECT ONLY
Duration _scaleEffect(Duration d) =>
    Duration(milliseconds: (d.inMilliseconds * kCompleteSpeed).round());

/// ✅ LessonStepTwo widget
class LessonStepTwo extends StatefulWidget {
  /// Fired AFTER COMPLETE (plus kContinueDelayMs) to unlock Continue.
  final VoidCallback onStarted;

  const LessonStepTwo({super.key, required this.onStarted});

  @override
  State<LessonStepTwo> createState() => _LessonStepTwoState();
}

class _LessonStepTwoState extends State<LessonStepTwo> {
  bool _started = false;

  void _handleStartPressed() {
    setState(() => _started = true);
    // Do NOT notify parent yet; unlock only after COMPLETE + delays.
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LessonText.box(
              margin: const EdgeInsets.only(top: 10, bottom: 7),
              child: LessonText.sentence([
                LessonText.word("But", Colors.black87, fontSize: 20),
                LessonText.word("to", Colors.black87, fontSize: 20),
                LessonText.word("a", Colors.black87, fontSize: 20),
                LessonText.word("computer,", mainConceptColor, fontSize: 20),
                LessonText.word("they", Colors.black87, fontSize: 20),
                LessonText.word("don't", Colors.black87, fontSize: 20),
                LessonText.word("directly", Colors.black87, fontSize: 20),
                LessonText.word("see", keyConceptGreen,
                    fontSize: 20, fontWeight: FontWeight.w800),
                LessonText.word("a", keyConceptGreen,
                    fontSize: 20, fontWeight: FontWeight.w800),
                LessonText.word("photo", keyConceptGreen,
                    fontSize: 20, fontWeight: FontWeight.w800),
                LessonText.word("or", Colors.black87, fontSize: 20),
                LessonText.word("hear", keyConceptGreen,
                    fontSize: 20, fontWeight: FontWeight.w800),
                LessonText.word("music.", keyConceptGreen,
                    fontSize: 20, fontWeight: FontWeight.w800),
              ]),
            ),
            LessonText.box(
              margin: const EdgeInsets.only(bottom: 5),
              child: LessonText.sentence([
                LessonText.word("This", Colors.black87, fontSize: 21),
                LessonText.word("is", Colors.black87, fontSize: 21),
                LessonText.word("what", Colors.black87, fontSize: 21),
                LessonText.word("they", Colors.black87, fontSize: 21),
                LessonText.word("actually", Color.fromARGB(255, 0, 48, 223),
                    fontSize: 21),
                LessonText.word("see", Color.fromARGB(255, 0, 48, 223),
                    fontSize: 21),
              ]),
            ),
            Center(
              child: SizedBox(
                width: 400,
                height: 300,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    BinaryTypingAnimation(
                      enabled: _started,
                      linesToType: maxLines,
                      postTypingHold: Duration(milliseconds: kPostTypingHoldMs),
                      continueDelay: Duration(milliseconds: kContinueDelayMs),
                      onFinished: widget.onStarted, // unlock Continue here
                    ),
                    if (!_started)
                      Transform.translate(
                        offset: const Offset(overlayOffsetX, overlayOffsetY),
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
          ],
        ),
      ),
    );
  }
}

/// ✅ Binary typing animation widget
class BinaryTypingAnimation extends StatefulWidget {
  final bool enabled;
  final int linesToType;
  final Duration postTypingHold; // hold with blinking cursor BEFORE COMPLETE
  final Duration continueDelay; // delay AFTER COMPLETE finishes
  final VoidCallback? onFinished;

  const BinaryTypingAnimation({
    super.key,
    required this.enabled,
    this.linesToType = maxLines,
    this.postTypingHold = Duration.zero,
    this.continueDelay = Duration.zero,
    this.onFinished,
  });

  @override
  State<BinaryTypingAnimation> createState() => _BinaryTypingAnimationState();
}

class _BinaryTypingAnimationState extends State<BinaryTypingAnimation>
    with TickerProviderStateMixin {
  String _binaryText = "";
  bool _showCursor = true;
  final Random _rng = Random();

  Timer? _typingTimer;
  Timer? _cursorTimer;
  final ScrollController _scrollController = ScrollController();

  int _typedNonNewlineChars = 0; // total chars typed excluding '\n'
  int _lines = 0;

  bool _doneTyping = false; // finished generating lines, holding cursor
  bool _showingComplete = false;

  // EFFECT: simple one-time fade-in (movie-style) — duration scaled by kCompleteSpeed
  late final Duration _completeFadeDuration;
  late final AnimationController _completeCtrl;
  late final Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();

    _completeFadeDuration = _scaleEffect(_kEffectFadeBase);
    _completeCtrl = AnimationController(
      vsync: this,
      duration: _completeFadeDuration,
    );
    _fadeIn =
        CurvedAnimation(parent: _completeCtrl, curve: Curves.easeOutCubic);
  }

  @override
  void didUpdateWidget(covariant BinaryTypingAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled && !oldWidget.enabled) {
      _startTyping();
      _startCursor();
    }
  }

  void _startTyping() {
    _typingTimer?.cancel();

    // Always start with '0'
    if (_typedNonNewlineChars == 0 && _lines == 0) {
      setState(() {
        _binaryText = "0";
        _typedNonNewlineChars = 1;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    }

    _typingTimer = Timer.periodic(typingInterval, (timer) {
      if (_doneTyping) return;

      // type next char
      final nextChar = _rng.nextBool() ? "0" : "1";

      setState(() {
        _binaryText += nextChar;
        _typedNonNewlineChars++;

        // When we would normally wrap, decide whether to add a newline.
        if (_typedNonNewlineChars % wrapEvery == 0) {
          // If this would complete the LAST line, don't insert a newline.
          // This keeps the cursor at the end of the final line (no blank next line).
          if (_lines + 1 >= widget.linesToType) {
            _lines++; // count the final line as complete
            // no '\n' appended here on purpose
          } else {
            _binaryText += "\n"; // normal wrap for non-final lines
            _lines++;
          }
        }

        // hard safety buffer (kept)
        if (_binaryText.length > maxBufferLength) {
          _binaryText =
              _binaryText.substring(_binaryText.length - maxBufferLength);
        }
      });

      // If we've reached the target number of lines, stop typing naturally
      // (cursor stays on SAME line because we skipped the trailing newline).
      if (_lines >= widget.linesToType) {
        _finishTyping();
        return;
      }

      // Auto-scroll
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    });
  }

  void _startCursor() {
    _cursorTimer?.cancel();
    _cursorTimer = Timer.periodic(cursorBlinkInterval, (_) {
      if (_showingComplete) return; // stop blinking once COMPLETE starts
      setState(() => _showCursor = !_showCursor);
    });
  }

  void _finishTyping() {
    _typingTimer?.cancel();
    setState(() {
      _doneTyping = true; // keep cursor blinking during the hold
    });

    // Hold with blinking cursor before showing COMPLETE
    Future.delayed(widget.postTypingHold, () {
      if (!mounted || _showingComplete) return;
      _startComplete();
    });
  }

  void _startComplete() {
    // Wipe text, stop cursor blinking, start fade-in once
    _cursorTimer?.cancel();
    setState(() {
      _showingComplete = true;
      _binaryText = "";
      _showCursor = false;
    });

    _completeCtrl.forward().whenComplete(() async {
      // After fade finishes, wait extra before unlocking Continue
      if (!mounted) return;
      await Future.delayed(widget.continueDelay);
      if (mounted) widget.onFinished?.call();
    });
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _cursorTimer?.cancel();
    _scrollController.dispose();
    _completeCtrl.dispose();
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
            child: Stack(
              alignment: Alignment.topLeft, // typing from top-left
              children: [
                if (!_showingComplete)
                  Positioned.fill(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: Text(
                        widget.enabled
                            ? _binaryText + (_showCursor ? "|" : "")
                            : "",
                        textAlign: TextAlign.left,
                        style: GoogleFonts.robotoMono(
                          fontSize: 16,
                          color: Colors.greenAccent,
                        ),
                      ),
                    ),
                  )
                else
                  // Simple one-time, slow fade-in (movie-style)
                  Center(
                    child: FadeTransition(
                      opacity: _fadeIn,
                      child: Text(
                        "COMPLETE",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.robotoMono(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.greenAccent,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
