// lib/accessories/decorations/fancy_box.dart
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart' as m;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/accessories/events/event_type.dart';

/// FancyBox — capsule header + rounded card + border + icon + value
/// Starts hidden (stopMoving). Use startMoving()/switchPhase(startMoving) to show.
class FancyBox extends PositionComponent {
  // ---- Config ----
  final String titleText; // header (capsule)
  final String mainContent; // value text

  /// [insideTintBase, bannerColor, borderColor]
  final List<m.Color> fillColors;

  /// [bannerFont, contentFont, iconSize]
  final List<double> fontSizes;

  /// [bannerText, contentText, iconColor]
  final List<m.Color> fontColors;

  /// Optional paddings [top, right, bottom, left]; else auto.
  final List<double>? paddings;

  /// Border stroke width.
  final double borderThickness;

  /// Card corner radius.
  final double borderRadius;

  /// Letter spacing for texts.
  final double letterSpacing;

  /// Text anchors (exposed for flexibility; default center).
  final Anchor insideTextAnchor;
  final Anchor bannerTextAnchor;

  /// Icon sources. If both given, Sprite wins.
  final Sprite? spriteIcon;
  final String? spritePath;
  final m.IconData? iconData;

  // ---- Phase state ----
  EventHorizontalObstacle currentEvent = EventHorizontalObstacle.stopMoving;
  bool _visible = false;

  // ---- Layout cache ----
  late Rect _cardRect;
  late RRect _cardRRect;
  late double _padTop, _padRight, _padBottom, _padLeft;

  // Cached sprite if loaded from path
  Sprite? _loadedSprite;

  FancyBox({
    required Vector2 position,
    required Anchor anchor,
    required Vector2 boxSize,
    required this.titleText,
    required this.mainContent,
    required this.fillColors, // [inside, banner, border]
    required this.fontSizes, // [bannerFs, contentFs, iconSize]
    required this.fontColors, // [bannerText, contentText, icon]
    this.paddings,
    this.borderThickness = 2.0,
    this.borderRadius = 16.0,
    this.letterSpacing = 0.2,
    this.insideTextAnchor = Anchor.center,
    this.bannerTextAnchor = Anchor.center,
    this.spriteIcon,
    this.spritePath,
    this.iconData,
  }) : assert(
         fillColors.length == 3,
         'fillColors must be [inside, banner, border]',
       ),
       assert(
         fontSizes.length == 3,
         'fontSizes must be [banner, content, icon]',
       ),
       assert(
         fontColors.length == 3,
         'fontColors must be [bannerText, contentText, icon]',
       ) {
    this.position = position;
    this.size = boxSize;
    this.anchor = anchor;
    _computePaddingAndRects();
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    if (spriteIcon != null) {
      _loadedSprite = spriteIcon;
    } else if (spritePath != null) {
      _loadedSprite = await Sprite.load(spritePath!);
    }
  }

  // ---- Phase API ----
  void switchPhase(EventHorizontalObstacle phase) {
    switch (phase) {
      case EventHorizontalObstacle.startMoving:
        show();
        break;
      case EventHorizontalObstacle.stopMoving:
        hide();
        break;
    }
  }

  void startMoving() => show();
  void stopMoving() => hide();

  void show() {
    _visible = true;
    currentEvent = EventHorizontalObstacle.startMoving;
    _computePaddingAndRects();
  }

  void hide() {
    _visible = false;
    currentEvent = EventHorizontalObstacle.stopMoving;
    _computePaddingAndRects();
  }

  // ---- Layout ----
  void _computePaddingAndRects() {
    if (paddings != null && paddings!.length == 4) {
      _padTop = paddings![0];
      _padRight = paddings![1];
      _padBottom = paddings![2];
      _padLeft = paddings![3];
    } else {
      // tuned to reference proportions
      _padTop = size.y * 0.18; // room for capsule
      _padBottom = size.y * 0.14;
      _padLeft = size.x * 0.10;
      _padRight = size.x * 0.10;
    }
    _cardRect = Rect.fromLTWH(0, 0, size.x, size.y);
    _cardRRect = RRect.fromRectAndRadius(
      _cardRect,
      Radius.circular(borderRadius),
    );
  }

  // ---- Render ----
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (!_visible) return;

