/// Custom exception class for handling permission-related errors.
class PermissionException implements Exception {
  /// Creates a [PermissionException] with a specific status and message.
  PermissionException(this.status, this.message);

  /// The message describing the permission exception.
  final String message;

  /// Status of the permission exception.
  final PermissionsExceptionStatus status;

  @override
  String toString() => "PermissionException: $message ($status)";
}

/// Enum representing different statuses of permission exceptions.
enum PermissionsExceptionStatus {
  /// The permission is denied.
  denied,

  /// The permission is permanently denied.
  permanentlyDenied,

  /// The permission is restricted.
  restricted,

  /// The permission is limited.
  limited,

  /// The permission is provisional.
  provisional,
}
