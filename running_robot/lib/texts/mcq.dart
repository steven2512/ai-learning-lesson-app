import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/events/event_type.dart';

/// MCQ text box for Flame with list-based configuration.
/// - Sizes:
///   - outerSize: [outerW, outerH]  (preferred)
///   - optionSizes: [w, h] uniform OR pairs [w1,h1,w2,h2,...] per option
///   - sizes (legacy): [outerW, outerH, optionH or per-option H...]
///   - If none provided, size auto-computes from text + options.
/// - Layout: [padding, gap, optionInnerPad]
/// - Opacities: [outerOpacity, optionOpacity, (optional) selectedOptionOpacity]
class McqTextBox extends PositionComponent implements OpacityProvider {
  // ---- Content ----
  final String question;
  final List<String> answers;
  final int correctAnswerIndex;

  // ---- Visuals ----
  final double borderRadius;
  final List<Color> textColors; // [question, answer]
  final List<Color> fillColors; // [outer, option, (optional) selected]
  final List<double> textSizes; // [question, answer]
  final double fadeDuration;

  // ---- Grouped config (lists) ----
  final List<double>? outerSize; // [outerW, outerH]
  final List<double>? optionSizes; // [w,h] or pairs [w1,h1,w2,h2,...]
  final List<double>?
  sizes; // legacy: [outerW, outerH, optionH or per-option H...]
  final List<double>? layout; // [padding, gap, optionInnerPad]
  final List<double>? opacities; // [outer, option, (optional) selected]

  // ---- Back-compat fallback (optional) ----
  final Vector2? boxSize;

  // ---- Callbacks ----
  final VoidCallback onCorrect;
  final VoidCallback onWrong;
  static void _noop() {}

  // ---- State ----
  EventHorizontalObstacle currentEvent = EventHorizontalObstacle.stopMoving;
  OpacityEffect? _fadeEffect;
  int? _selectedIndex;

  // ---- OpacityProvider (component-wide fade) ----
  double _opacity = 1.0;
  @override
  double get opacity => _opacity;
  @override
  set opacity(double v) {
    // avoid num->double issues from clamp
    _opacity = math.max(0.0, math.min(1.0, v));
  }

  // ---- Layout defaults (can be overridden by `layout`) ----
  double _padding = 16, _gap = 10, _optionInnerPad = 14;

  McqTextBox({
    // content
    required this.question,
    required this.answers,
    required this.correctAnswerIndex,

    // visuals
    required this.borderRadius,
    required this.textColors,
    required this.fillColors,
    required this.textSizes,
    required this.fadeDuration,

    // grouped lists
    this.outerSize,
    this.optionSizes,
    this.sizes, // legacy heights list still supported
    this.layout,
    this.opacities,

    // back-compat + init
    this.boxSize,
    required double initialOpacity,

    // placement
    Vector2? position,
    Anchor anchor = Anchor.topLeft,

    // callbacks
    List<VoidCallback>? callbacks,
  }) : onCorrect = (callbacks != null && callbacks.isNotEmpty)
           ? callbacks[0]
           : _noop,
       onWrong = (callbacks != null && callbacks.length > 1)
           ? callbacks[1]
           : _noop,
       super(
         position: position ?? Vector2.zero(),
         size: boxSize ?? Vector2.zero(), // will resolve below
         anchor: anchor,
       ) {
    opacity = initialOpacity;

    // Layout overrides
    if (layout != null && layout!.isNotEmpty) {
      if (layout!.length >= 1) _padding = layout![0];
      if (layout!.length >= 2) _gap = layout![1];
      if (layout!.length >= 3) _optionInnerPad = layout![2];
    }

    // ---- Resolve OUTER SIZE (priority: outerSize > sizes > boxSize > auto) ----
    Vector2? resolvedSize;
    if (outerSize != null && outerSize!.length >= 2) {
      assert(
        outerSize![0] > 0 && outerSize![1] > 0,
        'outerSize must be [W>0, H>0]',
      );
      resolvedSize = Vector2(outerSize![0], outerSize![1]);
    } else if (sizes != null && sizes!.length >= 2) {
      assert(sizes![0] > 0 && sizes![1] > 0, '`sizes[0..1]` must be > 0');
      resolvedSize = Vector2(sizes![0], sizes![1]);
    } else if (boxSize != null) {
      resolvedSize = boxSize!;
    } else {
      // Auto-size default: width 320; height from question text and options
      final n = answers.isEmpty ? 1 : (answers.length > 8 ? 8 : answers.length);
      final double questionSlot = textSizes[0] * 1.8;
      final double defaultOptH = 48.0;
      final double h =
          _padding * 2 + questionSlot + n * defaultOptH + _gap * (n - 1);
      resolvedSize = Vector2(320, h);
    }
    size = resolvedSize;

    // ---- Validations ----
    assert(textColors.length >= 2, 'textColors must be [question, answer]');
    assert(
      fillColors.length >= 2,
      'fillColors must be [outer, option, (optional) selected]',
    );
    assert(textSizes.length >= 2, 'textSizes must be [question, answer]');
    assert(
      correctAnswerIndex >= 0 && correctAnswerIndex < answers.length,
      'correctAnswerIndex out of range',
    );
    if (opacities != null) {
      assert(
        opacities!.length >= 2,
        'opacities must be [outer, option, (optional) selected]',
      );
      assert(
        opacities!.every((v) => v >= 0 && v <= 1),
        'opacities must be in [0, 1]',
      );
    }
    if (optionSizes != null && optionSizes!.isNotEmpty) {
      assert(
        optionSizes!.length >= 2,
        'optionSizes must be [w,h] or pairs [w1,h1,w2,h2,...]',
      );
    }
  }

