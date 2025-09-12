// FILE: lib/z_pages/lesson_page.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:running_robot/core/app_router.dart'
    show AppNavigate, RouteLesson;
import 'package:running_robot/z_pages/assets/lessonPage/map_geometry.dart';

import 'package:running_robot/z_pages/assets/lessonPage/chapter_dropdown.dart';
import 'package:running_robot/z_pages/assets/lessonPage/chapter_pill.dart';
import 'package:running_robot/z_pages/assets/lessonPage/lesson_node.dart';
import 'package:running_robot/z_pages/assets/lessonPage/path_painter.dart';
import 'package:running_robot/z_pages/assets/lessonPage/lesson_box.dart';
import 'package:running_robot/z_pages/assets/lessonPage/lesson_names.dart';

/// ===== Global gaps (map layout) =====
const double kPillTopGap = 25.0;
const double kMapTopGap = 100.0;

/// ===== Focus animation settings (separate in/out) =====
const Duration kFocusZoomInDuration =
    Duration(milliseconds: 650); // zoom into node
const Duration kUnfocusZoomOutDuration =
    Duration(milliseconds: 450); // zoom back to map
const double kFocusedScale = 1.50;

/// ===== Position of focused node (relative to screen) =====
const double kTargetXFactor = 0.57;
const double kTargetYFactor = 0.35;

/// ===== Blur/opacity settings =====
const double kMaxBlur = 6.0;
const double kMinOpacity = 0.0;

/// ===== Light beam settings =====
const double kBeamWidth = 100;
const double kBeamHeight = 90;
const Color kBeamColor = Colors.blueAccent;
const double kBeamYOffset = 10;
const double kBeamXOffset = -19.5;
const Duration kBeamDelay = Duration(milliseconds: 200);
const Duration kBeamDuration = Duration(milliseconds: 300);

/// ===== Box animation settings =====
const Duration kBoxDelay = Duration(milliseconds: 0);
const Duration kBoxAnimDuration = Duration(milliseconds: 500);

/// ===== UI fade/size knobs (direction-aware & separated) =====
/// Chapter pill
const Duration kChapterTopPillFadeOutDuration = Duration(milliseconds: 300);
const Duration kChapterTopPillFadeInDuration = Duration(milliseconds: 500);

/// Map path ONLY
const Duration kPathFadeOutDuration = Duration(milliseconds: 260);
const Duration kPathFadeInDuration = Duration(milliseconds: 450);

/// Non-selected lesson nodes ONLY (their blur/opacity)
const Duration kNodeFadeOutDuration = Duration(milliseconds: 260);
const Duration kNodeFadeInDuration = Duration(milliseconds: 450);

/// Curve + dropdown size anim
const Curve kUiFadeCurve = Curves.easeInOut;
const Duration kUiSizeDuration = Duration(milliseconds: 300);

class LessonPage extends StatefulWidget {
  final AppNavigate onNavigate;

  const LessonPage({
    super.key,
    required this.onNavigate,
  });

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late final ScrollController _scrollController;

  int? _selectedNodeIndex;
  late AnimationController _focusController;
  late AnimationController _beamController;
  late AnimationController _boxController;

  bool _showBeam = false;
  bool _showBox = false;
  bool _dropdownOpen = false;
  int _currentChapter = 1;

  final GlobalKey _pillKey = GlobalKey();
  double? _pillWidth;

  // [LOCK] gate all input during the zoom animation
  bool _inputLocked = false;

  bool get _isFocused => _selectedNodeIndex != null; // [FOCUS]

  // Invalidate pending async work when state changes fast
  int _session = 0; // monotonically increasing token
  int? _beamSession; // token captured when beam starts

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scrollController = ScrollController();

    _focusController = AnimationController(
      vsync: this,
      duration: kFocusZoomInDuration, // default forward duration
    );

