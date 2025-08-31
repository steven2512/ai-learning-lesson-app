// FILE: lib/z_pages/lesson_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:running_robot/z_pages/assets/lessonPage/box_circle.dart';

class LessonPage extends StatefulWidget {
  const LessonPage({super.key});
  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  final double itemSpacing = 28;

  // Brighter single tones
  static const Color _cData = Color(0xFF10B981); // emerald 500
  static const Color _cLearning = Color(0xFF6366F1); // indigo 500
  static const Color _cLocked = Color(0xFF7C8AA6); // slate-ish mid grey

  BoxWithCircle _lesson({
    required String title,
    String? subtitle,
    required bool locked,
    double percent = 0,
    required Color color,
    required IconData icon,
  }) {
    return BoxWithCircle(
      title: title,
      subtitle: subtitle,
      percent: percent,
      locked: locked,
      textColor: Colors.white,
      backgroundColor: color, // single tone
      backgroundGradient: null, // ensure no gradient
      progressColor: locked ? Colors.white70 : Colors.white,
      center: Icon(locked ? Icons.lock_rounded : icon,
          color: Colors.white, size: 28),
      onTap: () => debugPrint('Open $title'),
      onGo: () => debugPrint('Go to $title'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Lessons',
          style: GoogleFonts.lato(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.black,
            letterSpacing: 0.2,
          ),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _lesson(
            title: 'Chapter 1: Data',
            subtitle: 'Collect • Clean • Split',
            locked: false,
            percent: 0.35,
            color: _cData,
            icon: Icons.bolt_rounded,
          ),
          SizedBox(height: itemSpacing),
          _lesson(
            title: 'Chapter 2: Learning',
            subtitle: 'Supervised • Unsupervised • RL',
            locked: false,
            percent: 0.72,
            color: _cLearning,
            icon: Icons.local_fire_department_rounded,
          ),
          SizedBox(height: itemSpacing),
          _lesson(
            title: 'Chapter 3: Models',
            subtitle: 'Trees • Linear • KNN',
            locked: true,
            color: _cLocked,
            icon: Icons.lock_rounded,
          ),
          SizedBox(height: itemSpacing),
          _lesson(
            title: 'Chapter 4: Neural Networks',
            subtitle: 'Layers • Activation • Training',
            locked: true,
            color: _cLocked,
            icon: Icons.lock_rounded,
          ),
          SizedBox(height: itemSpacing),
          _lesson(
            title: 'Chapter 5: Applications',
            subtitle: 'Vision • Language • Agents',
            locked: true,
            color: _cLocked,
            icon: Icons.lock_rounded,
          ),
        ],
      ),
    );
  }
}
