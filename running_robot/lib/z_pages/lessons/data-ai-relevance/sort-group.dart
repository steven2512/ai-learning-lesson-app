// FILE: lib/z_pages/lessons/data-ai-relevance/sort_group.dart
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show Ticker;
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/z_pages/assets/lessonAssets/helpful_tools.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// GLOBAL TUNING
/// ─────────────────────────────────────────────────────────────────────────
const Color aiPink = Color(0xFFE91E63);
const Color titleInk = Colors.black87;
const Color brandBlue = Color(0xFF1E88E5);

/// Loop + phase timing
const Duration loopDelay = Duration(milliseconds: 500);
const int kExtraMsPerLeg = 2000; // slower clustering & toBoxes
const int kExtraMsAfterDrop = 2000; // hold after landing
const double fadeOutSeconds = 0.8; // content fade-out duration

/// Cluster/halo layout (auto top-left/right, safely inside edges)
const double haloRadius = 60; // halo circle radius
const double clusterEdgeInset = 14; // min distance from playfield edge
const double haloFadeInSeconds = 0.6; // halos fade in

/// Emoji visuals
const double emojiSize = 28.0;
const double emojiPad = 6.0;
const double emojiBorder = 2.0; // used for containment math

/// Spread of emojis inside a halo
const double clusterMaxRadiusUser = 34; // cap; real cap computed safely

/// Scene layout
const double headerFontSize = 20;
const double sceneHeight = 360;

