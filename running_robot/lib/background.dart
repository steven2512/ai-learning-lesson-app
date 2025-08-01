import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class Background extends RectangleComponent {
  Vector2 backgroundSize;

  Background({required this.backgroundSize})
    : super(
        size: backgroundSize,
        paint: Paint()
          ..shader =
              LinearGradient(
                colors: [
                  Color.fromARGB(255, 0, 114, 214),
                  Color.fromARGB(255, 46, 46, 255),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(
                Rect.fromLTWH(
                  0,
                  0,
                  backgroundSize.x,
                  backgroundSize.y,
                ),
              ),
      );
}
