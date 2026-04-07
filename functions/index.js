const admin = require("firebase-admin");
const logger = require("firebase-functions/logger");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { getLessonOrThrow, TOTAL_LESSON_COUNT } = require("./lessonManifest");
const {
  computeNextDailyStreak,
  dateKeyForOffset,
  readInt,
} = require("./progression");

admin.initializeApp();

const db = admin.firestore();
const LESSON_XP_REWARD = 50;
const XP_PER_LEVEL = 200;
const MAX_SESSION_SECONDS_PER_FLUSH = 60 * 60 * 4;

function requireAuth(request) {
  if (!request.auth?.uid) {
    throw new HttpsError("unauthenticated", "Authentication is required.");
  }

  return request.auth.uid;
}

function requireLessonId(data) {
  const lessonId = data?.lessonId;
  if (typeof lessonId !== "string" || lessonId.trim().length === 0) {
    throw new HttpsError("invalid-argument", "A valid lessonId is required.");
  }

  return lessonId.trim();
}

function requireStepIndex(data) {
  const rawStepIndex = data?.stepIndex;
  if (!Number.isInteger(rawStepIndex) || rawStepIndex < 0) {
    throw new HttpsError("invalid-argument", "A valid stepIndex is required.");
  }

  return rawStepIndex;
}

function requireLesson(data) {
  const lessonId = requireLessonId(data);

  try {
    return getLessonOrThrow(lessonId);
  } catch (error) {
    throw new HttpsError("invalid-argument", error.message);
  }
}

function userDoc(uid) {
  return db.collection("users").doc(uid);
}

function lessonDoc(uid, lessonId) {
  return userDoc(uid).collection("lessonProgress").doc(lessonId);
}

function levelForXp(xp) {
  const safeXp = Math.max(0, readInt(xp, 0));
  return Math.floor(safeXp / XP_PER_LEVEL) + 1;
}

function readTimestampMillis(value) {
  if (value && typeof value.toMillis === "function") {
    return value.toMillis();
  }

  return null;
}

function sessionSecondsSince(lessonData) {
  const startedAtMillis = readTimestampMillis(lessonData.activeSessionStartedAt);
  if (startedAtMillis == null) {
    return 0;
  }

  const elapsedSeconds = Math.floor((Date.now() - startedAtMillis) / 1000);
  if (!Number.isFinite(elapsedSeconds) || elapsedSeconds <= 0) {
    return 0;
  }

  return Math.min(elapsedSeconds, MAX_SESSION_SECONDS_PER_FLUSH);
}

function newLessonProgressPayload(lesson) {
  return {
    lessonId: lesson.lessonId,
    courseId: lesson.courseId,
    chapterId: lesson.chapterId,
    globalLessonNumber: lesson.globalLessonNumber,
    startedAt: admin.firestore.FieldValue.serverTimestamp(),
    activeSessionStartedAt: admin.firestore.FieldValue.serverTimestamp(),
    lastActiveAt: admin.firestore.FieldValue.serverTimestamp(),
    isCompleted: false,
    completedAt: null,
    completedCount: 0,
  };
}

function lessonCompletionPayload(
  lessonData,
  lesson,
  completedCount,
  alreadyCompleted,
) {
  return {
    lessonId: lesson.lessonId,
    courseId: lesson.courseId,
    chapterId: lesson.chapterId,
    globalLessonNumber: lesson.globalLessonNumber,
    startedAt: lessonData.startedAt ?? admin.firestore.FieldValue.serverTimestamp(),
    activeSessionStartedAt: null,
    lastActiveAt: admin.firestore.FieldValue.serverTimestamp(),
    completedCount: completedCount + 1,
    ...(alreadyCompleted
      ? {}
      : {
          isCompleted: true,
          completedAt: admin.firestore.FieldValue.serverTimestamp(),
        }),
  };
}

function userCompletionSummaryPayload({
  lessonsCompleted,
  xp,
  level,
  totalLearningSeconds,
  todayLessonCount,
  todayKey,
  dailyStreak,
  currentLesson,
}) {
  return {
    lessonsCompleted: lessonsCompleted + 1,
    xp: xp + LESSON_XP_REWARD,
    todayLessonCount,
    todayLessonCountDate: todayKey,
    dailyStreak,
    lastDailyLessonDate: todayKey,
    currentLesson,
    currentLessonStepIndex: 0,
    level,
    totalLearningSeconds,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };
}

