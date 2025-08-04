
/// A custom exception class for handling location-related errors.
/// This exception is thrown when there are issues with obtaining the user's location.
/// It extends the [Exception] class and provides a message detailing the error.
class LocationException implements Exception {
  final String message;

  LocationException(this.message);

  @override
  String toString() => message;
}
