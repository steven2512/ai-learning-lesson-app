import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuestionSummary extends StatelessWidget {
  QuestionSummary({required this.summary, super.key});
  final TextStyle questionStyle = GoogleFonts.lato(
    fontSize: 14,
    fontWeight: FontWeight.w900,
    letterSpacing: 0.1,
    color: Colors.white,
    height: 1.2,
  );

  final TextStyle userAnswerStyle = GoogleFonts.lato(
    fontSize: 14,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.1,
    color: const Color.fromARGB(255, 255, 238, 0),
  );

  final TextStyle correctAnswerStyle = GoogleFonts.lato(
    fontSize: 14,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.2,
    color: const Color.fromARGB(255, 0, 255, 157),
  );

  final TextStyle indexStyle = GoogleFonts.lato(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    color: const Color.fromARGB(255, 0, 0, 0),
  );

  final List<Map<String, Object>> summary;

  Color getCorrectColor(int index) {
    return ((summary[index]['correct'] as String) ==
            (summary[index]['user_answer'] as String))
        ? Color.fromARGB(255, 51, 255, 0)
        : Color.fromARGB(255, 211, 202, 202);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      //Forced to fit big content into SMALL space to use Scrollbar
      height: 300,
      //Scrollbar
      child: Scrollbar(
        thumbVisibility: false, // set false to auto-hide like iOS
        trackVisibility: false,
        thickness: 2.5,
        radius: const Radius.circular(8),
        interactive: true,
        child: SingleChildScrollView(
          //Main Column
          child: Column(
            spacing: 3,
            children: summary.map((x) {
              //Rows within the Main column
              return Container(
                padding: EdgeInsetsGeometry.only(right: 30),
                //Rows components
                child: Row(
                  children: [
                    Container(
                      margin: EdgeInsetsGeometry.only(bottom: 50, right: 15),
                      padding: EdgeInsetsGeometry.symmetric(
                        vertical: 10,
                        horizontal: 10,
                      ),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: getCorrectColor(x['index'] as int),
                      ),
                      child: Text(
                        ((x['index'] as int) + 1).toString(),
                        style: indexStyle,
                      ),
                    ),
                    //Column within a Row within a Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        //Question + user answer + correct answer
                        children: [
                          Text(
                            (x['question'] as String),
                            style: questionStyle,
                          ),
                          SizedBox(height: 5),
                          Text(
                            (x['user_answer'] as String),
                            style: userAnswerStyle,
                          ),
                          Text(
                            (x['correct'] as String),
                            style: correctAnswerStyle,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
