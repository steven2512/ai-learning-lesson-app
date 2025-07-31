import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    GameWidget(
      game: EmptyGame(),
    ),
  );
}

class EmptyGame extends FlameGame {
  @override
  FutureOr<void> onLoad() async {
    final square = RectangleComponent(
      size: Vector2(100, 100),
      paint: Paint()..color = const Color.fromARGB(255, 62, 167, 253),
    );

    square.position = Vector2(size.x / 2 - 50, size.y / 2 - 50);
    add(square);
  }
}
