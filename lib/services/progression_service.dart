import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:running_robot/models/lesson_progress.dart';
import 'package:running_robot/models/user_profile.dart';
import 'package:running_robot/services/user_profile_service.dart';

class ProgressionSnapshot {
  final UserProfile profile;
  final Map<String, LessonProgress> lessonProgressById;

  const ProgressionSnapshot({
    required this.profile,
    required this.lessonProgressById,
  });
}

class ProgressionService {
  static final _firestore = FirebaseFirestore.instance;

  static Future<ProgressionSnapshot?> loadCurrentProgression() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final profile = await UserProfileService.getCurrentUserProfile();
    if (profile == null) return null;

    final lessonSnapshots = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('lessonProgress')
        .get();

    final lessonProgressById = <String, LessonProgress>{};
    for (final doc in lessonSnapshots.docs) {
      lessonProgressById[doc.id] = LessonProgress.fromMap(doc.data());
    }

    return ProgressionSnapshot(
      profile: profile,
      lessonProgressById: lessonProgressById,
    );
  }
}
