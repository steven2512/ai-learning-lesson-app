import 'package:adv_basics/questions_summary.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:adv_basics/data/questions.dart';

class ResultScreen extends StatelessWidget {
  final List<String> userAnswers;
  const ResultScreen({required this.userAnswers, super.key});

  List<Map<String, Object>> getSummary() {
    final List<Map<String, Object>> summary = [];
    for (var i = 0; i < userAnswers.length; i++) {
      summary.add({
        'index': i,
        'question': questions[i].question,
        'correct': questions[i].answers[0],
        'user_answer': userAnswers[i],
      });
    }
    return summary;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You answerd X out of Y questions correctly!',
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            QuestionSummary(summary: getSummary()),
            SizedBox(height: 10),
            Text(
              'Lessons 1 Review',
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color.fromARGB(255, 255, 230, 0),
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {},

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20, // left/right padding
                  vertical: 0, // top/bottom padding
                ),
              ),
              child: Text('Restart Quiz'),
            ),
          ],
        ),
      ),
    );
  }
}
