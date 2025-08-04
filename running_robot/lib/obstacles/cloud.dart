import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class CloudComponent extends PositionComponent {
  final Color color;

  CloudComponent({
    required Vector2 position,
    this.color = const Color.fromARGB(255, 72, 0, 255),
  }) : super(
         position: position,
         size: Vector2(120, 60),
         anchor: Anchor.topLeft,
       );

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = color;

    // main body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(10, 20, size.x - 20, 30),
        const Radius.circular(20),
      ),
      paint,
    );

    // puffs
    canvas.drawCircle(const Offset(30, 30), 20, paint);
    canvas.drawCircle(const Offset(60, 20), 25, paint);
    canvas.drawCircle(const Offset(90, 30), 20, paint);
  }
}
