// FILE: lib/z_pages/lessonPage/chapter_dropdown.dart
import 'package:flutter/material.dart';

class ChapterDropdown extends StatelessWidget {
  final List<int> chapters;
  final int currentChapter;
  final ValueChanged<int> onChapterSelected;

  const ChapterDropdown({
    super.key,
    required this.chapters,
    required this.currentChapter,
    required this.onChapterSelected,
  });

  @override
  Widget build(BuildContext context) {
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
          final isCurrent = c == currentChapter;
          return InkWell(
            onTap: unlocked ? () => onChapterSelected(c) : null,
            child: Container(
              width: double.infinity,
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
}
