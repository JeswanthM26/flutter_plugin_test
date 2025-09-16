import "package:apz_utils/apz_utils.dart";
import "package:flutter/foundation.dart";
import "package:flutter/services.dart";

/// A plugin to request in-app reviews on both Android and iOS platforms.
class ApzInAppReview {
  /// Returns true if the current platform is web.
  bool getIsWeb() => kIsWeb;
  static const MethodChannel _channel = MethodChannel(
    "com.iexceed/in_app_review",
  );

  /// Requests an in-app review from the user.
  Future<void> requestReview() async {
    if (getIsWeb()) {
      throw UnsupportedPlatformException(
        "This plugin is not supported on the web platform",
      );
    }
    try {
      await _channel.invokeMethod("requestReview");
    } on Exception {
      rethrow;
    }
  }
}
