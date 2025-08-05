import 'dart:math';
import 'package:flame/components.dart';
import 'package:running_robot/obstacles/fall_obstacle.dart';
import 'package:running_robot/my_game.dart';

class RainSpawner {
  static List<FallObstacle> generateRain({
    required Vector2 screenSize,
    required double topY,
    required GamePhase phase,
    int count = 20,
  }) {
    final List<FallObstacle> obstacles = [];

    final double rainAreaWidth = screenSize.x / 3;
    final double rainStartX = (screenSize.x - rainAreaWidth) / 2;
    final double rainStartY = 270; // << Start just below the cloud

    for (int i = 0; i < count; i++) {
      final double x = rainStartX + Random().nextDouble() * rainAreaWidth;
      final rain = FallObstacle(
        initialPosition: Vector2(x, rainStartY),
        topY: topY,
        gamePhase: phase,
      );
      obstacles.add(rain);
    }

    return obstacles;
  }
}
