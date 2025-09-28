// lib/auth/back_button_universal.dart
import 'package:flutter/material.dart';

class BackButtonUniversal extends StatelessWidget {
  final double top;
  final double left;
  final Color color;
  final double size;

  const BackButtonUniversal({
    super.key,
    this.top = 40,
    this.left = 10,
    this.color = Colors.black,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      child: IconButton(
        icon: Icon(Icons.arrow_back, size: size, color: color),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }
}
