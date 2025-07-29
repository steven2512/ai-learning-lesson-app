import 'package:flutter/material.dart';

class QuestionSummary extends StatelessWidget {
  const QuestionSummary({required this.summary, super.key});

  final List<Map<String, Object>> summary;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: summary.map((x) {
        return Row(
          children: [
            Text(((x['index'] as int) + 1).toString()),
            Column(
              children: [
                Text(
                  (x['question'] as String),
                ),
                SizedBox(height: 5),
                Text(
                  (x['correct'] as String),
                ),
                Text(
                  (x['user_answer'] as String),
                ),
              ],
            ),
          ],
        );
      }).toList(),
    );
  }
}
