# Running Robot — AI Education App

> A cross-platform Flutter application that teaches Artificial Intelligence and Data Science fundamentals through interactive lessons, animated mini-games, and a physics-driven robot mascot.

---

## Table of Contents

- [Overview](#overview)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Architecture](#architecture)
  - [Navigation & Routing](#navigation--routing)
  - [Lesson System](#lesson-system)
  - [Game Engine Layer (Flame)](#game-engine-layer-flame)
  - [Authentication Flow](#authentication-flow)
  - [Firestore Data Model](#firestore-data-model)
- [Screens & Features](#screens--features)
  - [Welcome / Onboarding](#welcome--onboarding)
  - [Main Menu](#main-menu)
  - [Lesson Map](#lesson-map)
  - [Lessons](#lessons)
  - [Mini-Games](#mini-games)
  - [End Lesson Screen](#end-lesson-screen)
  - [Settings](#settings)
- [Lesson Manifest (Course Content)](#lesson-manifest-course-content)
- [Robot Character & Physics](#robot-character--physics)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Firebase Setup](#firebase-setup)
  - [Running the App](#running-the-app)
- [Building for Release](#building-for-release)
- [Dependencies](#dependencies)
- [Asset Catalogue](#asset-catalogue)
- [Firestore Security Notes](#firestore-security-notes)
- [Known Limitations & Roadmap](#known-limitations--roadmap)

---

## Overview

**Running Robot** is an edutainment mobile app aimed at teaching foundational AI and data science concepts to beginners — primarily students and curious learners with no prior technical background. The app takes a game-first approach: lessons are structured as interactive experiences, not passive reading. The running robot mascot reacts to the learner's progress with jump, duck, trip, electrocution, and hurt animations powered by the [Flame](https://flame-engine.org/) game engine.

The curriculum is structured around a single initial course — **AI Foundations** — containing one chapter with seven fully-implemented lessons spanning topics like binary data, qualitative vs. quantitative data, data samples, features, and the role of data in AI. The app is backed by Firebase Authentication and Cloud Firestore for persistent user profiles and granular lesson progress tracking.

---

## Tech Stack

| Layer | Technology |
|---|---|
| **Framework** | Flutter (Dart), targeting Android, iOS, Web, macOS, Windows, Linux |
| **Game Engine** | Flame `^1.30.1` + `flame_forge2d ^0.18.0` |
| **Backend / Auth** | Firebase Auth `^6.1.0` |
| **Database** | Cloud Firestore `^6.0.0` |
| **Auth Providers** | Email/Password, Google Sign-In `^7.2.0`, Facebook Auth `^7.1.2` |
| **UI** | Material 3, Google Fonts `^6.2.1`, flutter_svg `^2.0.9` |
| **Animations** | `animations ^2.0.11` (FadeThroughTransition), Flutter built-in AnimationController |
| **Image loading** | `cached_network_image ^3.3.1` |
| **Dart SDK** | `>=2.17.0 <4.0.0` (null-safe, Dart 3 compatible) |

---

## Project Structure

```
lib/
├── main.dart                        # Entry point: Firebase init + AuthGate
├── my_app.dart                      # Root StatefulWidget, custom router, page transitions
│
├── auth/
│   ├── auth_gate.dart               # Firebase StreamBuilder → MyApp or WelcomePage
│   ├── welcome_page.dart            # Landing screen with Get Started / Log In CTAs
│   ├── login_page.dart              # Email/password + Google + Facebook sign-in
│   ├── signup_page.dart             # Email entry point for new users
│   ├── sign_up_flow.dart            # Multi-step PageView: Name → DOB → Password
│   ├── back_button.dart             # Shared back navigation widget
│   ├── background_color.dart        # Gradient background helper
│   └── start_button.dart            # PillCta reusable button
│
├── core/
│   ├── app_router.dart              # AppRoute sealed hierarchy (RouteMainMenu, RouteLesson, RouteEndLesson)
│   ├── base_lesson_brain.dart       # Abstract BaseLessonBrain + BaseLessonBrainState
│   ├── lesson_locator.dart          # Global lesson index lookup
│   ├── lesson_manifest.dart         # Course → Chapter → Lesson manifest tree
│   ├── lesson_navigator.dart        # Navigates to next lesson or end screen
│   ├── lesson_steps.dart            # LessonStepRegistry (step count per lesson id)
│   └── widgets.dart                 # ScreenSize utility (global width/height)
│
├── models/
│   ├── lesson_model.dart            # Lesson data model
│   └── user_profile.dart            # UserProfile model with toMap/fromMap
│
├── services/
│   ├── lesson_service.dart          # Firestore CRUD: handleLesson, updateLesson, completeLesson
│   └── user_profile_service.dart    # createOrUpdateUserProfile (merge strategy)
│
├── game/
│   ├── characters/
│   │   ├── robot.dart               # Robot component: full physics + event FSM
│   │   ├── diziness.dart            # Dizzy stars particle effect (post-hurt)
│   │   └── electric.dart            # Electric arc component (electrocution)
│   ├── obstacles/
│   │   ├── bird.dart                # Animated bird obstacle (3-frame)
│   │   ├── cloud.dart               # Scrolling cloud decoration
│   │   ├── fence.dart               # Ground-level fence (trip trigger)
│   │   ├── finger.dart              # Tap-based finger obstacle
│   │   ├── rain.dart                # Rain obstacle (electrocute trigger)
│   │   └── superclass/
│   │       ├── animated_mover.dart  # Base for sprite-animated movers
│   │       ├── drawn_mover.dart     # Base for custom-drawn movers
│   │       └── simple_mover.dart    # Base for single-sprite movers
│   ├── buttons/
│   │   ├── generic_button.dart      # Flame text button (used in EndLesson)
│   │   └── icon_button.dart         # Flame icon button (X close button)
│   ├── decorations/
│   │   ├── fancy_box.dart           # Flame stat box with banner + icon
│   │   ├── progress_bar.dart        # Flame lesson progress bar (stages)
│   │   └── stars.dart               # Star rating decoration
│   ├── events/
│   │   └── event_type.dart          # EventRobot enum + EventHorizontalObstacle enum
│   ├── static/
│   │   ├── background.dart          # Scrolling background scene
│   │   └── ground.dart              # Ground plane
│   └── texts/
│       ├── arrow.dart               # Animated directional arrow
│       ├── mcq.dart                 # Flame MCQ component
│       ├── text_box.dart            # FancyTextBox typewriter component
│       └── lessons_text/
│           └── lesson3_text.dart    # Lesson 3 specific text sequences
│
└── z_pages/
    ├── end_lesson.dart              # EndLessonPage (FlameGame): XP + streak + progress boxes
    ├── root_nav.dart                # RootNavScaffold: bottom nav (Home/Lessons/Games/Settings)
    │
    ├── assets/
    │   ├── lessonAssets/            # Reusable lesson UI widgets
    │   │   ├── continueButton.dart
    │   │   ├── dialouge.dart
    │   │   ├── helpful_tools.dart   # LessonText rich-text builder
    │   │   ├── icon_button.dart
    │   │   ├── image_slider.dart
    │   │   ├── mascot_dialouge.dart
    │   │   ├── mcq_box.dart
    │   │   └── progress_bar.dart    # Flutter UI progress bar (top of lesson)
    │   ├── lessonPage/              # Lesson map widgets
    │   │   ├── lesson_page.dart     # Full animated lesson map screen
    │   │   ├── lesson_node.dart     # Individual pulsing lesson node
    │   │   ├── lesson_box.dart      # Focus-state info card
    │   │   ├── chapter_pill.dart    # Chapter selector pill
    │   │   ├── chapter_dropdown.dart
    │   │   ├── path_painter.dart    # CustomPainter for connecting path
    │   │   ├── map_geometry.dart    # Node/path layout algorithm
    │   │   ├── light_beam.dart      # Spotlight beam on focused node
    │   │   ├── box_circle.dart
    │   │   ├── complex_box.dart
    │   │   └── lesson_names.dart
    │   ├── mainMenu/               # Home tab widgets
    │   │   ├── main_menu.dart
    │   │   ├── header_greeting.dart
    │   │   ├── avatar.dart
    │   │   ├── bell.dart
    │   │   ├── box_with_progress.dart
    │   │   ├── circle_progress.dart
    │   │   ├── simple_box.dart
    │   │   └── weekly_streak.dart
    │   └── settings/
    │       └── setting.dart
    │
    ├── lessons/
    │   ├── data-intro/              # Lesson 1: What is Data?
    │   ├── data-ai-relevance/       # Lesson 2: Why is Data important for AI?
    │   ├── binary-intro/            # Lesson 3: What is Binary?
    │   ├── qual-quan/               # Lesson 4: Qualitative vs Quantitative
    │   ├── qual-game/               # Lesson 5: Qualitative Mini-Game
    │   ├── data-sample-intro/       # Lesson 6: What is a Data Sample?
    │   ├── features-intro/          # Lesson 7: What is a Feature?
    │   └── unknown/                 # WIP classification lesson content
    │
    └── mini-games/
        ├── drag_drop_game.dart      # Abstract DragDropGameBase + state machine
        ├── classify_game.dart       # Classify variant (many tokens → buckets)
        ├── mini_classify_game.dart  # Compact classify variant
        ├── match_game.dart          # Match variant
        └── pair_match.dart          # PairMatch variant (1:1 emoji pairing)
```

---

## Architecture

### Navigation & Routing

The app uses a **custom sealed-class router** rather than `Navigator` or `go_router`. All navigation is handled through `AppRoute` subclasses passed upward to the root `MyApp` widget via a callback:

```dart
abstract class AppRoute {}

class RouteMainMenu extends AppRoute { final int tab; }
class RouteLesson   extends AppRoute { final int lessonNumber; }
class RouteEndLesson extends AppRoute {
  final int xp, streak, chapterProgress, totalChapterLessons;
  final LessonProgressBar progressBar;
  final String topText;
  final AppRoute repeatLesson;
  final AppRoute? nextLesson;
}
```

`MyApp` holds a single `AppRoute _route` in state. Every screen receives `AppNavigate onNavigate` and calls it to trigger a root-level `setState`, which replaces the entire page tree. Page transitions are handled via `FadeThroughTransition` from the `animations` package. Each page swap increments a `_sceneKey` to force a clean widget remount.

This design means **there is no Navigator stack** during a lesson — pressing the X button routes directly to `RouteMainMenu`, preventing back-stack accumulation and accidental back-swipe mid-lesson.

---

### Lesson System

The lesson system is built on two key abstractions:

#### `BaseLessonBrain`

Every lesson is a `StatefulWidget` that extends `BaseLessonBrain`. The subclass only needs to:

1. Declare its `lessonId` string (e.g. `"data-intro"`)
2. Implement `buildSubLessons()` returning a `List<SubLesson>`

`BaseLessonBrain` automatically resolves `chapterId` and `courseId` by traversing the manifest, computes `globalLessonNumber` from `LessonLocator`, and wires Firestore calls to `LessonService`.

#### `SubLesson` and `LessonMechanic`

Each step in a lesson is a `SubLesson` with:

- `topOffset` — Y pixel offset from top of screen (controls visual positioning)
- `mechanic` — one of three advance modes:
  - `LessonMechanic.auto` — advances immediately when the content signals completion (no button shown)
  - `LessonMechanic.emit` — waits for `onComplete()` callback from content widget, then shows the Continue button
  - `LessonMechanic.manual` — shows the Continue button immediately, no content callback needed
- `build(onComplete, onReset)` — factory function returning the step widget

`BaseLessonBrainState` renders a `Stack` with:
1. The current step widget (keyed with a `_restartNonce` for Try Again remounting)
2. A `LessonProgressBar` pinned at the top
3. A `ContinueButton` at the bottom (when applicable)
4. An X icon button in the top-left corner

#### `LessonManifest`

The single source of truth for all lessons is the manifest in `lesson_manifest.dart`:

```dart
final List<ChapterMeta> chapterManifest = [
  ChapterMeta(
    id: "data-basics",
    title: "Foundations of AI",
    lessons: [
      LessonMeta(id: "data-intro",       title: "What is Data?",         builder: ...),
      LessonMeta(id: "data-ai-relevance",title: "Why is Data for AI?",   builder: ...),
      LessonMeta(id: "binary-intro",     title: "What is Binary?",       builder: ...),
      LessonMeta(id: "qual-quan",        title: "Qualitative vs Quantitative", builder: ...),
      LessonMeta(id: "qual-game",        title: "Qualitative Mini-Game", builder: ...),
      LessonMeta(id: "data-sample-intro",title: "What is a Data Sample?",builder: ...),
      LessonMeta(id: "features-intro",   title: "What is a Feature?",    builder: ...),
    ],
  ),
];
```

The `LessonNavigator` uses this manifest to compute the next lesson route or resolve to `RouteEndLesson` when the last step completes.

---

### Game Engine Layer (Flame)

Two key experiences use the Flame game engine:

**1. EndLessonPage** (`end_lesson.dart`)
A `FlameGame` that renders the post-lesson completion screen. It loads `blue_robot.png` as a centred illustration, places three animated `FancyBox` components (XP, Chapter Progress, Daily Streak), a `FancyTextBox` headline, a `GenericButton` ("Next Lesson"), and an X icon button. Layout is fully dynamic — robot size is constrained by both screen width and a height cap, and the stat boxes are positioned relative to the robot's bottom edge with a configurable gap.

**2. Robot Character** (`robot.dart`)
A `PositionComponent` with collision detection used in game-based lessons. It supports a full event-driven FSM via `EventRobot`:

| Event | Behaviour |
|---|---|
| `idle` | Tracks animate, robot stands still |
| `jump` | Upward velocity, gravity integration, landing detection |
| `duck` | Smooth squat-and-rise using quadratic easing over three phases |
| `trip` | Forward angular spin, gravity, bounce with restitution, pivot-lock rolling, settles face-down at `π/2` |
| `electrocute` | 2-second sinusoidal body/track shake + `Electric` arc child component |
| `hurt` | Three-phase: slump down → wiggle → hold → stand up. Spawns `Diziness` star particles |
| `resume` | Resets all transform state, re-enables tracks |

Collision detection uses `RectangleHitbox` on the body sprite. `Fence` triggers `trip()`, `Rain` triggers `electrocute()`, `Bird` triggers `hurt()`.

---

### Authentication Flow

```
app launch
    │
    └── AuthGate (StreamBuilder on FirebaseAuth.authStateChanges)
            │
            ├── waiting → CircularProgressIndicator
            ├── user == null → WelcomePage
            └── user != null → MyApp
```

**WelcomePage** offers "Get Started" (→ SignupPage) and "Already existing user? Log in" (→ LoginPage).

**LoginPage** supports:
- Email + password (`signInWithEmailAndPassword`)
- Google Sign-In via `GoogleSignIn.instance.authenticate()` with fallback to `signInWithPopup` on web
- Facebook login via `flutter_facebook_auth` with `email` + `public_profile` scopes

**SignupFlow** is a 3-page `PageView`:
1. Name entry
2. Date of birth via `CupertinoDatePicker`
3. Password + confirm password

On success, `UserProfileService.createOrUpdateUserProfile()` writes (or merges) the user document into Firestore before redirecting to `AuthGate`.

All auth pages share a consistent visual language: a top-to-bottom `LinearGradient` from `Color(0xFFF3E9FF)` to white, `BorderRadius.circular(16)` text fields, `Color(0xFF7F56D9)` brand purple, and `GoogleFonts.lato` typography.

---

### Firestore Data Model

The schema follows a flat-hierarchy design described in `backend_plan.txt`:

#### User Document — `users/{uid}`

```jsonc
{
  "uid":             "string",
  "name":            "string",
  "email":           "string",
  "photoUrl":        "string | null",
  "joinedAt":        "Timestamp",
  "lastLogin":       "Timestamp (serverTimestamp on every login)",
  "streak":          "int",
  "xp":              "int",
  "lessonsCompleted":"int",
  "currentLesson":   "int (global lesson number, 1-based)",
  "dob":             "Timestamp | null",
  "provider":        "google | facebook | password",
  "lastDevice":      "android | ios | web",
  "appVersion":      "string"
}
```

`UserProfileService` uses `SetOptions(merge: true)` so partial updates never overwrite unrelated fields. `joinedAt` is preserved from the first write — it is never overwritten.

#### Lesson Progress — `users/{uid}/progress/{courseId}/{chapterId}/{lessonId}`

```jsonc
{
  "lessonId":                  "string",
  "courseId":                  "string",
  "chapterId":                 "string",
  "startedAt":                 "Timestamp",
  "lastActiveAt":              "Timestamp (updated on every open)",
  "completedAt":               "Timestamp | null",
  "timeSpentToFirstCompletion":"int (ms)",
  "timeSpentTotal":            "int (ms)",
  "completedCount":            "int (increments on every completion, including replays)",
  "lastStepIndex":             "int (resume point)"
}
```

`LessonService` enforces the following logic:
- **First open**: creates the full document with `completedCount: 0`
- **Subsequent opens**: only updates `lastActiveAt`
- **Step advance**: calls `updateLesson({lastStepIndex: n})`
- **Completion**: sets `completedAt`, increments `completedCount`, and conditionally increments `users/{uid}.lessonsCompleted` (only on first-time completion, using a snapshot check). Also bumps `users/{uid}.currentLesson` if this lesson's global index is higher than the stored value.

---

## Screens & Features

### Welcome / Onboarding

- Full-screen illustration placeholder (80% of screen height) with a bottom 20% CTA strip
- "Get Started" → `SignupPage` → `SignupFlow` (3-step paged onboarding)
- "Log in" → `LoginPage`
- All transitions use `CupertinoPageRoute` (right-to-left slide)
- Edge-to-edge rendering: transparent status bar, `SystemUiMode.edgeToEdge`

### Main Menu

`MainMenuPage` is a `Scaffold` with a white background containing:

- **`HeaderGreeting`**: user avatar + notification bell in the top area
- **`WeeklyStreak`**: 7-day row showing `missed`, `completed`, or `todayPending` states. Hardcoded to `streakCount: 1` currently (Firestore wiring pending)
- **Learning Hub section**: A `BoxWithProgress` card ("Introduction to Artificial Intelligence") that navigates to `RouteLesson(1)`. Card uses a teal (`#00796B`) fill with a chatbot image.
- **Exercises section**: A `SimpleBox` card ("Mini Games — Coming Soon") in a deep red/plum colour
- All cards use `BorderRadius.circular(25)` and a subtle `BoxShadow`

### Lesson Map

`LessonPage` is one of the most complex screens in the app. It renders a scrollable vertical map of lesson nodes connected by a custom-painted `PathPainter` curve. Features:

- **Animated pulsing nodes** via a repeating `AnimationController` (2s reverse loop)
- **Focus mode**: tapping a node triggers a zoom animation (`kFocusedScale: 1.50`) that translates the node to a fixed target position on-screen. All other nodes fade and blur (`ImageFiltered`, `sigmaX: 6.0`)
- **Light beam**: after the focus zoom, a blue `LightBeam` (`CustomPainter` triangle gradient) sweeps down over the node
- **Info card (`LessonBox`)**: slides in below the node showing the lesson title, a thumbnail, and a "Continue Lesson" button
- **Chapter selector**: a pill at the top that opens an `AnimatedSize` dropdown to switch chapters
- Scroll is locked while a node is focused. `WillPopScope` catches back-swipe to unfocus instead of navigating away
- `PageStorageBucket` preserves scroll position between tab switches

### Lessons

Each lesson follows the `BaseLessonBrain` pattern. Examples of implemented lesson content:

**Lesson 1 — What is Data?** (`data-intro`)
Steps: intro mascot dialogue → "Computer to Data" interactive reveal → Data Types explainer → multiple dynamic quiz rounds (MCQ with `DataTypeQuiz`)

**Lesson 3 — What is Binary?** (`binary-intro`)
Includes `BinaryIntro`, `BinExample`, `BinaryGame`, `Comp0101`, `Music`, `Photo`, `Unicode` sub-steps. Demonstrates how text, images, and music are all ultimately binary.

**Lesson 4 — Qualitative vs Quantitative** (`qual-quan`)
Steps walk through definitions, examples, measurement concepts, and quizzes for both types. References `RecapBinary` and `RecapData` steps that reinforce prior lessons.

**Lesson 7 — What is a Feature?** (`features-intro`)
Covers measurability, what makes a good feature, movie rating examples, and MCQ quizzes.

All lessons share:
- A top `LessonProgressBar` (segmented, one segment per `SubLesson`)
- An X icon that returns to main menu
- A `ContinueButton` pinned at the bottom (when mechanic requires it)
- Firestore writes on every step advance via `updateLesson`

### Mini-Games

`DragDropGameBase` is a generic, reusable drag-and-drop game engine implemented as an abstract Flutter widget (not Flame). Key design decisions:

- **Token pool** rendered as a `Wrap` of draggable emoji tiles. Pool is shuffled on init and on retry.
- **DragTarget baskets** with animated border color (green flash on correct, red flash + shake on wrong). Shake is implemented with `TweenSequence<Offset>` on a `SlideTransition`.
- **Streaks and stats** tracked: correct attempts, incorrect attempts, longest streak
- **End-card choreography**: content fades out → end card fades in → compactly slides up → "Great work 🎉" expands to reveal stats + Try Again button. Uses `AnimatedPositioned` + `AnimatedSize` + a `_MeasureSize` render object for precise centering.
- **Two concrete implementations**: `PairMatch` (match emoji to its pair across two baskets) and `ClassifyGame` (categorise multiple tokens into labeled buckets)
- The `_restartNonce` mechanism in `BaseLessonBrainState` forces a clean widget remount on Try Again, resetting the game's internal `_completed` flag

### End Lesson Screen

`EndLessonPage` (a `FlameGame`) renders:
- A progress bar (the final state of the in-lesson bar, passed as a pre-built object)
- A centered `blue_robot.png` sprite scaled proportionally to fit within `min(33% screen height, 360px)` and `(screen width - 64px)` while preserving aspect ratio
- Three `FancyBox` stat components in a row: **Total XP** (orange), **Progress** (green, e.g. "3/7"), **Streak** (blue)
- "Next Lesson" button (navigates to next RouteLesson or RouteMainMenu if final)
- X button (returns to main menu)
- A `FancyTextBox` typewriter-style headline

### Settings

`SettingsPage` is mounted as the fourth tab in `RootNavScaffold`.

---

## Lesson Manifest (Course Content)

```
AI Foundations Course
└── Chapter 1: Foundations of AI (id: data-basics)
    ├── Lesson 1:  What is Data?                    (id: data-intro)
    ├── Lesson 2:  Why is Data so important for AI? (id: data-ai-relevance)
    ├── Lesson 3:  What is Binary?                  (id: binary-intro)
    ├── Lesson 4:  Qualitative vs Quantitative      (id: qual-quan)
    ├── Lesson 5:  Qualitative Mini-Game            (id: qual-game)
    ├── Lesson 6:  What is a Data Sample?           (id: data-sample-intro)
    └── Lesson 7:  What is a Feature?               (id: features-intro)
```

Additional lesson stubs exist under `lib/z_pages/lessons/unknown/` covering classification topics (binary classification, labelling) — these are not yet wired into the manifest.

---

## Robot Character & Physics

The `Robot` Flame component implements a full physics simulation from scratch (without `flame_forge2d`):

### State Machine

```
idle ←→ resume
 │         ↑
 ├→ jump ──┘
 ├→ duck ──┘
 ├→ trip  (gravity + angular spin + bounce + pivot-roll settle → head-on-ground pose)
 ├→ hurt  (slump → wiggle → hold 3s → stand up)
 └→ electrocute (2s sinusoidal shake + electric arc overlay)
```

### Trip Physics Detail

The trip event is the most physically complex:
1. An angular delta of `3.6 rad/s` is applied (forward spin impetus)
2. Gravity (`480 px/s²`) accumulates vertical velocity, capped at `620 px/s` terminal velocity
3. Air drag is applied exponentially per frame: `velocity.y *= pow(0.88, dt)`
4. On first ground contact, either bounces (if `|velocity.y| > 28`, with restitution `e = 0.64`) or locks into `_settling` mode
5. In settling, a pivot point is dynamically selected from the robot's transformed corner geometry — the lowest point becomes the pivot. As the robot rolls toward face-down (`angle = π/2`), the pivot switches to the head corner
6. Finish condition: `|_angleDelta| < 0.02` and `|bias| < 0.02`

### Collision

`RectangleHitbox` is centred on the body sprite. `onCollisionStart` checks the type of `other`:
- `Fence` → `trip()`
- `Rain` → `electrocute()` (only if not already electrocuted)
- `Bird` → `hurt()` (only if not already hurt)

---

## Getting Started

### Prerequisites

- Flutter SDK `>=3.0.0` (null-safe, Dart 3 compatible)
- Android SDK / Xcode (for mobile targets)
- A Firebase project with Authentication and Firestore enabled
- `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) from your Firebase console

### Installation

```bash
git clone https://github.com/your-org/running_robot.git
cd running_robot
flutter pub get
```

### Firebase Setup

1. Create a project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable **Authentication** → sign-in methods: Email/Password, Google, Facebook
3. Enable **Cloud Firestore** in production or test mode
4. Download `google-services.json` → place at `android/app/google-services.json`
5. Download `GoogleService-Info.plist` → place at `ios/Runner/GoogleService-Info.plist`
6. For web, add Firebase config to `web/index.html`

**Facebook Auth** requires additional setup:
- Create a Facebook App at developers.facebook.com
- Add `APP_ID` and `CLIENT_TOKEN` to `android/app/src/main/res/values/strings.xml`
- Configure `Info.plist` entries for iOS as per `flutter_facebook_auth` docs

### Running the App

```bash
# Android
flutter run -d android

# iOS
flutter run -d ios

# Web
flutter run -d chrome

# macOS
flutter run -d macos
```

---

## Building for Release

```bash
# Android APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release

# iOS (requires Xcode signing)
flutter build ios --release

# Web
flutter build web --release
```

For Android release signing, see `how to get keytool.txt` in the project root for keystore generation instructions.

---

## Dependencies

```yaml
# Core
flutter_sdk: flutter

# Firebase
firebase_core: ^4.0.0
firebase_auth: ^6.1.0
cloud_firestore: ^6.0.0

# Auth Providers
google_sign_in: ^7.2.0
flutter_facebook_auth: ^7.1.2

# Game Engine
flame: ^1.30.1
flame_forge2d: ^0.18.0

# UI
google_fonts: ^6.2.1
flutter_svg: ^2.0.9
animations: ^2.0.11
cupertino_icons: ^1.0.8
cached_network_image: ^3.3.1
```

---

## Asset Catalogue

All assets live under `assets/images/`. Major categories:

| Category | Files |
|---|---|
| Robot sprites | `robot_yellowBody.png`, `robot_yellowDamage1.png`, `blue_robot.png`, `tracks_long1.png`, `tracks_long2.png` |
| Obstacles | `fence.png`, `bird1–4.png`, `finger.png` |
| Clouds | `cloud_white.png`, `cloud_grey.png`, `cloud_shape3_3–5.png`, `cloud_shape4_4.png`, `cloud_shape5_3.png` |
| Fauna | `bee.png`, `bee_move.png`, `bat.png`, `bat_fly.png`, `bat_hang.png` |
| Aircraft | `planeGreen1–3.png` |
| UI icons | `star.png`, `star_empty.png`, `x_icon.png`, `down_arrow.png`, `next.png`, `arrow_left.png`, `bell.png`, `flame.png`, `google_icon.png` |
| Lesson illustrations | `ai_intro.png`, `ai_robot.png`, `ai_learning.png`, `chat_bot.png`, `chat_bot_1.png`, `brain_mri1–4.png`, `data_chart.png`, `tabular.png`, `notebook.png`, `qualitative.png`, `quantitative.png`, `data_sample.png`, `data_set.png`, `house1–4.png`, `movie_rating.png` |
| SVGs | `scribble_green.svg`, `scribble_orange.svg`, `trophy_people.svg`, `down_arrow.svg` |

---

## Firestore Security Notes

Firestore rules are not included in this repository. Before production deployment:

- Scope all user document reads/writes to `request.auth.uid == userId`
- Restrict `progress` subcollection writes to the owning user
- Do not allow client-side writes to aggregate fields (`xp`, `streak`) without server-side validation (consider Cloud Functions for streak logic to prevent manipulation)

---

## Known Limitations & Roadmap

### Current Limitations

- **Streak logic** is not yet wired to real Firestore data — `WeeklyStreak` on the home screen is rendered with hardcoded state
- **XP system** exists in the data model but XP values on the End Lesson screen are passed as constructor arguments rather than read from Firestore
- **Puzzles tab** is a stub ("This feature is in development")
- **`WelcomePage` illustration** is a placeholder (`Icon(Icons.auto_awesome)`) — designed to hold a hero illustration asset
- **Forgot password** flow shows a SnackBar placeholder only
- **`unknown/` lessons** (classification content) are implemented but not yet registered in the manifest

### Planned / In Progress (per `PLANS FROM NOW.docx` and `backend_plan.txt`)

- Full Firestore-backed XP and streak updates triggered server-side via Cloud Functions
- Mechanics subcollection tracking (per-game analytics: drag-drop stats, MCQ accuracy, catch game scores)
- Additional chapters and lessons beyond "Foundations of AI"
- Puzzles/Games tab with standalone mini-game challenges
- Badge/achievement system (`badges` array on user profile)
- Proper password reset flow via `sendPasswordResetEmail`
- Deeper analytics queries: average time per lesson, per-mechanic correctness rates across cohorts

---

*This README reflects the codebase as of the project's current state. The app is in active development.*
