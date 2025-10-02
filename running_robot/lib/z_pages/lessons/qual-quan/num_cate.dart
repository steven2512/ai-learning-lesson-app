// ✅ LessonStepThree — Slide 4 (Quantitative data question)
// Smooth animation: numbers (with units) + words fading in/out
// ❗ Guarantees kept:
//   - No overlap at any time (slot is exclusive until fade-out completes)
//   - No overflow: all text stays inside the box bounds (measured + clamped)
//   - No duplicate strings visible at once
//   - No immediate spawn on page load (blank until start delay)
//
// 🔷 UPDATED (looping behavior):
//   - animationStartDelayMs: page shows a blank animation area for 3s
//   - runWindowMs: run the animation for exactly 10s per cycle
//   - delayBetweenLoopMs: wait 2s between cycles (no new spawns during the gap)
//   - onCompleted fires ONCE right after the first 10s window ends
//   - Animation keeps looping indefinitely even after onCompleted

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';

// ========================== CONFIG =============================

// Lesson text size
const double lesson3FontSize = 20;

// Box height
const double _animBoxHeight = 160.0;

// Animation timing controls (per item)
const int fadeInMs = 500; // fade in duration
const int visibleMs = 1000; // full opacity duration
const int fadeOutMs = 500; // fade out duration

// How many slots (non-overlapping positions)
const int slotCount = 8;

// Optional extra delay before the first spawn (AFTER the global start delay)
const int firstSpawnDelayMs = 0;

// 🔷 Global timing for the loop controller
const int animationStartDelayMs = 1000; // 3s — container stays blank until this
const int runWindowMs = 8000; // 10s — active spawning window per cycle
const int delayBetweenLoopMs = 1500; // 2s — gap between cycles (no new spawns)

// =================================================================

class NumberAndCategoryIntro extends StatefulWidget {
  final VoidCallback? onCompleted;

  const NumberAndCategoryIntro({super.key, this.onCompleted});

  @override
  State<NumberAndCategoryIntro> createState() => _NumberAndCategoryIntroState();
}

