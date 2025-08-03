import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MainText extends TextBoxComponent implements OpacityProvider {
  final Vector2 dimensions;
  final List<String> sequence;

  int currentIndex = 0;
  double timer = 0.0;

  /// Time between switching to next text
  final double interval = 5.0;

  /// Duration (seconds) for fade out/in animations
  final double fadeDuration = 0.5;

  // Backing field for OpacityProvider
  double _opacity = 1.0;
  @override
  double get opacity => _opacity;
  @override
  set opacity(double value) => _opacity = value.clamp(0.0, 1.0);

  MainText({
    required this.dimensions,
    required this.sequence,
  }) : super(
         align: Anchor.center,
         text: sequence[0],
         anchor: Anchor.center,
         boxConfig: const TextBoxConfig(
           maxWidth: 350,
           timePerChar: 0.0,
         ),
         position: Vector2.zero(),
         textRenderer: TextPaint(
           style: GoogleFonts.lato(
             fontSize: 25,
             letterSpacing: 0.5,
             color: Colors.black,
             fontWeight: FontWeight.w800,
           ),
         ),
       ) {
    position = Vector2(dimensions.x / 2, dimensions.y / 3.5);
  }

  void _animateToNextText() {
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
            ),
          );
        },
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    timer += dt;
    if (timer >= interval) {
      timer = 0;
      if (currentIndex < sequence.length - 1) {
        _animateToNextText();
      }
    }
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
}
