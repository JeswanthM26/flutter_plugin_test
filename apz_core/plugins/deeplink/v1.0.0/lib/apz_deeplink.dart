import "dart:async";
import "package:apz_deeplink/deeplink_data.dart";
import "package:apz_utils/apz_utils.dart";
import "package:flutter/foundation.dart";
import "package:flutter/services.dart";
export "package:apz_deeplink/deeplink_data.dart";

/// A plugin to handle deep links in Flutter applications.
class ApzDeeplink {
  /// Factory constructor returns the same instance
  factory ApzDeeplink() => _instance;
  // Private constructor
  ApzDeeplink._()
    : _methodChannel = const MethodChannel("apz_deeplink/method"),
      _eventChannel = const EventChannel("apz_deeplink/events");

  final MethodChannel _methodChannel;
  final EventChannel _eventChannel;

  /// Private constructor to ensure singleton pattern.
  static final ApzDeeplink _instance = ApzDeeplink._();

  final StreamController<DeeplinkData> _linkController =
      StreamController<DeeplinkData>.broadcast();
  bool _isInitialized = false;

  /// Getter for the stream of deep links.
  Stream<DeeplinkData> get linkStream {
    unawaited(initialize()); // handles init internally
    return _linkController.stream;
  }

  /// initializes the plugin and starts listening for deep links.
  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }
    // --- Add platform check here ---
    if (kIsWeb) {
      throw UnsupportedPlatformException(
        "Deep linking is not supported on the web",
      );
    }
    _isInitialized = true;
    _eventChannel.receiveBroadcastStream().listen((final Object? event) {
      if (event is String) {
        final Uri uri = Uri.parse(event);
        _linkController.add(DeeplinkData.fromUri(uri));
      }
    });
  }

  /// gets the initial deep link when the app is launched.
  Future<String?> getInitialLink() async {
    if (kIsWeb) {
      throw UnsupportedPlatformException(
        "Initial deep link is not supported on the web",
      );
    }
    return _methodChannel.invokeMethod<String>("getInitialLink");
  }
}
