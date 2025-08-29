// FILE: lib/z_pages/lesson_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:running_robot/z_pages/assets/lessonPage/chapter_dropdown.dart';
import 'package:running_robot/z_pages/assets/lessonPage/chapter_pill.dart';
import 'package:running_robot/z_pages/assets/lessonPage/lesson_node.dart';

/// ===== Global gaps (tweak these) =====
const double kPillTopGap = 25.0;
const double kMapTopGap = 100.0;

class LessonPage extends StatefulWidget {
  const LessonPage({super.key});

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
                width: MediaQuery.of(context).size.width,
                height: 1800 + kMapTopGap,
                child: Padding(
                  padding: EdgeInsets.only(top: kMapTopGap),
                  child: Stack(
                    children: [
                      CustomPaint(
                        size: Size(MediaQuery.of(context).size.width, 1800),
                        painter: PathPainter(),
                      ),
                      ..._buildLessonNodes(),
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
  // LESSON NODES
  // =========================
  List<Widget> _buildLessonNodes() {
    final positions = [
      const Offset(165, 100),
      const Offset(215, 310),
      const Offset(120, 500),
      const Offset(160, 700),
      const Offset(80, 900),
      const Offset(190, 1100),
      const Offset(160, 1300),
      const Offset(230, 1500),
      const Offset(140, 1650),
    ];

    return List.generate(positions.length, (i) {
      bool unlocked = i < 3;
      return Positioned(
        left: positions[i].dx,
        top: positions[i].dy,
        child: LessonNode(
          unlocked: unlocked,
          animation: _pulseController,
        ),
      );
    });
  }
}