function ensureUnlocked(currentLesson, lesson) {
  if (lesson.globalLessonNumber > currentLesson) {
    throw new HttpsError(
      "permission-denied",
      "This lesson is still locked for the current user.",
    );
  }
}

exports.startLesson = onCall(async (request) => {
  const uid = requireAuth(request);
  const lesson = requireLesson(request.data);

  const response = await db.runTransaction(async (transaction) => {
    const userRef = userDoc(uid);
    const lessonRef = lessonDoc(uid, lesson.lessonId);

    const [userSnap, lessonSnap] = await Promise.all([
      transaction.get(userRef),
      transaction.get(lessonRef),
    ]);

    if (!userSnap.exists) {
      throw new HttpsError(
        "failed-precondition",
        "User profile must exist before starting a lesson.",
      );
    }

    const userData = userSnap.data() ?? {};
    const currentLesson = readInt(userData.currentLesson, 1);
    ensureUnlocked(currentLesson, lesson);

    const lessonData = lessonSnap.data() ?? {};
    const isCompleted = lessonData.isCompleted === true;
    const isCurrentProgressionLesson =
      currentLesson === lesson.globalLessonNumber && !isCompleted;
    const initialStepIndex = isCurrentProgressionLesson
      ? readInt(userData.currentLessonStepIndex, 0)
      : 0;

    if (!lessonSnap.exists) {
      transaction.set(lessonRef, newLessonProgressPayload(lesson));
    } else {
      transaction.set(lessonRef, {
        activeSessionStartedAt: admin.firestore.FieldValue.serverTimestamp(),
        lastActiveAt: admin.firestore.FieldValue.serverTimestamp(),
      }, { merge: true });
    }

    return {
      initialStepIndex,
      isCompleted,
      isCurrentProgressionLesson,
      currentLesson,
    };
  });

  return response;
});

