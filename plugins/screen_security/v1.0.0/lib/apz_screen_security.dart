import "package:apz_utils/apz_utils.dart";
import "package:flutter/foundation.dart"
    show kIsWeb; // Import kIsWeb for platform detection
import "package:flutter/services.dart"; // For MethodChannel and EventChannel

/// A class that provides methods to manage device screen security features.
class ApzScreenSecurity {
  // Factory constructor to return the same instance
  ///  A factory constructor that returns the singleton
  /// instance of [ApzScreenSecurity].
  factory ApzScreenSecurity() => _instance;
  // --- Singleton Setup ---
  ApzScreenSecurity._(); // Private constructor
  static final ApzScreenSecurity _instance = ApzScreenSecurity._();

  /// The singleton instance of [ApzScreenSecurity].
  
  //the native platform for method calls.
   final MethodChannel _methodChannel = const MethodChannel(
    "apz_screen_security",
  );

    void _throwIfWebUnsupported() {
    if (kIsWeb) {
      throw UnsupportedPlatformException(
        "ApzScreenSecurity has not been implemented for web.",
      );
    }
  }


  /// Enables screen security, preventing screenshots and screen recording.
   Future<bool> enableScreenSecurity() async {
    // Check if the application is running on the web platform
    try {
      _throwIfWebUnsupported();
      // The result from the native side for
      final bool? result = await _methodChannel.invokeMethod<bool>(
        "enableSecure",
      );
      if (result == null) {
        return false;
      }
      return result;
    } on PlatformException {
       rethrow;
    }  catch (e) {
       rethrow;
    }
  }

  /// Calls the native "disableSecure" method.
   Future<bool> disableScreenSecurity() async {
    // Check if the application is running on the web platform
    try {
      _throwIfWebUnsupported();
      // The result from the native side for
      final bool? result = await _methodChannel.invokeMethod<bool>(
        "disableSecure",
      );
      // If the native method returns null, treat it as a failure
      if (result == null) {
        return false;
      }
      return result;
    } on PlatformException {
      rethrow;
    }  catch (e) {
      rethrow;
    }
  }

  /// Checks if screen security is currently enabled.
   Future<bool> isScreenSecureEnabled() async {
    // Check if the application is running on the web platform
    try {
      _throwIfWebUnsupported();
      final bool? isEnabled = await _methodChannel.invokeMethod<bool>(
        "isScreenCaptured",
      );
      // If the native method returns null, treat it as disabled
      if (isEnabled == null) {
        return false;
      }
      return isEnabled;
    } on PlatformException {
      // Handle errors specific to platform calls
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
}
