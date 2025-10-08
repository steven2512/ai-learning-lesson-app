// FILE: matching_game.dart
// Independent column centering (equal top/between/bottom *per column*).
// Slot height per column = max intrinsic item height (tight text boxes).
// Lato + word-by-word wrap (no mid-word splits). Submit/Reset below.
// onCompleted fires only after a correct Submit.

import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MatchingGame extends StatefulWidget {
  final double width;
  final double height;

  final List<Widget> groupA; // left
  final List<Widget> groupB; // right

  /// Ground truth: leftIndex -> rightIndex
  final Map<int, int> correctPairs;

  final Map<int, int>? initialConnections;
  final void Function(Map<int, int> connections)? onChanged;

  /// Fired only after Submit AND if all pairs are correct.
  final VoidCallback? onCompleted;

  final bool enforceOneToOne;

  /// Freeze only after a correct Submit (no auto-freeze on drag).
  final bool freezeOnPerfect;

  final bool readOnly;

  /// Requested BETWEEN gap. Top & bottom are chosen to center the stack in
  /// its own column while keeping between gap == verticalGap (when possible).
  final double verticalGap;

  /// Show Submit / Reset (rendered below the canvas).
  final bool showControls;

  /// Require all left items in [correctPairs] to be connected before enabling Submit.
  final bool requireAllMatchedToSubmit;

  /// Fractions for columns (must sum to 1.0)
  final double leftFraction;
  final double centerFraction;
  final double rightFraction;

  const MatchingGame({
    super.key,
    required this.width,
    required this.height,
    required this.groupA,
    required this.groupB,
    required this.correctPairs,
    this.initialConnections,
    this.onChanged,
    this.onCompleted,
    this.enforceOneToOne = false,
    this.freezeOnPerfect = true,
    this.readOnly = false,
    this.verticalGap = 8,
    this.showControls = true,
    this.requireAllMatchedToSubmit = true,

    // 🔸 UPDATED FRACTIONS
    this.leftFraction = 0.34,
    this.centerFraction = 0.32,
    this.rightFraction = 0.34,
  }) : assert(
          (leftFraction + centerFraction + rightFraction) > 0.999 &&
              (leftFraction + centerFraction + rightFraction) < 1.001,
          'Column fractions must sum to 1.0',
        );

  @override
  State<MatchingGame> createState() => _MatchingGameState();
}

class _MatchingGameState extends State<MatchingGame> {
  // Connections: leftIndex -> rightIndex
  late Map<int, int> _connections;

  // Drag state
  int? _draggingLeftIndex;
  Offset? _dragPos;

  // Frozen after correct Submit (if freezeOnPerfect)
  bool _frozen = false;

  // Layout constants
  static const double _columnInnerPad = 8;
  static const double _minSlotHeight = 32;

  // Column widths
  double get _leftColWidth => widget.width * widget.leftFraction;
  double get _centerGapWidth => widget.width * widget.centerFraction;
  double get _rightColWidth => widget.width * widget.rightFraction;

  double get _leftSlotWidth => _leftColWidth - 2 * _columnInnerPad;
  double get _rightSlotWidth => _rightColWidth - 2 * _columnInnerPad;

  int get _nLeft => widget.groupA.length;
  int get _nRight => widget.groupB.length;

  // Intrinsic (measured) max height per column
  double? _leftIntrinsicMax;
  double? _rightIntrinsicMax;

  @override
  void initState() {
    super.initState();
    _connections = Map<int, int>.from(widget.initialConnections ?? {});
  }

