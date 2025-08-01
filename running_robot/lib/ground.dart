import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Ground extends RectangleComponent {
  Vector2 dimensions;
  Ground({required this.dimensions})
    : super(
        position: Vector2(dimensions.x / 2, dimensions.y / 2 + 50),
        size: Vector2(dimensions.x, 3),
        paint: Paint()..color = const Color.fromARGB(255, 197, 224, 255),
        anchor: Anchor.center,
      );
}
