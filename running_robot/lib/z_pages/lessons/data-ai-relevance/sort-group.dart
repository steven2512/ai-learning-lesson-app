// FILE: lib/z_pages/lessons/data-ai-relevance/sort_group.dart
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show Ticker; // ✅ createTicker/Ticker
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';

/// Colors (consistent with other slides)
const Color aiPink = Color(0xFFE91E63);
const Color titleInk = Colors.black87;
const Color brandBlue = Color(0xFF1E88E5);

const double headerFontSize = 20;
const double sceneHeight = 360;

class SortGroup extends StatelessWidget {
  final VoidCallback? onCompleted;
  const SortGroup({super.key, this.onCompleted});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header — EXACT phrasing
            LessonText.box(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Center(
                child: LessonText.sentence([
                  LessonText.word("AI", aiPink,
                      fontSize: headerFontSize, fontWeight: FontWeight.w900),
                  LessonText.word("can", titleInk, fontSize: headerFontSize),
                  LessonText.word("group", brandBlue,
                      fontSize: headerFontSize, fontWeight: FontWeight.w900),
                  LessonText.word("things", brandBlue,
                      fontSize: headerFontSize),
                  LessonText.word("without", brandBlue,
                      fontSize: headerFontSize),
                  LessonText.word("labels", brandBlue,
                      fontSize: headerFontSize, fontWeight: FontWeight.w900),
                ]),
              ),
            ),