  // ---------- Column metrics (each column centers itself) ----------
  // We base slot height on measured intrinsic height per column to keep boxes tight.
  _Metrics _metricsForColumn({
    required int count,
    required double columnWidth,
    required double measuredMax,
  }) {
    if (count <= 0) return const _Metrics.zero();

    double slotH = math.max(_minSlotHeight, measuredMax);
    double between = widget.verticalGap;

    // Used height with desired slotH and between gaps (top/bottom not included)
    double used = count * slotH + (count - 1) * between;

    // If everything + equal top/bottom fits, center the stack:
    if (used <= widget.height) {
      double leftover = widget.height - used;
      double top = leftover / 2;
      return _Metrics(slotH: slotH, between: between, top: top);
    }

    // Too tall: first try to reduce slotH to keep fixed between
    double availableForSlots = widget.height - (count - 1) * between;
    if (availableForSlots >= count * _minSlotHeight) {
      slotH = availableForSlots / count;
      return _Metrics(slotH: slotH, between: between, top: 0);
    }

    // Still too tall: set slotH to min, then reduce between
    slotH = _minSlotHeight;
    double availableForBetween = widget.height - count * slotH;
    if (count > 1) {
      between = math.max(0, availableForBetween / (count - 1));
    } else {
      between = 0;
    }
    return _Metrics(slotH: slotH, between: between, top: 0);
  }

  Rect _leftRect(int i, _Metrics m) {
    final y = m.top + i * (m.slotH + m.between);
    return Rect.fromLTWH(_columnInnerPad, y, _leftSlotWidth, m.slotH);
    // top/between/bottom are equal *within* this column (via m.top/m.between)
  }

  Rect _rightRect(int j, _Metrics m) {
    final x = _leftColWidth + _centerGapWidth + _columnInnerPad;
    final y = m.top + j * (m.slotH + m.between);
    return Rect.fromLTWH(x, y, _rightSlotWidth, m.slotH);
  }

  int? _leftIndexFromOffset(Offset p, _Metrics m) {
    // Expand hit area horizontally (so user doesn't need perfect precision)
    const double extraX = 40; // how far beyond the box to allow starting drag
    const double extraY = 16; // extra vertical tolerance

    for (var i = 0; i < _nLeft; i++) {
      final base = _leftRect(i, m);
      final expanded = Rect.fromLTRB(
        base.left - extraX,
        base.top - extraY,
        base.right + extraX,
        base.bottom + extraY,
      );
      if (expanded.contains(p)) return i;
    }
    return null;
  }

  int? _rightIndexFromOffset(Offset p, _Metrics m) {
    final rx = _leftColWidth + _centerGapWidth;
    if (p.dx < rx || p.dx > rx + _rightColWidth) return null;
    for (var j = 0; j < _nRight; j++) {
      if (_rightRect(j, m).contains(p)) return j;
    }
    return null;
  }

  void _emitChanged() =>
      widget.onChanged?.call(Map<int, int>.from(_connections));