class _NumberAndCategoryIntroState extends State<NumberAndCategoryIntro>
    with TickerProviderStateMixin {
  final Random _rand = Random();

  // Expanded words (categories, qualitative examples)
  final List<String> _words = const [
    "Apple",
    "Metal",
    "Blue",
    "Jazz",
    "Dog",
    "Soccer",
    "Banana",
    "Plastic",
    "Rock",
    "Guitar",
    "Cat",
    "Teacher",
    "Coffee",
    "Book",
    "Car",
    "Strawberry",
    "Dance",
    "Movie",
    "Friendship",
    "History",
    "Ocean",
    "Piano",
    "Chocolate",
    "Basketball",
    "Country"
  ];

  // Expanded numbers (quantitative examples)
  final List<String> _nums = const [
    "170",
    "55",
    "2.5",
    "37",
    "120",
    "1.8",
    "60",
    "45",
    "95",
    "200",
    "3.14",
    "88",
    "42",
    "15.6",
    "72",
    "305",
    "0.75",
    "99",
    "450",
    "12.7",
    "640",
    "7.2",
    "510",
    "360"
  ];

  final List<String> _units = const [
    "kg",
    "cm",
    "ml",
    "yrs",
    "m",
    "L",
    "g",
    "km",
    "°C",
    "%",
    "USD",
    "points",
    "items",
    "hours",
    "days"
  ];

  // -------- Runtime state --------
  final List<_Slot?> _slots = List.filled(slotCount, null);

  // Track active texts to avoid duplicates across the whole box
  final Set<String> _activeTexts = {};

  // Layout info (computed via LayoutBuilder)
  List<Rect> _slotRects = [];
  double _boxWidth = 0;
  double _boxHeight = _animBoxHeight;

  // Timers & guards
  Timer? _startTimer; // 3s blank delay (once)
  Timer? _spawnDelayTimer; // optional firstSpawnDelayMs (once)
  Timer? _spawnTimer; // periodic spawner (active during run windows)
  Timer? _cycleEndTimer; // ends each 10s run window
  Timer? _betweenCyclesTimer; // 2s gap between cycles
  bool _firstCompletionFired = false;
  bool _loopStarted = false;

  @override
  void initState() {
    super.initState();

    // 🔷 Do NOT spawn anything immediately: container must remain blank for 3s.
    _startTimer = Timer(Duration(milliseconds: animationStartDelayMs), () {
      if (!mounted) return;

      // Optional additional delay before the very first spawn (kept for parity)
      if (firstSpawnDelayMs > 0) {
        _spawnDelayTimer =
            Timer(Duration(milliseconds: firstSpawnDelayMs), _startLoopCycle);
      } else {
        _startLoopCycle();
      }
    });
  }

  // Start a 10s run window: begin spawning and schedule its end.
  void _startLoopCycle() {
    if (!mounted) return;

    _loopStarted = true;
    _beginSpawning();

    // End this active window after exactly runWindowMs
    _cycleEndTimer?.cancel();
    _cycleEndTimer = Timer(Duration(milliseconds: runWindowMs), () {
      if (!mounted) return;
      _endActiveWindow();

      // Fire onCompleted once after the FIRST run window finishes
      if (!_firstCompletionFired) {
        _firstCompletionFired = true;
        widget.onCompleted?.call();
      }

      // Schedule the next cycle after the configured gap
      _betweenCyclesTimer?.cancel();
      _betweenCyclesTimer =
          Timer(Duration(milliseconds: delayBetweenLoopMs), _startLoopCycle);
    });
  }

  // Begin periodic spawning (called at the start of each run window)
  void _beginSpawning() {
    _spawnTimer?.cancel();
    _spawnTimer = Timer.periodic(const Duration(milliseconds: 700), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_slotRects.length != slotCount) return; // wait for layout to be ready

      // Find free slots
      final free = <int>[];
      for (int i = 0; i < slotCount; i++) {
        if (_slots[i] == null) free.add(i);
      }
      if (free.isEmpty) return;

      final index = free[_rand.nextInt(free.length)];
      final newItem = _newItemForSlot(index);
      if (newItem != null) {
        setState(() {
          _slots[index] = newItem;
          _activeTexts.add(newItem.text);
        });
        newItem.controller.forward();
      }
    });
  }

  // End a run window: stop spawning (existing items finish their own fade-outs)
  void _endActiveWindow() {
    _spawnTimer?.cancel();
    _spawnTimer = null;
  }

  _Slot? _newItemForSlot(int slotIndex) {
    String? text;
    bool isNumber = false;

    // Pick a unique candidate (avoid duplicates currently on screen)
    for (int tries = 0; tries < 12; tries++) {
      final candidateIsNum = _rand.nextBool();
      final candidate = candidateIsNum
          ? "${_nums[_rand.nextInt(_nums.length)]} ${_units[_rand.nextInt(_units.length)]}"
          : _words[_rand.nextInt(_words.length)];
      if (!_activeTexts.contains(candidate)) {
        text = candidate;
        isNumber = candidateIsNum;
        break;
      }
    }
    if (text == null) return null;

    final color = isNumber
        ? Colors.blue[_rand.nextBool() ? 600 : 400]!
        : Colors.primaries[_rand.nextInt(Colors.primaries.length)][600]!;

    final Rect rect = _slotRects.isNotEmpty
        ? _slotRects[slotIndex]
        : Rect.fromLTWH(0, 0, _boxWidth, _boxHeight);

    const double baseFont = 26.0;
    const double pad = 8.0;

    // Measure at base font to scale down if needed
    final textPainterBase = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(fontSize: baseFont, fontWeight: FontWeight.w900),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();

    final double availW = (rect.width - 2 * pad).clamp(4.0, double.infinity);
    final double availH = (rect.height - 2 * pad).clamp(4.0, double.infinity);

    double fontSize = baseFont;
    if (textPainterBase.width > availW) {
      final scale = (availW / textPainterBase.width).clamp(0.6, 1.0);
      fontSize = (baseFont * scale).clamp(16.0, baseFont);
    }

    // Layout at final font size to get exact width/height
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w900),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();

    final tw = textPainter.width;
    final th = textPainter.height;

    final double freeW = max(0.0, availW - tw);
    final double freeH = max(0.0, availH - th);
    final left =
        rect.left + pad + (freeW == 0 ? 0 : _rand.nextDouble() * freeW);
    final top = rect.top + pad + (freeH == 0 ? 0 : _rand.nextDouble() * freeH);

    final totalDuration = fadeInMs + visibleMs + fadeOutMs;

    final controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: totalDuration),
    );

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() {
            _activeTexts.remove(text);
            _slots[slotIndex]?.controller.dispose();
            _slots[slotIndex] = null;
          });
        });
      }
    });

    return _Slot(
      text: text,
      color: color,
      left: left,
      top: top,
      fontSize: fontSize,
      controller: controller,
    );
  }

  @override
  void dispose() {
    // Dispose all animation controllers
    for (final slot in _slots) {
      slot?.controller.dispose();
    }
    // Cancel timers
    _startTimer?.cancel();
    _spawnDelayTimer?.cancel();
    _spawnTimer?.cancel();
    _cycleEndTimer?.cancel();
    _betweenCyclesTimer?.cancel();
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
            const SizedBox(height: 18),

            // 🟦 Big Question Box
            LessonText.box(
              margin: const EdgeInsets.only(bottom: 14),
              child: LessonText.sentence([
                LessonText.word("That's why the", Colors.black87,
                    fontSize: lesson3FontSize),
                LessonText.word(
                    "first thing", const Color.fromARGB(255, 255, 109, 12),
                    fontSize: lesson3FontSize),
                LessonText.word(
                    "we ask is:", const Color.fromARGB(221, 0, 0, 0),
                    fontSize: lesson3FontSize),
              ]),
            ),

            // 🟦 Key Question Box
            LessonText.box(
              margin: const EdgeInsets.only(bottom: 14),
              child: LessonText.sentence([
                LessonText.word("Is this data", Colors.black87,
                    fontSize: lesson3FontSize),
                LessonText.word(
                    "numbers", const Color.fromARGB(255, 0, 113, 206),
                    fontSize: lesson3FontSize, fontWeight: FontWeight.w800),
                LessonText.word("or", Colors.black87,
                    fontSize: lesson3FontSize),
                LessonText.word(
                    "categories?", const Color.fromARGB(255, 200, 0, 0),
                    fontSize: lesson3FontSize, fontWeight: FontWeight.w800),
              ]),
            ),

            // 🟦 Animated Box
            LessonText.box(
              margin: const EdgeInsets.only(bottom: 14),
              child: SizedBox(
                height: _animBoxHeight,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    _boxWidth = constraints.maxWidth;
                    _boxHeight = _animBoxHeight;

                    const minSlotW = 140.0;
                    int cols = (_boxWidth / minSlotW).floor().clamp(2, 4);
                    final rows = (slotCount / cols).ceil();
                    final slotW = _boxWidth / cols;
                    final slotH = _animBoxHeight / rows;

                    final List<Rect> rects = [];
                    for (int i = 0; i < slotCount; i++) {
                      final c = i % cols;
                      final r = i ~/ cols;
                      final left = c * slotW;
                      final top = r * slotH;
                      rects.add(Rect.fromLTWH(left, top, slotW, slotH));
                    }
                    _slotRects = rects;

                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      clipBehavior: Clip.hardEdge,
                      child: Stack(
                        children: List.generate(slotCount, (i) {
                          final slot = _slots[i];
                          if (slot == null) return const SizedBox.shrink();

                          return AnimatedBuilder(
                            animation: slot.controller,
                            builder: (context, child) {
                              final total =
                                  (fadeInMs + visibleMs + fadeOutMs).toDouble();
                              final fadeIn =
                                  Tween<double>(begin: 0, end: 1).animate(
                                CurvedAnimation(
                                  parent: slot.controller,
                                  curve: Interval(0.0, fadeInMs / total,
                                      curve: Curves.linear),
                                ),
                              );
                              final fadeOut =
                                  Tween<double>(begin: 1, end: 0).animate(
                                CurvedAnimation(
                                  parent: slot.controller,
                                  curve: Interval(
                                      (fadeInMs + visibleMs) / total, 1.0,
                                      curve: Curves.linear),
                                ),
                              );

                              final v = slot.controller.value;
                              double opacity;
                              if (v < fadeInMs / total) {
                                opacity = fadeIn.value;
                              } else if (v < (fadeInMs + visibleMs) / total) {
                                opacity = 1.0;
                              } else {
                                opacity = fadeOut.value;
                              }

                              return Positioned(
                                left: slot.left,
                                top: slot.top,
                                child: Opacity(
                                  opacity: opacity,
                                  child: Text(
                                    slot.text,
                                    style: TextStyle(
                                      fontSize: slot.fontSize,
                                      fontWeight: FontWeight.w900,
                                      color: slot.color,
                                      shadows: const [
                                        Shadow(
                                          offset: Offset(2, 2),
                                          blurRadius: 4,
                                          color: Colors.black26,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Slot model
class _Slot {
  final String text;
  final Color color;
  final double left;
  final double top;
  final double fontSize;
  final AnimationController controller;

  _Slot({
    required this.text,
    required this.color,
    required this.left,
    required this.top,
    required this.fontSize,
    required this.controller,
  });
}
