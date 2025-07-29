import 'package:adv_basics/question_screen.dart';
import 'package:adv_basics/questions_summary.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:adv_basics/data/questions.dart';

class ResultScreen extends StatelessWidget {
  final List<String> userAnswers;
  const ResultScreen({
    required this.userAnswers,
    required this.restartQuiz,
    super.key,
  });
  final void Function() restartQuiz;

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
              'You answered ${userAnswers.asMap().entries.fold(0, (acc, entry) => entry.value == questions[entry.key].answers[0] ? acc + 1 : acc)} out of ${questions.length} questions correctly!',
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 21,
                height: 1.2,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'Lessons 1 Review',
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 25,
                fontWeight: FontWeight.w900,
                color: const Color.fromARGB(255, 255, 230, 0),
              ),
            ),
            SizedBox(height: 2),
            QuestionSummary(summary: getSummary()),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                restartQuiz();
              },

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
