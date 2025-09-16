import "dart:async";
import "package:apz_universal_linking/link_data.dart";
import "package:apz_utils/apz_utils.dart";
import "package:flutter/foundation.dart"; // for kIsWeb
import "package:flutter/services.dart";
export "package:apz_universal_linking/link_data.dart";

/// A plugin to handle universal links in Flutter applications.
class ApzUniversalLinking {
  /// Factory constructor returns the same instance
  factory ApzUniversalLinking({final bool Function()? isWebOverride}) {
    if ((isWebOverride ?? () => kIsWeb)()) {
      throw UnsupportedPlatformException(
        "ApzUniversalLinking is not supported on the web",
      );
    }
    return _instance;
  }
  ApzUniversalLinking._()
    : _methodChannel = const MethodChannel("apz_universal_linking") {
    _methodChannel.setMethodCallHandler((final MethodCall call) async {
      if (call.method == "onLinkReceived") {
        final Map<String, dynamic> map = Map<String, dynamic>.from(
          call.arguments as Map<dynamic, dynamic>,
        );
        handleIncomingLink(map);
      }
    });
  }
  final MethodChannel _methodChannel;

  /// For testing purposes, allows access to the method channel.
  @visibleForTesting
  MethodChannel get methodChannel => _methodChannel;

  static ApzUniversalLinking _instance = ApzUniversalLinking._();
  final StreamController<LinkData> _streamController =
      StreamController<LinkData>.broadcast();

  /// Initializes the plugin and starts listening for universal links.
  Stream<LinkData> get linkStream => _streamController.stream;

  /// Handles incoming universal links from the platform.
  void handleIncomingLink(final Map<dynamic, dynamic> map) {
    _streamController.add(LinkData.fromMap(map));
  }

  /// Initializes the plugin and starts listening for universal links.
  Future<LinkData?> getInitialLink() async {
    if (kIsWeb) {
      throw UnsupportedPlatformException(
        "ApzUniversalLinking is not supported on the web",
      );
    }
    final dynamic rawResult = await _methodChannel.invokeMethod(
      "getInitialLink",
    );
    if (rawResult is Map) {
      final Map<String, dynamic> result = Map<String, dynamic>.from(rawResult);
      return LinkData.fromMap(result);
    }

    return null;
  }

  /// Optional cleanup
  Future<void> dispose() async {
    await _streamController.close();
  }

  /// for testing purpose
  @visibleForTesting
  Future<void> resetForTesting() async {
    await _streamController.close();
    _instance = ApzUniversalLinking._(); // Reset the singleton
  }
}
