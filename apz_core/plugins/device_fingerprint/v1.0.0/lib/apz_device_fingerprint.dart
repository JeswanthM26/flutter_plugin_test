import "package:apz_device_fingerprint/src/mobile_fingerprint.dart"
    if (dart.library.html) "package:apz_device_fingerprint/src/web_fingerprint.dart";
import "package:apz_device_fingerprint/utils/fingerprint_utils.dart";

/// This class is to fetch the device fingerprint
/// which is a unique identifier for the device.
/// It is used for security purposes and to identify the device.
/// The fingerprint is hashed to ensure privacy.
/// The class uses a MethodChannel to communicate with the native code.
class ApzDeviceFingerprint {
  final FingerprintUtils _fingerprintUtils = FingerprintUtils();

  /// Fetch the device fingerprint
  /// Returns a hashed device fingerprint as a string.
  /// Throws an exception if the operation fails.
  Future<String> getFingerprint() async {
    try {
      final String hashedData = await FingerprintData().getFingerprint(
        _fingerprintUtils,
      );
      return hashedData;
    } on Exception catch (_) {
      rethrow;
    }
  }
}
