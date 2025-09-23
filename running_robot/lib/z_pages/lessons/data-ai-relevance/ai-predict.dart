// FILE: lib/z_pages/lessons/data-ai-relevance/ai_predict.dart
// Smooth RIGHT→LEFT slides with staggered cross-fade (no blur).
// Houses 1–3: "(Data)"; House 4: "(prediction)".
// House 4 price: "??????" slides RIGHT out; real price slides LEFT in and pops.
// Price lane is constraint-safe and constant width (no jitter/overflow).

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';

/// Colors
const Color aiPink = Color(0xFFE91E63);
const Color titleInk = Colors.black87;
const Color houseNumRed = Color(0xFFE53935);
const Color priceGreen = Color.fromARGB(255, 0, 163, 54);
const Color priceBadgeBg = Colors.white;
const Color priceBadgeBorder = Colors.black;
const Color brandBlue = Color(0xFF1E88E5);

/// Layout
const double headerFontSize = 20;
const double sceneHeight = 360;

/// Pill metrics (exact sizing → perfect centering, no clipping)
const double _kPillPadH = 12.0; // horizontal padding in pill
const double _kPillBorder = 2.0; // border width in pill
const double _kPillExtraW = _kPillPadH * 2 + _kPillBorder * 2; // 28
const double _kPillHeight = 36.0; // pill height
const double _kLaneHeight = 44.0; // lane headroom
const double _kLaneSafety = 6.0; // ← NEW: width safety px

/// Reveal timing tweaks
const double _kFadeOutCutoff = 0.85; // unknown invisible by 85%
const double _kOvershoot = 6.0; // slide slightly past edge

/// Motion knobs
const bool kLoop = true;
const int kStartDelayMs = 2000;

// ≈2s/card: 700ms transition + 1300ms hold
const int kTurnMs = 700;
const int kHoldMs = 1300;
const int kRevealHoldMs = 1300;
const int kThinkingMs = 1600;
const int kGuessHoldMs = 5200;

// Slide geometry (no rotation)
const double kSlideOutPx = 160;
const double kSlideInStartPx = 260;

// Cross-fade staggering
const double kFadeInDelay = 0.20;
const double kFadeOutFinish = 0.68;

// Price reveal (Unknown→Real)
const int kPriceRevealMs = 520;

// Gentle pop scale for final price
const double kPopStart = 0.94;
const double kPopEnd = 1.04;

class AIPredict extends StatefulWidget {
  final VoidCallback? onCompleted; // optional callback when correct

  const AIPredict({super.key, this.onCompleted});
  @override
  State<AIPredict> createState() => _AIPredictState();
}

enum _Phase { page1, page2, page3, page4ShowUnknown, thinking, guessed }

class _AIPredictState extends State<AIPredict> with TickerProviderStateMixin {
  _Phase _phase = _Phase.page1;

  late final AnimationController _turnCtrl; // page slide
  late final AnimationController _popCtrl; // landing pop (title number)
  late final AnimationController _guessPopCtrl; // final price pop
  late final AnimationController _revealCtrl; // Unknown→Real

  int _currentIndex = 0;
  int? _nextIndex;

  final List<Timer> _timers = [];

