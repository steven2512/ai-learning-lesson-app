// ────────── ROBOT EVENTS ──────────
enum EventRobot {
  jump,
  duck,
  idle,
  resume,
  trip,
  electrocute,
  hurt,
}

// ────────── HORIZONTAL OBSTACLE EVENTS ──────────
enum EventHorizontalObstacle {
  startMoving,
  stopMoving,
}

// ────────── VERTICAL OBSTACLE EVENTS ──────────
enum EventVerticalObstacle {
  startFalling,
  stopFalling,
}

// ────────── CLOUD EVENTS ──────────
enum CloudEvent {
  startCloud,
  stopCloud,
}

// ────────── RAIN EVENTS ──────────
enum EventRain {
  startRain,
  stopRain,
}

// ────────── TEXT EVENTS ──────────
enum EventText {
  showText,
  hideText,
  nextSequence,
}

enum EventProgressBar {
  initial,
  proceed,
  finish,
}

enum EventEndLesson {
  initial,
  fill,
  full,
}

enum EventButton {
  unpressed,
  pressed,
  hold,
}

enum EventFancyBox { hide, show, animate }
