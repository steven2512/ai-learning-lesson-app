import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:running_robot/my_game.dart';

class DrawnMover extends PositionComponent with HasGameRef<MyGame> {
  final Vector2 startPosition;
  final Vector2 endPosition;
  final Vector2 velocity;
  final Vector2 customSize;

  final void Function(Canvas canvas, Size size)? customDraw;

  DrawnMover({
    required this.startPosition,
    required this.endPosition,
    required this.velocity,
    required this.customSize,
    this.customDraw,
  }) : super(
         position: startPosition.clone(),
         size: customSize,
         anchor: Anchor.center,
       );

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (customDraw != null) {
      customDraw!(canvas, size.toSize());
    } else {
      final paint = Paint()..color = const Color(0xFF2196F3);
      canvas.drawRect(size.toRect(), paint);
    }
  }

  void resetPosition() {
    position.setFrom(startPosition);
  }
}
