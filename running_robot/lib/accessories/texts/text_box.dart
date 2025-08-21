// lib/accessories/texts/text_box.dart
// FancyTextBox with EXACT grouped-alpha look (no per-frame saveLayer),
// uses your EventText + currentEvent + switchPhase API. Single-class change.

import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/accessories/events/event_type.dart'; // <- EventText lives here

class FancyTextBox extends TextBoxComponent implements OpacityProvider {
  // ---- Public config ----
  final List<String> sequence;

  /// Global visible duration (fallback) if per-item not provided.
  final double? interval;

  /// Per-item visible durations (seconds).
  final List<double>? durations;

  /// Per-item pre-gaps BEFORE showing each entry (seconds).
  final List<double>? intervals;

  /// Fade duration for show/hide.
  final double fadeDuration;

  // Background / layout
  final Color? boxFill;
  final double boxRadius;
  final double boxFillOpacity;
  final Vector2? boxSize; // inner content area for text
  final List<double>? boxPadding; // [top, right, bottom, left]
  final Color textColor;

  /// Kept for constructor/API parity; we still use it for text layout.
  final double maxWidthForLayout;

  // ---- App event state (as in your project) ----
  EventText currentEvent = EventText.hideText;

  // ---- Internal sequence state ----
  int currentIndex = 0;
  double _timer = 0.0;
  bool _waitingGap = false;
  bool _hasShownCurrent = false;

  // ---- Opacity (Effect-driven) ----
  double _opacity = 1.0;
  @override
  double get opacity => _opacity;
  @override
  set opacity(double value) {
    final v = value.clamp(0.0, 1.0);
    if (v == _opacity) return;
    _opacity = v;
    // We modulate at draw time; no need to rebuild raster on opacity change.
  }

  OpacityEffect? _fadeFx;

  // ---- Cached base text style (full opacity; we modulate at draw) ----
  late final TextStyle _baseTextStyle;

  // ---- RASTER CACHE: precompose background + text once per change ----
  ui.Image? _raster;
  bool _rasterDirty = true;
  double _lastDpr = ui.PlatformDispatcher.instance.views.isNotEmpty
      ? ui.PlatformDispatcher.instance.views.first.devicePixelRatio
      : (ui.PlatformDispatcher.instance.implicitView?.devicePixelRatio ?? 1.0);

  FancyTextBox({
    required Vector2 position,
    required Anchor anchor,
    required this.sequence,
    this.interval,
    required this.fadeDuration,
    this.durations,
    this.intervals,
    required double fontSize,
    required double letterSpacing,
    required FontWeight fontWeight,
    required double maxWidth,
    this.boxFill,
    this.boxRadius = 0.0,
    this.boxFillOpacity = 1.0,
    this.boxSize,
    this.textColor = Colors.black,
    this.boxPadding,
  })  : maxWidthForLayout = maxWidth,
        assert(interval == null || interval > 0, '`interval` must be > 0'),
        assert(durations == null ||
            (durations.isNotEmpty && durations.every((v) => v > 0))),
        assert(intervals == null || intervals.every((v) => v >= 0)),
        assert(boxFillOpacity >= 0.0 && boxFillOpacity <= 1.0),
        assert(
          boxPadding == null ||
              (boxPadding.length == 4 && boxPadding.every((v) => v >= 0)),
          '`boxPadding` must be [top, right, bottom, left]',
        ),
        super(
          align: anchor,
          anchor: anchor,
          text: sequence.isNotEmpty ? sequence[0] : '',
          position: position,
          boxConfig: TextBoxConfig(
            maxWidth: maxWidth,
            timePerChar: 0.0,
          ),
          textRenderer: TextPaint(
            style: GoogleFonts.lato(
              fontSize: fontSize,
              letterSpacing: letterSpacing,
              color: textColor,
              fontWeight: fontWeight,
            ),
          ),
        );

  // ---- Lifecycle ----
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _baseTextStyle = (textRenderer as TextPaint).style;

    // Establish component size now; height is finalized in raster build
    if (boxSize != null) {
      size = boxSize!;
    } else {
      size.x = maxWidthForLayout;
    }

