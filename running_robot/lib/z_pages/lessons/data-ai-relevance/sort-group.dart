// FILE: lib/z_pages/lessons/data-ai-relevance/sort_group.dart
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show Ticker;
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';

/// Colors
const Color aiPink = Color(0xFFE91E63);
const Color titleInk = Colors.black87;
const Color brandBlue = Color(0xFF1E88E5);

/// Global loop delay between animations
const Duration loopDelay = Duration(seconds: 2);

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
            // Header
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

enum _Phase { dropping, clustering, showBoxes, toBoxes, done }

class _ClusterScene extends StatefulWidget {
  final VoidCallback? onCompleted;
  const _ClusterScene({required this.onCompleted});

  @override
  State<_ClusterScene> createState() => _ClusterSceneState();
}

class _ClusterSceneState extends State<_ClusterScene>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Size _size = Size.zero;
  _Phase _phase = _Phase.dropping;

  static const double _g = 720.0;
  static const double _emojiSize = 28.0; // smaller
  static const double _tilePad = 6.0;
  static const double _boxesHeight = 120.0;
  static const double _boxesBottomPad = 10.0;
  static const double _groundMargin = _boxesHeight + _boxesBottomPad + 40.0;

  final Random _rnd = Random();
  List<_Thing> _things = <_Thing>[];

  // Only 2 cluster centers (TL + TR)
  List<Offset> _clusterCenters = const [Offset.zero, Offset.zero];
  final List<Color> _groupColors = const [Colors.indigo, Colors.teal];

  DateTime _clusterStart = DateTime.now();
  bool _doneNotified = false;

  bool _boxesVisible = false;
  double _boxesProgress = 0.0;
  double _mapProgress = 0.0;
  Rect? _box1, _box2;

  @override
  void initState() {
    super.initState();
    _things = _seedThings();
    _ticker = createTicker(_tick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  List<_Thing> _seedThings() {
    final List<_Thing> list = [];

    const List<String> animals = ["🐶", "🐱", "🐼", "🦊"];
    const List<String> faces = ["😀", "😢", "🤩"];

    final List<_Seed> seeds = <_Seed>[
      for (final e in animals) _Seed(e, 0),
      for (final e in faces) _Seed(e, 1),
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
        fadeInMs: 1000 + _rnd.nextInt(400),
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
                t.vel = Offset(0, _rnd.nextDouble() * 60 + 35);
                t.spawned = true;
                t.spawnAt =
                    now.subtract(Duration(milliseconds: _rnd.nextInt(300)));
              }
              final fade = ((now.millisecondsSinceEpoch -
                          t.spawnAt.millisecondsSinceEpoch) /
                      t.fadeInMs)
                  .clamp(0.0, 1.0);
              t.alpha = Curves.easeOutCubic.transform(fade);

              t.vel = t.vel + const Offset(0, _g * dt);
              double nextY = t.pos.dy + t.vel.dy * dt;
              if (nextY > groundY) {
                nextY = groundY;
                t.vel = Offset.zero;
              }
              t.pos = Offset(t.pos.dx, nextY);
            }

            if (_things.every((t) => (t.pos.dy - groundY).abs() < 0.75)) {
              _startClustering();
            }
            break;
          }

        case _Phase.clustering:
          {
            final now = DateTime.now();
            for (final t in _things) {
              final raw = ((now.millisecondsSinceEpoch -
                          t.legStart.millisecondsSinceEpoch) /
                      t.legDurMs)
                  .clamp(0.0, 1.0);
              final e = Curves.easeInOutCubic.transform(raw);
              t.pos = Offset(
                _lerp(t.startPos.dx, t.target!.dx, e),
                _lerp(t.startPos.dy, t.target!.dy, e),
              );
            }
            if (DateTime.now().difference(_clusterStart).inMilliseconds >
                3000) {
              _phase = _Phase.showBoxes;
              _boxesVisible = true;
              _boxesProgress = 0.0;
              _mapProgress = 0.0;
            }
            break;
          }

        case _Phase.showBoxes:
          {
            _boxesProgress = (_boxesProgress + dt / 0.7).clamp(0.0, 1.0);
            _mapProgress = (_mapProgress + dt / 0.8).clamp(0.0, 1.0);

            if (_boxesProgress >= 1.0) {
              _assignTargetsToBoxCorners();
              final now = DateTime.now();
              for (final t in _things) {
                t.startPos = t.pos;
                final int delay = 120 + _rnd.nextInt(220);
                t.legStart = now.add(Duration(milliseconds: delay));
                t.legDurMs = 1200 + _rnd.nextInt(300);
              }
              _phase = _Phase.toBoxes;
            }
            break;
          }

        case _Phase.toBoxes:
          {
            final now = DateTime.now();
            bool allArrived = true;

            for (final t in _things) {
              final raw = ((now.millisecondsSinceEpoch -
                          t.legStart.millisecondsSinceEpoch) /
                      t.legDurMs)
                  .clamp(0.0, 1.0);
              final e = Curves.easeInOutCubic.transform(raw);

              t.pos = Offset(
                _lerp(t.startPos.dx, t.target!.dx, e),
                _lerp(t.startPos.dy, t.target!.dy, e),
              );
              t.scale =
                  _lerp(1.0, t.boxScale, Curves.easeOutCubic.transform(e));

              if (raw < 0.999) allArrived = false;
            }
            _mapProgress = min(1.0, _mapProgress + dt / 1.6);

            if (allArrived && !_doneNotified) {
              _doneNotified = true;
              Future.delayed(const Duration(milliseconds: 700), () {
                if (!mounted) return;
                widget.onCompleted?.call();
                _phase = _Phase.done;

                // ⬅️ restart after loopDelay
                Future.delayed(loopDelay, () {
                  if (!mounted) return;
                  _restartAnimation();
                });
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
        _clusterCenters = [
          Offset(_size.width * 0.18, _size.height * 0.25), // far left
          Offset(_size.width * 0.82, _size.height * 0.25), // far right
        ];
        _layoutBoxes();
      }

      return Stack(
        children: [
          // background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black26, width: 1.2),
              ),
            ),
          ),
          // halos visible during clustering
          if (_phase == _Phase.clustering ||
              _phase == _Phase.showBoxes ||
              _phase == _Phase.toBoxes)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _ClusterHaloPainter(
                    centers: _clusterCenters,
                    colors: _groupColors,
                    visible: true,
                  ),
                ),
              ),
            ),
          // emojis
          for (final t in _things)
            Positioned(
              left: t.pos.dx,
              top: t.pos.dy,
              child: Opacity(
                opacity: t.alpha,
                child: Transform.scale(
                  scale: t.scale,
                  alignment: Alignment.center,
                  child: _emojiTile(t.emoji, t.category),
                ),
              ),
            ),
          // boxes
          if (_boxesVisible && _box1 != null && _box2 != null)
            ..._buildBoxesLayer(),
        ],
      );
    });
  }

  void _restartAnimation() {
    setState(() {
      _phase = _Phase.dropping;
      _things = _seedThings();
      _boxesVisible = false;
      _boxesProgress = 0.0;
      _mapProgress = 0.0;
      _doneNotified = false;
    });
  }

  void _startClustering() {
    _phase = _Phase.clustering;
    _clusterStart = DateTime.now();
    final now = DateTime.now();

    for (final t in _things) {
      t.startPos = t.pos;
      final Offset center = _clusterCenters[t.category];
      final Offset jitter = _randomRing(10, 40);
      t.target = center + jitter;
      final int delay = 160 + _rnd.nextInt(240);
      t.legStart = now.add(Duration(milliseconds: delay));
      t.legDurMs = 1400 + _rnd.nextInt(320);
    }
  }

  void _layoutBoxes() {
    const double pad = 20;
    final double top = _size.height - _boxesHeight - _boxesBottomPad;
    final double usableW = _size.width - pad * 2 - 12;
    final double boxW = usableW / 2.0;

    _box1 = Rect.fromLTWH(pad, top, boxW, _boxesHeight);
    _box2 = Rect.fromLTWH(pad + boxW + 12, top, boxW, _boxesHeight);
  }

  List<Widget> _buildBoxesLayer() {
    final double s =
        _lerp(0.90, 1.0, Curves.easeOutCubic.transform(_boxesProgress));
    final double a = _boxesProgress;

    return [
      _boxWidget(_box1!, "Group 1", _groupColors[0], a, s),
      _boxWidget(_box2!, "Group 2", _groupColors[1], a, s),
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

  Widget _emojiTile(String emoji, int category) {
    final color = _groupColors[category];
    return Container(
      padding: const EdgeInsets.all(_tilePad),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.7), width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(2, 2)),
        ],
      ),
      child: Text(emoji, style: const TextStyle(fontSize: _emojiSize)),
    );
  }

  void _assignTargetsToBoxCorners() {
    final Map<int, Rect> boxForCat = {0: _box1!, 1: _box2!};

    for (int cat = 0; cat < 2; cat++) {
      final members = _things.where((t) => t.category == cat).toList();
      final Rect box = boxForCat[cat]!;

      const double pad = 12;
      final Offset tl = Offset(box.left + pad, box.top + pad);
      final Offset tr =
          Offset(box.right - pad - (_emojiSize + _tilePad * 2), box.top + pad);
      final Offset bl = Offset(
          box.left + pad, box.bottom - pad - (_emojiSize + _tilePad * 2));
      final Offset br = Offset(box.right - pad - (_emojiSize + _tilePad * 2),
          box.bottom - pad - (_emojiSize + _tilePad * 2));

      final List<Offset> cornerOrder = [tl, tr, bl, br];
      for (int i = 0; i < members.length; i++) {
        final t = members[i];
        final Offset base = cornerOrder[min(i, cornerOrder.length - 1)];
        final double jx = (i.isEven ? 1 : -1) * 2.0;
        final double jy = (i % 3 == 0 ? -1 : 1) * 1.5;
        t.target = base + Offset(jx, jy);
        t.boxScale = 0.8;
      }
    }
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;
  Offset _randomRing(double minR, double maxR) {
    final double a = _rnd.nextDouble() * pi * 2;
    final double r = minR + _rnd.nextDouble() * (maxR - minR);
    return Offset(cos(a) * r, sin(a) * r);
  }
}

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
    if (!visible) return;
    const double radius = 60;
    for (int i = 0; i < centers.length; i++) {
      final p = Paint()
        ..color = colors[i].withOpacity(0.10)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(centers[i], radius, p);

      final s = Paint()
        ..color = colors[i].withOpacity(0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(centers[i], radius, s);
    }
  }

  @override
  bool shouldRepaint(covariant _ClusterHaloPainter old) =>
      old.centers != centers || old.colors != colors || old.visible != visible;
}

class _Thing {
  final String emoji;
  final int category;
  Offset pos;
  Offset vel;
  Offset startPos;
  Offset? target;
  bool spawned;
  DateTime spawnAt;
  int fadeInMs;
  double alpha = 0.0;
  DateTime legStart;
  int legDurMs;
  double scale;
  double boxScale = 0.8;

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
