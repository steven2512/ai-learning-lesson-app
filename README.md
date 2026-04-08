# Running Robot

Interactive Flutter app for teaching AI and data science basics through short lessons, mini-games, and a progression-based learning path. The app uses Firebase Authentication, Cloud Firestore, and callable Cloud Functions to keep user progress, lesson state, XP, and streak data in sync.

## What Is In This Repo

- Flutter client for Android, iOS, Web, Windows, macOS, and Linux
- Firebase Cloud Functions for lesson lifecycle and progression updates
- Firestore security rules for profile schema and access control
- Lesson content, mini-games, and progression UI

## Current Feature Set

- Email/password sign up and login
- Google sign in
- Facebook sign in
- Password reset flow
- Cached progression shell using `SharedPreferences`
- Home dashboard with lesson CTA, lesson count, level ring, and weekly streak
- Lesson map with locked, available, in-progress, and completed states
- Nine lesson entries in the manifest
- Profile page with editable name and birthday
- Settings page with refresh, password reset, app info, and logout
- Callable Cloud Functions for lesson start, save, pause, and completion flows

## Tech Stack

| Layer | Technology |
| --- | --- |
| Client | Flutter, Dart |
| Backend | Firebase Authentication, Cloud Firestore, Cloud Functions |
| Functions runtime | Node.js 20 |
| Game / interactive layer | Flame, flame_forge2d |
| UI | Material 3, Google Fonts, flutter_svg |
| Local cache | shared_preferences |

## Project Structure

```text
lib/
  auth/                     Authentication screens and auth gate
  core/                     Router, lesson manifest, progression scope, shared lesson base
  game/                     Flame components, progress bar, robot, obstacles
  models/                   UserProfile and LessonProgress models
  services/                 Firestore, callable functions, cache, auth helpers
  z_pages/                  Home, lessons map, profile, settings, lesson UIs, mini-games

functions/
  index.js                  Callable Cloud Functions
  lessonManifest.js         Server-side lesson metadata and ordering
  progression.js            Shared progression helpers for functions

firestore.rules             Firestore access and schema rules
firebase.json               Firebase config for functions + Firestore rules
```

## App Flow

### Authentication

`lib/main.dart` initializes Firebase and boots into `AuthGate`.

`AuthGate` listens to `FirebaseAuth.instance.authStateChanges()`:

- signed out users see the welcome flow
- signed in users enter `MyApp`
- progression is loaded on sign in and cleared on sign out

### Navigation

The app uses a lightweight custom route model in `lib/core/app_router.dart` instead of `Navigator` stacks for lesson flow.

Main shell tabs:

- Home
- Lessons
- Profile

The root shell lives in `lib/z_pages/root_nav_live.dart` and uses an `IndexedStack` plus `PageStorage` so the lessons tab can preserve state like scroll position.

### Progression Loading

`AppProgressionController` is the central client-side progression source.

It:

- loads cached progression snapshots from `SharedPreferences`
- refreshes from Firestore when a user is available
- exposes derived values such as current lesson, level, total XP, streak, and lesson UI state
- drives the home page, lesson page, profile page, and end-of-lesson routing

## Lessons And Progression

### Lesson Manifest

The current course manifest lives in `lib/core/lesson_manifest.dart`.

Current ordered lessons:

1. What is Data?
2. Why is Data so important for AI?
3. What is Binary?
4. Qualitative vs Quantitative
5. Qualitative Mini-Game
6. What is a Data Sample?
7. What is a Feature?
8. What is a Label?
9. label-Features Game

The course id used by both app and functions is `ai-theory-foundations`.

### Base Lesson System

All lessons build on `BaseLessonBrain` in `lib/core/base_lesson_brain.dart`.

That shared state handles:

- lesson bootstrapping through the backend
- restoring the saved step index
- pausing and resuming lesson sessions on app lifecycle changes
- saving current step progress
- completing lessons and routing to the end screen
- refreshing progression after lesson completion

Each lesson is composed from `SubLesson` entries with one of three mechanics:

- `manual`
- `emit`
- `auto`

### Lesson Persistence Model

Lesson progress is stored under:

`users/{uid}/lessonProgress/{lessonId}`

The client reads lesson progress directly, but lesson writes are handled through callable Cloud Functions instead of direct client writes.

Tracked fields include:

- `lessonId`
- `courseId`
- `chapterId`
- `globalLessonNumber`
- `startedAt`
- `lastActiveAt`
- `completedAt`
- `isCompleted`
- `completedCount`

User progression summary lives on:

`users/{uid}`

Important profile fields include:

- `currentLesson`
- `currentLessonStepIndex`
- `xp`
- `level`
- `lessonsCompleted`
- `totalLearningSeconds`
- `todayLessonCount`
- `todayLessonCountDate`
- `dailyStreak`
- `lastDailyLessonDate`
- `timezone`
- `timezoneOffsetMinutes`

