const LESSONS = [
  {
    lessonId: "data-intro",
    courseId: "ai-theory-foundations",
    chapterId: "data-basics",
    globalLessonNumber: 1,
  },
  {
    lessonId: "data-ai-relevance",
    courseId: "ai-theory-foundations",
    chapterId: "data-basics",
    globalLessonNumber: 2,
  },
  {
    lessonId: "binary-intro",
    courseId: "ai-theory-foundations",
    chapterId: "data-basics",
    globalLessonNumber: 3,
  },
  {
    lessonId: "qual-quan",
    courseId: "ai-theory-foundations",
    chapterId: "data-basics",
    globalLessonNumber: 4,
  },
  {
    lessonId: "qual-game",
    courseId: "ai-theory-foundations",
    chapterId: "data-basics",
    globalLessonNumber: 5,
  },
  {
    lessonId: "data-sample-intro",
    courseId: "ai-theory-foundations",
    chapterId: "data-basics",
    globalLessonNumber: 6,
  },
  {
    lessonId: "features-intro",
    courseId: "ai-theory-foundations",
    chapterId: "data-basics",
    globalLessonNumber: 7,
  },
  {
    lessonId: "label-intro",
    courseId: "ai-theory-foundations",
    chapterId: "data-basics",
    globalLessonNumber: 8,
  },
  {
    lessonId: "label-feature-game",
    courseId: "ai-theory-foundations",
    chapterId: "data-basics",
    globalLessonNumber: 9,
  },
];

const lessonsById = Object.freeze(
  Object.fromEntries(LESSONS.map((lesson) => [lesson.lessonId, lesson])),
);

function getLessonOrThrow(lessonId) {
  const lesson = lessonsById[lessonId];
  if (!lesson) {
    const error = new Error(`Unknown lesson: ${lessonId}`);
    error.code = "invalid-argument";
    throw error;
  }
  return lesson;
}

module.exports = {
  LESSONS,
  lessonsById,
  TOTAL_LESSON_COUNT: LESSONS.length,
  getLessonOrThrow,
};