    // Start hidden by default (matches EventText.hideText)
    currentEvent = EventText.hideText;
    opacity = 0.0;
    _rasterDirty = true;
  }

  @override
  void onGameResize(Vector2 _) {
    super.onGameResize(_);
    _rasterDirty = true;
  }

  @override
  void onRemove() {
    _disposeRaster();
    super.onRemove();
  }

  void _disposeRaster() {
    _raster?.dispose();
    _raster = null;
  }

  // ---- Public API (matches your architecture) ----
  void switchPhase(EventText next) {
    currentEvent = next;
    if (next == EventText.showText) {
      _show();
    } else if (next == EventText.hideText) {
      _hide();
    } else if (next == EventText.nextSequence) {
      _goNext(); // immediate step to next message
    }
  }

  // Optional convenience (if you call these elsewhere)
  void showText() => switchPhase(EventText.showText);
  void hideText() => switchPhase(EventText.hideText);

  // ---- Event handlers ----
  void _show() {
    if (_fadeFx != null && opacity < 1.0) {
      _fadeFx!.removeFromParent();
      _fadeFx = null;
    }
    if (opacity < 1.0) {
      _startFade(1.0, fadeDuration, onComplete: () => _hasShownCurrent = true);
    } else {
      _hasShownCurrent = true;
    }
  }

  void _hide() {
    _waitingGap = false;
    _hasShownCurrent = false;
    _timer = 0.0;

    _fadeFx?.removeFromParent();
    _fadeFx = OpacityEffect.to(
      0.0,
      EffectController(duration: fadeDuration),
    );
    add(_fadeFx!);
  }

  void _startFade(double target, double seconds, {VoidCallback? onComplete}) {
    _fadeFx?.removeFromParent();
    _fadeFx = OpacityEffect.to(
      target,
      EffectController(duration: seconds),
      onComplete: onComplete,
    );
    add(_fadeFx!);
  }

  // ---- Update loop ----
  @override
  void update(double dt) {
    super.update(dt);

    if (currentEvent != EventText.showText) return; // advance only when showing

    final double dur = (durations != null && currentIndex < (durations!.length))
        ? durations![currentIndex]
        : (interval ?? 2.0);

    if (!_hasShownCurrent) {
      if (opacity < 1.0 && _fadeFx == null) {
        _startFade(1.0, fadeDuration,
            onComplete: () => _hasShownCurrent = true);
      } else {
        _hasShownCurrent = true;
      }
      return;
    }

    _timer += dt;

    if (_timer >= dur && !_waitingGap) {
      final double gap = (intervals != null && currentIndex < intervals!.length)
          ? intervals![currentIndex]
          : 0.0;
      if (gap > 0) {
        _waitingGap = true;
        _timer = 0.0;
      } else {
        _goNext();
      }
    } else if (_waitingGap) {
      final double gapNow =
          (intervals != null && currentIndex < intervals!.length)
              ? intervals![currentIndex]
              : 0.0;
      if (_timer >= gapNow) {
        _waitingGap = false;
        _timer = 0.0;
        if (opacity < 1.0) {
          _startFade(1.0, fadeDuration,
              onComplete: () => _hasShownCurrent = true);
        } else {
          _hasShownCurrent = true;
        }
      }
    }
  }

  void _goNext() {
    if (currentIndex + 1 < sequence.length) {
      currentIndex += 1;
      text = sequence[currentIndex];
      _timer = 0.0;
      _hasShownCurrent = false;
      _rasterDirty = true; // text changed => rebuild raster
      if (opacity < 1.0) {
        _startFade(1.0, fadeDuration,
            onComplete: () => _hasShownCurrent = true);
      }
    }
  }

  // ---- Raster build: precompose bg + text (exact grouped-alpha) ----
  void _rebuildRaster() {
    _disposeRaster();

    final double dpr = ui.PlatformDispatcher.instance.views.isNotEmpty
        ? ui.PlatformDispatcher.instance.views.first.devicePixelRatio
        : (ui.PlatformDispatcher.instance.implicitView?.devicePixelRatio ??
            1.0);

    // Padding
    final double pt = boxPadding != null ? boxPadding![0] : 0.0;
    final double pr = boxPadding != null ? boxPadding![1] : 0.0;
    final double pb = boxPadding != null ? boxPadding![2] : 0.0;
    final double pl = boxPadding != null ? boxPadding![3] : 0.0;

    // Layout text with base style (full strength; fade applied at draw time)
    final double innerW = boxSize?.x ?? maxWidthForLayout;
    final painter = TextPainter(
      text: TextSpan(text: text, style: _baseTextStyle),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      maxLines: null,
    )..layout(maxWidth: innerW);

    final double textH = painter.height;
    final double innerH = boxSize?.y ?? textH;
    final double dy = ((innerH - textH) * 0.5).clamp(0.0, double.infinity);

    // Component outer size (includes padding)
    final double w = innerW + pl + pr;
    final double h = innerH + pt + pb;
    size = Vector2(w, h);

    final int pxW = (w * dpr).ceil().clamp(1, 100000);
    final int pxH = (h * dpr).ceil().clamp(1, 100000);

    final recorder = ui.PictureRecorder();
    final Canvas c = Canvas(recorder);

    // Draw in logical units; rasterized at device pixels for sharpness.
    c.save();
    c.scale(dpr, dpr);

    // Background at its own opacity (no overall fade here)
    if (boxFill != null && boxFillOpacity > 0.0) {
      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, w, h),
        Radius.circular(boxRadius),
      );
      c.drawRRect(rrect, Paint()..color = boxFill!.withOpacity(boxFillOpacity));
    }

    // Text centered in inner box; clip to avoid bleeding into padding.
    c.save();
    c.clipRect(Rect.fromLTWH(pl, pt, innerW, innerH));
    painter.paint(c, Offset(pl + (innerW - painter.width) / 2.0, pt + dy));
    c.restore();

    c.restore();

    final picture = recorder.endRecording();
    _raster = picture.toImageSync(pxW, pxH);
    _lastDpr = dpr;
    _rasterDirty = false;
  }

  // ---- Render ----
  @override
  void render(Canvas canvas) {
    if (opacity <= 0.001) return;

    final double dpr = ui.PlatformDispatcher.instance.views.isNotEmpty
        ? ui.PlatformDispatcher.instance.views.first.devicePixelRatio
        : (ui.PlatformDispatcher.instance.implicitView?.devicePixelRatio ??
            1.0);

    if (_raster == null || _rasterDirty || (dpr - _lastDpr).abs() > 1e-6) {
      _rebuildRaster();
    }
    if (_raster == null) return;

    final src = Rect.fromLTWH(
        0, 0, _raster!.width.toDouble(), _raster!.height.toDouble());
    final dst = Rect.fromLTWH(0, 0, size.x, size.y);

    // Exact grouped-alpha fade by modulating the precomposed image
    final paint = Paint()
      ..isAntiAlias = true
      ..filterQuality = FilterQuality.low
      ..colorFilter = ui.ColorFilter.mode(
        Colors.white.withOpacity(opacity),
        BlendMode.modulate,
      );

    canvas.drawImageRect(_raster!, src, dst, paint);
  }
}
