import 'package:flame/components.dart';
import 'package:running_robot/obstacles/superclass/horizontal.dart';

class Fence extends HorizontalObstacle {
  final Vector2 velocity = Vector2(-200, 0);
  final double resetXThreshold = -50;
  bool isPaused = false;

  Fence({
    required Vector2 initialPosition,
    required String picturePath,
    required Vector2 size,
  }) : super(
         initialPosition: initialPosition,
         picturePath: picturePath,
         size: size,
       );

  @override
  void update(double dt) {
    super.update(dt);

    // if (isPaused) return;

    position += velocity * dt;

    if (position.x <= resetXThreshold) {
      resetPosition();
    }
  }
}