            // Animation scene
            LessonText.box(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                height: sceneHeight,
                child: _ClusterScene(onCompleted: onCompleted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────
/// Drop → Cluster (corners) with halos → Boxes fade-in
/// → Glide (staggered) into BOX CORNERS + guide lines
/// ─────────────────────────────────────────────────────────────
class _ClusterScene extends StatefulWidget {
  final VoidCallback? onCompleted;
  const _ClusterScene({required this.onCompleted});

  @override
  State<_ClusterScene> createState() => _ClusterSceneState();
}

enum _Phase { dropping, clustering, showBoxes, toBoxes, done }

class _ClusterSceneState extends State<_ClusterScene>
    with SingleTickerProviderStateMixin {
  // Ticker
  late final Ticker _ticker;

  // Layout
  Size _size = Size.zero;

  // Phase
  _Phase _phase = _Phase.dropping;

  // Physics (slower so audience can follow)
  static const double _g = 720.0; // px/s^2 (↓ from 1150)
  static const double _emojiSize = 34.0;
  static const double _tilePad = 8.0;

  // Scene structure
  static const double _boxesHeight = 120.0; // ↑ to prevent overflow
  static const double _boxesBottomPad = 10.0;
  static const double _groundMargin =
      _boxesHeight + _boxesBottomPad + 40.0; // "floor" above boxes

  // Item set (10 total) → 4 / 3 / 3
  final Random _rnd = Random();
  List<_Thing> _things = <_Thing>[];

  // Cluster centers (TL, TR, BL)
  List<Offset> _clusterCenters = const [Offset.zero, Offset.zero, Offset.zero];
  final List<Color> _groupColors = const [
    Colors.indigo,
    Colors.teal,
    Colors.deepOrange
  ];

  // Timing
  DateTime _clusterStart = DateTime.now();
  bool _doneNotified = false;

  // Boxes
  bool _boxesVisible = false;
  double _boxesProgress = 0.0; // 0..1 (fade+scale)
  double _mapProgress = 0.0; // 0..1 guide-line progress
  Rect? _box1, _box2, _box3;

  @override
  void initState() {
    super.initState();
    _things = _seedThings(); // create 10 with 3 groups
    _ticker = createTicker(_tick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  // 10 emojis: Animals (4), Faces (3), Foods (3)
  List<_Thing> _seedThings() {
    final List<_Thing> list = [];

    const List<String> animals = ["🐶", "🐱", "🐼", "🦊"]; // 4
    const List<String> faces = ["😀", "😢", "🤩"]; // 3
    const List<String> foods = ["🍎", "🍕", "🍩"]; // 3

    final List<_Seed> seeds = <_Seed>[
      for (final e in animals) _Seed(e, 0),
      for (final e in faces) _Seed(e, 1),
      for (final e in foods) _Seed(e, 2),
    ]..shuffle(_rnd);

    final now = DateTime.now();

    for (final s in seeds) {
      list.add(_Thing(
        emoji: s.emoji,
        category: s.cat,
        pos: const Offset(-9999, -9999),
        vel: Offset.zero,
        startPos: Offset.zero,
        target: null,
        spawned: false,
        spawnAt: now,
        fadeInMs: 1000 + _rnd.nextInt(400), // slower fade-in
        legStart: now,
        legDurMs: 0,
        scale: 1.0,
      ));
    }
    return list;
  }

  void _tick(Duration elapsed) {
    if (!mounted || _size == Size.zero) return;

    const double dt = 1 / 60.0;
    final double groundY = _size.height - _groundMargin;

    setState(() {
      switch (_phase) {
        case _Phase.dropping:
          {
            final now = DateTime.now();
            for (final t in _things) {
              if (!t.spawned) {
                final double x = _rnd.nextDouble() *
                        (_size.width - 2 * _tilePad - _emojiSize) +
                    _tilePad;
                final double y = -(_rnd.nextDouble() * 160 + 40);
                t.pos = Offset(x, y);
                t.vel = Offset(0, _rnd.nextDouble() * 60 + 35); // slower
                t.spawned = true;
                t.spawnAt =
                    now.subtract(Duration(milliseconds: _rnd.nextInt(300)));
              }

              // fade-in (ease)
              final fade = ((now.millisecondsSinceEpoch -
                          t.spawnAt.millisecondsSinceEpoch) /
                      t.fadeInMs)
                  .clamp(0.0, 1.0);
              t.alpha = _easeOut(fade);

              // physics
              t.vel = t.vel + const Offset(0, _g * dt);
              double nextY = t.pos.dy + t.vel.dy * dt;
              if (nextY > groundY) {
                nextY = groundY;
                t.vel = Offset.zero;
              }
              t.pos = Offset(t.pos.dx, nextY);
            }

            // All landed? → brief hold then cluster
            bool landed = true;
            for (final t in _things) {
              if ((t.pos.dy - groundY).abs() > 0.75) {
                landed = false;
                break;
              }
            }
            if (landed) {
              _startClustering();
            }
            break;
          }

        case _Phase.clustering:
          {
            // Slow, readable glide to cluster corners with stagger
            final now = DateTime.now();
            for (final t in _things) {
              final double raw = ((now.millisecondsSinceEpoch -
                          t.legStart.millisecondsSinceEpoch) /
                      t.legDurMs)
                  .clamp(0.0, 1.0);
              final double e = _easeInOut(raw);
              t.pos = Offset(
                _lerp(t.startPos.dx, t.target!.dx, e),
                _lerp(t.startPos.dy, t.target!.dy, e),
              );
            }

            // after ~2.4s of clustering, start showing boxes
            final int ms =
                DateTime.now().difference(_clusterStart).inMilliseconds;
            if (ms > 2400) {
              _phase = _Phase.showBoxes;
              _boxesVisible = true;
              _boxesProgress = 0.0;
              _mapProgress = 0.0;
            }
            break;
          }

        case _Phase.showBoxes:
          {
            // fade+scale in ~700ms + draw guide lines
            _boxesProgress = (_boxesProgress + dt / 0.7).clamp(0.0, 1.0);
            _mapProgress = (_mapProgress + dt / 0.8).clamp(0.0, 1.0);

            if (_boxesProgress >= 1.0) {
              _assignTargetsToBoxCorners(); // ← place in CORNERS
              // setup slow glide to boxes
              final now = DateTime.now();
              for (final t in _things) {
                t.startPos = t.pos;
                final int delay = 120 + _rnd.nextInt(220); // readable stagger
                t.legStart = now.add(Duration(milliseconds: delay));
                t.legDurMs = 1200 + _rnd.nextInt(300); // slower/easy to track
              }
              _phase = _Phase.toBoxes;
            }
            break;
          }

        case _Phase.toBoxes:
          {
            // glide from cluster → box corners with ease
            final now = DateTime.now();
            bool allArrived = true;

            for (final t in _things) {
              final double raw = ((now.millisecondsSinceEpoch -
                          t.legStart.millisecondsSinceEpoch) /
                      t.legDurMs)
                  .clamp(0.0, 1.0);
              final double e = _easeInOut(raw);

              t.pos = Offset(
                _lerp(t.startPos.dx, t.target!.dx, e),
                _lerp(t.startPos.dy, t.target!.dy, e),
              );
              t.scale = _lerp(1.0, t.boxScale, _easeOut(e));

              if (raw < 0.999) allArrived = false;
            }

            // keep guide lines visible; then fade a bit at the end
            _mapProgress = min(1.0, _mapProgress + dt / 1.6);

            if (allArrived && !_doneNotified) {
              _doneNotified = true;
              Future.delayed(const Duration(milliseconds: 700), () {
                if (!mounted) return;
                widget.onCompleted?.call();
                _phase = _Phase.done;
              });
            }
            break;
          }

        case _Phase.done:
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, cts) {
      final Size newSize = Size(cts.maxWidth, cts.maxHeight);
      if (newSize != _size) {
        _size = newSize;

        // cluster corners (TL / TR / BL)
        _clusterCenters = <Offset>[
          Offset(_size.width * 0.18, _size.height * 0.24), // TL
          Offset(_size.width * 0.82, _size.height * 0.24), // TR
          Offset(_size.width * 0.26, _size.height * 0.52), // BL
        ];

        // recompute boxes rects if needed
        _layoutBoxes();
      }

      return Stack(
        children: [
          // playfield
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black26, width: 1.2),
              ),
            ),
          ),

          // faint floor line (above the boxes)
          Positioned(
            left: 10,
            right: 10,
            bottom: _boxesHeight + _boxesBottomPad + 35.0,
            child: Opacity(
              opacity: 0.10,
              child: Container(height: 2, color: Colors.black),
            ),
          ),

          // cluster halos (help the audience "see" the groups)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _ClusterHaloPainter(
                  centers: _clusterCenters,
                  colors: _groupColors,
                  visible: _phase == _Phase.clustering ||
                      _phase == _Phase.showBoxes ||
                      _phase == _Phase.toBoxes,
                ),
              ),
            ),
          ),

          // guide lines from clusters → boxes
          if (_boxesVisible && _box1 != null && _box2 != null && _box3 != null)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _GuideLinePainter(
                    centers: _clusterCenters,
                    boxes: [_box1!, _box2!, _box3!],
                    colors: _groupColors,
                    progress: _mapProgress,
                  ),
                ),
              ),
            ),

