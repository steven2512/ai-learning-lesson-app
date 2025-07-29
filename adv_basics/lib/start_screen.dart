import 'package:adv_basics/question_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final backgroundImage = Image.asset(
  'assets/images/quiz-logo.png',
  width: 250,
  color: const Color.fromARGB(200, 255, 255, 255),
);
final color1 = Colors.purple;
final mainMessage = Text(
  'Learn AI the fun way!',
  style: GoogleFonts.lato(
    color: Colors.white,
    fontSize: 30,
    fontWeight: FontWeight.w700,
  ),
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
          SizedBox(height: 50),
          backgroundImage,
          SizedBox(height: 30),
          mainMessage,
          SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: startQuiz,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(100, 40),
              foregroundColor: Colors.black,
            ),
            icon: Icon(Icons.arrow_right_alt),
            label: Text(
              'Start Journey',
              style: GoogleFonts.lato(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(height: 200),
        ],
      ),
    );
  }
}