/// Boxes layout
const double _boxesHeight = 120.0;
const double _boxesBottomPad = 10.0;

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
            Center(
              child: LessonText.word(
                "Example 2",
                Colors.red,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 20),
            LessonText.box(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Center(
                child: LessonText.sentence([
                  LessonText.word("AI", aiPink,
                      fontSize: headerFontSize, fontWeight: FontWeight.w900),
                  LessonText.word("can", titleInk, fontSize: headerFontSize),
                  LessonText.word("group", brandBlue,
                      fontSize: headerFontSize, fontWeight: FontWeight.w900),
                  LessonText.word("things", brandBlue,
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

enum _Phase { dropping, clustering, showBoxes, toBoxes, fading }

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
  static const double _g = 620.0;

  // ground is above boxes
  static const double _groundMargin = _boxesHeight + _boxesBottomPad + 40.0;

  final Random _rnd = Random();

  List<_Thing> _things = <_Thing>[];

  // persist seed order after first run so relaunch uses same items/ordering
  List<_Seed>? _seedOrder;

  // persist spawn plan (first run random; reused on loops)
  List<_Spawn>? _spawnPlan;
  Size? _spawnPlanForSize; // regenerate plan if size changes

  // cluster centers (computed to hug corners safely)
  List<Offset> _clusterCenters = const [Offset.zero, Offset.zero];
  final List<Color> _groupColors = const [Colors.indigo, Colors.teal];

  DateTime _clusterStart = DateTime.now();
  bool _postDropHoldStarted = false;
  late DateTime _postDropUntil;

  bool _boxesVisible = false;
  double _boxesProgress = 0.0;

  Rect? _box1, _box2;

  // halos fade
  double _haloAlpha = 0.0;

  // content fade (background stays visible)
  double _contentOpacity = 1.0;
  double _fadeElapsed = 0.0;

  double get _tileExtent => emojiSize + 2 * emojiPad + 2 * emojiBorder;

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
    final list = <_Thing>[];

    _seedOrder ??= () {
      const animals = ["🐶", "🐱", "🐼", "🦊"];
      const faces = ["😀", "😢", "🤩", "😎"];
      final seeds = <_Seed>[
        for (final e in animals) _Seed(e, 0),
        for (final e in faces) _Seed(e, 1),
      ]..shuffle(_rnd); // random only once
      return seeds;
    }();

    final now = DateTime.now();
    for (final s in _seedOrder!) {
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

  // spawn plan built once (per size), reused every loop
  void _ensureSpawnPlan() {
    if (_spawnPlan != null && _spawnPlanForSize == _size) return;
    if (_size == Size.zero) return;

    final plan = <_Spawn>[];
    final int n = _things.length;

    // Center-biased X (falls toward middle) — triangular distribution
    final double tile = _tileExtent;
    final double minX = emojiPad;
    final double maxX =
        (_size.width - tile - emojiPad).clamp(minX, _size.width - tile);
    final double xCenter = (_size.width - tile) / 2.0;
    final double spread =
        (_size.width - tile) * 0.38; // how wide to allow from center

    double sampleX() {
      final double tri =
          (_rnd.nextDouble() - _rnd.nextDouble()) * spread; // peak at 0
      return (xCenter + tri).clamp(minX, maxX);
    }

    for (int i = 0; i < n; i++) {
      final double x = sampleX();
      final double y = -(_rnd.nextDouble() * 160 + 40);
      final double vy = 0.0; // calm start
      final int fadeIn = 1000 + _rnd.nextInt(400);
      plan.add(_Spawn(x: x, y: y, vy: vy, fadeInMs: fadeIn));
    }
    _spawnPlan = plan;
    _spawnPlanForSize = _size;
  }

  void _tick(Duration elapsed) {
    if (!mounted || _size == Size.zero) return;
    const double dt = 1 / 60.0;
    final double groundY = _size.height - _groundMargin;

    setState(() {
      switch (_phase) {
        case _Phase.dropping:
          {
            _ensureSpawnPlan();

            final now = DateTime.now();
            for (int i = 0; i < _things.length; i++) {
              final t = _things[i];
              if (!t.spawned) {
                final sp = _spawnPlan![i];
                t.pos = Offset(sp.x, sp.y);
                t.vel = Offset(0, sp.vy);
                t.spawned = true;

                // Spawn with a small positive delay to prevent visible “firing/shake” at top.
                t.spawnAt = now.add(
                    Duration(milliseconds: _rnd.nextInt(180))); // ← key change
                t.fadeInMs = sp.fadeInMs;
              }

              // fade-in tiles
              final fade = ((now.millisecondsSinceEpoch -
                          t.spawnAt.millisecondsSinceEpoch) /
                      t.fadeInMs)
                  .clamp(0.0, 1.0);
              t.alpha = Curves.easeOutCubic.transform(fade);

              // gravity
              t.vel = t.vel + const Offset(0, _g * dt);
              double nextY = t.pos.dy + t.vel.dy * dt;
              if (nextY > groundY) {
                nextY = groundY;
                t.vel = Offset.zero;
              }
              t.pos = Offset(t.pos.dx, nextY);
            }

            // after all landed, hold before clustering
            final landed =
                _things.every((t) => (t.pos.dy - groundY).abs() < 0.75);
            if (landed) {
              if (!_postDropHoldStarted) {
                _postDropHoldStarted = true;
                _postDropUntil = DateTime.now()
                    .add(Duration(milliseconds: kExtraMsAfterDrop));
              } else if (DateTime.now().isAfter(_postDropUntil)) {
                _startClustering();
              }
            }
            break;
          }

        case _Phase.clustering:
          {
            // halos fade in
            _haloAlpha = (_haloAlpha + dt / haloFadeInSeconds).clamp(0.0, 1.0);

            final now = DateTime.now();
            for (final t in _things) {
              final raw = ((now.millisecondsSinceEpoch -
                          t.legStart.millisecondsSinceEpoch) /
                      t.legDurMs)
                  .clamp(0.0, 1.0);
              final e = Curves.easeInOutCubic.transform(raw);
              t.pos = Offset(_lerp(t.startPos.dx, t.target!.dx, e),
                  _lerp(t.startPos.dy, t.target!.dy, e));
            }

            // show boxes after ~3s in cluster
            if (DateTime.now().difference(_clusterStart).inMilliseconds >
                3000) {
              _phase = _Phase.showBoxes;
              _boxesVisible = true;
              _boxesProgress = 0.0;
            }
            break;
          }

        case _Phase.showBoxes:
          {
            // fade+scale of boxes
            _boxesProgress = (_boxesProgress + dt / 0.7).clamp(0.0, 1.0);

            if (_boxesProgress >= 1.0) {
              _assignTargetsToBoxCorners();
              final now = DateTime.now();
              for (final t in _things) {
                t.startPos = t.pos;
                final int delay = 120 + _rnd.nextInt(220);
                t.legStart = now.add(Duration(milliseconds: delay));
                t.legDurMs =
                    (1200 + _rnd.nextInt(300)) + kExtraMsPerLeg; // slower
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

              t.pos = Offset(_lerp(t.startPos.dx, t.target!.dx, e),
                  _lerp(t.startPos.dy, t.target!.dy, e));
              t.scale =
                  _lerp(1.0, t.boxScale, Curves.easeOutCubic.transform(e));

              if (raw < 0.999) allArrived = false;
            }

            if (allArrived) {
              // Delay Continue button by ~1s before notifying parent
              _phase = _Phase.fading; // start content fade-out
              _fadeElapsed = 0.0;
              Future.delayed(const Duration(seconds: 1), () {
                if (!mounted) return;
                widget.onCompleted?.call();
              });
            }
            break;
          }

        case _Phase.fading:
          {
            _fadeElapsed += dt;
            _contentOpacity =
                (1.0 - (_fadeElapsed / fadeOutSeconds)).clamp(0.0, 1.0);
            if (_contentOpacity <= 0.0) {
              Future.delayed(loopDelay, () {
                if (!mounted) return;
                _restartAnimation();
              });
            }
            break;
          }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, cts) {
      final Size newSize = Size(cts.maxWidth, cts.maxHeight);
      if (newSize != _size) {
        _size = newSize;
        _computeCornerCenters(); // top-left & top-right, safely inside edges
        _layoutBoxes();

        // changing size invalidates spawn plan so we recompute
        _spawnPlan = null;
        _spawnPlanForSize = null;
      }

      return Stack(
        children: [
          // Playfield (background DOES NOT fade) — prevents white flash
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black26, width: 1.2),
              ),
            ),
          ),

          // All animated content fades uniformly (halos, emojis, boxes)
          Positioned.fill(
            child: Opacity(
              opacity: _contentOpacity,
              child: Stack(
                children: [
                  // Halos (fade-in; also fade out with content)
                  if (_phase == _Phase.clustering ||
                      _phase == _Phase.showBoxes ||
                      _phase == _Phase.toBoxes ||
                      _phase == _Phase.fading)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(
                          painter: _ClusterHaloPainter(
                            centers: _clusterCenters,
                            colors: _groupColors,
                            alpha: (_phase == _Phase.fading)
                                ? (_haloAlpha * _contentOpacity)
                                : _haloAlpha,
                          ),
                        ),
                      ),
                    ),

                  // Emojis
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

                  // Boxes + labels
                  if (_boxesVisible && _box1 != null && _box2 != null)
                    ..._buildBoxesLayer(),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  // ───────────────────────── helpers ─────────────────────────
  void _computeCornerCenters() {
    // place halos maximally into TL & TR corners while fully inside playfield
    final double inset = clusterEdgeInset + haloRadius;
    final double top = inset;
    final double left = inset;
    final double right = _size.width - inset;
    _clusterCenters = [Offset(left, top), Offset(right, top)];
  }

  void _restartAnimation() {
    setState(() {
      _phase = _Phase.dropping;
      _things = _seedThings();
      _boxesVisible = false;
      _boxesProgress = 0.0;
      _postDropHoldStarted = false;
      _haloAlpha = 0.0;
      _contentOpacity = 1.0;
      // keep _spawnPlan as-is so the drop stays identical each loop
    });
  }

  void _startClustering() {
    _phase = _Phase.clustering;
    _clusterStart = DateTime.now();
    _haloAlpha = 0.0;
    final now = DateTime.now();

    // Compute safe max radius when targeting the TILE CENTER.
    final double itemHalf = (emojiSize / 2) + emojiPad + emojiBorder;
    final double safeMax =
        max(0.0, min(clusterMaxRadiusUser, haloRadius - itemHalf));
    final double cushion = 3.0; // push comfortably inside the halo
    final double rMax = max(0.0, safeMax - cushion);

    for (final t in _things) {
      t.startPos = t.pos;
      final Offset center = _clusterCenters[t.category];

      // Uniform in disk: fills the whole circle evenly
      final Offset jitter = _randomDisk(rMax);
      final Offset targetCenter = center + jitter;
      t.target =
          targetCenter - Offset(itemHalf, itemHalf); // convert to top-left

      final int delay = 160 + _rnd.nextInt(240);
      t.legStart = now.add(Duration(milliseconds: delay));
      t.legDurMs = (1400 + _rnd.nextInt(320)) + kExtraMsPerLeg;
      t.boxScale = 1.0; // exact size
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
        _lerp(0.94, 1.0, Curves.easeOutCubic.transform(_boxesProgress));
    final double a = _boxesProgress;

    return [
      ..._boxPair(_box1!, "Group 1", _groupColors[0], a, s),
      ..._boxPair(_box2!, "Group 2", _groupColors[1], a, s),
    ];
  }

  List<Widget> _boxPair(
      Rect r, String label, Color color, double alpha, double scale) {
    return [
      Positioned.fromRect(
        rect: r,
        child: Opacity(
          opacity: alpha,
          child: Transform.scale(
            scale: scale,
            alignment: Alignment.center,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(color: color, width: 2),
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ),
      Positioned(
        left: r.left,
        right: r.right,
        top: r.bottom + 6,
        child: Opacity(
          opacity: alpha,
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ),
        ),
      ),
    ];
  }

  Widget _emojiTile(String emoji, int category) {
    final color = _groupColors[category];
    return Container(
      padding: const EdgeInsets.all(emojiPad),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.7), width: emojiBorder),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(2, 2))
        ],
      ),
      child: Text(emoji, style: const TextStyle(fontSize: emojiSize)),
    );
  }

  void _assignTargetsToBoxCorners() {
    final Map<int, Rect> boxForCat = {0: _box1!, 1: _box2!};
    for (int cat = 0; cat < 2; cat++) {
      final members = _things.where((t) => t.category == cat).toList();
      final Rect box = boxForCat[cat]!;

      // exact containment using full tile size (incl. pad + border)
      const double boxInnerPad = 12;
      final double tile = _tileExtent;
      // safe rect for the TILE'S TOP-LEFT so that whole tile stays inside
      Rect safe = Rect.fromLTWH(
        box.left + boxInnerPad,
        box.top + boxInnerPad,
        max(0, box.width - 2 * boxInnerPad - tile),
        max(0, box.height - 2 * boxInnerPad - tile),
      );

      final Offset tl = Offset(safe.left, safe.top);
      final Offset tr = Offset(safe.right, safe.top);
      final Offset bl = Offset(safe.left, safe.bottom);
      final Offset br = Offset(safe.right, safe.bottom);
      final List<Offset> cornerOrder = [tl, tr, bl, br];

      for (int i = 0; i < members.length; i++) {
        final t = members[i];
        final Offset base = cornerOrder[min(i, cornerOrder.length - 1)];
        double jx = (i.isEven ? 1.5 : -1.5);
        double jy = (i % 3 == 0 ? -1.2 : 1.2);

        double x = (base.dx + jx).clamp(safe.left, safe.right);
        double y = (base.dy + jy).clamp(safe.top, safe.bottom);

        t.target = Offset(x, y);
        t.boxScale = 1.0;
      }
    }
  }

  // math/ease
  double _lerp(double a, double b, double t) => a + (b - a) * t;

  // uniform-in-disk (fills the halo evenly)
  Offset _randomDisk(double rMax) {
    if (rMax <= 0) return Offset.zero;
    final double u = _rnd.nextDouble();
    final double r = sqrt(u) * rMax; // sqrt makes area-uniform
    final double a = _rnd.nextDouble() * 2 * pi;
    return Offset(cos(a) * r, sin(a) * r);
  }
}

/// halos accept alpha to fade in/out
class _ClusterHaloPainter extends CustomPainter {
  final List<Offset> centers;
  final List<Color> colors;
  final double alpha; // 0..1

  _ClusterHaloPainter(
      {required this.centers, required this.colors, required this.alpha});

  @override
  void paint(Canvas canvas, Size size) {
    if (alpha <= 0) return;
    for (int i = 0; i < centers.length; i++) {
      final p = Paint()
        ..color = colors[i].withOpacity(0.10 * alpha)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(centers[i], haloRadius, p);

      final s = Paint()
        ..color = colors[i].withOpacity(0.35 * alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(centers[i], haloRadius, s);
    }
  }

  @override
  bool shouldRepaint(covariant _ClusterHaloPainter old) =>
      old.centers != centers || old.colors != colors || old.alpha != alpha;
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
  double boxScale = 1.0; // exact size

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

// persistent spawn plan
class _Spawn {
  final double x;
  final double y;
  final double vy;
  final int fadeInMs;
  const _Spawn({
    required this.x,
    required this.y,
    required this.vy,
    required this.fadeInMs,
  });
}
