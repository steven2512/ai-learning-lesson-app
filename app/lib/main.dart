import 'package:flutter/material.dart';
import 'package:app/gradient_container.dart';

const color1 = Color(0xFFEFF4FA);
const color2 = Color.fromARGB(255, 234, 243, 255);
var colors = [color1, color2];

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(body: GradientContainer(colors)),
    ),
  );
}
