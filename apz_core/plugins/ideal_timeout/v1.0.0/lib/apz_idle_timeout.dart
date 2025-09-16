import "dart:async";
import "package:flutter/gestures.dart";
import "package:flutter/widgets.dart";

/// A callback invoked when the user has been idle for a specified duration.
typedef IdleTimeOutCallback = Future<void> Function();

/// idle timeout manager for Flutter applications.
class ApzIdleTimeout with WidgetsBindingObserver {
  /// Singleton instance of ApzIdleTimeout.
  factory ApzIdleTimeout() => _instance;
  ApzIdleTimeout._internal();
  static final ApzIdleTimeout _instance = ApzIdleTimeout._internal();

  Duration _timeoutDuration = const Duration(seconds: 60);
  Timer? _idleTimer;
  Timer? _debounceTimer;
  final Duration _debounce = const Duration(milliseconds: 500);

  IdleTimeOutCallback? _idleTimeOutCallback;
  bool _enabled = true;

  /// start the idle timeout manager
  void start(final IdleTimeOutCallback callback, {final Duration? timeout}) {
    _idleTimeOutCallback = callback;
    _timeoutDuration = timeout ?? _timeoutDuration;
    WidgetsBinding.instance.addObserver(this);

    GestureBinding.instance.pointerRouter.addGlobalRoute((
      final PointerEvent event,
    ) {
      if (_enabled) {
        debounceUserInteraction();
      }
    });

    _startIdleTimer();
  }

  /// Debounce user interaction to prevent resetting the idle timer frequently
  void debounceUserInteraction() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounce, _startIdleTimer);
  }

  void _startIdleTimer() {
    _idleTimer?.cancel();
    _idleTimer = Timer(_timeoutDuration, () async {
      if (_enabled && _idleTimeOutCallback != null) {
        await _idleTimeOutCallback!();
      }
    });
  }

  /// Public control
  /// pause the idle timeout
  void pause() => _enabled = false;

  /// resume the idle timeout
  void resume() => _enabled = true;

  /// reset the idle timer
  void reset() {
    if (_enabled) {
      _startIdleTimer();
    }
  }

  /// dispose the idle timeout manager
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _idleTimer?.cancel();
    _debounceTimer?.cancel();
  }

  @override
  void didChangeAppLifecycleState(final AppLifecycleState state) {
    if (!_enabled) {
      return;
    }
    if (state == AppLifecycleState.paused) {
      _idleTimer?.cancel();
    } else if (state == AppLifecycleState.resumed) {
      _startIdleTimer();
    }
  }
}
