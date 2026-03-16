import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:running_robot/game/events/event_type.dart';
import 'package:running_robot/game/obstacles/superclass/animated_mover.dart';

class Bird extends AnimatedMover with CollisionCallbacks {
  EventHorizontalObstacle currentEvent = EventHorizontalObstacle.stopMoving;
  @override
  Future<void> onLoad() async {
    // TODO: implement onLoad
    super.onLoad();
    add(RectangleHitbox()..collisionType = CollisionType.active);
  }

  Bird({
    required List<String> framePaths,
    required Vector2 startPosition,
    required Vector2 endPosition,
    required Vector2 velocity,
    required Vector2 customSize,
    double stepTime = 0.25,
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

  void switchPhase(EventHorizontalObstacle phase) {
    switch (phase) {
      case EventHorizontalObstacle.stopMoving:
        stop();
        break;
      case EventHorizontalObstacle.startMoving:
        move();
        break;
    }
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

  void reset() {
    // Back to initial state
    currentEvent = EventHorizontalObstacle.stopMoving;

    // Return to start position (clone to avoid aliasing)
    position = startPosition.clone();

    // Optional sanity resets
    angle = 0.0;
    scale = Vector2.all(1.0);
  }
}
