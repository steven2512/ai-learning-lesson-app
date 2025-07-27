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
  QuizQuestion currentQuestion = questions[0];

  TextStyle qStyle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(currentQuestion.question, style: qStyle),
          SizedBox(
            height: 10,
          ),
          ...currentQuestion.answers.map(
            (item) => AnswerButton(
              text: item,
              onTap: () {}, // <--- must explicitly name it
            ),
          ),
        ],
      ),
    );
  }
}
