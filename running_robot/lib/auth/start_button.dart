// lib/ui/widgets/pill_cta.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PillCta extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final Color color; // e.g. const Color(0xFF7F56D9)

  // Optional padding (manual control). If null, fallback default.
  final EdgeInsetsGeometry? padding;

  // Optional font size for the label (default 18).
  final double fontSize;

  // NEW: expand to full width if true
  final bool expand;

  const PillCta({
    super.key,
    required this.label,
    required this.onTap,
    required this.color,
    this.padding,
    this.fontSize = 18,
    this.expand = false,
  });

  @override
  State<PillCta> createState() => _PillCtaState();
}

class _PillCtaState extends State<PillCta> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final base = widget.color;

    // Soft, purple-tinted shadow set (no inner lines at all).
    final Color rim = Color.lerp(base, Colors.black, 0.10)!;
    final Color ambient =
        Color.lerp(Colors.black, base, 0.18)!.withOpacity(0.22);

    final borderRadius = BorderRadius.circular(30);

    // Always use either provided padding or fixed default
    final EdgeInsetsGeometry resolvedPadding = widget.padding ??
        const EdgeInsets.symmetric(horizontal: 35, vertical: 18);

    return Semantics(
      button: true,
      label: widget.label,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        child: AnimatedScale(
          duration: const Duration(milliseconds: 90),
          curve: Curves.easeOut,
          scale: _pressed ? 0.98 : 1.0,
          child: widget.expand
              ? Container(
                  width: double.infinity, // full width
                  padding: resolvedPadding,
                  decoration: BoxDecoration(
                    color: base,
                    borderRadius: borderRadius,
                    boxShadow: [
                      BoxShadow(
                        color: rim,
                        offset: const Offset(0, 3),
                        blurRadius: 0,
                      ),
                      BoxShadow(
                        color: ambient,
                        offset: const Offset(0, 12),
                        blurRadius: 20,
                        spreadRadius: -4,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      widget.label,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                        fontSize: widget.fontSize,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.0,
                      ),
                    ),
                  ),
                )
              : Align(
                  alignment: Alignment.center,
                  child: Container(
                    padding: resolvedPadding,
                    decoration: BoxDecoration(
                      color: base,
                      borderRadius: borderRadius,
                      boxShadow: [
                        BoxShadow(
                          color: rim,
                          offset: const Offset(0, 3),
                          blurRadius: 0,
                        ),
                        BoxShadow(
                          color: ambient,
                          offset: const Offset(0, 12),
                          blurRadius: 20,
                          spreadRadius: -4,
                        ),
                      ],
                    ),
                    child: Text(
                      widget.label,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                        fontSize: widget.fontSize,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
