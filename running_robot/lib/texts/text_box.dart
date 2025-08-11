import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/events/event_type.dart';

class FancyTextBox extends TextBoxComponent implements OpacityProvider {
  final List<String> sequence;

  // Global visible duration fallback (legacy).
  final double? interval;

  // Per-item visible durations.
  final List<double>? durations;

  // Per-item gaps BEFORE showing each entry.
  final List<double>? intervals;

  final double fadeDuration;
  int currentIndex = 0;
  double timer = 0.0;

  bool _waitingGap = false;
  bool _hasShownCurrent = false;

  static const double _kDefaultDuration = 2.0;

  double _opacity = 1.0;
  @override
  double get opacity => _opacity;
  @override
  set opacity(double value) => _opacity = value.clamp(0.0, 1.0);

  OpacityEffect? _fadeEffect;

  EventText currentEvent = EventText.hideText;

  FancyTextBox({
    required Vector2 position,
    required Anchor anchor,
    required this.sequence,
    this.interval,
    required this.fadeDuration,
    this.durations,
    this.intervals,
    required double fontSize,
    required double letterSpacing,
    required FontWeight fontWeight,
    required double maxWidth,
  }) : assert(
         interval == null || interval > 0,
         '`interval` must be > 0 if provided',
       ),
       assert(
         durations == null ||
             (durations.isNotEmpty && durations.every((v) => v > 0)),
         '`durations` values must be > 0',
       ),
       assert(
         intervals == null || intervals.every((v) => v >= 0),
         '`intervals` (gaps) must be >= 0',
       ),
       super(
         align: anchor,
         anchor: anchor,
         text: sequence[0],
         position: position,
         // FIX: use the real maxWidth from the start; no placeholder/override
         boxConfig: TextBoxConfig(
           // <-- FIX
           maxWidth: maxWidth, // <-- FIX
           timePerChar: 0.0,
         ),
         textRenderer: TextPaint(
           style: GoogleFonts.lato(
             fontSize: fontSize,
             letterSpacing: letterSpacing,
             color: Colors.black,
             fontWeight: fontWeight,
           ),
         ),
       );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    if (currentEvent == EventText.hideText) {
      opacity = 0.0;
    }
  }

  void switchPhase(EventText phase) {
    switch (phase) {
      case EventText.showText:
        showText();
        break;
      case EventText.hideText:
        hideText();
        break;
      case EventText.nextSequence:
        break;
    }
  }

  void showText() {
    currentEvent = EventText.showText;

    final gap = _currentGap();
    if (opacity < 1.0 && gap > 0 && !_hasShownCurrent) {
      _fadeEffect?.removeFromParent();
      _waitingGap = true;
      timer = 0;
      return;
    }

    if (opacity < 1.0) {
      _startFade(
        1.0,
        fadeDuration,
        onComplete: () {
          _hasShownCurrent = true;
        },
      );
    }
  }

  void hideText() {
    currentEvent = EventText.hideText;
    timer = 0;
    _startFade(0.0, fadeDuration);
  }

  void _startFade(double target, double duration, {VoidCallback? onComplete}) {
    _fadeEffect?.removeFromParent();
    final fx = OpacityEffect.to(
      target,
      EffectController(duration: duration),
      onComplete: () {
        _fadeEffect = null;
        onComplete?.call();
      },
    );
    _fadeEffect = fx;
    add(fx);
  }

  double _currentDuration() {
    final d = durations;
    if (d != null && d.isNotEmpty) {
      if (currentIndex < d.length) return d[currentIndex];
      return d.last;
    }
    if (interval != null) return interval!;
    return _kDefaultDuration;
  }

  double _currentGap() {
    final g = intervals;
    if (g != null && g.isNotEmpty) {
      if (currentIndex < g.length) return g[currentIndex];
      return g.last;
    }
    return 0.0;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_waitingGap) {
      timer += dt;
      if (timer >= _currentGap()) {
        _waitingGap = false;
        timer = 0;
        _startFade(
          1.0,
          fadeDuration,
          onComplete: () {
            _hasShownCurrent = true;
            currentEvent = EventText.showText;
          },
        );
      }
      return;
    }

    switch (currentEvent) {
      case EventText.showText:
        timer += dt;
        if (timer >= _currentDuration() && currentIndex < sequence.length - 1) {
          timer = 0;
          currentEvent = EventText.nextSequence;
        }
        break;
      case EventText.nextSequence:
        _fadeToNext();
        currentEvent = EventText.hideText;
        break;
      case EventText.hideText:
        break;
    }
  }

  void _fadeToNext() {
    _startFade(
      0.0,
      fadeDuration,
      onComplete: () {
        opacity = 0;
        currentIndex++;
        text = sequence[currentIndex];
        timer = 0;
        _hasShownCurrent = false;

        final gap = _currentGap();
        if (gap > 0) {
          _waitingGap = true;
        } else {
          _startFade(
            1.0,
            fadeDuration,
            onComplete: () {
              _hasShownCurrent = true;
              currentEvent = EventText.showText;
            },
          );
        }
      },
    );
  }

  @override
  void render(Canvas canvas) {
    canvas.saveLayer(
      null,
      Paint()..color = Color.fromRGBO(255, 255, 255, opacity),
    );
    super.render(canvas);
    canvas.restore();
  }

  void resetText() {
    currentIndex = 0;
    text = sequence[0];
    timer = 0;
    opacity = 1;
    _waitingGap = false;
    _hasShownCurrent = true; // since opacity=1
    _fadeEffect?.removeFromParent();
    _fadeEffect = null;
    currentEvent = EventText.showText;
  }

  void skipToEnd() {
    currentIndex = sequence.length - 1;
    text = sequence.last;
    _waitingGap = false;
    _hasShownCurrent = true;
    _fadeEffect?.removeFromParent();
    _fadeEffect = null;
    currentEvent = EventText.showText;
  }
}