  // ---------- Interaction ----------
  void _onPanStart(DragStartDetails d, _Metrics lm) {
    if (_frozen || widget.readOnly) return;
    _draggingLeftIndex = _leftIndexFromOffset(d.localPosition, lm);
    _dragPos = d.localPosition;
    setState(() {});
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_frozen || widget.readOnly) return;
    if (_draggingLeftIndex == null) return;
    _dragPos = d.localPosition;
    setState(() {});
  }

  void _onPanEnd(DragEndDetails d, _Metrics rm) {
    if (_frozen || widget.readOnly) return;
    final from = _draggingLeftIndex;
    _draggingLeftIndex = null;

    if (from == null) {
      _dragPos = null;
      return;
    }
    final rp = _dragPos;
    _dragPos = null;

    if (rp != null) {
      final to = _rightIndexFromOffset(rp, rm);
      if (to != null) {
        if (widget.enforceOneToOne) {
          final removeKey = _connections.entries
              .firstWhere((e) => e.value == to,
                  orElse: () => const MapEntry(-1, -1))
              .key;
          if (removeKey != -1) _connections.remove(removeKey);
        }
        _connections[from] = to;
        _emitChanged();
      }
    }
    setState(() {});
  }

  bool get _allRequiredConnected =>
      widget.correctPairs.keys.every(_connections.containsKey);

  // ---------- Submit/Reset ----------
  void _handleSubmit() {
    if (_frozen) return;
    final allCorrect = widget.correctPairs.entries
        .every((e) => _connections[e.key] == e.value);
    if (allCorrect) {
      if (widget.freezeOnPerfect) setState(() => _frozen = true);
      widget.onCompleted?.call(); // only after Submit & correct
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not quite — check the connections.')),
      );
    }
  }

  void _handleReset() {
    setState(() {
      _connections.clear();
      _frozen = false;
    });
    _emitChanged();
  }

  // ---------- Measurement updates ----------
  void _updateLeftIntrinsic(int idx, double h) {
    final v = (_leftIntrinsicMax ?? 0);
    if (h > v) setState(() => _leftIntrinsicMax = h);
  }

  void _updateRightIntrinsic(int idx, double h) {
    final v = (_rightIntrinsicMax ?? 0);
    if (h > v) setState(() => _rightIntrinsicMax = h);
  }

  @override
  Widget build(BuildContext context) {
    // Lato; force English to avoid mid-word splits.
    final latoBase = GoogleFonts.lato().copyWith(locale: const Locale('en'));
    const fontSize = 22.0;

    final textStyle = latoBase.merge(const TextStyle(
      fontSize: fontSize,
      height: 1.8,
    ));

    final tightStrut = const StrutStyle(
      height: 1.8,
      leading: 0,
      forceStrutHeight: true,
    );

    const tightTHB = TextHeightBehavior(
      applyHeightToFirstAscent: false,
      applyHeightToLastDescent: false,
    );

    // ---------- Offstage measurement layer ----------
    // We render once (offscreen) to get intrinsic heights for tight boxes.
    final measureLayer = Offstage(
      offstage: false,
      child: SizedBox(
        width: widget.width,
        height: 0, // no paint; still lays out children
        child: Row(
          children: [
            SizedBox(
              width: _leftColWidth,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: _columnInnerPad),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (int i = 0; i < _nLeft; i++)
                      _MeasureSize(
                        onChange: (sz) => _updateLeftIntrinsic(i, sz.height),
                        child: _SlotBox(
                          child: widget.groupA[i],
                          textStyle: textStyle,
                          strut: tightStrut,
                          thb: tightTHB,
                          isImage: widget.groupA[i] is Image ||
                              widget.groupA[i] is Icon,
                          scrollableText: false, // measure natural height
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(width: _centerGapWidth),
            SizedBox(
              width: _rightColWidth,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: _columnInnerPad),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (int j = 0; j < _nRight; j++)
                      _MeasureSize(
                        onChange: (sz) => _updateRightIntrinsic(j, sz.height),
                        child: _SlotBox(
                          child: widget.groupB[j],
                          textStyle: textStyle,
                          strut: tightStrut,
                          thb: tightTHB,
                          isImage: widget.groupB[j] is Image ||
                              widget.groupB[j] is Icon,
                          scrollableText: false, // measure natural height
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // Fallbacks if measurement hasn't arrived yet
    final leftMeasured =
        math.max(_minSlotHeight, (_leftIntrinsicMax ?? _minSlotHeight));
    final rightMeasured =
        math.max(_minSlotHeight, (_rightIntrinsicMax ?? _minSlotHeight));

    final leftMetrics = _metricsForColumn(
      count: _nLeft,
      columnWidth: _leftSlotWidth,
      measuredMax: leftMeasured,
    );
    final rightMetrics = _metricsForColumn(
      count: _nRight,
      columnWidth: _rightSlotWidth,
      measuredMax: rightMeasured,
    );

    // ---------- Canvas ----------
    final canvas = SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: [
          measureLayer,

          // Lines
          CustomPaint(
            size: Size(widget.width, widget.height),
            painter: _LinesPainter(
              leftCount: _nLeft,
              rightCount: _nRight,
              leftRect: (i) => _leftRect(i, leftMetrics),
              rightRect: (j) => _rightRect(j, rightMetrics),
              draggingFrom: _draggingLeftIndex,
              dragPos: _dragPos,
              connections: _connections,
            ),
          ),

          // Left slots (interactive)
          for (int i = 0; i < _nLeft; i++)
            Positioned.fromRect(
              rect: _leftRect(i, leftMetrics),
              child: _SlotBox(
                child: widget.groupA[i],
                textStyle: textStyle,
                strut: tightStrut,
                thb: tightTHB,
                isImage: widget.groupA[i] is Image || widget.groupA[i] is Icon,
                scrollableText: true, // live boxes can scroll if needed
              ),
            ),

          // Right slots (interactive)
          for (int j = 0; j < _nRight; j++)
            Positioned.fromRect(
              rect: _rightRect(j, rightMetrics),
              child: _SlotBox(
                child: widget.groupB[j],
                textStyle: textStyle,
                strut: tightStrut,
                thb: tightTHB,
                isImage: widget.groupB[j] is Image || widget.groupB[j] is Icon,
                scrollableText: true,
              ),
            ),

          // Drag layer
          // 🔸 Drag layer — locks gesture to first touched left slot (dominant drag)
          IgnorePointer(
            ignoring: _frozen || widget.readOnly,
            child: RawGestureDetector(
              behavior: HitTestBehavior.translucent,
              gestures: {
                PanGestureRecognizer:
                    GestureRecognizerFactoryWithHandlers<PanGestureRecognizer>(
                  // 👇 Create recognizer
                  () => PanGestureRecognizer()
                    ..gestureSettings =
                        const DeviceGestureSettings(touchSlop: 2),
                  // 👇 Configure recognizer
                  (PanGestureRecognizer instance) {
                    instance.onDown = (d) {
                      if (_frozen || widget.readOnly) return;
                      final pos = d.localPosition;
                      final idx = _leftIndexFromOffset(pos, leftMetrics);
                      if (idx != null) {
                        _draggingLeftIndex = idx;
                        _dragPos = pos;
                        setState(() {});
                      }
                    };

                    instance.onStart = (d) => _onPanStart(d, leftMetrics);
                    instance.onUpdate = _onPanUpdate;
                    instance.onEnd = (d) => _onPanEnd(d, rightMetrics);

                    instance.onCancel = () {
                      if (_draggingLeftIndex != null || _dragPos != null) {
                        _draggingLeftIndex = null;
                        _dragPos = null;
                        setState(() {});
                      }
                    };
                  },
                ),
              },
            ),
          ),
        ],
      ),
    );

    // Controls (below)
    final controls = (!widget.showControls || widget.readOnly)
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: (_frozen ||
                          (widget.requireAllMatchedToSubmit &&
                              !_allRequiredConnected))
                      ? null
                      : _handleSubmit,
                  child: const Text('Submit'),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: _handleReset,
                  child: const Text('Reset'),
                ),
              ],
            ),
          );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        canvas,
        controls,
      ],
    );
  }
}

