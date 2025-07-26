import 'package:flutter/material.dart';

class BasicTextStyle extends StatelessWidget {
  const BasicTextStyle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF1F2933),
        fontSize: 28,
      ),
    );
  }
}
