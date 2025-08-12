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

  // Background options
  final Color? boxFill;
  final double boxRadius;
  final double boxFillOpacity;
  final Vector2? boxSize; // when provided, center text inside this area

  // Text & padding
  final Color textColor;
  final List<double>? boxPadding; // [top, right, bottom, left]

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

    // Visuals
    this.boxFill,
    this.boxRadius = 0.0,
    this.boxFillOpacity = 1.0,
    this.boxSize,
    this.textColor = Colors.black,
    this.boxPadding,
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
       assert(
         boxFillOpacity >= 0.0 && boxFillOpacity <= 1.0,
         '`boxFillOpacity` must be between 0 and 1',
       ),
       assert(
         boxPadding == null ||
             (boxPadding.length == 4 && boxPadding.every((v) => v >= 0)),
         '`boxPadding` must be 4 non-negative doubles: [top, right, bottom, left]',
       ),
       super(
         align: anchor,
         anchor: anchor,
         text: sequence[0],
         position: position,
         boxConfig: TextBoxConfig(
           maxWidth: (boxSize != null ? boxSize.x : maxWidth),
           timePerChar: 0.0,
         ),
         textRenderer: TextPaint(
           style: GoogleFonts.lato(
             fontSize: fontSize,
             letterSpacing: letterSpacing,
             color: textColor,
             fontWeight: fontWeight,
           ),
         ),
       );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    if (boxSize != null) {
      size = boxSize!;
    }
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
      _startFade(1.0, fadeDuration, onComplete: () => _hasShownCurrent = true);
    }
  }

  void hideText() {
    // FIX: cancel any pending show-after-gap that would re-fade-in
    _waitingGap = false; // FIX
    _hasShownCurrent = false; // FIX

    currentEvent = EventText.hideText;
    timer = 0;

    // FIX: ensure we land exactly at 0.0
    _startFade(
      0.0,
      fadeDuration,
      onComplete: () {
        opacity = 0.0; // FIX
      },
    );
  }

  void _startFade(double target, double duration, {VoidCallback? onComplete}) {
    _fadeEffect?.removeFromParent();
    final fx = OpacityEffect.to(
      target,
      EffectController(duration: duration),
      onComplete: () {
        _fadeEffect = null;
        // FIX: snap to target to avoid residual alpha (e.g., 0.0001 keeping text visible)
        opacity = target; // FIX
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
        opacity = 0.0; // FIX: exact zero after step fade
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
    // FIX: if fully transparent, skip drawing entirely
    if (opacity <= 0.001) {
      // FIX
      return;
    }

    // Padding unpack (top, right, bottom, left)
    final double pt = boxPadding != null ? boxPadding![0] : 0.0;
    final double pr = boxPadding != null ? boxPadding![1] : 0.0;
    final double pb = boxPadding != null ? boxPadding![2] : 0.0;
    final double pl = boxPadding != null ? boxPadding![3] : 0.0;

    // Inner text area
    final double innerW = (boxSize?.x ?? size.x);
    final double innerH = (boxSize?.y ?? size.y);

    // Background expands by padding
    final double w = innerW + pl + pr;
    final double h = innerH + pt + pb;

    // Group alpha so background + text fade together
    final Rect layerBounds = Rect.fromLTWH(-pl, -pt, w, h);
    canvas.saveLayer(
      layerBounds,
      Paint()..color = const Color(0xFFFFFFFF).withOpacity(opacity),
    );

    // Background (optional)
    if (boxFill != null && boxFillOpacity > 0.0) {
      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(-pl, -pt, w, h),
        Radius.circular(boxRadius),
      );
      final combinedAlpha = (boxFill!.opacity * boxFillOpacity).clamp(0.0, 1.0);
      final fillColor = boxFill!.withOpacity(combinedAlpha);
      canvas.drawRRect(rrect, Paint()..color = fillColor);
    }

    // ---- TEXT RENDERING ----
    if (boxSize == null) {
      // Legacy behavior (left/top aligned by TextBoxComponent)
      super.render(canvas);
    } else {
      // Center horizontally & vertically within inner box, respecting padding.
      final style = (textRenderer as TextPaint).style;
      final painter = TextPainter(
        text: TextSpan(text: text, style: style),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      painter.layout(maxWidth: innerW);

      final double contentH = painter.height;
      final double dy = ((innerH - contentH) * 0.5).clamp(0.0, double.infinity);

      canvas.save();
      // Clip to inner area so long text doesn't bleed into padding/background
      canvas.clipRect(Rect.fromLTWH(0, 0, innerW, innerH));
      canvas.translate(0, dy);
      // Paint at (0, 0); TextAlign.center + maxWidth=innerW centers horizontally.
      painter.paint(canvas, const Offset(0, 0));
      canvas.restore();
    }

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

  void reset() {
    // Back to initial hidden state & first entry
    currentEvent = EventText.hideText;

    _fadeEffect?.removeFromParent();
    _fadeEffect = null;

    currentIndex = 0;
    text = sequence[0];
    timer = 0.0;

    _waitingGap = false;
    _hasShownCurrent = false;

    opacity = 0.0;
  }
}
