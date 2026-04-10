import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

class AppSessionTracker with WidgetsBindingObserver {
  AppSessionTracker._();

  static final AppSessionTracker instance = AppSessionTracker._();

  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  DateTime? _sessionStartedAt;
  bool _isAttached = false;
  bool _isFlushing = false;

  void attach() {
    if (_isAttached) return;
    WidgetsBinding.instance.addObserver(this);
    _isAttached = true;
    _startSessionIfNeeded();
  }

  void detach() {
    if (!_isAttached) return;
    WidgetsBinding.instance.removeObserver(this);
    _isAttached = false;
    _flushActiveSession();
    _sessionStartedAt = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _startSessionIfNeeded();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _flushActiveSession();
        break;
    }
  }

  void _startSessionIfNeeded() {
    if (FirebaseAuth.instance.currentUser == null) return;
    if (_sessionStartedAt != null) return;

    _sessionStartedAt = DateTime.now();
    _markDailyActivitySafely();
  }

  Future<void> _flushActiveSession() async {
    if (_isFlushing) return;

    final startedAt = _sessionStartedAt;
    if (startedAt == null) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    _sessionStartedAt = null;
    if (currentUser == null) return;

    final elapsedSeconds = DateTime.now().difference(startedAt).inSeconds;
    if (elapsedSeconds <= 0) return;

    _isFlushing = true;
    try {
      await _functions
          .httpsCallable(
        'flushAppSession',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 20),
        ),
      )
          .call({
        'sessionSeconds': elapsedSeconds,
      });
    } catch (_) {
      // Keep the app usable even if analytics/session flushing is unavailable.
    } finally {
      _isFlushing = false;
    }
  }

  Future<void> _markDailyActivitySafely() async {
    try {
      await _functions
          .httpsCallable(
            'markDailyActivity',
            options: HttpsCallableOptions(
              timeout: const Duration(seconds: 20),
            ),
          )
          .call();
    } catch (_) {
      // Ignore so the main app flow stays responsive.
    }
  }
}
