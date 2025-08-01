import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:running_robot/my_game.dart';

void main() {
  runApp(
    GameWidget(
      game: MyGame(),
    ),
  );
}
