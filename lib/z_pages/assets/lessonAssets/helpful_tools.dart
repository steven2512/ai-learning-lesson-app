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
    bool underline = false, // ✅ supports underline
    double? fontSize,
  }) {
    return Text(
      "$text ",
      style: GoogleFonts.lato(
        fontSize: fontSize ?? defaultFontSize,
        fontWeight: fontWeight ?? FontWeight.w800,
        fontStyle: italic ? FontStyle.italic : FontStyle.normal,
        decoration: underline ? TextDecoration.underline : TextDecoration.none,
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

  // ──────────────────────────────────────────────
  // Default lesson box
  // ──────────────────────────────────────────────
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

  static Widget box({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry padding =
        const EdgeInsets.symmetric(vertical: 15, horizontal: 13),
    EdgeInsetsGeometry margin = const EdgeInsets.only(bottom: 10),
    BoxDecoration? decoration,
  }) {
    return Container(
      key: key,
      width: double.infinity,
      padding: padding,
      margin: margin,
      decoration: decoration ?? defaultBoxDecoration(),
      child: child,
    );
  }

  // ──────────────────────────────────────────────
  // NEW: Fashionable Nostalgic Recap Box
  // ──────────────────────────────────────────────
  static BoxDecoration recapBoxDecoration() {
    return BoxDecoration(
      // Slight retro vibe with a peachy gradient
      gradient: LinearGradient(
        colors: [
          const Color(0xFFFFF4EC), // warm peach-cream
          const Color(0xFFFFFFFF), // soft white fade
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: const Color(0xFFE0C3A0), // soft golden-brown accent
        width: 1.2,
      ),
      boxShadow: const [
        BoxShadow(
          color: Color(0x26000000), // subtle soft shadow
          blurRadius: 10,
          offset: Offset(0, 5),
        ),
      ],
    );
  }

  static Widget recapBox({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry padding =
        const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
    EdgeInsetsGeometry margin = const EdgeInsets.only(bottom: 0),
    BoxDecoration? decoration,
  }) {
    return Container(
      key: key,
      width: double.infinity,
      padding: padding,
      margin: margin,
      decoration: decoration ?? recapBoxDecoration(),
      child: child,
    );
  }
}