  // ---- Effective colors (fill + explicit component opacities) ----
  double _effOpacity(int idx, double fallback) {
    if (opacities != null && opacities!.length > idx) {
      final v = opacities![idx];
      return v < 0 ? 0 : (v > 1 ? 1 : v);
    }
    return fallback;
  }

  Color _outerColor() =>
      fillColors[0].withOpacity(_effOpacity(0, fillColors[0].opacity));
  Color _optionColor() =>
      fillColors[1].withOpacity(_effOpacity(1, fillColors[1].opacity));
  Color _selectedColor() {
    final base = (fillColors.length > 2) ? fillColors[2] : fillColors[1];
    final optOp = _effOpacity(1, fillColors[1].opacity);
    final selOp = (opacities != null && opacities!.length > 2)
        ? _effOpacity(2, base.opacity)
        : math.min(1.0, optOp * 1.35);
    return base.withOpacity(selOp);
  }

  // ---- Resolve option heights from `sizes` (legacy) or auto ----
  List<double> _resolveHeightsFromLegacyOrAuto(int n, double optionsAreaH) {
    if (sizes != null && sizes!.length >= 3) {
      if (sizes!.length == 3) {
        final h = sizes![2];
        assert(h > 0, '`sizes[2]` option height must be > 0');
        return List<double>.filled(n, h);
      } else {
        final rest = sizes!.sublist(2);
        assert(rest.every((h) => h > 0), 'All option heights must be > 0');
        return List<double>.generate(
          n,
          (i) => i < rest.length ? rest[i] : rest.last,
        );
      }
    }
    // Auto: uniform height to fit available space
    final totalGap = _gap * (n - 1);
    final rawH = (optionsAreaH - totalGap) / n;
    final h = math.max(36.0, math.min(120.0, rawH));
    return List<double>.filled(n, h);
  }

