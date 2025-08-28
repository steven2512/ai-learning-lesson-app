// FILE: lib/z_pages/lesson_page.dart
import 'package:flutter/material.dart';

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

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        // title: const Text(
        //   "Lesson Map",
        //   style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        // ),
      ),
      body: Column(
        children: [
          // const SizedBox(height: 16),
          // ======= CHAPTER SELECTOR PILL =======
          Center(
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
                      child:
                          const Icon(Icons.expand_more, color: Colors.black54),
                    )
                  ],
                ),
              ),
            ),
          ),

          // ======= DROPDOWN LIST =======
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _dropdownOpen
                ? Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 8),
                            child: Row(
                              children: [
                                Icon(
                                  unlocked
                                      ? Icons.auto_awesome
                                      : Icons.lock_outline,
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
                                    fontWeight: isCurrent
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    fontSize: 14,
                                    color: unlocked
                                        ? (isCurrent
                                            ? Colors.blue.shade700
                                            : Colors.black87)
                                        : Colors.grey.shade400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          const SizedBox(height: 20),

          // ======= MAP =======
          Expanded(
            child: SingleChildScrollView(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 1800,
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
        ],
      ),
    );
  }

  List<Widget> _buildLessonNodes() {
    final positions = [
      const Offset(150, 100),
      const Offset(200, 300),
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

// ========== NODE WIDGET ==========
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
          : AlwaysStoppedAnimation(1.0),
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
        child: Center(
          child: Icon(
            unlocked ? Icons.auto_awesome : Icons.lock,
            color: Colors.white,
            size: 32,
          ),
        ),
      ),
    );
  }
}

// ========== PATH PAINTER ==========
class PathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black26
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(190, 140);
    path.quadraticBezierTo(300, 200, 240, 340);
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
