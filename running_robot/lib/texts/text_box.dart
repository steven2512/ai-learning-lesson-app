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

  Enum currentEvent = EventText.showText;

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
        currentEvent = EventText.hideText; // temporarily pause updates
        break;

      case EventText.hideText:
        // waiting for fade effect to finish
        break;
    }
  }

  void _fadeToNext() {
    add(
      OpacityEffect.to(
        0,
        EffectController(duration: fadeDuration),
        onComplete: () {
          currentIndex++;
          text = sequence[currentIndex];
          add(
            OpacityEffect.to(
              1,
              EffectController(duration: fadeDuration),
              onComplete: () {
                currentEvent = EventText.showText;
              },
            ),
          );
        },
      ),
    );
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.saveLayer(
      null,
      Paint()..color = Color.fromRGBO(255, 255, 255, opacity),
    );
    super.render(canvas);
    canvas.restore();
  }

  /// Optional manual controls
  void resetText() {
    currentIndex = 0;
    text = sequence[0];
    timer = 0;
    opacity = 1;
    currentEvent = EventText.showText;
  }

  void skipToEnd() {
    currentIndex = sequence.length - 1;
    text = sequence.last;
    currentEvent = EventText.showText;
  }
}
