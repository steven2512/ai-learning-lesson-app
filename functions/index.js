const admin = require("firebase-admin");
const crypto = require("crypto");
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
const MAX_APP_SESSION_SECONDS_PER_FLUSH = 60 * 60 * 12;
const OTP_LENGTH = 6;
const OTP_EXPIRY_MS = 10 * 60 * 1000;
const OTP_RESEND_COOLDOWN_MS = 60 * 1000;
const OTP_MAX_VERIFY_ATTEMPTS = 5;
const OTP_MAX_SENDS_PER_HOUR = 5;
const SIGNUP_VERIFICATION_EXPIRY_MS = 30 * 60 * 1000;

function envValue(name) {
  const raw = process.env[name];
  if (typeof raw !== "string") {
    return "";
  }

  return raw.trim();
}

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

function activityDayDoc(uid, dateKey) {
  return userDoc(uid).collection("activityDays").doc(dateKey);
}

function emailOtpDoc(uid) {
  return db.collection("_emailOtpSessions").doc(uid);
}

function signupEmailOtpDoc(email) {
  return db.collection("_signupEmailOtpSessions").doc(
    crypto.createHash("sha256").update(email).digest("hex"),
  );
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

function activitySummaryPayload({ activityStreak, todayKey }) {
  return {
    activityStreak,
    lastActivityDateKey: todayKey,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };
}

function requireSessionSeconds(data) {
  const rawSeconds = data?.sessionSeconds;
  if (!Number.isInteger(rawSeconds) || rawSeconds <= 0) {
    throw new HttpsError(
      "invalid-argument",
      "A valid positive sessionSeconds value is required.",
    );
  }

  return Math.min(rawSeconds, MAX_APP_SESSION_SECONDS_PER_FLUSH);
}

function ensureActivityDay(transaction, activityRef, activitySnap, todayKey) {
  transaction.set(
    activityRef,
    {
      dateKey: todayKey,
      didOpenApp: true,
      lastSeenAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      ...(activitySnap.exists
        ? {}
        : {
            firstSeenAt: admin.firestore.FieldValue.serverTimestamp(),
          }),
    },
    { merge: true },
  );
}

function incrementIfPositive(amount) {
  return amount > 0 ? admin.firestore.FieldValue.increment(amount) : undefined;
}

function writeActivityDayMetrics(
  transaction,
  activityRef,
  activitySnap,
  todayKey,
  {
    learningSecondsDelta = 0,
    sessionSecondsDelta = 0,
    lessonsCompletedDelta = 0,
    didCompleteLesson = false,
  } = {},
) {
  const activityData = activitySnap.data() ?? {};

  ensureActivityDay(transaction, activityRef, activitySnap, todayKey);

  transaction.set(
    activityRef,
    {
      ...(learningSecondsDelta > 0
        ? { learningSeconds: incrementIfPositive(learningSecondsDelta) }
        : {}),
      ...(sessionSecondsDelta > 0
        ? { sessionSeconds: incrementIfPositive(sessionSecondsDelta) }
        : {}),
      ...(lessonsCompletedDelta > 0
        ? { lessonsCompleted: incrementIfPositive(lessonsCompletedDelta) }
        : {}),
      ...(didCompleteLesson ? { didCompleteLesson: true } : {}),
    },
    { merge: true },
  );

  return {
    learningSeconds: readInt(activityData.learningSeconds, 0) + learningSecondsDelta,
    sessionSeconds: readInt(activityData.sessionSeconds, 0) + sessionSecondsDelta,
    lessonsCompleted: readInt(activityData.lessonsCompleted, 0) + lessonsCompletedDelta,
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

function signInProviderFor(request) {
  return request.auth?.token?.firebase?.sign_in_provider ?? null;
}

function isPasswordSignIn(request) {
  return signInProviderFor(request) === "password";
}

function isVerifiedPasswordUser(request) {
  if (!isPasswordSignIn(request)) {
    return true;
  }

  return request.auth?.token?.email_verified === true ||
    request.auth?.token?.verified_email_otp === true;
}

function requireVerifiedAccount(request) {
  if (!isVerifiedPasswordUser(request)) {
    throw new HttpsError(
      "failed-precondition",
      "Verify your email before continuing.",
    );
  }
}

function requireOtpConfig() {
  if (!envValue("AUTH_OTP_SECRET") || !envValue("AUTH_EMAIL_FROM")) {
    throw new HttpsError(
      "failed-precondition",
      "Email OTP is not configured on the server.",
    );
  }

  if (!envValue("RESEND_API_KEY")) {
    throw new HttpsError(
      "failed-precondition",
      "The email delivery provider is not configured on the server.",
    );
  }
}

function readTimestampDate(value) {
  if (value && typeof value.toDate === "function") {
    return value.toDate();
  }

  if (value instanceof Date) {
    return value;
  }

  return null;
}

function generateOtpCode() {
  return `${crypto.randomInt(0, 10 ** OTP_LENGTH)}`.padStart(OTP_LENGTH, "0");
}

function hashOtpCode(uid, code) {
  return crypto
    .createHmac("sha256", envValue("AUTH_OTP_SECRET"))
    .update(`${uid}:${code}`)
    .digest("hex");
}

function generateVerificationToken() {
  return crypto.randomBytes(24).toString("hex");
}

function isValidEmailFormat(email) {
  return /^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(email);
}

function senderFromAddress() {
  const fromEmail = envValue("AUTH_EMAIL_FROM");
  const productName = envValue("AUTH_EMAIL_PRODUCT_NAME") || "Running Robot";

  if (!fromEmail) {
    return "";
  }

  if (fromEmail.includes("<") && fromEmail.includes(">")) {
    return fromEmail;
  }

  if (isValidEmailFormat(fromEmail)) {
    return `${productName} <${fromEmail}>`;
  }

  return fromEmail;
}

function extractProviderErrorMessage(errorBody) {
  if (typeof errorBody !== "string" || errorBody.trim().length === 0) {
    return "";
  }

  try {
    const parsed = JSON.parse(errorBody);
    const directMessage = parsed?.message?.toString?.() ?? "";
    if (directMessage.length > 0) {
      return directMessage;
    }

    const nestedMessage = parsed?.error?.message?.toString?.() ?? "";
    if (nestedMessage.length > 0) {
      return nestedMessage;
    }

    const fallbackError = parsed?.error?.toString?.() ?? "";
    if (fallbackError.length > 0 && fallbackError !== "[object Object]") {
      return fallbackError;
    }
  } catch (_) {
    // Ignore JSON parsing failures and fall back to the raw body below.
  }

  return errorBody.trim();
}

function providerErrorMessage(providerMessage) {
  if (providerMessage.length === 0) {
    return "Unable to send a verification code right now.";
  }

  if (
    providerMessage.includes("only send testing emails to your own email address") ||
    (providerMessage.includes("testing email") &&
      providerMessage.includes("own email address"))
  ) {
    return "Resend test mode can only send to your own verified Resend email. Use that exact inbox or verify a sending domain.";
  }

  if (
    providerMessage.includes("Invalid `from` field") ||
    providerMessage.includes("The from field is invalid")
  ) {
    return "The email sender address is invalid. Check AUTH_EMAIL_FROM in functions/.env.";
  }

  if (providerMessage.includes("API key is invalid")) {
    return "The Resend API key is invalid. Generate a new RESEND_API_KEY.";
  }

  if (providerMessage.includes("domain is not verified")) {
    return "The sender domain is not verified in Resend yet.";
  }

  if (
    providerMessage.includes("403") &&
    providerMessage.includes("1010")
  ) {
    return "Resend rejected the request because the direct API call is missing a required User-Agent header.";
  }

  if (
    providerMessage.includes("User-Agent") ||
    providerMessage.includes("user agent")
  ) {
    return "Resend rejected the request because the direct API call is missing a required User-Agent header.";
  }

  return `Verification email failed: ${providerMessage.slice(0, 180)}`;
}

function maskEmail(email) {
  const normalized = `${email ?? ""}`.trim();
  const parts = normalized.split("@");
  if (parts.length !== 2) {
    return normalized;
  }

  const [localPart, domainPart] = parts;
  if (localPart.length <= 2) {
    return `${localPart[0] ?? "*"}***@${domainPart}`;
  }

  return `${localPart[0]}***${localPart[localPart.length - 1]}@${domainPart}`;
}

function ensureOtpEligible(request) {
  if (!isPasswordSignIn(request)) {
    throw new HttpsError(
      "failed-precondition",
      "Email OTP is only available for email and password accounts.",
    );
  }

  const email = request.auth?.token?.email;
  if (typeof email !== "string" || email.trim().length === 0) {
    throw new HttpsError(
      "failed-precondition",
      "An email address is required for verification.",
    );
  }

  return email.trim().toLowerCase();
}

function requireEmailValue(data) {
  const email = `${data?.email ?? ""}`.trim().toLowerCase();
  if (!isValidEmailFormat(email)) {
    throw new HttpsError(
      "invalid-argument",
      "Enter a valid email address.",
    );
  }

  return email;
}

async function assertEmailAvailableForSignup(email) {
  try {
    await admin.auth().getUserByEmail(email);
    throw new HttpsError(
      "already-exists",
      "An account with this email already exists.",
    );
  } catch (error) {
    if (error instanceof HttpsError) {
      throw error;
    }

    if (error?.code === "auth/user-not-found") {
      return;
    }

    throw new HttpsError(
      "internal",
      "Unable to check that email right now.",
    );
  }
}

async function sendOtpEmail({ email, code }) {
  const productName = envValue("AUTH_EMAIL_PRODUCT_NAME") || "Running Robot";
  const resendApiKey = envValue("RESEND_API_KEY");
  const fromEmail = senderFromAddress();
  const response = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${resendApiKey}`,
      "Content-Type": "application/json",
      "User-Agent": "running-robot-functions/1.0",
    },
    body: JSON.stringify({
      from: fromEmail,
      to: [email],
      subject: `${productName} verification code`,
      text:
        `Your ${productName} verification code is ${code}. ` +
        "It expires in 10 minutes.",
      html:
        `<p>Your <strong>${productName}</strong> verification code is:</p>` +
        `<p style="font-size:28px;font-weight:700;letter-spacing:6px;">${code}</p>` +
        "<p>This code expires in 10 minutes.</p>",
    }),
  });

  if (!response.ok) {
    const errorBody = await response.text();
    const providerMessage = extractProviderErrorMessage(errorBody);
    const userFacingMessage = providerErrorMessage(providerMessage);

    logger.error("Failed to send verification email", {
      status: response.status,
      fromEmail,
      toEmail: email,
      errorBody,
      providerMessage,
    });
    throw new HttpsError(
      "failed-precondition",
      userFacingMessage,
    );
  }
}

async function sendOtpWithRateLimit({
  otpRef,
  subjectKey,
  email,
  loggerContext,
  extraFields = {},
}) {
  const now = new Date();
  const otpSnap = await otpRef.get();
  const otpData = otpSnap.data() ?? {};
  const resendAvailableAt = readTimestampDate(otpData.resendAvailableAt);
  const sendWindowStartedAt = readTimestampDate(otpData.sendWindowStartedAt);
  const sendsInWindow = readInt(otpData.sendsInWindow, 0);

  if (resendAvailableAt != null && resendAvailableAt.getTime() > now.getTime()) {
    const retryAfterSeconds = Math.ceil(
      (resendAvailableAt.getTime() - now.getTime()) / 1000,
    );
    throw new HttpsError(
      "resource-exhausted",
      `Please wait ${retryAfterSeconds} seconds before requesting another code.`,
    );
  }

  const hourWindowStart = sendWindowStartedAt != null &&
      now.getTime() - sendWindowStartedAt.getTime() < 60 * 60 * 1000
    ? sendWindowStartedAt
    : now;
  const nextSendsInWindow = hourWindowStart === now ? 1 : sendsInWindow + 1;

  if (nextSendsInWindow > OTP_MAX_SENDS_PER_HOUR) {
    throw new HttpsError(
      "resource-exhausted",
      "Too many verification emails requested. Please try again later.",
    );
  }

  const code = generateOtpCode();
  await sendOtpEmail({ email, code });

  await otpRef.set({
    email,
    codeHash: hashOtpCode(subjectKey, code),
    failedAttempts: 0,
    expiresAt: new Date(now.getTime() + OTP_EXPIRY_MS),
    resendAvailableAt: new Date(now.getTime() + OTP_RESEND_COOLDOWN_MS),
    sendWindowStartedAt: hourWindowStart,
    sendsInWindow: nextSendsInWindow,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    ...extraFields,
  }, { merge: true });

  logger.info(loggerContext, {
    email,
  });

  return {
    maskedEmail: maskEmail(email),
    cooldownSeconds: Math.floor(OTP_RESEND_COOLDOWN_MS / 1000),
  };
}

function validateOtpCode(code) {
  if (!/^\d{6}$/.test(code)) {
    throw new HttpsError(
      "invalid-argument",
      "Enter the 6-digit code from your email.",
    );
  }
}

async function verifyOtpAttempt({
  otpRef,
  subjectKey,
  expectedEmail,
  code,
  onSuccess,
}) {
  const otpSnap = await otpRef.get();
  const otpData = otpSnap.data() ?? {};

  if (!otpSnap.exists) {
    throw new HttpsError(
      "failed-precondition",
      "Request a verification code first.",
    );
  }

  if (otpData.email !== expectedEmail) {
    throw new HttpsError(
      "permission-denied",
      "This verification code does not match the expected email.",
    );
  }

  const expiresAt = readTimestampDate(otpData.expiresAt);
  if (expiresAt == null || expiresAt.getTime() <= Date.now()) {
    await otpRef.delete();
    throw new HttpsError(
      "deadline-exceeded",
      "This verification code has expired. Request a new one.",
    );
  }

  const failedAttempts = readInt(otpData.failedAttempts, 0);
  if (failedAttempts >= OTP_MAX_VERIFY_ATTEMPTS) {
    await otpRef.delete();
    throw new HttpsError(
      "resource-exhausted",
      "Too many incorrect codes. Request a new one.",
    );
  }

  if (otpData.codeHash !== hashOtpCode(subjectKey, code)) {
    await otpRef.set(
      {
        failedAttempts: failedAttempts + 1,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
    throw new HttpsError(
      "permission-denied",
      "That verification code is incorrect.",
    );
  }

  return onSuccess(otpData);
}

exports.startSignupEmailOtp = onCall(async (request) => {
  requireOtpConfig();
  const email = requireEmailValue(request.data);
  await assertEmailAvailableForSignup(email);

  return sendOtpWithRateLimit({
    otpRef: signupEmailOtpDoc(email),
    subjectKey: email,
    email,
    loggerContext: "Sent signup email verification OTP",
    extraFields: {
      verifiedAt: null,
      verificationTokenHash: null,
      verificationTokenExpiresAt: null,
    },
  });
});

exports.verifySignupEmailOtp = onCall(async (request) => {
  requireOtpConfig();
  const email = requireEmailValue(request.data);
  const code = `${request.data?.code ?? ""}`.trim();
  validateOtpCode(code);

  return verifyOtpAttempt({
    otpRef: signupEmailOtpDoc(email),
    subjectKey: email,
    expectedEmail: email,
    code,
    onSuccess: async () => {
      const verificationToken = generateVerificationToken();
      await signupEmailOtpDoc(email).set({
        verifiedAt: admin.firestore.FieldValue.serverTimestamp(),
        verificationTokenHash: hashOtpCode(email, verificationToken),
        verificationTokenExpiresAt: new Date(
          Date.now() + SIGNUP_VERIFICATION_EXPIRY_MS,
        ),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      }, { merge: true });

      logger.info("Verified signup email OTP", {
        email,
      });

      return {
        verified: true,
        maskedEmail: maskEmail(email),
        verificationToken,
      };
    },
  });
});

exports.claimVerifiedSignupEmail = onCall(async (request) => {
  const uid = requireAuth(request);
  requireOtpConfig();
  const verificationToken = `${request.data?.verificationToken ?? ""}`.trim();

  if (verificationToken.length < 16) {
    throw new HttpsError(
      "invalid-argument",
      "A valid signup verification token is required.",
    );
  }

  const authUser = await admin.auth().getUser(uid);
  const email = `${authUser.email ?? ""}`.trim().toLowerCase();
  if (!isValidEmailFormat(email)) {
    throw new HttpsError(
      "failed-precondition",
      "The signed-in account must have a valid email address.",
    );
  }

  const otpRef = signupEmailOtpDoc(email);
  const otpSnap = await otpRef.get();
  const otpData = otpSnap.data() ?? {};

  if (!otpSnap.exists || otpData.email !== email) {
    throw new HttpsError(
      "failed-precondition",
      "Verify your email before creating the account.",
    );
  }

  const tokenExpiresAt = readTimestampDate(otpData.verificationTokenExpiresAt);
  if (tokenExpiresAt == null || tokenExpiresAt.getTime() <= Date.now()) {
    await otpRef.delete();
    throw new HttpsError(
      "deadline-exceeded",
      "Your signup verification expired. Verify your email again.",
    );
  }

  if (otpData.verificationTokenHash !== hashOtpCode(email, verificationToken)) {
    throw new HttpsError(
      "permission-denied",
      "This signup verification token is invalid.",
    );
  }

  const existingClaims = authUser.customClaims ?? {};
  await admin.auth().setCustomUserClaims(uid, {
    ...existingClaims,
    verified_email_otp: true,
  });
  await otpRef.delete();

  logger.info("Claimed verified signup email", {
    uid,
    email,
  });

  return {
    verified: true,
    maskedEmail: maskEmail(email),
  };
});

exports.sendEmailOtp = onCall(async (request) => {
  const uid = requireAuth(request);
  requireOtpConfig();
  const email = ensureOtpEligible(request);

  if (request.auth?.token?.verified_email_otp === true ||
      request.auth?.token?.email_verified === true) {
    return {
      alreadyVerified: true,
      maskedEmail: maskEmail(email),
      cooldownSeconds: 0,
    };
  }

  return sendOtpWithRateLimit({
    otpRef: emailOtpDoc(uid),
    subjectKey: uid,
    email,
    loggerContext: "Sent email verification OTP",
  });
});

exports.verifyEmailOtp = onCall(async (request) => {
  const uid = requireAuth(request);
  requireOtpConfig();
  const email = ensureOtpEligible(request);
  const code = `${request.data?.code ?? ""}`.trim();
  validateOtpCode(code);

  return verifyOtpAttempt({
    otpRef: emailOtpDoc(uid),
    subjectKey: uid,
    expectedEmail: email,
    code,
    onSuccess: async () => {
      const authUser = await admin.auth().getUser(uid);
      const existingClaims = authUser.customClaims ?? {};
      await admin.auth().setCustomUserClaims(uid, {
        ...existingClaims,
        verified_email_otp: true,
      });
      await emailOtpDoc(uid).delete();

      logger.info("Verified email OTP", {
        uid,
        email,
      });

      return {
        verified: true,
        maskedEmail: maskEmail(email),
      };
    },
  });
});

exports.markDailyActivity = onCall(async (request) => {
  const uid = requireAuth(request);
  requireVerifiedAccount(request);

  const response = await db.runTransaction(async (transaction) => {
    const userRef = userDoc(uid);
    const userSnap = await transaction.get(userRef);

    if (!userSnap.exists) {
      throw new HttpsError(
        "failed-precondition",
        "User profile must exist before tracking daily activity.",
      );
    }

    const userData = userSnap.data() ?? {};
    const todayKey = dateKeyForOffset(userData.timezoneOffsetMinutes);
    const activityRef = activityDayDoc(uid, todayKey);
    const activitySnap = await transaction.get(activityRef);

    const activityStreak = computeNextDailyStreak(
      userData.lastActivityDateKey ?? null,
      todayKey,
      readInt(userData.activityStreak, 0),
    );

    ensureActivityDay(transaction, activityRef, activitySnap, todayKey);

    transaction.set(
      userRef,
      activitySummaryPayload({
        activityStreak,
        todayKey,
      }),
      { merge: true },
    );

    return {
      activityStreak,
      todayKey,
    };
  });

  logger.info("Tracked daily activity", {
    uid,
    activityStreak: response.activityStreak,
    todayKey: response.todayKey,
  });

  return response;
});

exports.flushAppSession = onCall(async (request) => {
  const uid = requireAuth(request);
  requireVerifiedAccount(request);
  const sessionSeconds = requireSessionSeconds(request.data);

  const response = await db.runTransaction(async (transaction) => {
    const userRef = userDoc(uid);
    const userSnap = await transaction.get(userRef);

    if (!userSnap.exists) {
      throw new HttpsError(
        "failed-precondition",
        "User profile must exist before tracking app sessions.",
      );
    }

    const userData = userSnap.data() ?? {};
    const todayKey = dateKeyForOffset(userData.timezoneOffsetMinutes);
    const activityRef = activityDayDoc(uid, todayKey);
    const activitySnap = await transaction.get(activityRef);
    const activityStreak = computeNextDailyStreak(
      userData.lastActivityDateKey ?? null,
      todayKey,
      readInt(userData.activityStreak, 0),
    );

    const dayMetrics = writeActivityDayMetrics(
      transaction,
      activityRef,
      activitySnap,
      todayKey,
      {
        sessionSecondsDelta: sessionSeconds,
      },
    );

    transaction.set(
      userRef,
      {
        ...activitySummaryPayload({
          activityStreak,
          todayKey,
        }),
        totalSessionSeconds:
          readInt(userData.totalSessionSeconds, 0) + sessionSeconds,
      },
      { merge: true },
    );

    return {
      activityStreak,
      todayKey,
      sessionSeconds: dayMetrics.sessionSeconds,
      totalSessionSeconds:
        readInt(userData.totalSessionSeconds, 0) + sessionSeconds,
    };
  });

  logger.info("Flushed app session seconds", {
    uid,
    todayKey: response.todayKey,
    sessionSeconds: sessionSeconds,
  });

  return response;
});

exports.startLesson = onCall(async (request) => {
  const uid = requireAuth(request);
  requireVerifiedAccount(request);
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
  requireVerifiedAccount(request);
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
    const todayKey = dateKeyForOffset(userData.timezoneOffsetMinutes);
    const activityRef = activityDayDoc(uid, todayKey);
    const activitySnap = await transaction.get(activityRef);

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

    writeActivityDayMetrics(
      transaction,
      activityRef,
      activitySnap,
      todayKey,
      {
        learningSecondsDelta: elapsedSeconds,
      },
    );

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
  requireVerifiedAccount(request);
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
    const todayKey = dateKeyForOffset(userData.timezoneOffsetMinutes);
    const activityRef = activityDayDoc(uid, todayKey);
    const activitySnap = await transaction.get(activityRef);

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

    writeActivityDayMetrics(
      transaction,
      activityRef,
      activitySnap,
      todayKey,
      {
        learningSecondsDelta: elapsedSeconds,
      },
    );

    return { totalLearningSeconds };
  });

  return response;
});

exports.completeLesson = onCall(async (request) => {
  const uid = requireAuth(request);
  requireVerifiedAccount(request);
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
    const todayKey = dateKeyForOffset(userData.timezoneOffsetMinutes);
    const activityRef = activityDayDoc(uid, todayKey);
    const activitySnap = await transaction.get(activityRef);

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

    writeActivityDayMetrics(
      transaction,
      activityRef,
      activitySnap,
      todayKey,
      {
        learningSecondsDelta: elapsedSeconds,
        lessonsCompletedDelta: alreadyCompleted ? 0 : 1,
        didCompleteLesson: !alreadyCompleted,
      },
    );

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
