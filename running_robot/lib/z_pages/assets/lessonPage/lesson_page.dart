// FILE: lib/z_pages/lesson_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:running_robot/core/app_router.dart' show AppNavigate;
import 'package:running_robot/z_pages/assets/lessonPage/map_geometry.dart';

import 'package:running_robot/z_pages/assets/lessonPage/chapter_dropdown.dart';
import 'package:running_robot/z_pages/assets/lessonPage/chapter_pill.dart';
import 'package:running_robot/z_pages/assets/lessonPage/lesson_node.dart';
import 'package:running_robot/z_pages/assets/lessonPage/path_painter.dart';

/// ===== Global gaps (tweak these) =====
const double kPillTopGap = 25.0;
const double kMapTopGap = 100.0;

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chapters = List.generate(9, (i) => i + 1);
    final double statusBar = MediaQuery.of(context).padding.top;

    // Fixed canvas size (height matches your original)
    final mapSize = LessonMapGeometry.mapSize(context);
    final path = LessonMapGeometry.pathFor(_currentChapter, mapSize);
    final nodes = LessonMapGeometry.nodesFor(_currentChapter, mapSize);

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
      body: Stack(
        children: [
          // ===== MAP SCROLL AREA =====
          Positioned.fill(
            child: SingleChildScrollView(
              child: SizedBox(
                width: mapSize.width,
                height: mapSize.height + kMapTopGap,
                child: Padding(
                  padding: const EdgeInsets.only(top: kMapTopGap),
                  child: Stack(
                    children: [
                      CustomPaint(
                        size: mapSize,
                        painter: PathPainter(path: path),
                      ),
                      ..._buildLessonNodes(nodes),
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
                            },
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // LESSON NODES (HARDCODED CENTERS)
  // =========================
  List<Widget> _buildLessonNodes(List<Offset> centers) {
    return List<Widget>.generate(centers.length, (i) {
      final unlocked = i < 3; // your rule
      final c = centers[i];
      return Positioned(
        left: c.dx - 40, // center the 80x80 node
        top: c.dy - 40,
        child: LessonNode(
          unlocked: unlocked,
          animation: _pulseController,
          onNavigate: widget.onNavigate,
          onTapBuilder: (nav) {
            return () {
              // TODO: preview → nav(RouteLesson1());
            };
          },
        ),
      );
    });
  }
}