    _beamController = AnimationController(
      vsync: this,
      duration: kBeamDuration,
    )..addStatusListener((status) async {
        if (status == AnimationStatus.completed) {
          final int? tokenAtStart = _beamSession;
          await Future.delayed(kBoxDelay);
          if (!mounted) return;
          if (!_isFocused || tokenAtStart == null || tokenAtStart != _session) {
            return; // stale; do nothing
          }
          setState(() => _showBox = true);
          _boxController.forward(from: 0);
        }
        if (status == AnimationStatus.dismissed) {
          if (mounted && _showBeam) {
            setState(() => _showBeam = false);
          }
        }
      });

    _boxController = AnimationController(
      vsync: this,
      duration: kBoxAnimDuration,
    );

    // Precache image + measure pill width
    WidgetsBinding.instance.addPostFrameCallback((_) {
      precacheImage(
          const AssetImage("assets/images/robot_family.jpg"), context);

      final renderBox =
          _pillKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        setState(() => _pillWidth = renderBox.size.width);
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scrollController.dispose();
    _focusController.dispose();
    _beamController.dispose();
    _boxController.dispose();
    super.dispose();
  }

  // Scales a 0..1 progress 'p' to finish in 'desiredDur' while the controller runs for 'animDur'
  double _scaleProgress(double p, Duration animDur, Duration desiredDur) {
    final int animMs = animDur.inMilliseconds;
    final int wantMs = desiredDur.inMilliseconds;
    if (wantMs <= 0) return p > 0 ? 1.0 : 0.0; // instant after first tick
    final double scaled = p * (animMs / wantMs);
    return scaled.clamp(0.0, 1.0);
  }

  Future<void> _focusOnNode(int index) async {
    final int mySession = ++_session;

    setState(() {
      _selectedNodeIndex = index;
      _showBox = false;
      _showBeam = false;
      _dropdownOpen = false; // keep UI clean when focusing
      _inputLocked = true;
    });

    _beamSession = null;
    _beamController.stop();
    _beamController.value = 0.0;
    _boxController.stop();
    _boxController.reset();

    // ensure forward duration
    _focusController.duration = kFocusZoomInDuration;
    await _focusController.forward(from: 0);

    if (mounted) setState(() => _inputLocked = false);

    await Future.delayed(kBeamDelay);
    if (!mounted) return;
    if (!_isFocused || _session != mySession || _selectedNodeIndex != index) {
      return;
    }

    setState(() {
      _showBeam = true;
      _beamSession = mySession;
    });
    _beamController.forward(from: 0);
  }

  void _clearFocus() {
    _session++;

    setState(() {
      _selectedNodeIndex = null;
      _showBeam = false;
      _showBox = false;
      _dropdownOpen = false;
    });

    _beamSession = null;
    _beamController.stop();
    _beamController.value = 0.0;

    // reverse with its own duration (controls non-selected nodes "fade-in" & zoom-out)
    _focusController.stop();
    _focusController.animateBack(
      0.0,
      duration: kUnfocusZoomOutDuration,
      curve: kUiFadeCurve,
    );

    _boxController.stop();
    _boxController.reset();
  }

  // [FOCUS] compute target in map's coordinate space (scroll-aware)
  double _targetX(Size screen) => screen.width * kTargetXFactor;
  double _targetY(Size screen) {
    final scrollY =
        _scrollController.hasClients ? _scrollController.offset : 0.0;
    return scrollY + screen.height * kTargetYFactor - kMapTopGap;
  }

  @override
  Widget build(BuildContext context) {
    final chapters = List.generate(9, (i) => i + 1);
    final double statusBar = MediaQuery.of(context).padding.top;

    final mapSize = LessonMapGeometry.mapSize(context);
    final path = LessonMapGeometry.pathFor(_currentChapter, mapSize);
    final nodes = LessonMapGeometry.nodesFor(_currentChapter, mapSize);

    final screen = MediaQuery.of(context).size;

    final content = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (_isFocused && !_inputLocked) {
          _clearFocus();
        }
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: (_inputLocked || _isFocused)
                  ? const NeverScrollableScrollPhysics()
                  : null,
              child: SizedBox(
                width: mapSize.width,
                height: mapSize.height + kMapTopGap,
                child: Padding(
                  padding: const EdgeInsets.only(top: kMapTopGap),
                  child: Stack(
                    children: [
                      // Map path fade with separate IN/OUT durations
                      AnimatedOpacity(
                        opacity: _selectedNodeIndex == null ? 1.0 : 0.0,
                        duration: (_selectedNodeIndex == null)
                            ? kPathFadeInDuration
                            : kPathFadeOutDuration,
                        curve: kUiFadeCurve,
                        child: CustomPaint(
                          size: mapSize,
                          painter: PathPainter(path: path),
                        ),
                      ),
                      ..._buildLessonNodes(nodes, screen),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ===== FLOATING PILL + DROPDOWN =====
          Positioned(
            top: statusBar + kPillTopGap,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              // Pill fade with separate IN/OUT durations
              opacity: _isFocused ? 0.0 : 1.0,
              duration: _isFocused
                  ? kChapterTopPillFadeOutDuration
                  : kChapterTopPillFadeInDuration,
              curve: kUiFadeCurve,
              child: IgnorePointer(
                ignoring: _inputLocked || _isFocused,
                child: Column(
                  children: [
                    ChapterPill(
                      key: _pillKey,
                      currentChapter: _currentChapter,
                      dropdownOpen: _dropdownOpen,
                      onTap: () =>
                          setState(() => _dropdownOpen = !_dropdownOpen),
                    ),
                    AnimatedSize(
                      duration: kUiSizeDuration,
                      curve: kUiFadeCurve,
                      child:
                          (_dropdownOpen && _pillWidth != null && !_isFocused)
                              ? SizedBox(
                                  width: _pillWidth! * 0.42,
                                  child: ChapterDropdown(
                                    chapters: chapters,
                                    currentChapter: _currentChapter,
                                    onChapterSelected: (c) {
                                      _clearFocus();
                                      setState(() {
                                        _currentChapter = c;
                                        _dropdownOpen = false;
                                      });
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                        if (_scrollController.hasClients) {
                                          _scrollController.jumpTo(0);
                                        }
                                      });
                                    },
                                  ),
                                )
                              : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ===== DESCRIPTION BOX =====
          if (_selectedNodeIndex != null && _showBox)
            FadeTransition(
              opacity: _boxController,
              child: Align(
                alignment: const Alignment(0, 0.6),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: GestureDetector(
                    onTap: () {}, // absorb taps on box surface
                    behavior: HitTestBehavior.translucent,
                    child: LessonBox(
                      pictureLink: "assets/images/robot_family2.jpg",
                      lessonTitle:
                          "Lesson $_currentChapter.${_selectedNodeIndex! + 1}",
                      titleText:
                          "${lessonTitles[_currentChapter - 1][_selectedNodeIndex!]}",
                      buttonText: "Continue Lesson",
                      onNavigate: () {
                        final globalLessonIndex = (_currentChapter - 1) * 9 +
                            (_selectedNodeIndex! + 1);
                        widget.onNavigate(RouteLesson(globalLessonIndex));
                      },
                      imageHeight: 120,
                      width: 280,
                      height: 280,
                      buttonColor: Colors.black,
                      boxFill: Colors.white,
                      textColors: [Colors.black, Colors.orange, Colors.white],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    return WillPopScope(
      onWillPop: () async {
        if (_isFocused) {
          _clearFocus();
          return false;
        }
        return true;
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: const Color(0xFFF3F4F6),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
          ),
        ),
        body: AbsorbPointer(
          absorbing: _inputLocked,
          child: content,
        ),
      ),
    );
  }

  List<Widget> _buildLessonNodes(List<Offset> centers, Size screen) {
    return List<Widget>.generate(centers.length, (i) {
      final unlocked = i < 15;
      final c = centers[i];

      final node = LessonNode(
        unlocked: unlocked,
        animation: _pulseController,
        onNavigate: widget.onNavigate,
        onTapBuilder: (nav) {
          return () {
            if (_inputLocked || _isFocused) return;
            _focusOnNode(i);
          };
        },
      );

      if (_selectedNodeIndex == i) {
        return Stack(
          children: [
            if (_showBeam)
              AnimatedBuilder(
                animation: _beamController,
                builder: (context, _) {
                  final t = _beamController.value;
                  final dx = _targetX(screen);
                  final dy = _targetY(screen);
                  return Positioned.fill(
                    child: LightBeam(
                      origin: Offset(dx, dy),
                      progress: t,
                      width: kBeamWidth,
                      height: kBeamHeight,
                      color: kBeamColor,
                    ),
                  );
                },
              ),
            AnimatedBuilder(
              animation: _focusController,
              builder: (context, child) {
                final t = _focusController.value;
                final dx = lerpDouble(c.dx, _targetX(screen), t)!;
                final dy = lerpDouble(c.dy, _targetY(screen), t)!;
                final scale = lerpDouble(1.0, kFocusedScale, t)!;
                return Positioned(
                  left: dx - 40 * scale,
                  top: dy - 40 * scale,
                  child: AbsorbPointer(
                    absorbing: true,
                    child: Transform.scale(scale: scale, child: child),
                  ),
                );
              },
              child: node,
            ),
          ],
        );
      }

      // Other (non-selected) nodes: fade/blur independently of zoom duration
      return AnimatedBuilder(
        animation: _focusController,
        builder: (context, child) {
          final status = _focusController.status;
          final t = _focusController.value;

          // Forward = focusing (fade OUT), Reverse = clearing focus (fade IN)
          final bool isForward = status == AnimationStatus.forward ||
              (status == AnimationStatus.completed && _isFocused);

          double effectiveT;
          if (isForward) {
            // progress 0→1 during focus
            final p = t;
            final pScaled =
                _scaleProgress(p, kFocusZoomInDuration, kNodeFadeOutDuration);
            effectiveT = pScaled; // 0..1, controls fade OUT
          } else {
            // progress 0→1 while unfocusing; map to fade IN
            final p = 1.0 - t; // 0..1 as we animate back
            final pScaled =
                _scaleProgress(p, kUnfocusZoomOutDuration, kNodeFadeInDuration);
            effectiveT = 1.0 -
                pScaled; // transform back to 1→0 (remove blur, restore opacity)
          }

          final blur = lerpDouble(0, kMaxBlur, effectiveT)!;
          final opacity = lerpDouble(1, kMinOpacity, effectiveT)!;

          return Positioned(
            left: c.dx - 40,
            top: c.dy - 40,
            child: Opacity(
              opacity: opacity,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                child: child,
              ),
            ),
          );
        },
        child: IgnorePointer(
          ignoring: _isFocused, // when focused, taps go through to background
          child: node,
        ),
      );
    });
  }
}

/// =========================
/// LIGHT BEAM WIDGET
/// =========================
class LightBeam extends StatelessWidget {
  final Offset origin;
  final double width;
  final double height;
  final Color color;
  final double progress;

  const LightBeam({
    super.key,
    required this.origin,
    required this.progress,
    this.width = 200,
    this.height = 300,
    this.color = Colors.blueAccent,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LightBeamPainter(
        origin: origin,
        width: width,
        height: height,
        progress: progress,
        color: color,
      ),
    );
  }
}

class _LightBeamPainter extends CustomPainter {
  final Offset origin;
  final double width;
  final double height;
  final double progress;
  final Color color;

  _LightBeamPainter({
    required this.origin,
    required this.width,
    required this.height,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final startX = origin.dx + kBeamXOffset;
    final startY = origin.dy + kBeamYOffset;

    final fullPath = Path()
      ..moveTo(startX, startY)
      ..lineTo(startX - width / 2, startY + height)
      ..lineTo(startX + width / 2, startY + height)
      ..close();

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withOpacity(0.6), color.withOpacity(0.0)],
      ).createShader(Rect.fromLTWH(
        startX - width / 2,
        startY,
        width,
        height,
      ));

    final visibleHeight = height * progress;

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(
      startX - width / 2,
      startY,
      width,
      visibleHeight,
    ));
    canvas.drawPath(fullPath, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LightBeamPainter oldDelegate) {
    return oldDelegate.origin != origin ||
        oldDelegate.width != width ||
        oldDelegate.height != height ||
        oldDelegate.progress != progress ||
        oldDelegate.color != color;
  }
}
