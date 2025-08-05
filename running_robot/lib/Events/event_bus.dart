typedef EventCallback = void Function();

class EventBus {
  // Singleton pattern
  static final EventBus _instance = EventBus._internal();
  factory EventBus() => _instance;
  EventBus._internal();

  final Map<String, List<EventCallback>> _listeners = {};

  // Register a callback to a specific event
  void on(String eventKey, EventCallback callback) {
    _listeners.putIfAbsent(eventKey, () => []).add(callback);
  }

  // Remove a specific callback (optional)
  void off(String eventKey, EventCallback callback) {
    _listeners[eventKey]?.remove(callback);
    if (_listeners[eventKey]?.isEmpty ?? false) {
      _listeners.remove(eventKey);
    }
  }

  // Emit an event
  void emit(String eventKey) {
    if (_listeners.containsKey(eventKey)) {
      for (final callback in List<EventCallback>.from(_listeners[eventKey]!)) {
        callback(); // Execute each registered callback
      }
    }
  }

  // Clear all listeners (e.g., when resetting the game)
  void clear() {
    _listeners.clear();
  }
}
