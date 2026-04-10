class ActivityDayMetrics {
  final String dateKey;
  final int learningSeconds;
  final int sessionSeconds;
  final int lessonsCompleted;
  final bool didOpenApp;
  final bool didCompleteLesson;

  const ActivityDayMetrics({
    required this.dateKey,
    this.learningSeconds = 0,
    this.sessionSeconds = 0,
    this.lessonsCompleted = 0,
    this.didOpenApp = false,
    this.didCompleteLesson = false,
  });

  bool get hasActivity =>
      didOpenApp ||
      didCompleteLesson ||
      learningSeconds > 0 ||
      sessionSeconds > 0 ||
      lessonsCompleted > 0;

  factory ActivityDayMetrics.fromMap(
    String fallbackDateKey,
    Map<String, dynamic> map,
  ) {
    return ActivityDayMetrics(
      dateKey: map['dateKey']?.toString().trim().isNotEmpty == true
          ? map['dateKey'].toString()
          : fallbackDateKey,
      learningSeconds: _readInt(map['learningSeconds']),
      sessionSeconds: _readInt(map['sessionSeconds']),
      lessonsCompleted: _readInt(map['lessonsCompleted']),
      didOpenApp: map['didOpenApp'] == true,
      didCompleteLesson: map['didCompleteLesson'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dateKey': dateKey,
      'learningSeconds': learningSeconds,
      'sessionSeconds': sessionSeconds,
      'lessonsCompleted': lessonsCompleted,
      'didOpenApp': didOpenApp,
      'didCompleteLesson': didCompleteLesson,
    };
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