// ---------- Slot box (tight text; word-by-word wrap; minimal padding) ----------
class _SlotBox extends StatelessWidget {
  final Widget child;
  final TextStyle textStyle;
  final StrutStyle strut;
  final TextHeightBehavior thb;
  final bool isImage;
  final bool scrollableText;

  const _SlotBox({
    required this.child,
    required this.textStyle,
    required this.strut,
    required this.thb,
    required this.isImage,
    this.scrollableText = true,
  });

  bool _isPlainText(Widget w) => w is Text && w.data != null;

  @override
  Widget build(BuildContext context) {
    const textPadding = EdgeInsets.symmetric(horizontal: 6, vertical: 18);
    const imagePadding = EdgeInsets.symmetric(horizontal: 4, vertical: 5);

    Widget content = child;

    if (_isPlainText(child)) {
      // Word-by-word wrap => never breaks inside a word.
      final t = child as Text;
      final words = t.data!.split(RegExp(r'\s+'));
      final wordWrap = Wrap(
        spacing: 4,
        runSpacing: 0,
        children: [
          for (final w in words)
            Text(w,
                style: textStyle, strutStyle: strut, textHeightBehavior: thb),
        ],
      );
      content = scrollableText
          ? SingleChildScrollView(primary: false, child: wordWrap)
          : wordWrap;
    } else if (child is Text && (child as Text).textSpan != null) {
      final t = child as Text;
      final rich = RichText(
        text: t.textSpan!,
        textAlign: t.textAlign ?? TextAlign.start,
        textDirection: t.textDirection,
        strutStyle: strut,
        textHeightBehavior: thb,
      );
      content = scrollableText
          ? SingleChildScrollView(primary: false, child: rich)
          : rich;
    } else if (child is RichText) {
      final r = child as RichText;
      final rich = RichText(
        text: r.text,
        textAlign: r.textAlign,
        textDirection: r.textDirection,
        strutStyle: strut,
        textHeightBehavior: thb,
      );
      content = scrollableText
          ? SingleChildScrollView(primary: false, child: rich)
          : rich;
    } else if (isImage) {
      content = Center(child: FittedBox(fit: BoxFit.contain, child: child));
    } else {
      content = Center(child: FittedBox(fit: BoxFit.contain, child: child));
    }

    return Container(
      padding: isImage ? imagePadding : textPadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12, width: 1),
        boxShadow: const [
          BoxShadow(
            blurRadius: 2,
            spreadRadius: 0,
            offset: Offset(0, 1),
            color: Colors.black12,
          )
        ],
      ),
      alignment: isImage ? Alignment.center : Alignment.centerLeft,
      child: content,
    );
  }
}

