import 'package:flutter/material.dart';

final backgroundImage = Image.asset(
  'assets/images/quiz-logo.png',
  width: 250,
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
            ElevatedButton(
              onPressed: () {},
              child: Text(
                'Start Quiz',
                style: TextStyle(color: Colors.black),
              ),
            ),
            SizedBox(height: 200),
          ],
        ),
      ),
    );
  }
}
