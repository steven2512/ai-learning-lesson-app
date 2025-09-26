// lib/core/lesson_manifest.dart
import 'package:running_robot/core/app_router.dart';
import 'package:running_robot/z_pages/lessons/data-ai-relevance/_brain.dart';

// brains
import 'package:running_robot/z_pages/lessons/data-intro/_brain.dart';
import 'package:running_robot/z_pages/lessons/binary-intro/_brain.dart';
import 'package:running_robot/z_pages/lessons/qual-quan/_brain.dart';
import 'package:running_robot/z_pages/lessons/qual-game/_brain.dart';

typedef LessonBuilder = dynamic Function(AppNavigate onNavigate);

/// ===== LESSON =====
class LessonMeta {
  final String id; // semantic id (e.g. "data-intro")
  final String title; // display title
  final LessonBuilder builder;

  const LessonMeta({
    required this.id,
    required this.title,
    required this.builder,
  });
}

/// ===== CHAPTER =====
class ChapterMeta {
  final String id; // semantic id (e.g. "foundations")
  final String title; // display title
  final List<LessonMeta> lessons; // ordered lessons

  const ChapterMeta({
    required this.id,
    required this.title,
    required this.lessons,
  });
}

/// ===== MASTER MANIFEST =====
final List<ChapterMeta> chapterManifest = [
  ChapterMeta(
    id: "foundations",
    title: "Foundations of AI",
    lessons: [
      LessonMeta(
        id: "data-intro",
        title: "Data Intro",
        builder: (nav) => DataIntroBrain(onNavigate: nav),
      ),
      LessonMeta(
          id: "data-ai-relevance",
          title: "Why is Data so important for AI?",
          builder: (nav) => DataAiRelevance(onNavigate: nav)),
      LessonMeta(
        id: "binary-intro",
        title: "Binary Intro",
        builder: (nav) => BinaryIntroBrain(onNavigate: nav),
      ),
      LessonMeta(
        id: "qual-quan",
        title: "Qualitative vs Quantitative",
        builder: (nav) => QualQuanBrain(onNavigate: nav),
      ),
      LessonMeta(
        id: "qual-game",
        title: "Qualitative Game",
        builder: (nav) => QualGameBrain(onNavigate: nav),
      ),
    ],
  ),

  // 🔮 Future example:
  // ChapterMeta(
  //   id: "ml-basics",
  //   title: "Machine Learning Basics",
  //   lessons: [...],
  // ),
];