          // items
          for (final t in _things)
            Positioned(
              left: t.pos.dx,
              top: t.pos.dy,
              child: Opacity(
                opacity: t.alpha,
                child: Transform.scale(
                  scale: t.scale,
                  alignment: Alignment.center,
                  child: _emojiTile(t.emoji),
                ),
              ),
            ),

          // boxes (fade+scale in)
          if (_boxesVisible && _box1 != null && _box2 != null && _box3 != null)
            ..._buildBoxesLayer(),
        ],
      );
    });
  }

  // ───────────────────────────────── helpers ────────────────────────────────
  void _startClustering() {
    _phase = _Phase.clustering;
    _clusterStart = DateTime.now();
    final now = DateTime.now();

    // leg: from landed → cluster corner (+ slight jitter)
    for (final t in _things) {
      t.startPos = t.pos;
      final Offset center = _clusterCenters[t.category];

      // jitter ring (so you can see several points in the cluster)
      final Offset jitter = _randomRing(16, 54);
      t.target = center + jitter;

      // readable stagger + slower leg
      final int delay = 160 + _rnd.nextInt(240);
      t.legStart = now.add(Duration(milliseconds: delay));
      t.legDurMs = 1400 + _rnd.nextInt(320);
    }
  }

  void _layoutBoxes() {
    // 3 roomy boxes along the bottom
    const double pad = 10;
    final double top = _size.height - _boxesHeight - _boxesBottomPad;
    const double gap = 12;
    final double usableW = _size.width - pad * 2 - gap * 2;
    final double boxW = usableW / 3.0;

    _box1 = Rect.fromLTWH(pad, top, boxW, _boxesHeight);
    _box2 = Rect.fromLTWH(pad + boxW + gap, top, boxW, _boxesHeight);
    _box3 = Rect.fromLTWH(pad + (boxW + gap) * 2, top, boxW, _boxesHeight);
  }

  List<Widget> _buildBoxesLayer() {
    final double s = _lerp(0.90, 1.0, _easeOut(_boxesProgress));
    final double a = _boxesProgress;

    return <Widget>[
      _boxWidget(_box1!, "Group 1", _groupColors[0], a, s),
      _boxWidget(_box2!, "Group 2", _groupColors[1], a, s),
      _boxWidget(_box3!, "Group 3", _groupColors[2], a, s),
    ];
  }

  Widget _boxWidget(
      Rect r, String label, Color color, double alpha, double scale) {
    return Positioned.fromRect(
      rect: r,
      child: Opacity(
        opacity: alpha,
        child: Transform.scale(
          scale: scale,
          alignment: Alignment.center,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: color, width: 2),
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Text(label,
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: color,
                    )),
                const Spacer(),
                Opacity(
                  opacity: 0.25,
                  child: Text("⬇️",
                      style: GoogleFonts.lato(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: color,
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emojiTile(String emoji) {
    return Container(
      padding: const EdgeInsets.all(_tilePad),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black26, width: 1.6),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(2, 2)),
        ],
      ),
      child: Text(emoji, style: const TextStyle(fontSize: _emojiSize)),
    );
  }

  /// Put members in the *corners* of each box (TL/TR/BL/BR order).
  void _assignTargetsToBoxCorners() {
    final Map<int, Rect> boxForCat = <int, Rect>{
      0: _box1!,
      1: _box2!,
      2: _box3!
    };

    for (int cat = 0; cat < 3; cat++) {
      final List<_Thing> members =
          _things.where((t) => t.category == cat).toList();
      final Rect box = boxForCat[cat]!;

      // four corners with small inner padding
      const double pad = 12;
      final Offset tl = Offset(box.left + pad, box.top + pad);
      final Offset tr =
          Offset(box.right - pad - (_emojiSize + _tilePad * 2), box.top + pad);
      final Offset bl = Offset(
          box.left + pad, box.bottom - pad - (_emojiSize + _tilePad * 2));
      final Offset br = Offset(box.right - pad - (_emojiSize + _tilePad * 2),
          box.bottom - pad - (_emojiSize + _tilePad * 2));

      final List<Offset> cornerOrder = <Offset>[tl, tr, bl, br];

      // scale down slightly inside boxes
      for (int i = 0; i < members.length; i++) {
        final _Thing t = members[i];
        final Offset base = cornerOrder[min(i, cornerOrder.length - 1)];
        // tiny jitter to avoid exact overlap if <4 items
        final double jx = (i.isEven ? 1 : -1) * 2.0;
        final double jy = (i % 3 == 0 ? -1 : 1) * 1.5;
        t.target = base + Offset(jx, jy);
        t.boxScale = 0.84; // gentle scale-in for neat fit
      }
    }
  }

  // math bits
  double _lerp(double a, double b, double t) => a + (b - a) * t;
  Offset _randomRing(double minR, double maxR) {
    final double a = _rnd.nextDouble() * pi * 2;
    final double r = minR + _rnd.nextDouble() * (maxR - minR);
    return Offset(cos(a) * r, sin(a) * r);
  }

  // easing
  double _easeInOut(double x) =>
      Curves.easeInOutCubic.transform(x.clamp(0.0, 1.0));
  double _easeOut(double x) => Curves.easeOutCubic.transform(x.clamp(0.0, 1.0));
}

