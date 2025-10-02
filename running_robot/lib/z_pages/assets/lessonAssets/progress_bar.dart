// FILE: lib/z_pages/assets/lessonAssets/progress_bar.dart
import 'package:flutter/material.dart';
import 'package:running_robot/core/widgets.dart';

class LessonProgressBar extends StatefulWidget {
  final int totalStages;
  final int currentStage;
  final Duration stepDuration;

  const LessonProgressBar({
    super.key,
    required this.totalStages,
    required this.currentStage,
    this.stepDuration = const Duration(milliseconds: 500),
  });

  @override
  State<LessonProgressBar> createState() => _LessonProgressBarState();
}

class _LessonProgressBarState extends State<LessonProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  // ───────── VISUAL TUNING ─────────
  static const double _height = 22;
  static const double _radius = _height / 2;

  static const Color _trackBase = Color(0xFFFFFFFF);
  static const double _trackAlphaInitial = 0.35;
  static const double _trackAlphaActive = 0.55;

  static const Color _borderColor = Color(0xFF0F172A);
  static const double _borderAlpha = 0.10;

  static const Color _fillStart = Color(0xFF00E676);
  static const Color _fillEnd = Color(0xFF00C853);
  static const double _fillAlphaInitial = 0.65;
  static const double _fillAlphaActive = 0.95;

  static const double _glowAlpha = 0.18;

  double _from = 0.0;
  double _to = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.stepDuration,
    );
    _setupAnimation();
  }

  @override
  void didUpdateWidget(LessonProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentStage != widget.currentStage) {
      _from = _animation.value;
      _to = (widget.currentStage / widget.totalStages).clamp(0.0, 1.0);
      _setupAnimation();
      _controller.forward(from: 0);
    }
  }

  void _setupAnimation() {
    _animation = Tween<double>(begin: _from, end: _to).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    )..addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final double screenW = ScreenSize.width; // ✅ get screen width dynamically
    final double width = screenW * 0.7;

    final progress = _animation.value;
    final isInitialLook = widget.currentStage == 0 && progress <= 0.0001;

    final trackAlpha = isInitialLook ? _trackAlphaInitial : _trackAlphaActive;
    final fillAlpha = isInitialLook ? _fillAlphaInitial : _fillAlphaActive;

    return SizedBox(
      width: width,
      height: _height,
      child: CustomPaint(
        painter: _ProgressPainter(
          progress: progress,
          totalStages: widget.totalStages,
          isInitialLook: isInitialLook,
          trackAlpha: trackAlpha,
          fillAlpha: fillAlpha,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _ProgressPainter extends CustomPainter {
  final double progress;
  final int totalStages;
  final bool isInitialLook;
  final double trackAlpha;
  final double fillAlpha;

  const _ProgressPainter({
    required this.progress,
    required this.totalStages,
    required this.isInitialLook,
    required this.trackAlpha,
    required this.fillAlpha,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(_LessonProgressBarState._radius),
    );

    // Track (background)
    final trackPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          _LessonProgressBarState._trackBase.withOpacity(trackAlpha + 0.08),
          _LessonProgressBarState._trackBase.withOpacity(trackAlpha),
        ],
      ).createShader(rect);
    canvas.drawRRect(rrect, trackPaint);

    // Border
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = _LessonProgressBarState._borderColor
          .withOpacity(_LessonProgressBarState._borderAlpha);
    canvas.drawRRect(rrect, borderPaint);

    // Stage markers
    if (totalStages > 1 && totalStages <= 12) {
      final sepPaint = Paint()
        ..strokeWidth = 1
        ..color = _LessonProgressBarState._borderColor.withOpacity(0.10);
      final double stepW = size.width / totalStages;
      for (int i = 1; i < totalStages; i++) {
        final x = stepW * i;
        canvas.drawLine(Offset(x, 4), Offset(x, size.height - 4), sepPaint);
      }
    }

    // Fill
    final fillW = (size.width * progress).clamp(0.0, size.width);
    if (fillW > 0) {
      final dynR = fillW < _LessonProgressBarState._radius * 2
          ? fillW / 2
          : _LessonProgressBarState._radius;
      final fillRect = Rect.fromLTWH(0, 0, fillW, size.height);
      final fillRRect =
          RRect.fromRectAndRadius(fillRect, Radius.circular(dynR));

      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            _LessonProgressBarState._fillStart.withOpacity(fillAlpha),
            _LessonProgressBarState._fillEnd.withOpacity(fillAlpha),
          ],
        ).createShader(fillRect);
      canvas.drawRRect(fillRRect, fillPaint);

      // Gloss
      final glossRect = Rect.fromLTWH(0, 0, fillW, size.height * 0.52);
      final glossPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withOpacity(isInitialLook ? 0.14 : 0.10),
            Colors.white.withOpacity(0.00),
          ],
        ).createShader(glossRect);
      canvas.drawRRect(
        RRect.fromRectAndRadius(glossRect, Radius.circular(dynR)),
        glossPaint,
      );

      // Inner edge
      final innerEdge = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = Colors.black.withOpacity(0.05);
      canvas.drawRRect(fillRRect.deflate(0.4), innerEdge);

      // Glow
      if (!isInitialLook) {
        final glowPaint = Paint()
          ..color = _LessonProgressBarState._fillEnd
              .withOpacity(_LessonProgressBarState._glowAlpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);
        canvas.save();
        canvas.clipRRect(rrect);
        canvas.drawRRect(fillRRect, glowPaint);
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressPainter old) =>
      old.progress != progress ||
      old.totalStages != totalStages ||
      old.isInitialLook != isInitialLook;
}
