import 'package:adv_basics/answer_button.dart';
import 'package:adv_basics/models/question_quiz.dart';
import 'package:flutter/material.dart';
import 'package:adv_basics/data/questions.dart';
import 'package:google_fonts/google_fonts.dart';

class QuestionScreen extends StatefulWidget {
  final void Function(String answer) storeAnswer;

  const QuestionScreen({super.key, required this.storeAnswer});

  @override
  State<QuestionScreen> createState() {
    return _QuestionScreenState();
  }
}

class _QuestionScreenState extends State<QuestionScreen> {
  var currentQuestionIndex = 0;

  void switchQuestion(String userAnswer) {
    //store User's Answer when move on to next question
    widget.storeAnswer(userAnswer);
    setState(() {
      currentQuestionIndex++;
    });
  }

  TextStyle qStyle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 20,
    height: 1.3,
  );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            //Question
            Text(
              questions[currentQuestionIndex].question,
              style: GoogleFonts.lato(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.2,
                color: Colors.white,
              ),

              textAlign: TextAlign.center,
            ),

            //Empty space
            SizedBox(
              height: 10,
            ),

            //Answers
            ...questions[currentQuestionIndex].getShuffledAnswers().map(
              (item) => AnswerButton(
                text: item,
                onTap: () {
                  switchQuestion(item);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
