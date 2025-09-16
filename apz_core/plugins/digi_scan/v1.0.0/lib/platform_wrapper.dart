import "dart:io";

/// This class provides an interface to determine the platform type
abstract class PlatformWrapper {
  /// Returns true if the platform is Android
  bool get isAndroid;

  /// Returns true if the platform is iOS
  bool get isIOS;
}

/// This class provides a real implementation of the PlatformWrapper
class RealPlatformWrapper implements PlatformWrapper {
  @override
  bool get isAndroid => Platform.isAndroid;
  @override
  bool get isIOS => Platform.isIOS;
}
