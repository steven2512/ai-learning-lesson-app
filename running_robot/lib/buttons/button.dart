import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/events/event_type.dart'; // EventHorizontalObstacle

/// Single-color pill with **bevel depth** (no shadow, no gradient).
/// Depth = an inner darker bottom band + a 1px top highlight.
/// Event‐driven like the rest of your project.
class GenericButton<T> extends PositionComponent with TapCallbacks {
  // ---- Public config
  final Vector2 buttonSize;
  final List<double> padding; // [top, left, bottom, right]
  final String content;

  final Color boxColor; // solid fill
  final double boxOpacity; // 0..1
  final double borderRadius;

  final double fontSize;
  final FontWeight fontWeight;
  final Color fontColor;

  final void Function(T? value)? onPressed;
  final T? payload;

  /// Height (px) of the inner bottom bevel band.
  final double bevelHeight;

  // ---- Event state
  EventHorizontalObstacle currentEvent = EventHorizontalObstacle.stopMoving;
  bool _phaseDirty = true;
  bool _isVisible = false;

  // ---- Paints (flat fill; no blending artifacts)
  final Paint _bodyPaint = Paint()
    ..isAntiAlias = true
    ..blendMode = BlendMode.src; // force solid color
  final Paint _overlayPaint = Paint()..isAntiAlias = true;

  GenericButton({
    required Vector2 position,
    required Anchor anchor,
    required this.buttonSize,
    required this.padding,
    required this.content,
    required this.boxColor,
    required this.boxOpacity,
    required this.fontSize,
    required this.fontWeight,
    required this.fontColor,
    required this.borderRadius,
    this.onPressed,
    this.payload,
    this.bevelHeight = 6.0, // tweak to taste
  }) : super(position: position, size: buttonSize, anchor: anchor) {
    assert(padding.length == 4, 'padding must be [top, left, bottom, right]');
    assert(borderRadius >= 0, 'borderRadius must be >= 0');
    _bodyPaint.color = boxColor.withOpacity(boxOpacity.clamp(0.0, 1.0));
  }

  // ---- API
  void switchPhase(EventHorizontalObstacle next) {
    next == EventHorizontalObstacle.startMoving ? show() : hide();
  }

  void show() {
    currentEvent = EventHorizontalObstacle.startMoving;
    _phaseDirty = true;
  }

  void hide() {
    currentEvent = EventHorizontalObstacle.stopMoving;
    _phaseDirty = true;
  }

  // ---- Lifecycle
  @override
  void update(double dt) {
    super.update(dt);
    if (_phaseDirty) {
      _isVisible = currentEvent == EventHorizontalObstacle.startMoving;
      _phaseDirty = false;
    }
  }

  @override
  void render(Canvas canvas) {
    if (!_isVisible) return;

    final Rect rect = Offset.zero & Size(size.x, size.y);
    final RRect rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(borderRadius),
    );

    // Base fill
    canvas.save();
    canvas.clipRRect(rrect);
    canvas.drawRRect(rrect, _bodyPaint);

    // ---- Top inner highlight (1px) for crisp, friendly edge
    _overlayPaint
      ..color = _lighten(boxColor, 0.22).withOpacity(boxOpacity)
      ..blendMode = BlendMode.srcOver;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, 1),
      _overlayPaint,
    );

    // ---- Bottom inner bevel band (gives "raised" depth; no shadow)
    final double h = bevelHeight.clamp(0.0, size.y / 2);
    _overlayPaint.color = _darken(boxColor, 0.18).withOpacity(boxOpacity);
    canvas.drawRect(
      Rect.fromLTWH(0, size.y - h, size.x, h),
      _overlayPaint,
    );

    // Optional crisper bottom lip (1px line)
    _overlayPaint.color = _darken(boxColor, 0.28).withOpacity(boxOpacity);
    canvas.drawRect(
      Rect.fromLTWH(0, size.y - 1, size.x, 1),
      _overlayPaint,
    );

    // ---- Text (centered, respects padding)
    final double top = padding[0];
    final double left = padding[1];
    final double bottom = padding[2];
    final double right = padding[3];

    final Rect contentRect = Rect.fromLTWH(
      left,
      top,
      (size.x - left - right).clamp(0, size.x).toDouble(),
      (size.y - top - bottom).clamp(0, size.y).toDouble(),
    );

    final textStyle = GoogleFonts.lato(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: fontColor,
      height: 1.0,
    );

    final tp = TextPainter(
      text: TextSpan(text: content, style: textStyle),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: contentRect.width);

    final double dx = contentRect.left + (contentRect.width - tp.width) / 2.0;
    final double dy = contentRect.top + (contentRect.height - tp.height) / 2.0;

    canvas.save();
    canvas.clipRect(contentRect);
    tp.paint(canvas, Offset(dx, dy));
    canvas.restore(); // text clip
    canvas.restore(); // rrect clip
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (_isVisible) onPressed?.call(payload);
  }

  // ---- Color helpers
  static Color _mix(Color a, Color b, double t) {
    t = t.clamp(0.0, 1.0);
    return Color.fromARGB(
      (a.alpha + (b.alpha - a.alpha) * t).round(),
      (a.red + (b.red - a.red) * t).round(),
      (a.green + (b.green - a.green) * t).round(),
      (a.blue + (b.blue - a.blue) * t).round(),
    );
  }

  static Color _darken(Color c, double t) => _mix(c, Colors.black, t);
  static Color _lighten(Color c, double t) => _mix(c, Colors.white, t);
}
