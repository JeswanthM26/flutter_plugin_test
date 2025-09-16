import "dart:io";
import "package:apz_utils/apz_utils.dart";
import "package:flutter/foundation.dart";
import "package:flutter/services.dart";

/// Platform abstraction for testability
abstract class ApzPlatform {
  /// Whether the current platform is Android
  bool get isAndroid;

  /// Whether the current platform is Web
  bool get isWeb;
}

/// Default platform implementation using dart:io and kIsWeb
class DefaultApzPlatform implements ApzPlatform {
  @override
  bool get isAndroid => Platform.isAndroid;
  @override
  bool get isWeb => kIsWeb;
}

/// This class provides methods to prepare and request integrity tokens
/// from the Play Integrity API, which helps protect your app
/// from various types of abuse, such as fraud and unauthorized access.
class ApzPlayIntegrity {
  /// Private constructor for singleton pattern
  factory ApzPlayIntegrity({final ApzPlatform? platform}) {
    if (platform != null) {
      _instance._platform = platform;
    }
    return _instance;
  }

  ApzPlayIntegrity._();

  static final ApzPlayIntegrity _instance = ApzPlayIntegrity._();

  static const MethodChannel _channel = MethodChannel("play_integrity_plugin");
  ApzPlatform _platform = DefaultApzPlatform();

  /// Prepares the Standard Play Integrity API, which is a required step
  /// before requesting a Standard token.
  /// The `cloudProjectNumber` is the numeric project ID
  /// from the Google Cloud Console.
  /// This method returns `true`
  /// if the token provider was successfully initialized.
  Future<bool> prepareStandardIntegrityToken({
    required final String cloudProjectNumber,
  }) async {
    _checkPlatform();

    if (cloudProjectNumber.isEmpty) {
      handlePlatformException("EMPTY_CLOUD_PROJECT_NUMBER", null);
    }

    try {
      final bool tokenInitialised =
          (await _channel.invokeMethod<bool>(
            "prepareStandardIntegrityToken",
            <String, String>{"cloudProjectNumber": cloudProjectNumber},
          )) ??
          false;
      return tokenInitialised;
    } on PlatformException catch (e) {
      throw handlePlatformException(e.code, e.message);
    } on Exception catch (_) {
      rethrow;
    }
  }

  /// Requests a Standard integrity token from the Play Integrity API.
  /// This check is for low-value actions and uses an optional `requestHash`.
  /// The `requestHash` is a base64-encoded SHA-256 hash of up to 500 bytes.
  /// If not provided, an empty string will be used.
  /// The `requestHash` is used to bind the integrity token
  /// to a specific request.
  Future<String> requestStandardIntegrityToken({
    final String? requestHash,
  }) async {
    _checkPlatform();

    try {
      final String? token = await _channel.invokeMethod<String>(
        "requestStandardIntegrityToken",
        <String, String>{"requestHash": requestHash ?? ""},
      );
      return token ?? "";
    } on PlatformException catch (e) {
      throw handlePlatformException(e.code, e.message);
    } on Exception catch (_) {
      rethrow;
    }
  }

  /// Requests a Classic integrity token from the Play Integrity API.
  /// This check is for high-value actions and uses a `nonce`.
  /// The `nonce` is a base64-encoded, non-wrapping, URL-safe and SHA-256
  /// hash of data with minimum of 16 characters and maximum of 500 characters.
  /// The `cloudProjectNumber` is the numeric project ID
  /// from the Google Cloud Console.
  /// The `nonce` is used to bind the integrity token
  /// to a specific request.
  /// This method returns the integrity token as a `String`.
  Future<String> requestClassicIntegrityToken({
    required final String nonce,
    required final String cloudProjectNumber,
  }) async {
    _checkPlatform();

    if (nonce.isEmpty) {
      handlePlatformException("EMPTY_NONCE", null);
    } else if (cloudProjectNumber.isEmpty) {
      handlePlatformException("EMPTY_CLOUD_PROJECT_NUMBER", null);
    }

    try {
      final String? token = await _channel.invokeMethod<String>(
        "requestClassicIntegrityToken",
        <String, String>{
          "nonce": nonce,
          "cloudProjectNumber": cloudProjectNumber,
        },
      );
      return token ?? "";
    } on PlatformException catch (e) {
      throw handlePlatformException(e.code, e.message);
    } on Exception catch (_) {
      rethrow;
    }
  }

  void _checkPlatform() {
    if (_platform.isWeb || (!_platform.isWeb && !_platform.isAndroid)) {
      throw UnsupportedPlatformException(
        "Play Integrity is only supported on Android.",
      );
    }
  }

  /// Handles platform exceptions and throws appropriate errors
  Exception handlePlatformException(final String code, final String? message) {
    final String errorMessage = message ?? "";

    if (code == "INVALID_CLOUD_PROJECT_NUMBER") {
      return Exception(errorMessage);
    } else if (code == "CLASSIC_PLAY_INTEGRITY_ERROR") {
      return Exception("Classic Integrity API error: $errorMessage");
    } else if (code == "STANDARD_PLAY_INTEGRITY_ERROR") {
      return Exception("Standard Integrity API error: $errorMessage");
    } else if (code == "TOKEN_PROVIDER_NOT_INITIALISED") {
      return Exception("Standard Integrity API error: $errorMessage");
    } else if (code == "EMPTY_NONCE") {
      return Exception("Nonce can't be empty");
    } else if (code == "EMPTY_CLOUD_PROJECT_NUMBER") {
      return Exception("Cloud project number can't be empty");
    } else {
      return Exception("Something Went Wrong");
    }
  }

  /// Public getter for platform (for testing)
  @visibleForTesting
  ApzPlatform get platform => _platform;
}
