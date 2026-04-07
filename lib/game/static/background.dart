import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Background extends RectangleComponent {
  final Vector2 backgroundSize;
  final List<Color> colors;

  static List<Color> _resolveColors(List<Color>? input) {
    if (input == null || input.isEmpty)
      return const [Colors.white, Colors.white];
    if (input.length == 1) return [input[0], input[0]];
    return input;
  }

  Background({
    required this.backgroundSize,
    List<Color>? colors,
  })  : colors = _resolveColors(colors),
        super(
          size: backgroundSize,
          paint: Paint()
            ..shader = LinearGradient(
              colors: _resolveColors(colors),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(
              Rect.fromLTWH(0, 0, backgroundSize.x, backgroundSize.y),
            ),
        );
}
