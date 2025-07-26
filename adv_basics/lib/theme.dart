import 'package:adv_basics/question_screen.dart';
import 'package:flutter/material.dart';

final backgroundImage = Image.asset(
  'assets/images/quiz-logo.png',
  width: 250,
  color: const Color.fromARGB(200, 255, 255, 255),
);
final color1 = Colors.purple;
final mainMessage = Text(
  'Learn FLutter the fun way!',
  style: TextStyle(color: Colors.white, fontSize: 25),
);
final mediumBox = SizedBox(height: 50);
final smallBox = SizedBox(height: 20);

class MainTheme extends StatelessWidget {
  const MainTheme({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple, Colors.blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            backgroundImage,
            mediumBox,
            mainMessage,
            smallBox,
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(QuestionScreen()),
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
              ),
              icon: Icon(Icons.arrow_right_alt),
              label: Text(
                'Start Quiz',
              ),
            ),
            SizedBox(height: 200),
          ],
        ),
      ),
    );
  }
}