  // ---- Resolve per-option sizes (Vector2 w,h) ----
  List<Vector2> _resolveOptionSizes(
    int n,
    double innerMaxW,
    double optionsAreaH,
  ) {
    // Start with heights from legacy/auto
    final heights = _resolveHeightsFromLegacyOrAuto(n, optionsAreaH);

    // If optionSizes provided:
    if (optionSizes != null && optionSizes!.isNotEmpty) {
      if (optionSizes!.length == 2) {
        // uniform [w,h]
        final w = math.min(optionSizes![0], innerMaxW);
        final h = optionSizes![1] > 0 ? optionSizes![1] : heights.first;
        return List<Vector2>.filled(n, Vector2(w, h));
      } else {
        // treat as pairs [w1,h1,w2,h2,...]; repeat last
        final pairs = <Vector2>[];
        for (int i = 0; i + 1 < optionSizes!.length; i += 2) {
          final w = math.min(optionSizes![i], innerMaxW);
          final h = optionSizes![i + 1] > 0
              ? optionSizes![i + 1]
              : heights[math.min(i ~/ 2, heights.length - 1)];
          pairs.add(Vector2(w, h));
        }
        return List<Vector2>.generate(
          n,
          (i) => i < pairs.length ? pairs[i] : pairs.last,
        );
      }
    }

    // Default: full width, heights from legacy/auto
    return List<Vector2>.generate(n, (i) => Vector2(innerMaxW, heights[i]));
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // --- Question ---
    final questionWidth = size.x - 2 * _padding;
    final questionText = TextBoxComponent(
      text: question,
      position: Vector2(_padding, _padding),
      size: Vector2(
        questionWidth,
        textSizes[0] * 1.8,
      ), // min slot; wraps as needed
      boxConfig: TextBoxConfig(maxWidth: questionWidth, timePerChar: 0.0),
      textRenderer: TextPaint(
        style: GoogleFonts.lato(
          fontSize: textSizes[0],
          color: textColors[0],
          fontWeight: FontWeight.w700,
        ),
      ),
    )..anchor = Anchor.topLeft;
    add(questionText);

    // --- Options ---
    final int n = answers.isEmpty
        ? 1
        : (answers.length > 8 ? 8 : answers.length);
    final double topAfterQuestion =
        questionText.position.y + questionText.size.y + _gap;
    final double optionsAreaH = size.y - topAfterQuestion - _padding;
    final double innerMaxW = size.x - 2 * _padding;

    final optionSizesResolved = _resolveOptionSizes(n, innerMaxW, optionsAreaH);
    final Color optColor = _optionColor();
    final Color selColor = _selectedColor();

    double y = topAfterQuestion;
    for (int i = 0; i < n; i++) {
      final sz = optionSizesResolved[i];
      final double w = sz.x, h = sz.y;
      final double pillRadius = math.max(
        8.0,
        math.min(h / 2.0, borderRadius * 0.6),
      );

      add(
        _McqOption(
          index: i,
          label: answers[i],
          size: Vector2(w, h),
          // center horizontally within inner width
          position: Vector2(_padding + (innerMaxW - w) / 2, y),
          cornerRadius: pillRadius,
          bgColor: optColor,
          selectedColor: selColor,
          textColor: textColors[1],
          textSize: textSizes[1],
          innerPad: _optionInnerPad,
          onTap: _onOptionTapped,
        ),
      );

      y += h + _gap;
    }
  }

  // ---- Visibility control ----
  void switchPhase(EventHorizontalObstacle phase) {
    currentEvent = phase;
    _startFade(
      phase == EventHorizontalObstacle.startMoving ? 1.0 : 0.0,
      fadeDuration,
    );
  }

  void _startFade(double target, double duration) {
    _fadeEffect?.removeFromParent();
    final fx = OpacityEffect.to(
      target,
      EffectController(duration: duration),
      onComplete: () => _fadeEffect = null,
    );
    _fadeEffect = fx;
    add(fx);
  }

  // ---- Interaction ----
  void _onOptionTapped(int index) {
    if (opacity <= 0.01 || _selectedIndex != null) return;
    _selectedIndex = index;
    (index == correctAnswerIndex ? onCorrect : onWrong).call();

    for (final c in children.whereType<_McqOption>()) {
      c.setSelected(index == c.index);
    }
  }

  // ---- Drawing ----
  @override
  void render(Canvas canvas) {
    // apply component-wide opacity
    canvas.saveLayer(
      null,
      Paint()..color = Color.fromRGBO(255, 255, 255, opacity),
    );

    // outer rounded card
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Radius.circular(borderRadius),
    );
    canvas.drawRRect(rrect, Paint()..color = _outerColor());

    super.render(canvas);
    canvas.restore();
  }
}

// ---- Internal option row ----
class _McqOption extends PositionComponent with TapCallbacks {
  final int index;
  final String label;
  final double cornerRadius;
  final Color bgColor, selectedColor, textColor;
  final double textSize, innerPad;
  final void Function(int index) onTap;

  bool _selected = false;
  late final TextComponent _text;

  _McqOption({
    required this.index,
    required this.label,
    required Vector2 size,
    required Vector2 position,
    required this.cornerRadius,
    required this.bgColor,
    required this.selectedColor,
    required this.textColor,
    required this.textSize,
    required this.innerPad,
    required this.onTap,
  }) : super(size: size, position: position, anchor: Anchor.topLeft);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _text = TextComponent(
      text: label,
      textRenderer: TextPaint(
        style: GoogleFonts.lato(
          fontSize: textSize,
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      position: Vector2(innerPad, size.y / 2),
      anchor: Anchor.centerLeft,
    );
    add(_text);
  }

  void setSelected(bool v) => _selected = v;

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = _selected ? selectedColor : bgColor;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Radius.circular(cornerRadius),
    );
    canvas.drawRRect(rrect, paint);
    super.render(canvas);
  }

  @override
  void onTapUp(TapUpEvent event) {
    onTap(index);
    super.onTapUp(event);
  }
}
