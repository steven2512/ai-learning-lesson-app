// FILE: lib/z_pages/lessonPage/chapter_pill.dart
import 'package:flutter/material.dart';

class ChapterPill extends StatelessWidget {
  final int currentChapter;
  final bool dropdownOpen;
  final VoidCallback onTap;

  const ChapterPill({
    super.key,
    required this.currentChapter,
    required this.dropdownOpen,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(40),
        child: InkWell(
          borderRadius: BorderRadius.circular(40),
          onTap: onTap,
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, color: Colors.blue.shade600),
                const SizedBox(width: 10),
                Text(
                  "Chapter $currentChapter",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 10),
                AnimatedRotation(
                  turns: dropdownOpen ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: const Icon(Icons.expand_more, color: Colors.black54),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
