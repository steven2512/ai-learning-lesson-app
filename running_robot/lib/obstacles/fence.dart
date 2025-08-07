import 'dart:async';
import 'package:flame/components.dart';
import 'package:running_robot/obstacles/superclass/simple_mover.dart';
import 'package:running_robot/events/event_type.dart';

class Fence extends SimpleMover {
  EventHorizontalObstacle currentEvent = EventHorizontalObstacle.stopMoving;

  final Vector2 velocity;
  final double resetXThreshold = -50;
  bool isPaused = false;

  Fence({
    required super.initialPosition,
    required super.picturePath,
    required super.size,
    required this.velocity,
  });

  @override
  Future<void> onLoad() async {
    super.onLoad();

    void move() {
      currentEvent = EventHorizontalObstacle.startMoving;
    }

    void stop() {
      currentEvent = EventHorizontalObstacle.stopMoving;
    }

    void switchPhase(EventHorizontalObstacle phase) {
      switch (phase) {
        case EventHorizontalObstacle.stopMoving:
          stop();
        case EventHorizontalObstacle.startMoving:
          move();
      }
      ;
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
}
