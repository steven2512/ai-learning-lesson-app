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

/// ===== Global gaps (map layout) =====
const double kPillTopGap = 25.0;
const double kMapTopGap = 100.0;

/// ===== Focus animation settings =====
const Duration kFocusDuration = Duration(milliseconds: 500);
const double kFocusedScale = 1.6; // how big focused node gets

// Position of focused node (relative to screen)
const double kTargetXFactor =
    0.57; // 0 = far left, 0.5 = horizontal center, 1 = far right
const double kTargetYFactor = 0.3; // 0 = top, 0.5 = vertical center, 1 = bottom

/// ===== Blur/opacity settings =====
const double kMaxBlur = 6.0;
const double kMinOpacity = 0.0;

/// ===== Description box settings =====
const EdgeInsets kBoxMargin = EdgeInsets.all(24);
const EdgeInsets kBoxPadding = EdgeInsets.all(16);
const double kBoxRadius = 16;
const double kBoxShadowBlur = 12;
const Color kBoxColor = Colors.white;
const Color kBoxShadowColor = Colors.black26;
const double kBoxFontSize = 16;

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

  int? _selectedNodeIndex; // which node is focused
  late AnimationController _focusController;

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    super.dispose();
  }

  void _focusOnNode(int index) {
    setState(() => _selectedNodeIndex = index);
    _focusController.forward(from: 0);
  }

  void _clearFocus() {
    setState(() => _selectedNodeIndex = null);
    _focusController.reverse();
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
            // ===== MAP AREA =====
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
                        // Background path fades when node is selected
                        AnimatedOpacity(
                          opacity: _selectedNodeIndex == null ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 400),
                          child: CustomPaint(
                            size: mapSize,
                            painter: PathPainter(path: path),
                          ),
                        ),

                        // Nodes
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
            if (_selectedNodeIndex != null)
              FadeTransition(
                opacity: _focusController,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    margin: kBoxMargin,
                    padding: kBoxPadding,
                    decoration: BoxDecoration(
                      color: kBoxColor,
                      borderRadius: BorderRadius.circular(kBoxRadius),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: kBoxShadowBlur,
                          color: kBoxShadowColor,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Text(
                      "Lesson ${_selectedNodeIndex! + 1} description goes here...",
                      style: TextStyle(fontSize: kBoxFontSize),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // =========================
  // LESSON NODES
  // =========================
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

      // Focused node → animate to global target position
      if (_selectedNodeIndex == i) {
        return AnimatedBuilder(
          animation: _focusController,
          builder: (context, child) {
            final t = _focusController.value;

            final dx = lerpDouble(c.dx, screen.width * kTargetXFactor, t)!;
            final dy = lerpDouble(c.dy, screen.height * kTargetYFactor, t)!;
            final scale = lerpDouble(1.0, kFocusedScale, t)!;

            return Positioned(
              left: dx - 40 * scale,
              top: dy - 40 * scale,
              child: Transform.scale(
                scale: scale,
                child: child,
              ),
            );
          },
          child: node,
        );
      }

      // Non-focused nodes → blur + fade
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
