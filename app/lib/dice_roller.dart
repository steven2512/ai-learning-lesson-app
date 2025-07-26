import 'package:flutter/material.dart';
import 'dart:math';

final random = Random();

class DiceRoller extends StatefulWidget {
  const DiceRoller({super.key});

  State<DiceRoller> createState() {
    return _DiceRollerState();
  }
}

class _DiceRollerState extends State<DiceRoller> {
  var randomNum = 1;
  void rollDice() {
    setState(() {
      randomNum = random.nextInt(6) + 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/dice-$randomNum.png',
          width: 200,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: rollDice,
          style: TextButton.styleFrom(
            textStyle: const TextStyle(
              fontSize: 18,
            ),
            foregroundColor: Colors.black,
          ),
          child: const Text('Roll'),
        ),
      ],
    );
  }
}