/// Soft colored halos to make clusters obvious
class _ClusterHaloPainter extends CustomPainter {
  final List<Offset> centers;
  final List<Color> colors;
  final bool visible;

  _ClusterHaloPainter({
    required this.centers,
    required this.colors,
    required this.visible,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!visible || centers.length < 3) return;

    final List<double> radii = <double>[46, 46, 46];
    for (int i = 0; i < 3; i++) {
      final Paint p = Paint()
        ..color = colors[i].withOpacity(0.08)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(centers[i], radii[i], p);

      final Paint stroke = Paint()
        ..color = colors[i].withOpacity(0.28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6;
      canvas.drawCircle(centers[i], radii[i], stroke);
    }
  }

  @override
  bool shouldRepaint(covariant _ClusterHaloPainter oldDelegate) {
    return oldDelegate.centers != centers ||
        oldDelegate.colors != colors ||
        oldDelegate.visible != visible;
  }
}

/// Guide lines from cluster centers to the middle-top of each box.
class _GuideLinePainter extends CustomPainter {
  final List<Offset> centers;
  final List<Rect> boxes;
  final List<Color> colors;
  final double progress; // 0..1

  _GuideLinePainter({
    required this.centers,
    required this.boxes,
    required this.colors,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final int n = min(3, min(centers.length, boxes.length));
    for (int i = 0; i < n; i++) {
      final Offset start = centers[i];
      final Rect b = boxes[i];
      final Offset end = Offset(b.center.dx, b.top); // aim to top center
      final Offset mid = Offset(
          lerpDouble(start.dx, end.dx, 0.5)!, min(start.dy, end.dy) - 30);

      // Draw a quadratic curve (start → mid → end), partial by progress
      final Path full = Path()
        ..moveTo(start.dx, start.dy)
        ..quadraticBezierTo(mid.dx, mid.dy, end.dx, end.dy);

      final PathMetric? pm =
          full.computeMetrics().isEmpty ? null : full.computeMetrics().first;
      if (pm == null) continue;

      final double len = pm.length * progress.clamp(0.0, 1.0);
      final Path partial = pm.extractPath(0, len);

      final Paint p = Paint()
        ..color = colors[i].withOpacity(0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawPath(partial, p);
    }
  }

  @override
  bool shouldRepaint(covariant _GuideLinePainter oldDelegate) {
    return oldDelegate.centers != centers ||
        oldDelegate.boxes != boxes ||
        oldDelegate.colors != colors ||
        oldDelegate.progress != progress;
  }
}

class _Thing {
  final String emoji;
  final int category; // 0,1,2

  // motion
  Offset pos;
  Offset vel;
  Offset startPos;
  Offset? target;

  // lifecycle
  bool spawned;
  DateTime spawnAt;
  int fadeInMs;
  double alpha = 0.0;

  // legs (cluster leg, box leg)
  DateTime legStart;
  int legDurMs;

  // visuals
  double scale;
  double boxScale = 0.84;

  _Thing({
    required this.emoji,
    required this.category,
    required this.pos,
    required this.vel,
    required this.startPos,
    required this.target,
    required this.spawned,
    required this.spawnAt,
    required this.fadeInMs,
    required this.legStart,
    required this.legDurMs,
    required this.scale,
  });
}

class _Seed {
  final String emoji;
  final int cat;
  const _Seed(this.emoji, this.cat);
}
