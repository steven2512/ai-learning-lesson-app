// lib/core/lesson_manifest.dart
import 'package:running_robot/core/app_router.dart';
import 'package:running_robot/z_pages/lessons/data-ai-relevance/_brain.dart';

// brains
import 'package:running_robot/z_pages/lessons/data-intro/_brain.dart';
import 'package:running_robot/z_pages/lessons/binary-intro/_brain.dart';
import 'package:running_robot/z_pages/lessons/data-sample-intro/_brain.dart';
import 'package:running_robot/z_pages/lessons/features-intro/_brain.dart';
import 'package:running_robot/z_pages/lessons/label-feature-game/_brain.dart';
import 'package:running_robot/z_pages/lessons/label-intro/_brain.dart';
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

/// ===== COURSE =====
class CourseMeta {
  final String id; // semantic id (e.g. "ai-course-1")
  final String title; // display title
  final List<ChapterMeta> chapters; // ordered chapters

  const CourseMeta({
    required this.id,
    required this.title,
    required this.chapters,
  });
}

/// ===== MASTER MANIFEST (backward-compatible) =====
final List<ChapterMeta> chapterManifest = [
  ChapterMeta(
    id: "data-basics",
    title: "Foundations of AI",
    lessons: [
      LessonMeta(
        id: "data-intro",
        title: "What is Data?",
        builder: (nav) => DataIntroBrain(onNavigate: nav),
      ),
      LessonMeta(
        id: "data-ai-relevance",
        title: "Why is Data so important for AI?",
        builder: (nav) => DataAiRelevance(onNavigate: nav),
      ),
      LessonMeta(
        id: "binary-intro",
        title: "What is Binary?",
        builder: (nav) => BinaryIntroBrain(onNavigate: nav),
      ),
      LessonMeta(
        id: "qual-quan",
        title: "Qualitative vs Quantitative",
        builder: (nav) => QualQuanBrain(onNavigate: nav),
      ),
      LessonMeta(
        id: "qual-game",
        title: "Qualitative Mini-Game",
        builder: (nav) => QualGameBrain(onNavigate: nav),
      ),
      LessonMeta(
        id: "data-sample-intro",
        title: "What is a Data Sample?",
        builder: (nav) => DataSampleIntroBrain(onNavigate: nav),
      ),
      LessonMeta(
        id: "features-intro",
        title: "What is a Feature?",
        builder: (nav) => FeaturesIntroBrain(onNavigate: nav),
      ),
      LessonMeta(
        id: "label-intro",
        title: "What is a Label?",
        builder: (nav) => LabelIntroBrain(onNavigate: nav),
      ),
      LessonMeta(
        id: "label-feature-game",
        title: "label-Features Game",
        builder: (nav) => LabelFeatureGameBrain(onNavigate: nav),
      ),
    ],
  ),
];

/// ===== NEW: COURSE MANIFEST =====
final List<CourseMeta> courseManifest = [
  CourseMeta(
    id: "ai-theory-foundations",
    title: "AI Foundations Course",
    chapters: chapterManifest, // reuse existing chapters
  ),
  // 🔮 Add more courses later
];
