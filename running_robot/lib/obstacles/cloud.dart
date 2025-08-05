import 'package:flame/components.dart';
import 'package:running_robot/events/event_type.dart';
import 'package:running_robot/obstacles/superclass/simple_mover.dart';

class Cloud extends SimpleMover {
  EventHorizontalObstacle currentEvent = EventHorizontalObstacle.stopMoving;

  final Vector2 velocity;
  final double resetXThreshold = -50;
  bool isPaused = false;

  Cloud({
    required Vector2 initialPosition,
    required double scale,
    required this.velocity,
  }) : super(
         initialPosition: initialPosition,
         picturePath: 'cloud_grey.png',
         size: Vector2(scale * 80, scale * 50),
       );

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
