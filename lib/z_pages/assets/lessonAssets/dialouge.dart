import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/auth/start_button.dart';

/// Instant-switch DialogueBox:
/// - Supports a single Widget or List<Widget> as `content` (use your LessonText widgets).
/// - No animations/effects; page changes happen immediately.
/// - Optional width/height to control the anchor zone (height = bubble zone height).
/// - Bottom-right "Next" button appears only when there are more pages.
/// - If [finishButton] and [finishCallback] are both provided → show "Finish" button at end.
class DialogueBox extends StatefulWidget {
  final dynamic content; // Widget or List<Widget>
  final EdgeInsets padding;
  final double? width;

  /// Height = anchor zone height. Bubble pins to the bottom of this zone and
  /// expands upward only. If null, we use a sensible default (160).
  final double? height;

  final bool finishButton;
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
    final isLastPage = _currentIndex == _pages.length - 1;

    // Bubble paint (content grows upward inside)
    final bubble = CustomPaint(
      painter: const _BubblePainter(),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Container(
          padding: widget.padding,
          child: _pages[_currentIndex],
        ),
      ),
    );

    final bubbleSized = widget.width != null
        ? SizedBox(width: widget.width, child: bubble)
        : bubble;

    // 🔑 Anchor zone: fixes the absolute Y of the bottom edge + pointer.
    final double zoneHeight =
        widget.height ?? 160; // set explicitly per placement
    final anchoredBubble = SizedBox(
      width: widget.width,
      height: zoneHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
              left: 0,
              bottom: 0, // bottom edge + pointer are fixed here
              child: bubbleSized // bubble expands upward only
              ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        anchoredBubble,
        if (_pages.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8, right: 8),
            child: Builder(
              builder: (_) {
                if (!isLastPage) {
                  return PillCta(
                    label: 'Next',
                    color: const Color.fromARGB(255, 18, 148, 35),
                    onTap: _next,
                    width: 120,
                    height: 40,
                    fontSize: 15,
                  );
                } else if (widget.finishButton &&
                    widget.finishCallback != null) {
                  // ✅ SAME STYLE AS NEXT BUTTON
                  return PillCta(
                    label: 'Finish',
                    color: const Color.fromARGB(255, 18, 148, 35),
                    onTap: widget.finishCallback!,
                    width: 120,
                    height: 40,
                    fontSize: 15,
                  );
                } else {
                  return const SizedBox.shrink();
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
    const double radius = 12;
    const double tailWidth = 20;
    const double tailHeight = 25;
    const double tailOffset = 40; // move tail horizontally

    final path = Path();

    // Top edge
    path.moveTo(radius, 0);
    path.lineTo(size.width - radius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, radius);

    // Right edge
    path.lineTo(size.width, size.height - radius);
    path.quadraticBezierTo(
        size.width, size.height, size.width - radius, size.height);

    // Bottom edge (straight) until tail
    path.lineTo(tailWidth + radius + tailOffset, size.height);

    // Tail
    path.lineTo((tailWidth / 2) + tailOffset, size.height + tailHeight); // tip
    path.lineTo(radius + tailOffset, size.height);

    // Continue flat bottom edge to left corner
    path.lineTo(radius, size.height);

    // Bottom-left corner + left edge
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
