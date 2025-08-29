// FILE: lib/z_pages/lesson_page.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:running_robot/core/app_router.dart' show AppNavigate;
import 'package:running_robot/z_pages/assets/lessonPage/map_geometry.dart';

import 'package:running_robot/z_pages/assets/lessonPage/chapter_dropdown.dart';
import 'package:running_robot/z_pages/assets/lessonPage/chapter_pill.dart';
import 'package:running_robot/z_pages/assets/lessonPage/lesson_node.dart';
import 'package:running_robot/z_pages/assets/lessonPage/path_painter.dart';
import 'package:running_robot/z_pages/assets/lessonPage/lesson_box.dart';
import 'package:running_robot/core/app_router.dart';
import 'package:running_robot/z_pages/assets/lessonPage/lesson_names.dart';

/// ===== Global gaps (map layout) =====
const double kPillTopGap = 25.0;
const double kMapTopGap = 100.0;

/// ===== Focus animation settings =====
const Duration kFocusDuration = Duration(milliseconds: 650);
const double kFocusedScale = 1.6;

/// ===== Position of focused node (relative to screen) =====
const double kTargetXFactor = 0.57;
const double kTargetYFactor = 0.25;

/// ===== Blur/opacity settings =====
const double kMaxBlur = 6.0;
const double kMinOpacity = 0.0;

/// ===== Light beam settings =====
const double kBeamWidth = 120;
const double kBeamHeight = 130;
const Color kBeamColor = Colors.blueAccent;
const double kBeamYOffset = 10;
const double kBeamXOffset = -24;
const Duration kBeamDelay = Duration(milliseconds: 200);
const Duration kBeamDuration = Duration(milliseconds: 400);

/// ===== Box animation settings =====
const Duration kBoxDelay = Duration(milliseconds: 20);
const Duration kBoxAnimDuration = Duration(milliseconds: 400);

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
      duration: kFocusDuration,
    );

    _beamController = AnimationController(
      vsync: this,
      duration: kBeamDuration,
    )..addStatusListener((status) async {
        if (status == AnimationStatus.completed) {
          await Future.delayed(kBoxDelay);
          setState(() => _showBox = true);
          _boxController.forward(from: 0);
        }
      });

    _boxController = AnimationController(
      vsync: this,
      duration: kBoxAnimDuration,
    );

    // Precache image
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

  Future<void> _focusOnNode(int index) async {
    setState(() {
      _selectedNodeIndex = index;
      _showBox = false;
    });
    await _focusController.forward(from: 0);
    await Future.delayed(kBeamDelay);
    setState(() => _showBeam = true);
    _beamController.forward(from: 0);
  }

  void _clearFocus() {
    setState(() {
      _selectedNodeIndex = null;
      _showBeam = false;
      _showBox = false;
    });
    _beamController.reverse();
    _focusController.reverse();
    _boxController.reset();
  }

  @override
  Widget build(BuildContext context) {
    final chapters = List.generate(9, (i) => i + 1);
    final double statusBar = MediaQuery.of(context).padding.top;

    final mapSize = LessonMapGeometry.mapSize(context);
    final path = LessonMapGeometry.pathFor(_currentChapter, mapSize);
    final nodes = LessonMapGeometry.nodesFor(_currentChapter, mapSize);

    final screen = MediaQuery.of(context).size;

    return Scaffold(
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
          shadowColor: Colors.transparent,
        ),
      ),
      body: GestureDetector(
        onTap: () {
          if (_selectedNodeIndex != null) {
            _clearFocus();
          }
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: SizedBox(
                  width: mapSize.width,
                  height: mapSize.height + kMapTopGap,
                  child: Padding(
                    padding: const EdgeInsets.only(top: kMapTopGap),
                    child: Stack(
                      children: [
                        AnimatedOpacity(
                          opacity: _selectedNodeIndex == null ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 400),
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
              child: Column(
                children: [
                  ChapterPill(
                    key: _pillKey,
                    currentChapter: _currentChapter,
                    dropdownOpen: _dropdownOpen,
                    onTap: () => setState(() => _dropdownOpen = !_dropdownOpen),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: _dropdownOpen && _pillWidth != null
                        ? SizedBox(
                            width: _pillWidth! * 0.42,
                            child: ChapterDropdown(
                              chapters: chapters,
                              currentChapter: _currentChapter,
                              onChapterSelected: (c) {
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

            // ===== DESCRIPTION BOX =====
            if (_selectedNodeIndex != null && _showBox)
              FadeTransition(
                opacity: _boxController,
                child: Align(
                  alignment: const Alignment(0, 0.6),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: LessonBox(
                      pictureLink: "assets/images/robot_family2.jpg",
                      // 🔥 CHANGED: Lesson title is now "Lesson 1.2"
                      lessonTitle:
                          "Lesson $_currentChapter.${_selectedNodeIndex! + 1}",
                      // Keep text title the same
                      titleText:
                          "${lessonTitles[_currentChapter - 1][_selectedNodeIndex!]}",
                      buttonText: "Continue Lesson",
                      onNavigate: () {
                        widget.onNavigate(RouteLesson1());
                      },
                      imageHeight: 120,
                      width: 280,
                      height: 280,
                      buttonColor: Colors.black,
                      boxFill: Colors.white,
                      textColors: [
                        Colors.black,
                        Colors.orange,
                        Colors.white,
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildLessonNodes(List<Offset> centers, Size screen) {
    return List<Widget>.generate(centers.length, (i) {
      final unlocked = i < 3;
      final c = centers[i];

      final node = LessonNode(
        unlocked: unlocked,
        animation: _pulseController,
        onNavigate: widget.onNavigate,
        onTapBuilder: (nav) {
          return () {
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
                  final dx =
                      lerpDouble(c.dx, screen.width * kTargetXFactor, 1)!;
                  final dy =
                      lerpDouble(c.dy, screen.height * kTargetYFactor, 1)!;
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
                final dx = lerpDouble(c.dx, screen.width * kTargetXFactor, t)!;
                final dy = lerpDouble(c.dy, screen.height * kTargetYFactor, t)!;
                final scale = lerpDouble(1.0, kFocusedScale, t)!;
                return Positioned(
                  left: dx - 40 * scale,
                  top: dy - 40 * scale,
                  child: Transform.scale(scale: scale, child: child),
                );
              },
              child: node,
            ),
          ],
        );
      }

      return AnimatedBuilder(
        animation: _focusController,
        builder: (context, child) {
          final t = _focusController.value;
          final blur = lerpDouble(0, kMaxBlur, t)!;
          final opacity = lerpDouble(1, kMinOpacity, t)!;
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
        child: node,
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
