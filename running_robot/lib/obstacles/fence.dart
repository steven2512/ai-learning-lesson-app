import 'package:flame/components.dart';
import 'package:running_robot/obstacles/superclass/horizontal.dart';
import 'package:running_robot/Events/event_type.dart';

class Fence extends HorizontalObstacle {
  String currentEvent = EventHorizontalObstacle.stopMoving;

  final Vector2 velocity;
  final double resetXThreshold = -50;
  bool isPaused = false;

  Fence({
    required super.initialPosition,
    required super.picturePath,
    required super.size,
    required this.velocity, // ✅ Now injected
  });

  void move() {
    currentEvent = EventHorizontalObstacle.startMoving;
  }

  void stop() {
    currentEvent = EventHorizontalObstacle.stopMoving;
  }

  @override
  void update(double dt) {
    super.update(dt);

    switch (currentEvent) {
      case EventHorizontalObstacle.startMoving:
        position += velocity * dt;
        if (position.x <= resetXThreshold) {
          resetPosition();
        }
        break;

      case EventHorizontalObstacle.stopMoving:
        // Do nothing
        break;
    }
  }
}
