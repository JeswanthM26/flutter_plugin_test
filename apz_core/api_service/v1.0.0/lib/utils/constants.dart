import "package:apz_crypto/apz_crypto.dart";

/// Constants for the app
class Constants {
  /// Request Success Codes
  static const int requestSuccessCode = 200;

  /// Request Common Error Codes
  static const int requestCommonErrorCode = -1;

  /// Request Common Error Message
  static const String requestCommonErrorMessage = "Something went wrong";

  /// Invalid Server URL Error Codes
  static const int invalidServerUrlErrorCode = 600;

  /// Invalid Server URL Error Message
  static const String invalidServerUrlErrorMessage = "Invalid server url";

  /// Request Timed Out Error Codes
  static const int requestTimedOutErrorCode = 601;

  /// Request Timed Out Error Message
  static const String requestTimedOutErrorMessage = "Request timed out";

  /// No Internet Connection Error Codes
  static const int noInternetConnectionErrorCode = 602;

  /// No Internet Connection Error Message
  static const String noInternetConnectionErrorMessage =
      "No internet Connection";

  /// Response Failed Error Codes
  static const int responseFailedErrorCode = 0;

  /// Response Failed Error Message
  static const String responseFailedErrorMessage = "Response failed";

  /// Salt length in bytes
  static const int saltLength = 16;

  /// Symmetric key length in bytes
  static const int symmetricKeyLength = 32;

  /// Hashed symmetric key output length in bytes
  static const int hashedSymmetricKeyOutputLength = 32;

  /// Initialization vector length in bytes
  static const int ivLength = 12;

  /// Symmetric key hashing iteration count
  static const int symmetricKeyHashingIterationCount = 10000;

  /// Symmetric key hashing type
  static const HashType symmetricKeyHashingType = HashType.sha512;

  /// Asymmetric key algorithm
  static const String algo = "6";
}
