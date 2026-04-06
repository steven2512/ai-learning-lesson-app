// FILE: lib/z_pages/assets/lessonPage/lesson_node.dart
import 'package:flutter/material.dart';
import 'package:running_robot/core/app_router.dart'
    show AppNavigate; // CHANGE: need AppNavigate for builder
import 'package:running_robot/services/app_progression_controller.dart';

class LessonNode extends StatelessWidget {
  final LessonUiState state;
  final Animation<double> animation;

  // CHANGE: accept onNavigate and a builder that returns a VoidCallback
  final AppNavigate onNavigate; // provided by parent page
  final VoidCallback Function(AppNavigate) onTapBuilder; // returns onTap

  const LessonNode({
    super.key,
    required this.state,
    required this.animation,
    required this.onNavigate, // CHANGE
    required this.onTapBuilder, // CHANGE
  });

  @override
  Widget build(BuildContext context) {
    final unlocked = state != LessonUiState.locked;
    final pulsing = state == LessonUiState.inProgress;
    final IconData icon;
    final Color iconColor;
    final Gradient? gradient;
    final Color? fillColor;
    final Color borderColor;

    switch (state) {
      case LessonUiState.completed:
        icon = Icons.check_rounded;
        iconColor = Colors.white;
        gradient = const LinearGradient(
          colors: [Color(0xFF16A34A), Color(0xFF4ADE80)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        fillColor = null;
        borderColor = const Color(0xFFBBF7D0);
        break;
      case LessonUiState.inProgress:
        icon = Icons.play_arrow_rounded;
        iconColor = Colors.white;
        gradient = const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFFCD34D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        fillColor = null;
        borderColor = const Color(0xFFFDE68A);
        break;
      case LessonUiState.available:
        icon = Icons.auto_awesome;
        iconColor = Colors.white;
        gradient = const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        fillColor = null;
        borderColor = const Color(0xFFBFDBFE);
        break;
      case LessonUiState.locked:
        icon = Icons.lock_rounded;
        iconColor = Colors.white70;
        gradient = null;
        fillColor = Colors.grey.shade400;
        borderColor = Colors.grey.shade600;
        break;
    }

    return ScaleTransition(
      scale: pulsing
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
              gradient: gradient,
              color: fillColor,
              border: Border.all(
                color: borderColor,
                width: 4,
              ),
            ),
            child: Center(
              child: Icon(
                icon,
                color: iconColor,
                size: 32,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
