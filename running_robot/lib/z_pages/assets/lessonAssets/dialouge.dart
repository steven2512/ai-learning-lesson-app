import 'package:flutter/material.dart';

/// Instant-switch DialogueBox:
/// - Supports a single Widget or List<Widget> as `content` (use your LessonText widgets).
/// - No animations/effects; page changes happen immediately.
/// - Optional width/height to manually size the bubble.
/// - Bottom-right "Next" button appears only when there are more pages.
/// - If [finishButton] and [finishCallback] are both provided → show "Finish" button at end.
class DialogueBox extends StatefulWidget {
  final dynamic content; // Widget or List<Widget>
  final EdgeInsets padding;
  final double? width;
  final double? height;

  /// ✅ NEW: show Finish button at end
  final bool finishButton;

  /// ✅ NEW: callback when Finish pressed
  final VoidCallback? finishCallback;

  const DialogueBox({
    super.key,
    required this.content,
    this.padding =
        const EdgeInsets.fromLTRB(16, 14, 16, 22), // extra bottom for tail
    this.width,
    this.height,
    this.finishButton = false,
    this.finishCallback,
  });

  @override
  State<DialogueBox> createState() => _DialogueBoxState();
}

class _DialogueBoxState extends State<DialogueBox> {
  late final List<Widget> _pages;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.content is Widget) {
      _pages = [widget.content as Widget];
    } else if (widget.content is List<Widget>) {
      _pages = List<Widget>.from(widget.content);
    } else {
      throw Exception("DialogueBox.content must be a Widget or List<Widget>.");
    }
  }

  void _next() {
    if (_currentIndex < _pages.length - 1) {
      setState(() => _currentIndex++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bubble = CustomPaint(
      painter: const _BubblePainter(),
      child: Container(
        padding: widget.padding,
        child: _pages[_currentIndex], // 🔥 Instant swap: no animations
      ),
    );

    final sized = SizedBox(
      width: widget.width, // if null → takes parent constraints
      height: widget.height, // if null → wraps content
      child: bubble,
    );

    final isLastPage = _currentIndex == _pages.length - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        sized,
        if (_pages.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8, right: 8),
            child: Builder(
              builder: (_) {
                if (!isLastPage) {
                  // ✅ Regular "Next" button
                  return ElevatedButton.icon(
                    onPressed: _next,
                    icon: const Icon(Icons.chevron_right),
                    label: const Text("Next"),
                  );
                } else if (widget.finishButton &&
                    widget.finishCallback != null) {
                  // ✅ Show Finish button only if BOTH provided
                  return ElevatedButton.icon(
                    onPressed: widget.finishCallback,
                    icon: const Icon(Icons.check),
                    label: const Text("Finish"),
                  );
                } else {
                  return const SizedBox.shrink(); // nothing
                }
              },
            ),
          ),
      ],
    );
  }
}

/// Draws the rounded rectangle with a bottom-left tail as a single continuous path.
class _BubblePainter extends CustomPainter {
  const _BubblePainter();

  @override
  void paint(Canvas canvas, Size size) {
    const double radius = 16;
    const double tailWidth = 20;
    const double tailHeight = 18;

    final path = Path();

    // Top edge
    path.moveTo(radius, 0);
    path.lineTo(size.width - radius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, radius);

    // Right edge
    path.lineTo(size.width, size.height - radius);
    path.quadraticBezierTo(
        size.width, size.height, size.width - radius, size.height);

    // Bottom edge to start of tail
    path.lineTo(tailWidth + radius, size.height);

    // Tail
    path.lineTo(tailWidth / 2, size.height + tailHeight); // tip
    path.lineTo(radius, size.height);

    // Bottom-left corner + left edge + close
    path.quadraticBezierTo(0, size.height, 0, size.height - radius);
    path.lineTo(0, radius);
    path.quadraticBezierTo(0, 0, radius, 0);
    path.close();

    final fill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final stroke = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
