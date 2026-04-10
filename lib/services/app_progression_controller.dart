import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:running_robot/core/lesson_manifest.dart';
import 'package:running_robot/models/activity_day_metrics.dart';
import 'package:running_robot/models/lesson_progress.dart';
import 'package:running_robot/models/user_profile.dart';
import 'package:running_robot/services/app_cache_service.dart';
import 'package:running_robot/services/progression_service.dart';

enum LessonUiState { locked, available, inProgress, completed }

class AppProgressionController extends ChangeNotifier {
  AppProgressionController._();

  static final AppProgressionController instance = AppProgressionController._();

  ProgressionSnapshot? _snapshot;
  bool _isLoading = false;
  Object? _error;

  ProgressionSnapshot? get snapshot => _snapshot;
  bool get hasSnapshot => _snapshot != null;
  bool get isLoading => _isLoading;
  Object? get error => _error;
  bool get shouldShowShellSkeleton => _snapshot == null && _isLoading;

  UserProfile? get profile => _snapshot?.profile;
  Map<String, LessonProgress> get lessonProgressById =>
      _snapshot?.lessonProgressById ?? const {};

  List<LessonMeta> get allLessons =>
      chapterManifest.expand((chapter) => chapter.lessons).toList();

  int get totalLessonCount => allLessons.length;
  int get currentLessonNumber => profile?.currentLesson ?? 1;
  int get currentLessonStepIndex => profile?.currentLessonStepIndex ?? 0;
  int get lessonsCompleted => profile?.lessonsCompleted ?? 0;
  int get totalXp => profile?.xp ?? 0;
  int get level => profile?.level ?? 1;
  int get totalLearningSeconds => profile?.totalLearningSeconds ?? 0;
  int get totalSessionSeconds => profile?.totalSessionSeconds ?? 0;
  int get dailyStreak => profile?.dailyStreak ?? 0;
  int get todayLessonCount => profile?.todayLessonCount ?? 0;
  String? get lastDailyLessonDate => profile?.lastDailyLessonDate;
  int get activityStreak => profile?.activityStreak ?? 0;
  String? get lastActivityDateKey => profile?.lastActivityDateKey;
  Set<String> get weeklyActivityDateKeys =>
      _snapshot?.weeklyActivityDateKeys ?? const <String>{};
  Map<String, ActivityDayMetrics> get weeklyActivityByDateKey =>
      _snapshot?.weeklyActivityByDateKey ?? const <String, ActivityDayMetrics>{};

  int get courseProgressPercent {
    if (totalLessonCount == 0) return 0;
    return ((lessonsCompleted / totalLessonCount) * 100).round().clamp(0, 100);
  }

  LessonMeta? get currentLessonMeta {
    if (allLessons.isEmpty) return null;
    final safeIndex = (currentLessonNumber - 1).clamp(0, allLessons.length - 1);
    return allLessons[safeIndex];
  }

  String? get currentLessonId => currentLessonMeta?.id;

  Future<void> load() async {
    if (_snapshot != null || _isLoading) return;
    await _hydrateAndRefresh();
  }

  Future<void> refresh() async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      final user = FirebaseAuth.instance.currentUser;
      final freshSnapshot = await ProgressionService.loadCurrentProgression();
      _error = null;
      if (freshSnapshot != null) {
        _snapshot = freshSnapshot;
        if (user != null) {
          await AppCacheService.writeProgressionSnapshot(
            user.uid,
            freshSnapshot,
          );
        }
      }
    } catch (error) {
      _error = error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _snapshot = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _hydrateAndRefresh() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      clear();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final cachedSnapshot =
          await AppCacheService.readProgressionSnapshot(user.uid);
      if (cachedSnapshot != null) {
        _snapshot = cachedSnapshot;
        _error = null;
        notifyListeners();
      }

      final freshSnapshot = await ProgressionService.loadCurrentProgression();
      _error = null;

      if (freshSnapshot != null) {
        _snapshot = freshSnapshot;
        await AppCacheService.writeProgressionSnapshot(user.uid, freshSnapshot);
      }
    } catch (error) {
      _error = error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  LessonProgress? lessonProgressByIdOrNull(String lessonId) {
    return lessonProgressById[lessonId];
  }

  bool isLessonCompleted(String lessonId) {
    return lessonProgressById[lessonId]?.isCompleted == true;
  }

  bool isLessonUnlocked(int globalLessonNumber) {
    return globalLessonNumber <= currentLessonNumber;
  }

  LessonUiState lessonUiStateFor({
    required String lessonId,
    required int globalLessonNumber,
  }) {
    if (isLessonCompleted(lessonId)) return LessonUiState.completed;
    if (globalLessonNumber == currentLessonNumber) {
      return LessonUiState.inProgress;
    }
    if (isLessonUnlocked(globalLessonNumber)) return LessonUiState.available;
    return LessonUiState.locked;
  }

  String actionLabelForLesson({
    required String lessonId,
    required int globalLessonNumber,
  }) {
    final state = lessonUiStateFor(
      lessonId: lessonId,
      globalLessonNumber: globalLessonNumber,
    );

    switch (state) {
      case LessonUiState.completed:
        return 'Review Lesson';
      case LessonUiState.inProgress:
        return currentLessonStepIndex > 0 ? 'Continue Lesson' : 'Start Lesson';
      case LessonUiState.available:
        return 'Start Lesson';
      case LessonUiState.locked:
        return 'Locked';
    }
  }
}
