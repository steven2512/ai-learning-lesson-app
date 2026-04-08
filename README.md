# Running Robot

> Cross-platform Flutter app for teaching AI and data fundamentals through interactive lessons, mini-games, and server-backed progression.

## Table of Contents

- [Overview](#overview)
- [Project Snapshot](#project-snapshot)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Current Curriculum](#current-curriculum)
- [Cloud Functions](#cloud-functions)
- [Firestore Model](#firestore-model)
- [Main Screens](#main-screens)
- [Project Structure](#project-structure)
- [Authentication](#authentication)
- [Local Development](#local-development)
- [Notes](#notes)

## Overview

Running Robot is an educational mobile and desktop application built with Flutter and Firebase. The product is designed around short, guided AI lessons that blend structured teaching, interactive lesson mechanics, lightweight mini-games, and progression tracking into one learning flow.

The repo includes both the client application and the backend logic that powers lesson lifecycle events. Users can sign in, resume their current lesson, complete activities, earn XP, build streaks, and move through an ordered course path with Firebase-backed persistence.

## Project Snapshot

| Area | Details |
| --- | --- |
| Product type | Interactive AI learning app |
| Primary focus | Beginner-friendly AI and data science foundations |
| Platforms | Android, iOS, Web, Windows, macOS, Linux |
| Client architecture | Flutter app with custom route model and shared lesson framework |
| Backend | Firebase Authentication, Cloud Firestore, callable Cloud Functions |
| Progression design | Cached client reads plus backend-owned progression writes |
| Current shell | Home, Lessons, Profile |
| Active course | `ai-theory-foundations` |
| Active lesson count | 9 lessons |

## Tech Stack

| Layer | Technology |
| --- | --- |
| Client framework | Flutter, Dart |
| Authentication | Firebase Authentication |
| Database | Cloud Firestore |
| Backend logic | Firebase Cloud Functions |
| Functions runtime | Node.js 20 |
| Local cache | `shared_preferences` |
| UI | Material 3, `google_fonts`, `flutter_svg` |
| Game / interaction layer | `flame`, `flame_forge2d` |
| Social sign in | Google Sign-In, Facebook Auth |

## Architecture

### System Overview

| Layer | Responsibility |
| --- | --- |
| `lib/main.dart` | Initializes Firebase and launches the auth-gated app flow |
| `lib/auth/` | Login, signup, onboarding, and auth gate handling |
| `lib/core/` | Route model, lesson manifest, lesson base classes, navigation helpers |
| `lib/services/` | Progression reads, callable function wrappers, auth helpers, cache integration |
| `lib/z_pages/` | Home, lessons map, profile, settings, and lesson UI surfaces |
| `functions/` | Callable Cloud Functions for lesson progression and course validation |
| `firestore.rules` | Access control and schema enforcement for profile data |

### Client Flow

| Concern | Implementation |
| --- | --- |
| App bootstrap | Firebase initializes in `lib/main.dart`, then `AuthGate` decides whether to show auth flow or the main app |
| Root navigation | `lib/z_pages/root_nav_live.dart` hosts the main shell with `Home`, `Lessons`, and `Profile` |
| Route handling | Lightweight app router in `lib/core/app_router.dart` instead of deep Navigator-driven lesson flow |
| Tab preservation | `IndexedStack` plus `PageStorage` preserves shell state such as lesson tab position |
| Progression source | `AppProgressionController` acts as the central client-side progression controller |
| Fast loading | Cached progression is read first from `SharedPreferences`, then refreshed from Firestore |

### Lesson Architecture

| Component | Role |
| --- | --- |
| `BaseLessonBrain` | Shared lesson lifecycle handling for start, save, pause, resume, and complete |
| `SubLesson` | Defines each step within a lesson |
| `manual` mechanic | Advances with a visible continue action |
| `emit` mechanic | Waits for content to signal completion before allowing advance |
| `auto` mechanic | Advances automatically when the step completes |
| `lesson_manifest.dart` | Source of truth for course, chapter, lesson ids, titles, and ordering on the client |

### Why The Architecture Matters

| Decision | Benefit |
| --- | --- |
| Cache-first progression hydration | Faster perceived startup and less empty-state flashing |
| Backend-owned progression writes | Stronger control over lesson state, XP, and streak updates |
| Shared lesson framework | New lessons inherit common behavior instead of re-implementing lifecycle logic |
| Separate server lesson manifest | Cloud Functions can validate lesson ids and unlock order independently of the client |
| Firestore rules with schema checks | Tighter control over what clients can read and write |

## Current Curriculum

The active course id used by both the client and backend is `ai-theory-foundations`.

| Order | Lesson ID | Title | Type |
| --- | --- | --- | --- |
| 1 | `data-intro` | What is Data? | Lesson |
| 2 | `data-ai-relevance` | Why is Data so important for AI? | Lesson |
| 3 | `binary-intro` | What is Binary? | Lesson |
| 4 | `qual-quan` | Qualitative vs Quantitative | Lesson |
| 5 | `qual-game` | Qualitative Mini-Game | Interactive mini-game lesson |
| 6 | `data-sample-intro` | What is a Data Sample? | Lesson |
| 7 | `features-intro` | What is a Feature? | Lesson |
| 8 | `label-intro` | What is a Label? | Lesson |
| 9 | `label-feature-game` | label-Features Game | Interactive mini-game lesson |

The client manifest lives in `lib/core/lesson_manifest.dart`, and the backend keeps a matching manifest in `functions/lessonManifest.js`. Those two files need to stay aligned so the server can validate lesson progression correctly.

## Cloud Functions

Progression writes are fully wired through callable Cloud Functions in `functions/index.js`.

| Function | Purpose | Main Responsibilities |
| --- | --- | --- |
| `startLesson` | Begin or resume a lesson session | Validates auth, validates lesson id, checks unlock state, creates progress if missing, returns initial step index |
| `saveLessonProgress` | Save in-session progress | Validates step index, updates saved step, rolls active time into learning totals, refreshes activity timestamp |
| `pauseLessonSession` | Persist paused session state | Stores step index, flushes active session time, clears active session start marker |
| `completeLesson` | Finalize lesson completion | Marks completion, increments replay count, awards XP on first completion, advances current lesson, updates daily count and streak |

### Progression Rules Enforced By The Backend

| Rule | Current Behavior |
| --- | --- |
| Unlock validation | Users cannot start lessons beyond their unlocked progression point |
| XP reward | First completion awards `50 XP` |
| Leveling | Levels are derived at `200 XP` per level |
| Resume support | Active lesson sessions can continue from the saved step index |
| Replay tracking | Completed lessons increment `completedCount` when replayed |
| Learning time | Active session time is accumulated into `totalLearningSeconds` |

## Firestore Model

### Collections

| Path | Purpose |
| --- | --- |
| `users/{uid}` | Canonical user profile and progression summary |
| `users/{uid}/lessonProgress/{lessonId}` | Per-lesson progression state |

### User Profile Fields

| Field | Meaning |
| --- | --- |
| `currentLesson` | Current unlocked lesson number |
| `currentLessonStepIndex` | Resume point for the active lesson |
| `xp` | Accumulated XP |
| `level` | Derived progression level |
| `lessonsCompleted` | Count of first-time lesson completions |
| `totalLearningSeconds` | Total tracked learning time |
| `todayLessonCount` | Number of lessons completed today |
| `todayLessonCountDate` | Date key for today's completions |
| `dailyStreak` | Consecutive day streak |
| `lastDailyLessonDate` | Last day a lesson completion was recorded |
| `timezone` | Stored user timezone |
| `timezoneOffsetMinutes` | Stored timezone offset |

### Lesson Progress Fields

| Field | Meaning |
| --- | --- |
| `lessonId` | Stable lesson identifier |
| `courseId` | Course identifier |
| `chapterId` | Chapter identifier |
| `globalLessonNumber` | Global lesson order in the course |
| `startedAt` | First lesson start timestamp |
| `lastActiveAt` | Most recent activity timestamp |
| `completedAt` | Completion timestamp for first completion |
| `isCompleted` | Whether the lesson has been completed at least once |
| `completedCount` | Total number of completions including replays |

### Firestore Rules Summary

| Rule Area | Current Behavior |
| --- | --- |
| User document reads | Users can only read their own profile |
| User document creation | Users can only create their own canonical profile document |
| Metadata updates | Restricted to approved fields |
| Legacy schema repair | Allowed under strict validation rules |
| Lesson progress reads | Users can read their own lesson progress documents |
| Default posture | Everything else is denied |

Because lesson progression writes now go through Admin SDK Cloud Functions, the client does not need broad direct write access to lesson progress documents.

## Main Screens

| Screen | File | Purpose |
| --- | --- | --- |
| Home | `lib/z_pages/assets/mainMenu/main_menu.dart` | Shows current lesson CTA, course progress, today count, level context, and streak visuals |
| Lessons | `lib/z_pages/assets/lessonPage/lesson_page.dart` | Displays ordered lesson map with locked, available, in-progress, and completed states |
| Profile | `lib/z_pages/assets/profile/profile_page_live.dart` | Displays identity, XP, streak, current lesson, completed lessons, and editable profile fields |
| Settings | `lib/z_pages/assets/settings/settings_page_live.dart` | Supports refresh, account info, password reset for email/password users, version details, timezone info, and logout |

## Project Structure

```text
lib/
  auth/                     Authentication screens and auth gate
  core/                     Router, lesson manifest, progression scope, shared lesson system
  game/                     Flame components and interactive game pieces
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

## Authentication

| Auth Path | Notes |
| --- | --- |
| Email / password | Supported for signup and login |
| Google sign in | Uses native/mobile sign-in where supported and popup flow on web |
| Facebook sign in | Implemented via `flutter_facebook_auth` |
| Password reset | Available for email/password users |

On successful login or signup, the app ensures the user profile document exists and carries metadata such as provider, app version, last device, timezone, and timezone offset.

## Local Development

### Prerequisites

| Requirement | Notes |
| --- | --- |
| Flutter SDK | Required for the client app |
| Node.js 20 | Required for Cloud Functions work |
| Firebase CLI | Required for local emulation and deploys |
| Firebase project | Authentication, Firestore, and Functions should be enabled |
| Platform tooling | Android Studio and/or Xcode for mobile targets |

### Required Local Config Files

These files are intentionally ignored and should remain local:

| File | Purpose |
| --- | --- |
| `android/app/google-services.json` | Android Firebase configuration |
| `android/app/src/main/res/values/strings.xml` | Android Facebook app id and client token values |
| `ios/Runner/GoogleService-Info.plist` | iOS Firebase configuration |

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

## Notes

| Topic | Current Status |
| --- | --- |
| Callable progression flow | Implemented |
| Client progression reads | Loaded from Firestore and cached locally |
| Profile and settings pages | Live |
| Automated tests | Still limited beyond the default Flutter scaffold |
| Manifest sync | Client and server lesson manifests must stay aligned manually |
| Legacy lesson content | Some older lesson content still exists outside the active manifest |
| Firebase target | `.firebaserc` currently points to `ai-learning-app-42d8b` |

If you use a different Firebase project, update local config files and your Firebase CLI project selection before deploying.
