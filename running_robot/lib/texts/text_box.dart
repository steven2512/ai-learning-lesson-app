// fancy_text_box.dart
// FULL FILE — implements smooth hide() fade-out
// CHANGES:
// - ✨ ADDED: _fadeEffect ref + _startFade() helper to avoid stacking effects
// - ✨ ADDED: hideText() now triggers a smooth fade to 0 opacity
// - ✨ UPDATED: _fadeToNext() uses _startFade() (cancels any running fade first)
// - 🛠️ FIXED: render() had an extra save() without a matching restore()

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/events/event_type.dart';

class FancyTextBox extends TextBoxComponent implements OpacityProvider {
  final List<String> sequence;
  final double interval;
  final double fadeDuration;
  int currentIndex = 0;
  double timer = 0.0;

  // Opacity logic
  double _opacity = 1.0;
  @override
  double get opacity => _opacity;
  @override
  set opacity(double value) => _opacity = value.clamp(0.0, 1.0);

  // ✨ ADDED: keep a handle to the active opacity effect so we can cancel/replace cleanly
  OpacityEffect? _fadeEffect; // <<< ADDED

  EventText currentEvent = EventText.hideText;

  FancyTextBox({
    required Vector2 position,
    required Anchor anchor,
    required this.sequence,
    required this.interval,
    required this.fadeDuration,
    required double fontSize,
    required double letterSpacing,
    required FontWeight fontWeight,
    required double maxWidth,
  }) : super(
         align: anchor,
         anchor: anchor,
         text: sequence[0],
         position: position,
         boxConfig: TextBoxConfig(
           maxWidth: maxWidth,
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

  // ───── Phase Dispatcher ─────
  void switchPhase(EventText phase) {
    switch (phase) {
      case EventText.showText:
        showText();
        break;
      case EventText.hideText:
        hideText(); // <<< CHANGED: call smooth fade
        break;
      case EventText.nextSequence:
        // internal use only
        break;
    }
  }

  // ───── Public Controls ─────
  void showText() {
    // If coming from hidden state, ensure we start counting again
    currentEvent = EventText.showText;
    // Optional: if you also want a fade-in when showing from hidden, uncomment:
    // if (opacity < 1.0) _startFade(1.0, fadeDuration);
  }

  void hideText() {
    // ✨ Smoothly fade to 0 and then stay hidden (no auto-resume)
    currentEvent = EventText.hideText;
    timer = 0; // stop auto-advance timing while hidden
    _startFade(0.0, fadeDuration); // <<< ADDED
  }

  // ✨ ADDED: centralize fade handling and avoid stacking multiple effects
  void _startFade(double target, double duration, {VoidCallback? onComplete}) {
    // <<< ADDED
    _fadeEffect?.removeFromParent(); // cancel any running fade
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

  // ───── Frame Updates ─────
  @override
  void update(double dt) {
    super.update(dt);

    switch (currentEvent) {
      case EventText.showText:
        timer += dt;
        if (timer >= interval && currentIndex < sequence.length - 1) {
          timer = 0;
          currentEvent = EventText.nextSequence;
        }
        break;

      case EventText.nextSequence:
        _fadeToNext();
        currentEvent = EventText.hideText;
        break;

      case EventText.hideText:
        // idle while hidden (fade handled by effect)
        break;
    }
  }

  // ───── Transition Effects ─────
  void _fadeToNext() {
    // Fade out → swap text → fade back in
    _startFade(
      0.0,
      fadeDuration,
      onComplete: () {
        // <<< CHANGED: use helper
        opacity = 0; // Force-set to fully invisible before changing text
        currentIndex++;
        text = sequence[currentIndex];

        _startFade(
          1.0,
          fadeDuration,
          onComplete: () {
            // <<< CHANGED
            currentEvent = EventText.showText;
          },
        );
      },
    );
  }

  // ───── Custom Rendering ─────
  @override
  void render(Canvas canvas) {
    // 🛠️ FIXED: removed extra save(); keep saveLayer/restore balanced
    canvas.saveLayer(
      null,
      Paint()..color = Color.fromRGBO(255, 255, 255, opacity),
    );
    super.render(canvas);
    canvas.restore();
  }

  // ───── Optional Manual Resets ─────
  void resetText() {
    currentIndex = 0;
    text = sequence[0];
    timer = 0;
    opacity = 1;
    _fadeEffect?.removeFromParent(); // <<< ADDED
    _fadeEffect = null; // <<< ADDED
    currentEvent = EventText.showText;
  }

  void skipToEnd() {
    currentIndex = sequence.length - 1;
    text = sequence.last;
    _fadeEffect?.removeFromParent(); // <<< ADDED
    _fadeEffect = null; // <<< ADDED
    currentEvent = EventText.showText;
  }
}