    final insideBase = fillColors[0];
    final bannerColor = fillColors[1];
    final borderColor = fillColors[2];

    // background tint
    final bgPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = insideBase.withOpacity(0.08);
    canvas.drawRRect(_cardRRect, bgPaint);

    // border
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderThickness
      ..color = borderColor;
    canvas.drawRRect(_cardRRect, borderPaint);

    // header capsule
    _drawBanner(canvas, bannerColor);

    // icon + value row
    _drawIconAndValue(canvas);
  }

  void _drawBanner(Canvas canvas, m.Color capsuleColor) {
    final bannerFs = fontSizes[0];
    final bannerTextColor = fontColors[0];

    final tp = TextPainter(
      text: TextSpan(
        text: titleText.toUpperCase(),
        style: GoogleFonts.lato(
          fontSize: bannerFs,
          fontWeight: m.FontWeight.w700,
          color: bannerTextColor,
          letterSpacing: letterSpacing,
        ),
      ),
      textDirection: m.TextDirection.ltr,
    )..layout();

    const double hPad = 12, vPad = 6;
    final Size capSize = Size(tp.width + hPad * 2, tp.height + vPad * 2);

    // horizontal placement by bannerTextAnchor
    double x;
    switch (bannerTextAnchor) {
      case Anchor.center:
      case Anchor.topCenter:
      case Anchor.bottomCenter:
        x = (size.x - capSize.width) / 2;
        break;
      case Anchor.centerRight:
      case Anchor.topRight:
      case Anchor.bottomRight:
        x = size.x - _padRight - capSize.width;
        break;
      default: // left and others
        x = _padLeft;
    }

    final double y = _padTop - (tp.height * 0.15);

    final RRect cap = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, capSize.width, capSize.height),
      const Radius.circular(12),
    );
    final capPaint = Paint()..color = capsuleColor;
    canvas.drawRRect(cap, capPaint);

    final Offset textOffset = Offset(
      x + (capSize.width - tp.width) / 2,
      y + (capSize.height - tp.height) / 2,
    );
    tp.paint(canvas, textOffset);
  }

  void _drawIconAndValue(Canvas canvas) {
    final contentFs0 = fontSizes[1];
    final iconSize = fontSizes[2];
    final contentColor = fontColors[1];
    final iconColor = fontColors[2];

    // area below banner
    final double top = _padTop + 28.0;
    final double bottom = size.y - _padBottom;
    final double availH = (bottom - top).clamp(0.0, size.y);
    final double rowY = top + (availH - iconSize) / 2;

    // icon + gap + value
    final double iconW = iconSize;
    const double gap = 8.0;

    double contentFs = contentFs0;
    TextPainter _layout(double fs) => TextPainter(
      text: TextSpan(
        text: mainContent,
        style: GoogleFonts.lato(
          fontSize: fs,
          fontWeight: m.FontWeight.w700,
          color: contentColor,
          letterSpacing: letterSpacing,
        ),
      ),
      textDirection: m.TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout();

    var valueTp = _layout(contentFs);

    double rowWidth() => iconW + gap + valueTp.width;
    final double maxRowWidth = size.x - _padLeft - _padRight;

    while (rowWidth() > maxRowWidth && contentFs > 10) {
      contentFs -= 1;
      valueTp = _layout(contentFs);
    }

    final double rowX = (size.x - rowWidth()) / 2;

    // icon
    if (_loadedSprite != null) {
      _loadedSprite!.render(
        canvas,
        position: Vector2(rowX, rowY),
        size: Vector2(iconW, iconW),
      );
    } else if (iconData != null) {
      final iconTp = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(iconData!.codePoint),
          style: m.TextStyle(
            fontSize: iconSize,
            fontFamily: iconData!.fontFamily,
            package: iconData!.fontPackage,
            color: iconColor,
          ),
        ),
        textDirection: m.TextDirection.ltr,
      )..layout();
      iconTp.paint(canvas, Offset(rowX, rowY + (iconSize - iconTp.height) / 2));
    }

    // value
    final double valX = rowX + iconW + gap;
    final double valY = rowY + (iconSize - valueTp.height) / 2;
    valueTp.paint(canvas, Offset(valX, valY));
  }

  @override
  void update(double dt) {
    super.update(dt);
  }
}