  @override
  void initState() {
    super.initState();

    _turnCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: kTurnMs),
    )..addListener(() => mounted ? setState(() {}) : null);

    _popCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    )..addListener(() => mounted ? setState(() {}) : null);

    _guessPopCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 340),
      lowerBound: 0.0,
      upperBound: 1.0,
    );

    _revealCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: kPriceRevealMs),
    )..addListener(() => mounted ? setState(() {}) : null);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _popCtrl.forward(from: 0.86);
    });

    Future.delayed(const Duration(milliseconds: kStartDelayMs), _runStoryboard);
  }

  void _runStoryboard() {
    int t = 0;

    void turnTo(int idx, _Phase p) {
      _chain(Duration(milliseconds: t),
          () => _turnTo(idx, then: () => _setPhase(p)));
      t += kTurnMs;
      t += (p == _Phase.page4ShowUnknown ? kRevealHoldMs : kHoldMs);
    }

    // 1 → 2 → 3 → 4 (Unknown)
    turnTo(1, _Phase.page2);
    turnTo(2, _Phase.page3);
    turnTo(3, _Phase.page4ShowUnknown);

    // Thinking
    _chain(Duration(milliseconds: t), () => _setPhase(_Phase.thinking));
    t += kThinkingMs;

    // Reveal final price
// Reveal final price
    _chain(Duration(milliseconds: t), () {
      _setPhase(_Phase.guessed);
      _revealCtrl.forward(from: 0.0);
      _guessPopCtrl.forward(from: 0.0);
    });

// 🔹 Trigger continue button ~2s after guessed
    _chain(Duration(milliseconds: t + 2000), () {
      widget.onCompleted?.call();
    });

    t += kGuessHoldMs;

    if (kLoop) {
      _chain(Duration(milliseconds: t), () {
        if (!mounted) return;
        _resetAll();
        Future.delayed(
            const Duration(milliseconds: kStartDelayMs), _runStoryboard);
      });
    }
  }

  void _resetAll() {
    for (final t in _timers) t.cancel();
    _timers.clear();
    _turnCtrl.value = 0;
    _popCtrl.value = 0;
    _guessPopCtrl.value = 0;
    _revealCtrl.value = 0;
    _currentIndex = 0;
    _nextIndex = null;
    _phase = _Phase.page1;
    if (mounted) setState(() {});
  }

  void _popLanding() => _popCtrl.forward(from: 0.86);

  void _turnTo(int index, {VoidCallback? then}) {
    _nextIndex = index;
    _turnCtrl.forward(from: 0.0).whenComplete(() {
      _currentIndex = index;
      _nextIndex = null;
      _popLanding();
      then?.call();
    });
  }

  void _chain(Duration after, VoidCallback f) {
    _timers.add(Timer(after, f));
  }

  void _setPhase(_Phase p) {
    if (!mounted) return;
    setState(() => _phase = p);
  }

  @override
  void dispose() {
    for (final t in _timers) t.cancel();
    _turnCtrl.dispose();
    _popCtrl.dispose();
    _guessPopCtrl.dispose();
    _revealCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // HEADER (TOP, CENTERED)
            LessonText.box(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Center(
                child: LessonText.sentence([
                  LessonText.word("AI", aiPink,
                      fontSize: headerFontSize, fontWeight: FontWeight.w900),
                  LessonText.word("can", titleInk, fontSize: headerFontSize),
                  LessonText.word("predict", brandBlue,
                      fontSize: headerFontSize, fontWeight: FontWeight.w900),
                  LessonText.word("unknown", brandBlue,
                      fontSize: headerFontSize, fontWeight: FontWeight.w900),
                  LessonText.word("values", brandBlue,
                      fontSize: headerFontSize, fontWeight: FontWeight.w900),
                ]),
              ),
            ),

            // SCENE (animation)
            LessonText.box(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: SizedBox(
                height: sceneHeight,
                child: _turnScene(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Clean slide with staggered cross-fade
  Widget _turnScene() {
    return AnimatedBuilder(
      animation: _turnCtrl,
      builder: (context, _) {
        final current = _pageFor(_currentIndex);
        final next = _pageFor(_nextIndex ?? _currentIndex);

        final double s = _clamp01(_turnCtrl.value);
        final double e = Curves.easeInOutCubic.transform(s);

        final double outDx = (-kSlideOutPx * e).roundToDouble();
        final double inDx = (kSlideInStartPx * (1 - e)).roundToDouble();

        final double outOp = _fadeOutStagger(s);
        final double inOp = _fadeInStagger(s);

        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (_nextIndex == null) current,
              if (_nextIndex != null) ...[
                Opacity(
                  opacity: outOp,
                  child: Transform.translate(
                    offset: Offset(outDx, 0),
                    child: current,
                  ),
                ),
                Opacity(
                  opacity: inOp,
                  child: Transform.translate(
                    offset: Offset(inDx, 0),
                    child: next,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  double _fadeOutStagger(double s) {
    final g = (s / kFadeOutFinish).clamp(0.0, 1.0);
    return (1.0 - Curves.easeIn.transform(g)).clamp(0.0, 1.0);
  }

  double _fadeInStagger(double s) {
    final g = ((s - kFadeInDelay) / (1.0 - kFadeInDelay)).clamp(0.0, 1.0);
    return Curves.easeOut.transform(g).clamp(0.0, 1.0);
  }

  /// index: 0..3 → House 1..3 (Data), House 4 (prediction)
  Widget _pageFor(int index) {
    final numbers = [1, 2, 3, 4];
    final suffixes = ["(Data)", "(Data)", "(Data)", "(prediction)"];
    final images = [
      "assets/images/house1.png",
      "assets/images/house4.png",
      "assets/images/house2.png",
      "assets/images/house3.png",
    ];

    final bool isFinal = (index == 3);
    final bool isGuessed = (_phase == _Phase.guessed);

    const String unknownTxt = "??????";
    const String guessTxt = "\$1,807,250"; // exact

    return _HouseFullCard(
      number: numbers[index],
      suffix: suffixes[index],
      imagePath:
          (index < images.length) ? images[index] : "assets/images/house3.png",
      priceValue: isFinal
          ? guessTxt
          : (index == 0
              ? "\$980,000"
              : index == 1
                  ? "\$700,000"
                  : "\$550,000"),
      isFinal: isFinal,
      isGuessed: isGuessed,
      popNumbers: CurvedAnimation(parent: _popCtrl, curve: Curves.easeOutBack),
      popFinalPrice: isFinal && isGuessed
          ? CurvedAnimation(parent: _guessPopCtrl, curve: Curves.easeOutBack)
          : null,
      reveal: isFinal
          ? CurvedAnimation(parent: _revealCtrl, curve: Curves.easeInOutCubic)
          : null,
      unknownText: unknownTxt,
    );
  }
}

class _HouseFullCard extends StatelessWidget {
  final int number;
  final String suffix;
  final String imagePath;
  final String priceValue;
  final bool isFinal;
  final bool isGuessed;

  final Animation<double> popNumbers;
  final Animation<double>? popFinalPrice;
  final Animation<double>? reveal;
  final String? unknownText;

  const _HouseFullCard({
    required this.number,
    required this.suffix,
    required this.imagePath,
    required this.priceValue,
    required this.isFinal,
    required this.isGuessed,
    required this.popNumbers,
    this.popFinalPrice,
    this.reveal,
    this.unknownText,
    super.key,
  });

  double _textWidth(String text, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    return tp.width;
  }

  @override
  Widget build(BuildContext context) {
    final popScale = Tween<double>(begin: 0.86, end: 1.0).animate(popNumbers);
    final Animation<double> pricePopScale = (popFinalPrice == null)
        ? const AlwaysStoppedAnimation(1.0)
        : Tween<double>(begin: kPopStart, end: kPopEnd).animate(popFinalPrice!);

    final labelStyle = GoogleFonts.lato(
      fontSize: 20,
      fontWeight: FontWeight.w800,
      color: titleInk,
    );
    final badgeTextStyle = GoogleFonts.lato(
      fontSize: 22,
      fontWeight: FontWeight.w900,
      color: priceGreen,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12, width: 1.2),
        boxShadow: const [
          BoxShadow(
              color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("House ",
                  style: GoogleFonts.lato(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: titleInk,
                  )),
              ScaleTransition(
                scale: popScale,
                child: Text("$number",
                    style: GoogleFonts.lato(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: houseNumRed,
                    )),
              ),
              Text(" $suffix",
                  style: GoogleFonts.lato(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: titleInk,
                  )),
            ],
          ),
          const SizedBox(height: 10),

          // Big image
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                imagePath,
                width: double.infinity,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.none,
                errorBuilder: (ctx, err, st) => Container(
                  color: const Color(0xFFF3F3F3),
                  alignment: Alignment.center,
                  child: Text("Image not found",
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        color: Colors.black54,
                        fontWeight: FontWeight.w700,
                      )),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // CENTERED Price row, constant lane width (with safety)
          LayoutBuilder(
            builder: (context, constraints) {
              final double maxW = constraints.maxWidth;
              const double spacing = 6.0;

              final double labelW = _textWidth("Price: ", labelStyle);

              final String unkText = (unknownText ?? "??????");
              final double wUnknown =
                  _textWidth(unkText, badgeTextStyle) + _kPillExtraW;
              final double wReal =
                  _textWidth(priceValue, badgeTextStyle) + _kPillExtraW;

              final double availableForLane =
                  (maxW - labelW - spacing).clamp(120.0, maxW) as double;

              // ← NEW: ceil + safety so last digit never clips
              double laneW =
                  ((wUnknown > wReal ? wUnknown : wReal) + _kLaneSafety)
                      .clamp(120.0, availableForLane) as double;

              laneW = laneW.ceilToDouble();

              return Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Price: ", style: labelStyle),
                    const SizedBox(width: spacing),
                    SizedBox(
                      width: laneW,
                      child: isFinal
                          ? _RevealablePrice(
                              isGuessed: isGuessed,
                              reveal: reveal,
                              priceText: priceValue,
                              unknownText: unkText,
                              scale: pricePopScale,
                            )
                          : _PriceBadge(text: priceValue),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Unknown → Real inside a fixed-width lane.
/// Unknown fades while sliding right with a small overshoot.
/// Final pill is a separate widget that slides in and pops.
class _RevealablePrice extends StatelessWidget {
  final bool isGuessed;
  final Animation<double>? reveal; // 0..1
  final String priceText;
  final String unknownText;
  final Animation<double> scale;

  const _RevealablePrice({
    required this.isGuessed,
    required this.reveal,
    required this.priceText,
    required this.unknownText,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final double r = ((reveal?.value) ?? 0.0).clamp(0.0, 1.0);
    final double t = Curves.easeInOutCubic.transform(r);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double laneW = constraints.maxWidth;

        final double unkX = _lerp(0.0, laneW + _kOvershoot, t);
        final double realX = _lerp(laneW + _kOvershoot, 0.0, t);

        // Fade unknown out before it reaches the edge
        final double fadeT = (t / _kFadeOutCutoff).clamp(0.0, 1.0);
        final double unkOpacity = 1.0 - Curves.easeOut.transform(fadeT);

        return SizedBox(
          height: _kLaneHeight,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            alignment: Alignment.centerLeft,
            children: [
              if (!isGuessed || r < 1.0)
                Opacity(
                  opacity: unkOpacity,
                  child: Transform.translate(
                    offset: Offset(unkX, 0),
                    child: const _PriceBadge(
                      text: "??????",
                      textColor: Colors.red,
                    ),
                  ),
                ),
              if (isGuessed || r > 0.0)
                Transform.translate(
                  offset: Offset(realX, 0),
                  child: Transform.scale(
                    alignment: Alignment.centerLeft,
                    scale:
                        1.0 + (scale.value - 1.0) * Curves.easeOut.transform(t),
                    child: _PriceBadge(text: priceText),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;
}

/// Simple pill (fixed height + centered text).
class _PriceBadge extends StatelessWidget {
  final String text;
  final bool emphasize;
  final bool dim;
  final Animation<double>? scale; // kept for compatibility
  final Color? textColor;
  const _PriceBadge({
    required this.text,
    this.emphasize = true,
    this.dim = false,
    this.scale,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final pill = RepaintBoundary(
      child: Container(
        height: _kPillHeight,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: _kPillPadH),
        decoration: BoxDecoration(
          color: priceBadgeBg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: priceBadgeBorder,
            width: emphasize ? _kPillBorder : 1.2,
          ),
        ),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.clip,
          softWrap: false,
          style: GoogleFonts.lato(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: textColor ?? (dim ? Colors.black54 : priceGreen),
            height: 1.0,
          ),
        ),
      ),
    );

    return scale == null
        ? pill
        : Align(
            alignment: Alignment.centerLeft,
            child: ScaleTransition(scale: scale!, child: pill),
          );
  }
}

/// Helpers
double _clamp01(double x) => x < 0 ? 0 : (x > 1 ? 1 : x);
