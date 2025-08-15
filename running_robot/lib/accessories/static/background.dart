import 'package:flame/components.dart';
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
                  Color.fromARGB(255, 255, 255, 255),
                  Color.fromARGB(255, 255, 255, 255),
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
