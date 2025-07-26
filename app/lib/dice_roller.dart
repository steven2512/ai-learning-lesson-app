import 'package:flutter/material.dart';
import 'dart:math';

class DiceRoller extends StatefulWidget {
  const DiceRoller({super.key});

  State<DiceRoller> createState() {
    return _DiceRollerState();
  }
}

class _DiceRollerState extends State<DiceRoller> {
  var activeDice = 'assets/images/dice-1.png';
  void rollDice() {
    setState(() {
      var randomNum = Random().nextInt(5) + 1;
      activeDice = 'assets/images/dice-$randomNum.png';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          activeDice,
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
