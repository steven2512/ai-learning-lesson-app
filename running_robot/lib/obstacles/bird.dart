import 'package:flame/components.dart';
import 'package:running_robot/obstacles/superclass/animated_horizontal.dart';

class Bird extends AnimatedHorizontalObstacle {
  Bird({
    required Vector2 initialPosition,
  }) : super(
         initialPosition: initialPosition,
         framePaths: [
           'bird1.png',
           'bird2.png',
           'bird3.png',
           'bird4.png',
         ],
         customSize: Vector2.all(60), // ✅ use this not `size`
       );
}
