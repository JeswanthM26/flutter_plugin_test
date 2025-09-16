import "package:apz_biometric/apz_auth_result.dart";
import "package:apz_utils/apz_utils.dart";
import "package:flutter/foundation.dart";
import "package:flutter/services.dart";
import "package:local_auth/local_auth.dart";
import "package:local_auth_android/local_auth_android.dart";
import "package:local_auth_darwin/local_auth_darwin.dart";

/// ApzBiometric class, used to handle biometric authentication
class ApzBiometric {
  /// Added constructor to allow dependency injection for testing
  ApzBiometric({final LocalAuthentication? auth})
    : _auth = auth ?? LocalAuthentication();
  final LocalAuthentication _auth;

  /// Check if the device supports biometric authentication
  Future<bool> isBiometricSupported() async {
    if (kIsWeb) {
      throw UnsupportedPlatformException(
        "This plugin is not supported on the web platform",
      );
    } else {
      final bool isBiometricSupported = await _auth.isDeviceSupported();
      return isBiometricSupported;
    }
  }

  /// check biometric types supported by the device
  Future<List<BiometricType>> fetchAvailableBiometrics() async {
    if (kIsWeb) {
      throw UnsupportedPlatformException(
        "This plugin is not supported on the web platform",
      );
    } else {
      final List<BiometricType> biometrics = await _auth
          .getAvailableBiometrics();
      return biometrics;
    }
  }

  /// authenticate method, used to authenticate the user
  Future<AuthResult> authenticate({
    required final String reason,
    required final bool stickyAuth,
    required final bool biometricOnly,
    final AndroidAuthMessages? androidAuthMessage,
    final IOSAuthMessages? iosAuthMessage,
  }) async {
    if (kIsWeb) {
      throw UnsupportedPlatformException(
        "This plugin is not supported on the web platform",
      );
    } else {
      try {
        final List<AuthMessages> authMessages = <AuthMessages>[];
        if (androidAuthMessage != null) {
          authMessages.add(androidAuthMessage);
        }
        if (iosAuthMessage != null) {
          authMessages.add(iosAuthMessage);
        }

        final bool isAuthenticated = await _auth.authenticate(
          localizedReason: reason,
          authMessages: authMessages,
          options: AuthenticationOptions(
            stickyAuth: stickyAuth,
            biometricOnly: biometricOnly,
          ),
        );
        return AuthResult(
          status: isAuthenticated,
          message: isAuthenticated
              ? "Authentication successful"
              : "Authentication canceled by user",
        );
      } on PlatformException catch (e) {
        return AuthResult(status: false, message: "Error: ${e.message}");
      }
    }
  }
}
