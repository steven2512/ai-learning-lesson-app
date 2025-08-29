// FILE: lib/z_pages/assets/lessonPage/lesson_node.dart
import 'package:flutter/material.dart';
import 'package:running_robot/core/app_router.dart'
    show AppNavigate; // CHANGE: need AppNavigate for builder

class LessonNode extends StatelessWidget {
  final bool unlocked;
  final Animation<double> animation;

  // CHANGE: accept onNavigate and a builder that returns a VoidCallback
  final AppNavigate onNavigate; // provided by parent page
  final VoidCallback Function(AppNavigate) onTapBuilder; // returns onTap

  const LessonNode({
    super.key,
    required this.unlocked,
    required this.animation,
    required this.onNavigate, // CHANGE
    required this.onTapBuilder, // CHANGE
  });

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: unlocked
          ? Tween<double>(begin: 1.0, end: 1.15).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeInOut),
            )
          : const AlwaysStoppedAnimation(1.0),
      child: Material(
        // CHANGE: add Material for proper InkWell splash
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap:
              unlocked ? onTapBuilder(onNavigate) : null, // CHANGE: clickable
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
