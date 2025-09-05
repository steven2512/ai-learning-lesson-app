import 'package:flutter/material.dart';

/// Minimal icon-only button for Flutter:
/// - Takes a PNG asset (no background)
/// - Optional tint; preserves icon aspect ratio
/// - Visibility can be set at construction (default true)
/// - Can be toggled later with .show() / .hide()
class IconButtonWidget<T> extends StatefulWidget {
  final String iconPath; // e.g. 'assets/ui/x_icon.png'
  final void Function(T? value)? onPressed;
  final T? payload;
  final Color? tint;
  final double size;
  final bool visible; // ✅ initial visibility

  const IconButtonWidget({
    super.key,
    required this.iconPath,
    this.onPressed,
    this.payload,
    this.tint,
    this.size = 22.0,
    this.visible = true, // ✅ default visible
  });

  @override
  State<IconButtonWidget<T>> createState() => _IconButtonWidgetState<T>();
}

class _IconButtonWidgetState<T> extends State<IconButtonWidget<T>> {
  late bool _isVisible;

  @override
  void initState() {
    super.initState();
    _isVisible = widget.visible; // initialize from constructor
  }

  // ───────── API ─────────
  void show() => setState(() => _isVisible = true);
  void hide() => setState(() => _isVisible = false);

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => widget.onPressed?.call(widget.payload),
      child: Image.asset(
        widget.iconPath,
        width: widget.size,
        height: widget.size,
        color: widget.tint,
        fit: BoxFit.contain,
      ),
    );
  }
}
