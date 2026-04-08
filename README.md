# Running Robot

Running Robot is a cross-platform Flutter learning app that teaches AI and data fundamentals through short interactive lessons, mini-games, and progression-driven onboarding. It combines a polished client experience with a Firebase backend that tracks lesson state, XP, streaks, daily activity, and resume progress across sessions.

This repository is not just a UI prototype. It includes the actual product loop end to end:

- multi-provider authentication
- lesson manifest and progression logic
- resumable lesson sessions
- profile and settings flows
- Cloud Functions-backed progression updates
- Firestore rules for schema enforcement and access control

## Why This Project Is Strong

Running Robot showcases product thinking and backend discipline in the same codebase.

- It is built as a real learning product, not a static demo screen.
- Lesson progression is server-aware, not only stored in local widget state.
- The app mixes educational content, lightweight game mechanics, and user progression in one experience.
- Progression reads are fast because the client hydrates from cache first, then refreshes from Firestore.
- Sensitive progression writes are routed through callable Cloud Functions instead of relying on broad client-side write access.
- Firestore rules enforce a canonical user profile shape and tightly scoped reads.

## Core Experience

The app is designed around a guided AI foundations course. Users can sign in, continue from where they left off, complete lessons, build streaks, earn XP, and unlock the next lesson in sequence.

Current product features:

- Email/password authentication
- Google sign in
- Facebook sign in
- Password reset flow
- Home dashboard with current lesson CTA and progression summary
- Lessons tab with locked, available, in-progress, and completed lesson states
- Profile page with editable display name and birthday
- Settings page with account info, refresh controls, version info, and logout
- Local progression caching with `SharedPreferences`
- Cloud Functions for lesson start, save, pause, and completion flows

## Current Curriculum

The active course id is `ai-theory-foundations`.

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

These lessons live in the client manifest at `lib/core/lesson_manifest.dart`, and the backend keeps a matching manifest in `functions/lessonManifest.js` so unlock order and lesson identity stay aligned.

## Product Architecture

### Client

The Flutter client targets Android, iOS, Web, Windows, macOS, and Linux from one codebase.

Main responsibilities:

- authentication and auth-gated boot flow
- lesson navigation and UI composition
- cached progression hydration
- profile and settings experiences
- Flame-based mini-game integration

Entry point:

- `lib/main.dart` initializes Firebase and launches `AuthGate`

Main shell:

- `lib/z_pages/root_nav_live.dart` hosts `Home`, `Lessons`, and `Profile`
- the shell uses `IndexedStack` plus `PageStorage` to preserve tab state

### Progression Layer

`AppProgressionController` is the central client-side progression source.

It:

- hydrates the last known progression snapshot from local cache
- refreshes the latest profile and lesson progress from Firestore
- exposes derived values like current lesson, XP, level, streak, and completion percentage
- feeds the home screen, lesson screen, profile, and post-lesson transitions

This gives the app a better user experience than a cold-start-only Firestore load because the shell can show meaningful state quickly and then reconcile with the backend.

### Lesson System

All active lessons build on `BaseLessonBrain` in `lib/core/base_lesson_brain.dart`.

That shared lesson infrastructure handles:

- backend lesson bootstrap
- resume from saved step index
- save-on-progress
- pause handling on lifecycle changes
- completion submission
- progression refresh after lesson completion

Each lesson is composed from `SubLesson` units using three execution styles:

- `manual`
- `emit`
- `auto`

This structure makes the lesson system reusable and keeps content screens from re-implementing the same lifecycle logic.

## Backend Design

### Firebase Stack

| Layer | Technology |
| --- | --- |
| Client | Flutter, Dart |
| Auth | Firebase Authentication |
| Database | Cloud Firestore |
| Backend logic | Firebase Cloud Functions |
| Functions runtime | Node.js 20 |
| Interactive/game layer | Flame, flame_forge2d |
| UI support | Material 3, Google Fonts, flutter_svg |
| Local cache | shared_preferences |

### Callable Cloud Functions

Progression writes are now fully wired through callable Cloud Functions in `functions/index.js`.

Implemented functions:

- `startLesson`
- `saveLessonProgress`
- `pauseLessonSession`
- `completeLesson`

What they do:

