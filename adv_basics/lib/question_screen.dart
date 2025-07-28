import 'package:adv_basics/answer_button.dart';
import 'package:adv_basics/models/question_quiz.dart';
import 'package:flutter/material.dart';
import 'package:adv_basics/data/questions.dart';

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({super.key});

  @override
  State<QuestionScreen> createState() {
    return _QuestionScreenState();
  }
}

class _QuestionScreenState extends State<QuestionScreen> {
  var currentQuestionIndex = 0;

  void switchQuestion() {
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
            Text(
              questions[currentQuestionIndex].question,
              style: qStyle,
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 10,
            ),
            ...questions[currentQuestionIndex].getShuffledAnswers().map(
              (item) => AnswerButton(
                text: item,
                onTap: () {
                  switchQuestion();
                }, // <--- must explicitly name it
              ),
            ),
          ],
        ),
      ),
    );
  }
}
