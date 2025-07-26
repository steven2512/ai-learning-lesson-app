import 'package:flutter/material.dart';

const startAlignment = Alignment.topLeft;
const endAlignment = Alignment.bottomRight;

class GradientContainer extends StatelessWidget {
  const GradientContainer(this.colors, {super.key});

  final List<Color> colors;
  void rollDice() {}

  @override
  Widget build(BuildContext buildContext) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: startAlignment,
          end: endAlignment,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/dice-2.png',
              width: 150,
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
        ),
      ),
    );
  }
}
