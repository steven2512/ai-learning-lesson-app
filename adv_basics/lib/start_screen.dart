import 'package:adv_basics/question_screen.dart';
import 'package:flutter/material.dart';

final backgroundImage = Image.asset(
  'assets/images/quiz-logo.png',
  width: 250,
  color: const Color.fromARGB(200, 255, 255, 255),
);
final color1 = Colors.purple;
final mainMessage = Text(
  'Learn AI the fun way!',
  style: TextStyle(color: Colors.white, fontSize: 25),
);

class StartScreen extends StatelessWidget {
  const StartScreen(this.startQuiz, {super.key});

  final void Function() startQuiz;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          backgroundImage,
          SizedBox(height: 50),
          mainMessage,
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: startQuiz,
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black,
            ),
            icon: Icon(Icons.arrow_right_alt),
            label: Text(
              'Start Journey',
            ),
          ),
          SizedBox(height: 200),
        ],
      ),
    );
  }
}