exports.saveLessonProgress = onCall(async (request) => {
  const uid = requireAuth(request);
  const lesson = requireLesson(request.data);
  const stepIndex = requireStepIndex(request.data);

  const response = await db.runTransaction(async (transaction) => {
    const userRef = userDoc(uid);
    const lessonRef = lessonDoc(uid, lesson.lessonId);

    const [userSnap, lessonSnap] = await Promise.all([
      transaction.get(userRef),
      transaction.get(lessonRef),
    ]);

    if (!userSnap.exists) {
      throw new HttpsError(
        "failed-precondition",
        "User profile must exist before saving lesson progress.",
      );
    }

    const userData = userSnap.data() ?? {};
    const currentLesson = readInt(userData.currentLesson, 1);
    ensureUnlocked(currentLesson, lesson);

    const lessonData = lessonSnap.data() ?? {};
    const isCompleted = lessonData.isCompleted === true;
    const elapsedSeconds = sessionSecondsSince(lessonData);
    const totalLearningSeconds =
      readInt(userData.totalLearningSeconds, 0) + elapsedSeconds;

    if (!lessonSnap.exists) {
      transaction.set(lessonRef, newLessonProgressPayload(lesson));
    } else {
      transaction.set(
        lessonRef,
        {
          activeSessionStartedAt: admin.firestore.FieldValue.serverTimestamp(),
          lastActiveAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
    }

    let savedStepIndex = readInt(userData.currentLessonStepIndex, 0);
    if (currentLesson === lesson.globalLessonNumber && !isCompleted) {
      savedStepIndex = stepIndex;
    }

    transaction.set(
      userRef,
      {
        currentLessonStepIndex: savedStepIndex,
        totalLearningSeconds,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true },
    );

    return { savedStepIndex };
  });

  return response;
});

exports.pauseLessonSession = onCall(async (request) => {
  const uid = requireAuth(request);
  const lesson = requireLesson(request.data);
  const stepIndex = requireStepIndex(request.data);

  const response = await db.runTransaction(async (transaction) => {
    const userRef = userDoc(uid);
    const lessonRef = lessonDoc(uid, lesson.lessonId);

    const [userSnap, lessonSnap] = await Promise.all([
      transaction.get(userRef),
      transaction.get(lessonRef),
    ]);

    if (!userSnap.exists) {
      throw new HttpsError(
        "failed-precondition",
        "User profile must exist before pausing a lesson session.",
      );
    }

    if (!lessonSnap.exists) {
      return { totalLearningSeconds: readInt(userSnap.data()?.totalLearningSeconds, 0) };
    }

    const userData = userSnap.data() ?? {};
    const currentLesson = readInt(userData.currentLesson, 1);
    ensureUnlocked(currentLesson, lesson);

    const lessonData = lessonSnap.data() ?? {};
    const isCompleted = lessonData.isCompleted === true;
    const elapsedSeconds = sessionSecondsSince(lessonData);
    const totalLearningSeconds =
      readInt(userData.totalLearningSeconds, 0) + elapsedSeconds;
    const savedStepIndex =
      currentLesson === lesson.globalLessonNumber && !isCompleted
        ? stepIndex
        : readInt(userData.currentLessonStepIndex, 0);

    transaction.set(
      lessonRef,
      {
        activeSessionStartedAt: null,
        lastActiveAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true },
    );

    transaction.set(
      userRef,
      {
        currentLessonStepIndex: savedStepIndex,
        totalLearningSeconds,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true },
    );

    return { totalLearningSeconds };
  });

  return response;
});

exports.completeLesson = onCall(async (request) => {
  const uid = requireAuth(request);
  const lesson = requireLesson(request.data);

  const response = await db.runTransaction(async (transaction) => {
    const userRef = userDoc(uid);
    const lessonRef = lessonDoc(uid, lesson.lessonId);

    const [userSnap, lessonSnap] = await Promise.all([
      transaction.get(userRef),
      transaction.get(lessonRef),
    ]);

    if (!userSnap.exists) {
      throw new HttpsError(
        "failed-precondition",
        "User profile must exist before completing a lesson.",
      );
    }

    const userData = userSnap.data() ?? {};
    const currentLesson = readInt(userData.currentLesson, 1);
    ensureUnlocked(currentLesson, lesson);

    const lessonData = lessonSnap.data() ?? {};
    const alreadyCompleted = lessonData.isCompleted === true;
    const completedCount = readInt(lessonData.completedCount, 0);
    const elapsedSeconds = sessionSecondsSince(lessonData);
    const currentXp = readInt(userData.xp, 0);
    const totalLearningSeconds =
      readInt(userData.totalLearningSeconds, 0) + elapsedSeconds;

    transaction.set(
      lessonRef,
      lessonCompletionPayload(
        lessonData,
        lesson,
        completedCount,
        alreadyCompleted,
      ),
      { merge: true },
    );

    let xpAwarded = 0;
    let nextCurrentLesson = currentLesson;
    let lessonsCompleted = readInt(userData.lessonsCompleted, 0);
    let todayLessonCount = readInt(userData.todayLessonCount, 0);
    let dailyStreak = readInt(userData.dailyStreak, 0);
    let level = readInt(userData.level, levelForXp(currentXp));

    if (!alreadyCompleted) {
      const nextLesson = lesson.globalLessonNumber < TOTAL_LESSON_COUNT
        ? lesson.globalLessonNumber + 1
        : lesson.globalLessonNumber;
      const todayKey = dateKeyForOffset(userData.timezoneOffsetMinutes);
      const todayLessonCountDate = userData.todayLessonCountDate ?? null;
      const lastDailyLessonDate = userData.lastDailyLessonDate ?? null;
      const isSameDay = todayLessonCountDate === todayKey;
      const nextTodayLessonCount = isSameDay ? todayLessonCount + 1 : 1;
      const nextDailyStreak = computeNextDailyStreak(
        lastDailyLessonDate,
        todayKey,
        dailyStreak,
      );

      nextCurrentLesson = Math.max(currentLesson, nextLesson);
      xpAwarded = LESSON_XP_REWARD;
      lessonsCompleted += 1;
      todayLessonCount = nextTodayLessonCount;
      dailyStreak = nextDailyStreak;
      level = levelForXp(currentXp + LESSON_XP_REWARD);

      transaction.set(
        userRef,
        userCompletionSummaryPayload({
          lessonsCompleted: readInt(userData.lessonsCompleted, 0),
          xp: currentXp,
          level,
          totalLearningSeconds,
          todayLessonCount: nextTodayLessonCount,
          todayKey,
          dailyStreak: nextDailyStreak,
          currentLesson: nextCurrentLesson,
        }),
        { merge: true },
      );
    } else {
      transaction.set(
        userRef,
        {
          totalLearningSeconds,
          level,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
    }

    return {
      firstCompletion: !alreadyCompleted,
      completedCount: completedCount + 1,
      xpAwarded,
      level,
      totalLearningSeconds,
      currentLesson: nextCurrentLesson,
      lessonsCompleted,
      todayLessonCount,
      dailyStreak,
    };
  });

  logger.info("Completed lesson progression update", {
    uid,
    lessonId: lesson.lessonId,
    firstCompletion: response.firstCompletion,
  });

  return response;
});
