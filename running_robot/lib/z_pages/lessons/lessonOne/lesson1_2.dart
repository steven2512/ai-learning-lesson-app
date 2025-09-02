import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color mainConceptColor =
    Color.fromARGB(255, 255, 109, 12); // Classification color
const Color labelColor = Color.fromARGB(255, 12, 109, 255); // Label color
const double maxTextWidth = 350;
const double secondLineSize = 20.5;
const FontWeight secondLineWeight = FontWeight.w800;

class LessonStepOne extends StatelessWidget {
  final VoidCallback onContinue;

  const LessonStepOne({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              margin: const EdgeInsets.only(bottom: 20, top: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black26, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSentence([
                    _word("Each", Colors.black87,
                        fontSize: secondLineSize, fontWeight: secondLineWeight),
                    _word("data", mainConceptColor,
                        fontSize: secondLineSize, fontWeight: FontWeight.w800),
                    _word("has a", Colors.black87,
                        fontSize: secondLineSize, fontWeight: secondLineWeight),
                    _word("label.", labelColor,
                        fontSize: secondLineSize, fontWeight: FontWeight.w800),
                  ]),
                ],
              ),
            ),

            // Explanation box (split row WITH divider)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                  left: 15, right: 11, top: 15, bottom: 15),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black26, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  )
                ],
              ),
              child: IntrinsicHeight(
                // ✅ ensures divider spans full height
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Data column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSentence([
                            _word("Data", mainConceptColor,
                                fontSize: 16, fontWeight: FontWeight.w800),
                            _word("is the input we give the computer.",
                                Colors.black87,
                                fontSize: 16, fontWeight: secondLineWeight),
                          ], constrainWidth: false),
                        ],
                      ),
                    ),

                    // Vertical divider
                    Container(
                      width: 1,
                      color: Colors.black12, // ✅ faint border
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                    ),

                    // Label column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSentence([
                            _word("Label", labelColor,
                                fontSize: 16, fontWeight: FontWeight.w800),
                            _word("is the correct answer for the data",
                                Colors.black87,
                                fontSize: 16, fontWeight: secondLineWeight),
                          ], constrainWidth: false),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Table-like structure
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black26, width: 1),
              ),
              child: Table(
                border: TableBorder.symmetric(
                    inside: BorderSide(color: Colors.black12, width: 1)),
                columnWidths: const {
                  0: FixedColumnWidth(120), // Image column
                  1: FlexColumnWidth(),
                  2: FlexColumnWidth(),
                },
                children: [
                  // Header row
                  TableRow(
                    decoration: BoxDecoration(color: Colors.grey.shade100),
                    children: [
                      _tableCell("Input", bold: true),
                      _tableCell("Dog", color: Colors.green, bold: true),
                      _tableCell("Cat", color: Colors.red, bold: true),
                    ],
                  ),
                  // Row 1: Dog1
                  TableRow(children: [
                    _imageCell('assets/images/dog1.png'),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: _iconCell(true),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: _iconCell(false),
                    ),
                  ]),
                  // Row 2: Cat1
                  TableRow(children: [
                    _imageCell('assets/images/cat1.jpg'),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: _iconCell(false),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: _iconCell(true),
                    ),
                  ]),
                ],
              ),
            ),

            // Continue button
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.teal),
                    padding: MaterialStateProperty.all<EdgeInsets>(
                      const EdgeInsets.symmetric(horizontal: 38, vertical: 14),
                    ),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  onPressed: onContinue,
                  child: Text(
                    'Continue',
                    style: GoogleFonts.lato(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // helpers
  static Widget _word(String text, Color color,
      {FontWeight? fontWeight, bool italic = false, double? fontSize}) {
    return Text(
      "$text ",
      style: GoogleFonts.lato(
        fontSize: fontSize ?? 22,
        fontWeight: fontWeight ?? FontWeight.w800,
        fontStyle: italic ? FontStyle.italic : FontStyle.normal,
        color: color,
      ),
    );
  }

  static Widget _buildSentence(List<Widget> words,
      {WrapAlignment alignment = WrapAlignment.start,
      bool constrainWidth = true}) {
    final content = Wrap(alignment: alignment, children: words);
    return constrainWidth
        ? ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: maxTextWidth),
            child: content,
          )
        : content;
  }

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

  static Widget _iconCell(bool correct) {
    return Center(
      child: Icon(
        correct ? Icons.check_circle : Icons.radio_button_unchecked,
        color: correct ? Colors.green : Colors.black26,
        size: 40,
      ),
    );
  }
}
