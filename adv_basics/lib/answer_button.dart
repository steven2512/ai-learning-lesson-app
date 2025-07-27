import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AnswerButton extends StatelessWidget {
  String text;
  final void Function() onTap;

  AnswerButton({required this.text, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        textStyle: TextStyle(
          fontSize: 15,
          color: const Color.fromARGB(255, 0, 0, 0),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 40, // left/right padding
          vertical: 0, // top/bottom padding
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      ),
      child: Text(text),
    );
  }
}
