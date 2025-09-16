import "dart:async";

import "package:apz_utils/apz_utils.dart";
import "package:flutter/foundation.dart"; // For AppLifecycleState
import "package:flutter/scheduler.dart";
import "package:flutter/services.dart"; // For MethodChannel, PlatformException

/// A singleton class to detect app lifecycle changes across platforms.
class ApzAppSwitch {
  /// Factory constructor to ensure singleton usage.
  factory ApzAppSwitch() => _instance;
  // --- Singleton Setup ---
  ApzAppSwitch._(); // Private constructor
  static final ApzAppSwitch _instance = ApzAppSwitch._();

  /// for testing purpose
  @visibleForTesting
  void resetForTest() {
    _isInitialized = false;
  }

  /// for testing purpose
  @visibleForTesting
  Stream<String>? debugOverrideEventStream;

  bool? _overrideIsWeb;

  /// For testing purpose
  bool get isWeb => _overrideIsWeb ?? kIsWeb;

  /// for testing purpose
  @visibleForTesting
  set isWeb(final bool value) {
    _overrideIsWeb = value;
  }

  // --- Method & Event Channels (Native Only) ---
  final MethodChannel _methodChannel = const MethodChannel(
    "apz_app_switch_method",
  );
  final EventChannel _eventChannel = const EventChannel(
    "apz_app_switch_events",
  );
  AppLifecycleState? _lastKnownState; // Last known lifecycle state
  bool _isInitialized = false; // Prevent multiple initializations
  ///
  StreamController<AppLifecycleState>? _lifecycleStreamController;

  /// Getter for lifecycle stream
  Stream<AppLifecycleState> get lifecycleStream {
    unawaited(initialize()); // handles init internally
    return _lifecycleStreamController!.stream;
  }

  /// Returns the last known lifecycle state (if available)
  AppLifecycleState? get currentState => _lastKnownState;

  /// Initializes the lifecycle detection system (call once at startup).
  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }
    _isInitialized = true;
    if (isWeb) {
      throw UnsupportedPlatformException(
        "ApzLife-cycle has not been implemented for web.",
      );
    }
    _lifecycleStreamController =
        StreamController<AppLifecycleState>.broadcast();

    try {
      await _methodChannel.invokeMethod<void>("initialize");
      (debugOverrideEventStream ??
              _eventChannel.receiveBroadcastStream().cast<String>())
          .listen((final String event) {
            final AppLifecycleState? state = _mapStringToState(event);
            // Prevent duplicate consecutive emissions
            if (state != null && _lastKnownState == state) {
              return;
            }
            _lastKnownState = state;
            _lifecycleStreamController?.add(state!);
          });
    } on PlatformException {
      _isInitialized = false;
      rethrow;
    } catch (e) {
      _isInitialized = false;
      await _lifecycleStreamController?.close();
      _lifecycleStreamController = null;
      rethrow;
    }
  }

  // --- Internal: Native mapping ---
  AppLifecycleState? _mapStringToState(final String value) {
    switch (value) {
      case "resumed":
        return AppLifecycleState.resumed;
      case "inactive":
        return AppLifecycleState.inactive;
      case "paused":
        return AppLifecycleState.paused;
      default:
        return null;
    }
  }
}
