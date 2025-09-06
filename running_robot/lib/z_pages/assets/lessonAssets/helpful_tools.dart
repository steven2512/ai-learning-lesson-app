import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Shared text builder helpers for all lessons.
/// Lets you easily build styled words, sentences, and consistent lesson boxes.
class LessonText {
  static const double defaultFontSize = 22;
  static const double maxTextWidth = 350;

  /// Build a styled word span
  static Widget word(
    String text,
    Color color, {
    FontWeight? fontWeight,
    bool italic = false,
    double? fontSize,
  }) {
    return Text(
      "$text ",
      style: GoogleFonts.lato(
        fontSize: fontSize ?? defaultFontSize,
        fontWeight: fontWeight ?? FontWeight.w800,
        fontStyle: italic ? FontStyle.italic : FontStyle.normal,
        color: color,
      ),
    );
  }

  /// Build a sentence (multiple words) wrapped into a line
  static Widget sentence(
    List<Widget> words, {
    WrapAlignment alignment = WrapAlignment.start,
    bool constrainWidth = true,
  }) {
    final content = Wrap(alignment: alignment, children: words);
    return constrainWidth
        ? ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: maxTextWidth),
            child: content,
          )
        : Center(child: content);
  }

  /// ✅ Shared lesson box decoration
  static BoxDecoration defaultBoxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.black26, width: 1),
      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 6,
          offset: Offset(0, 3),
        )
      ],
    );
  }

  /// ✅ Convenience: wrap content in a styled box
  /// By default uses `defaultBoxDecoration`, but you can override with `decoration:`
  static Widget box({
    required Widget child,
    EdgeInsetsGeometry padding =
        const EdgeInsets.symmetric(vertical: 15, horizontal: 13),
    EdgeInsetsGeometry margin = const EdgeInsets.only(bottom: 10),
    BoxDecoration? decoration, // 👈 optional override
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      margin: margin,
      decoration: decoration ?? defaultBoxDecoration(),
      child: child,
    );
  }
}