## Cloud Functions

Cloud Functions are fully wired and are the source of truth for lesson progression writes.

Function entrypoints live in `functions/index.js`.

Implemented callable functions:

- `startLesson`
- `saveLessonProgress`
- `pauseLessonSession`
- `completeLesson`

### What The Functions Do

`startLesson`

- validates auth
- validates lesson id against the server manifest
- checks lesson unlock state
- creates lesson progress if missing
- starts a lesson and also handles resume behavior for active lesson sessions
- returns the initial step index and status flags

`saveLessonProgress`

- validates auth and step index
- updates the current lesson step if the lesson is the active progression lesson
- rolls elapsed active-session time into `totalLearningSeconds`
- refreshes `lastActiveAt`

`pauseLessonSession`

- stores the current step index
- flushes active session time into `totalLearningSeconds`
- clears `activeSessionStartedAt`

`completeLesson`

- marks first completion
- increments replay count for completed lessons
- awards `50 XP` on first completion
- recalculates level at `200 XP` per level
- advances `currentLesson`
- updates `todayLessonCount`
- updates `dailyStreak`
- stores learning time

### Server Lesson Manifest

The server keeps its own ordered manifest in `functions/lessonManifest.js`. That means lesson ids and ordering must stay aligned between:

- `lib/core/lesson_manifest.dart`
- `functions/lessonManifest.js`

## Firestore Rules

Rules live in `firestore.rules`.

Key rule behavior:

- users can only read their own user document
- users can only create their own canonical profile document
- metadata updates are tightly scoped
- legacy profile schema repair is allowed under strict validation
- users can read their own `lessonProgress` subcollection
- everything else is denied by default

Because lesson progression writes go through Admin SDK Cloud Functions, the client does not need direct write access to `lessonProgress`.

## Main Screens

### Home

`lib/z_pages/assets/mainMenu/main_menu.dart`

Shows:

- current lesson CTA
- total course progress percentage
- lessons completed today
- current level ring
- weekly streak visualization

### Lesson Map

`lib/z_pages/assets/lessonPage/lesson_page.dart`

Uses `AppProgressionController` to determine whether a lesson is:

- locked
- available
- in progress
- completed

### Profile

`lib/z_pages/assets/profile/profile_page_live.dart`

Shows:

- avatar and account identity
- XP, streak, current lesson, lessons completed
- total learning time
- profile completion prompt
- editable profile sheet for display name and birthday

### Settings

`lib/z_pages/assets/settings/settings_page_live.dart`

Supports:

- refresh progression from Firebase
- password reset for email/password accounts
- account info display
- app version, timezone, last device
- logout

## Authentication Details

Email/password auth uses Firebase Auth directly.

Google sign in:

- mobile and desktop path uses `GoogleSignIn.instance.authenticate()` when supported
- web falls back to `FirebaseAuth.instance.signInWithPopup()`

Facebook sign in uses `flutter_facebook_auth`.

On successful login or signup, `UserProfileService.createOrUpdateUserProfile()` ensures the profile document has the canonical schema and current metadata such as:

- provider
- last device
- app version
- timezone
- timezone offset

## Local Setup

### Prerequisites

- Flutter SDK
- Firebase project with Authentication, Firestore, and Functions
- Android Studio and/or Xcode for mobile targets
- Node.js 20 for Cloud Functions work

### Required Local Config Files

These files are intentionally ignored and should stay local:

- `android/app/google-services.json`
- `android/app/src/main/res/values/strings.xml`
- `ios/Runner/GoogleService-Info.plist`

`strings.xml` is used for Android Facebook values such as app id and client token.

### Install

```bash
flutter pub get
cd functions
npm install
```

### Run The App

```bash
flutter run -d android
flutter run -d ios
flutter run -d chrome
flutter run -d windows
flutter run -d macos
flutter run -d linux
```

### Run Functions Locally

```bash
cd functions
npm install
npm run serve
```

### Deploy Firebase Resources

```bash
firebase deploy --only functions
firebase deploy --only firestore:rules
```

## Current Notes

- The repo now includes full callable progression wiring for lesson lifecycle events.
- Progression reads still come from Firestore on the client side.
- Profile and settings experiences are live and tied into progression refresh.
- The repo contains some old lesson content under `lib/z_pages/lessons/unknown/`, but the active manifest currently exposes the 9 lessons listed above.

## Known Gaps

- There is no broad automated test coverage yet beyond the default Flutter widget test scaffold.
- The local Firebase config files are not committed, so a fresh clone still needs per-developer setup for Firebase and Facebook auth.
- The server and client lesson manifests must be kept in sync manually.

## Repository Note

Firebase project wiring in `.firebaserc` currently points at `ai-learning-app-42d8b`.

If you clone this repo for a different Firebase project, update local config files and Firebase CLI project selection before deploying.
