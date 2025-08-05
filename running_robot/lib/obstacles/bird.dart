import 'package:flame/components.dart';
import 'package:running_robot/Events/event_type.dart';
import 'package:running_robot/obstacles/superclass/animated_mover.dart';

class Bird extends AnimatedMover {
  String currentEvent = EventHorizontalObstacle.stopMoving;

  Bird({
    required List<String> framePaths,
    required Vector2 startPosition,
    required Vector2 endPosition,
    required Vector2 velocity,
    required Vector2 customSize,
    double stepTime = 0.12,
  }) : super(
         framePaths: framePaths,
         startPosition: startPosition,
         endPosition: endPosition,
         velocity: velocity,
         customSize: customSize,
         stepTime: stepTime,
       );

  void move() {
    currentEvent = EventHorizontalObstacle.startMoving;
  }

  void stop() {
    currentEvent = EventHorizontalObstacle.stopMoving;
  }

  @override
  void update(double dt) {
    updateAnimation(dt);

    switch (currentEvent) {
      case EventHorizontalObstacle.startMoving:
        updateMovement(dt);
        break;

      case EventHorizontalObstacle.stopMoving:
    }
  }
}
