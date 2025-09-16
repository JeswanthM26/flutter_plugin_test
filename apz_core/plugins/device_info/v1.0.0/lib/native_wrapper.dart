import "package:flutter/services.dart";

/// A wrapper class to interact with native platform code for
/// device information.
class NativeWrapper {
  static const MethodChannel _channel = MethodChannel(
    "com.iexceed/device_info",
  );

  /// Fetches device information from the native platform.
  Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      final dynamic result = await _channel.invokeMethod("getDeviceInfo");
      return (result as Map<Object?, Object?>).cast<String, dynamic>();
    } on Exception catch (_) {
      return <String, dynamic>{};
    }
  }
}