- validate authentication
- validate lesson identity against the server manifest
- enforce lesson unlock order
- create lesson progress documents when needed
- resume active lessons safely
- store active learning time
- update current lesson step index
- award XP on first completion
- advance the unlocked lesson pointer
- update daily lesson count and streak metrics

The most important design choice here is that lesson progression writes are backend-owned. That makes the progression system more robust than a direct-write client model and gives the project a much stronger engineering story.

### Firestore Model

User progression summary is stored on:

`users/{uid}`

Lesson-specific state is stored on:

`users/{uid}/lessonProgress/{lessonId}`

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

Lesson progress documents track:

- `lessonId`
- `courseId`
- `chapterId`
- `globalLessonNumber`
- `startedAt`
- `lastActiveAt`
- `completedAt`
- `isCompleted`
- `completedCount`

### Firestore Rules

Firestore rules in `firestore.rules` are more than basic auth checks. They enforce a fairly opinionated profile schema and restrict what clients can do directly.

Key rule behavior:

- users can only read their own user document
- users can only create their own canonical profile document
- metadata updates are scoped to approved fields
- legacy profile schema repair is allowed under strict validation
- users can read their own `lessonProgress` documents
- everything else is denied by default

Because progression writes happen through Admin SDK Cloud Functions, the client does not need direct lesson progress write access.

## Main User-Facing Screens

### Home

`lib/z_pages/assets/mainMenu/main_menu.dart`

Highlights:

- current lesson CTA
- course progress percentage
- lessons completed today
- level and XP context
- weekly streak visualization

### Lessons

`lib/z_pages/assets/lessonPage/lesson_page.dart`

Highlights:

- ordered lesson map
- unlocked versus locked lesson states
- in-progress detection
- completed lesson review state

### Profile

`lib/z_pages/assets/profile/profile_page_live.dart`

Highlights:

- account identity
- XP and streak summary
- current lesson and lessons completed
- total learning time
- profile completion prompts
- editable profile sheet

### Settings

`lib/z_pages/assets/settings/settings_page_live.dart`

Highlights:

- progression refresh
- password reset for email/password users
- account info display
- app version and timezone information
- logout

## Project Structure

```text
lib/
  auth/                     Auth gate, login, signup, onboarding
  core/                     Router, manifests, progression scope, shared lesson logic
  game/                     Flame components and mini-game systems
  models/                   User profile and lesson progress models
  services/                 Firebase services, progression reads, cache, auth helpers
  z_pages/                  Home, lessons, profile, settings, lesson UIs, mini-games

functions/
  index.js                  Callable lesson lifecycle functions
  lessonManifest.js         Server-side lesson metadata and ordering
  progression.js            Shared progression helpers

firestore.rules             Firestore validation and access rules
firebase.json               Firebase configuration
```

## Authentication Flow

Authentication is handled with Firebase Auth.

Supported paths:

- email/password sign up and login
- Google sign in
- Facebook sign in

On successful login or signup, the app ensures a canonical user profile exists with metadata such as:

- auth provider
- app version
- last device
- timezone
- timezone offset

This creates a cleaner base for progression, analytics-style counters, and profile completeness.

## Local Development

### Prerequisites

- Flutter SDK
- Node.js 20
- Firebase CLI
- Firebase project with Authentication, Firestore, and Functions enabled
- Android Studio and/or Xcode for mobile targets

### Required Local Config Files

These files are intentionally ignored and should remain local:

- `android/app/google-services.json`
- `android/app/src/main/res/values/strings.xml`
- `ios/Runner/GoogleService-Info.plist`

`strings.xml` is used for Android Facebook values such as app id and client token.

### Install Dependencies

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

## Practical Notes

- The repo currently includes the full callable progression flow for lesson lifecycle events.
- Progression reads still happen on the client from Firestore snapshots.
- The client and server lesson manifests must stay in sync.
- There is still limited automated test coverage beyond the default Flutter test scaffold.
- Some older lesson content still exists in the repo, but the active manifest currently exposes the 9 lessons listed above.

## Firebase Project Note

`.firebaserc` currently points to `ai-learning-app-42d8b`.

If you use a different Firebase project, update your local Firebase config files and CLI project selection before running deploy commands.
