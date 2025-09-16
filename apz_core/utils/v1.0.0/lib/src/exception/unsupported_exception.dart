/// Thrown when the current platform is not supported.
class UnsupportedPlatformException implements Exception {
  /// Creates an [UnsupportedPlatformException] with a specific message.
  UnsupportedPlatformException(this.message);

  /// The message describing the unsupported platform exception.
  final String message;

  @override
  String toString() => "UnsupportedPlatformException: $message";
}
