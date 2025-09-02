import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const double maxTextWidth = 350;

class LessonStepThree extends StatelessWidget {
  const LessonStepThree({super.key});

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
                        inside: BorderSide(color: Colors.black12, width: 1)),
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
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: _iconCell(true),
                        ),
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: _iconCell(false),
                        ),
                      ]),
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
                ],
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
