class EventRobot {
  static const String jump = 'robot_jump';
  static const String duck = 'robot_duck';
  static const String idle = 'robot_idle';
  static const String stop = 'robot_stop';
  static const String resume = 'robot_resume';
  static const String pause = "pause";
}

class EventDuckObstacle {
  static const String startMoving = 'duckObstacle_startMoving';
  static const String stopMoving = 'duckObstacle_stopMoving';
  static const String pause = "pause";
}

class EventJumpObstacle {
  static const String startMoving = 'jumpObstacle_startMoving';
  static const String stopMoving = 'jumpObstacle_stopMoving';
  static const String pause = "pause";
}

class EventFallObstacle {
  static const String startFalling = 'fallObstacle_startFalling';
  static const String stopFalling = 'fallObstacle_stopFalling';
  static const String pause = "pause";
}

class EventRain {
  static const String startRain = 'rain_startRain';
  static const String stopRain = 'rain_stopRain';
  static const String pause = "pause";
}

class EventTextObject {
  static const String showText = 'text_show';
  static const String hideText = 'text_hide';
  static const String nextSequence = 'text_next';
  static const String pause = "pause";
}
