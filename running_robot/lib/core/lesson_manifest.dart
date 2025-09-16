// lib/core/lesson_manifest.dart
import 'package:running_robot/core/app_router.dart';
import 'package:running_robot/z_pages/lessons/data-intro/_brain.dart';
import 'package:running_robot/z_pages/lessons/binary-intro/_brain.dart';
import 'package:running_robot/z_pages/lessons/qual-game/_brain.dart';
import 'package:running_robot/z_pages/lessons/qual-quan/_brain.dart';

typedef LessonBuilder = dynamic Function(AppNavigate onNavigate);

class LessonMeta {
  final String id;
  final String title;
  final LessonBuilder builder;

  const LessonMeta(
      {required this.id, required this.title, required this.builder});
}

// 🔹 ONLY order + existence
final List<LessonMeta> lessonManifest = [
  LessonMeta(
    id: "data-intro",
    title: "Data Intro",
    builder: (nav) => DataIntroBrain(onNavigate: nav),
  ),
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
  // add new lessons here, order-only
];
