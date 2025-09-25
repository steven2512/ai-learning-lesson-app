// lib/ui/widgets/pill_cta.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PillCta extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final Color color; // e.g. const Color(0xFF7F56D9)

  // NEW: optional padding control
  // Pass any EdgeInsets (e.g., EdgeInsets.symmetric(horizontal: 48, vertical: 20))
  // If null, we use the original snug default.
  final EdgeInsetsGeometry? padding; // <-- NEW

  // NEW: optional font size for the label (default 18)
  final double fontSize; // <-- NEW

  const PillCta({
    super.key,
    required this.label,
    required this.onTap,
    required this.color,
    this.padding, // <-- NEW
    this.fontSize = 18, // <-- NEW (default)
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

    // NEW: resolve padding (default keeps the previous look)
    final EdgeInsetsGeometry resolvedPadding = widget.padding ??
        const EdgeInsets.symmetric(horizontal: 35, vertical: 18); // <-- NEW

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
          child: IntrinsicWidth(
            // keeps width = content + padding (snug) unless parent constraints expand it
            child: Container(
              padding:
                  resolvedPadding, // <-- CHANGED to use custom/default padding
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
                    fontSize:
                        widget.fontSize, // <-- NEW (uses custom/default size)
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.0,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
