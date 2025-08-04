import "package:flutter/services.dart";

/// It uses a platform channel to communicate with the native code.
class DeviceVersionInfo {
  static const MethodChannel _channel = MethodChannel(
    "com.iexceed/device_version",
  );

  /// used to get the device version information
  Future<int?> getSdkInt() async {
    try {
      final int sdkInt = await _channel.invokeMethod("getSdkInt");
      return sdkInt;
    } on PlatformException {
      return null;
    }
  }
}
