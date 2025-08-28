// FILE: lib/z_pages/lesson_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// ===== Global gaps (tweak these) =====
const double kPillTopGap = 25.0; // distance from STATUS BAR to Chapter pill
const double kMapTopGap =
    100.0; // extra space between pill area and first node/map

class LessonPage extends StatefulWidget {
  const LessonPage({super.key});

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _dropdownOpen = false;
  int _currentChapter = 1;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
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
      // allow body to render behind the transparent AppBar
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark, // dark status bar icons

        // ===== FIX: remove Material3 scrolled-under tint/overlay =====
        scrolledUnderElevation: 0, // <--- CHANGED
        surfaceTintColor: Colors.transparent, // <--- CHANGED
        shadowColor: Colors.transparent, // <--- CHANGED (belt & braces)
      ),
      body: Stack(
        children: [
          // ===== MAP SCROLL AREA =====
          Positioned.fill(
            child: SingleChildScrollView(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 1800 + kMapTopGap, // make room for the top gap
                child: Padding(
                  // push the entire map (path + nodes) down by kMapTopGap
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

          // ===== FLOATING PILL + DROPDOWN (overlaps AppBar area) =====
          Positioned(
            // Pill sits relative to status bar + your global gap
            top: statusBar + kPillTopGap,
            left: 0,
            right: 0,
            child: Column(
              children: [
                _buildChapterPill(),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: _dropdownOpen
                      ? _buildDropdown(chapters)
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
  // CHAPTER PILL
  // =========================
  Widget _buildChapterPill() {
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(40),
          onTap: () => setState(() => _dropdownOpen = !_dropdownOpen),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome, color: Colors.blue.shade600),
              const SizedBox(width: 10),
              Text(
                "Chapter $_currentChapter",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 10),
              AnimatedRotation(
                turns: _dropdownOpen ? 0.5 : 0,
                duration: const Duration(milliseconds: 300),
                child: const Icon(Icons.expand_more, color: Colors.black54),
              )
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // DROPDOWN
  // =========================
  Widget _buildDropdown(List<int> chapters) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        children: chapters.map((c) {
          final unlocked = c <= 3; // first 3 unlocked
          final isCurrent = c == _currentChapter;
          return InkWell(
            onTap: unlocked
                ? () {
                    setState(() {
                      _currentChapter = c;
                      _dropdownOpen = false;
                    });
                  }
                : null,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Row(
                children: [
                  Icon(
                    unlocked ? Icons.auto_awesome : Icons.lock_outline,
                    color: unlocked
                        ? (isCurrent
                            ? Colors.blue.shade600
                            : Colors.grey.shade600)
                        : Colors.grey.shade400,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Chapter $c",
                    style: TextStyle(
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                      fontSize: 14,
                      color: unlocked
                          ? (isCurrent ? Colors.blue.shade700 : Colors.black87)
                          : Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
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

// =========================
// NODE WIDGET
// =========================
class LessonNode extends StatelessWidget {
  final bool unlocked;
  final Animation<double> animation;

  const LessonNode({
    super.key,
    required this.unlocked,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: unlocked
          ? Tween<double>(begin: 1.0, end: 1.15).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeInOut),
            )
          : const AlwaysStoppedAnimation(1.0),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: unlocked
              ? const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: unlocked ? null : Colors.grey.shade400,
          border: Border.all(
            color: unlocked ? Colors.blue.shade200 : Colors.grey.shade600,
            width: 4,
          ),
        ),
        child: const Center(
          child: Icon(
            Icons.auto_awesome,
            color: Colors.white,
            size: 32,
          ),
        ),
      ),
    );
  }
}

// =========================
// PATH
// =========================
class PathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black26
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(200, 140);
    path.quadraticBezierTo(320, 200, 260, 340);
    path.quadraticBezierTo(100, 420, 140, 520);
    path.quadraticBezierTo(260, 620, 210, 720);
    path.quadraticBezierTo(50, 800, 100, 920);
    path.quadraticBezierTo(300, 1000, 230, 1120);
    path.quadraticBezierTo(100, 1200, 160, 1320);
    path.quadraticBezierTo(280, 1400, 270, 1520);
    path.quadraticBezierTo(100, 1600, 160, 1670);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
