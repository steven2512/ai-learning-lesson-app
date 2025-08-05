import 'dart:math';
import 'package:flame/components.dart';
import 'package:running_robot/obstacles/fall_obstacle.dart';
import 'package:running_robot/my_game.dart';

class Rain extends FallObstacle {
  Rain({
    required Vector2 initialPosition,
    required double topY,
  }) : super(
         initialPosition: initialPosition,
         topY: topY,
       );

  @override
  void update(double dt) {
    super.update(dt); // Optional: keep fall behavior from FallObstacle

    // Add any custom Rain behavior here
    // e.g. change color, spawn particles, check event type, etc.
  }

  /// Static method to generate a list of Rain objects
  static List<Rain> generateRain({
    required Vector2 screenSize,
    required double topY,
    int count = 20,
  }) {
    final List<Rain> obstacles = [];

    final double rainAreaWidth = screenSize.x / 3;
    final double rainStartX = (screenSize.x - rainAreaWidth) / 2;
    final double rainStartY = 270;

    for (int i = 0; i < count; i++) {
      final double x = rainStartX + Random().nextDouble() * rainAreaWidth;
      final rain = Rain(
        initialPosition: Vector2(x, rainStartY),
        topY: topY,
      );
      obstacles.add(rain);
    }

    return obstacles;
  }
}