// ---------- Metrics helper ----------
class _Metrics {
  final double slotH;
  final double between;
  final double top; // top == bottom when centered

  const _Metrics(
      {required this.slotH, required this.between, required this.top});
  const _Metrics.zero()
      : slotH = 0,
        between = 0,
        top = 0;
}

// ---------- Lines painter (curved green connections) ----------
class _LinesPainter extends CustomPainter {
  final int leftCount;
  final int rightCount;
  final Rect Function(int i) leftRect;
  final Rect Function(int j) rightRect;
  final Map<int, int> connections;
  final int? draggingFrom;
  final Offset? dragPos;

  _LinesPainter({
    required this.leftCount,
    required this.rightCount,
    required this.leftRect,
    required this.rightRect,
    required this.connections,
    required this.draggingFrom,
    required this.dragPos,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    connections.forEach((l, r) {
      if (l < 0 || r < 0 || l >= leftCount || r >= rightCount) return;
      final a = leftRect(l);
      final b = rightRect(r);
      final start = Offset(a.right, a.center.dy);
      final end = Offset(b.left, b.center.dy);
      _curve(canvas, paint, start, end);
    });

    if (draggingFrom != null &&
        dragPos != null &&
        draggingFrom! >= 0 &&
        draggingFrom! < leftCount) {
      final a = leftRect(draggingFrom!);
      final start = Offset(a.right, a.center.dy);
      _curve(canvas, paint, start, dragPos!);
    }
  }

  void _curve(Canvas canvas, Paint paint, Offset start, Offset end) {
    final control = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _LinesPainter old) {
    return old.connections != connections ||
        old.draggingFrom != draggingFrom ||
        old.dragPos != dragPos ||
        old.leftRect != leftRect ||
        old.rightRect != rightRect;
  }
}

// ---------- Offstage size measurer ----------
class _MeasureSize extends StatefulWidget {
  final Widget child;
  final void Function(Size) onChange;

  const _MeasureSize({required this.child, required this.onChange});

  @override
  State<_MeasureSize> createState() => _MeasureSizeState();
}

class _MeasureSizeState extends State<_MeasureSize> {
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final box = context.findRenderObject() as RenderBox?;
      if (box != null) widget.onChange(box.size);
    });
    return widget.child;
  }
}
