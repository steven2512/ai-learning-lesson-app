// bird.dart
import 'package:flame/components.dart';
import 'package:running_robot/my_game.dart';

class DuckObstacle extends SpriteAnimationComponent {
  final Vector2 initialPosition;
  GamePhase gamePhase;
  bool isPaused = false;
  Vector2 velocity = Vector2(-250, 0); // fly left

  DuckObstacle({
    required this.initialPosition,
    required this.gamePhase,
  }) : super(
         position: initialPosition.clone(),
         size: Vector2.all(60), // scale up from 21×21
         anchor: Anchor.center,
       );

  @override
  Future<void> onLoad() async {
    // Load the four frames in order
    final frames = await Future.wait([
      Sprite.load('bird1.png'),
      Sprite.load('bird2.png'),
      Sprite.load('bird3.png'),
      Sprite.load('bird4.png'),
    ]);

    animation = SpriteAnimation.spriteList(
      frames,
      stepTime: 0.14, // flap speed (seconds per frame)
      loop: true,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    //intro -everything freezes
    if (gamePhase == GamePhase.intro) return;

    if (isPaused) return;

    position += velocity * dt; // constant leftward motion

    // recycle bird when it leaves the screen
    if (position.x < -size.x) {
      position
        ..x = initialPosition.x
        ..y = initialPosition.y;
    }
  }
}
