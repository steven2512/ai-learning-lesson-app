import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const double maxTextWidth = 350;

class LessonStepThree extends StatefulWidget {
  final ValueNotifier<bool>? answeredNotifier; // ✅ notifier

  const LessonStepThree({super.key, this.answeredNotifier});

  @override
  State<LessonStepThree> createState() => _LessonStepThreeState();
}

class _LessonStepThreeState extends State<LessonStepThree> {
  String? dogRowSelection;
  String? catRowSelection;
  bool triedWrong = false; // track wrong attempt

  void _checkAnswers() {
    if (dogRowSelection != null && catRowSelection != null) {
      if (dogRowSelection == "dog" && catRowSelection == "cat") {
        widget.answeredNotifier?.value = true;
        triedWrong = false;
      } else {
        widget.answeredNotifier?.value = false;
        triedWrong = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Table container
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black26, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: Text(
                        "Match the data to the label",
                        style: GoogleFonts.lato(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  Table(
                    border: const TableBorder.symmetric(
                      inside: BorderSide(color: Colors.black12, width: 1),
                    ),
                    columnWidths: const {
                      0: FixedColumnWidth(120),
                      1: FlexColumnWidth(),
                      2: FlexColumnWidth(),
                    },
                    children: [
                      TableRow(
                        decoration: BoxDecoration(color: Colors.grey.shade100),
                        children: [
                          _tableCell("Data / Label", bold: true),
                          _tableCell("Dog", color: Colors.green, bold: true),
                          _tableCell("Cat", color: Colors.red, bold: true),
                        ],
                      ),
                      TableRow(children: [
                        _imageCell('assets/images/dog1.png'),
                        _iconCell(
                          selected: dogRowSelection == "dog",
                          onTap: () => setState(
                              () => {dogRowSelection = "dog", _checkAnswers()}),
                        ),
                        _iconCell(
                          selected: dogRowSelection == "cat",
                          onTap: () => setState(
                              () => {dogRowSelection = "cat", _checkAnswers()}),
                        ),
                      ]),
                      TableRow(children: [
                        _imageCell('assets/images/cat1.jpg'),
                        _iconCell(
                          selected: catRowSelection == "dog",
                          onTap: () => setState(
                              () => {catRowSelection = "dog", _checkAnswers()}),
                        ),
                        _iconCell(
                          selected: catRowSelection == "cat",
                          onTap: () => setState(
                              () => {catRowSelection = "cat", _checkAnswers()}),
                        ),
                      ]),
                    ],
                  ),
                ],
              ),
            ),

            // ✅ Try Again message
            if (triedWrong)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200, width: 1),
                ),
                child: Text(
                  "Try Again!",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade700,
                  ),
                ),
              ),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  // helpers
  static Widget _tableCell(String text,
      {Color color = Colors.black87, bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Text(
          text,
          style: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
            color: color,
          ),
        ),
      ),
    );
  }

  static Widget _imageCell(String assetPath, {double height = 140}) {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(6.0),
      child: SizedBox(
        height: height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            assetPath,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  static Widget _iconCell(
      {required bool selected, required VoidCallback onTap}) {
    return Center(
      child: IconButton(
        onPressed: onTap,
        icon: Icon(
          selected ? Icons.check_circle : Icons.radio_button_unchecked,
          color: selected ? Colors.green : Colors.black26,
          size: 40,
        ),
      ),
    );
  }
}
