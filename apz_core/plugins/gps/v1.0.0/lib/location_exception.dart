/// A custom exception class for handling location-related errors.
/// This exception is thrown when there are issues with
/// obtaining the user's location.
/// It extends the [Exception] class and provides a message detailing the error.
class LocationException implements Exception {
  /// Creates a [LocationException] with the given error [message].
  LocationException(this.message);

  /// The error message associated with this exception.
  final String message;

  @override
  String toString() => message;
}
