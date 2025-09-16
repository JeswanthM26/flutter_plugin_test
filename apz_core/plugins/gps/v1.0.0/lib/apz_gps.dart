import "package:apz_gps/location_exception.dart";
import "package:apz_gps/location_model.dart";
import "package:apz_utils/apz_utils.dart";
import "package:geolocator/geolocator.dart";
import "package:permission_handler/permission_handler.dart";

/// A class to handle GPS functionalities,
/// including fetching the current location.
/// It checks for location permissions and
/// services before attempting to retrieve the location.
class ApzGPS {
  /// Retrieves the current location of the device.
  /// Throws a [PermissionException] if location permissions are not granted.
  /// Throws a [LocationException] if location services are disabled or
  /// if there is an error while fetching the location.
  Future<LocationModel> getCurrentLocation() async {
    /// Check if the Geolocator is initialized
    await _checkLocationPermissions();

    /// Check if location services are enabled
    await _checkLocationServices();

    try {
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return LocationModel(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        altitude: position.altitude,
        speed: position.speed,
        timestamp: position.timestamp,
      );
    } catch (e) {
      throw LocationException("Failed to get location: $e");
    }
  }

  /// Checks and requests location permissions.
  Future<void> _checkLocationPermissions() async {
    final PermissionStatus status = await Permission.location.request();
    _evaluatePermission(status, "Location");
  }

  /// Checks if location services are enabled.
  Future<void> _checkLocationServices() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationException(
        "Location services are disabled. Please enable them in settings.",
      );
    }
  }

  /// Evaluates the permission status and
  /// throws an exception if the permission is not granted.
  /// [status] - The status of the permission.
  /// [label] - A label for the permission, used in the exception message.
  /// Throws a [PermissionException] if the permission is denied or restricted.
  /// [PermissionsExceptionStatus] - The status of the permission exception.
  void _evaluatePermission(final PermissionStatus status, final String label) {
    switch (status) {
      case PermissionStatus.granted:
        return;
      case PermissionStatus.denied:
        throw PermissionException(
          PermissionsExceptionStatus.denied,
          "$label permission not granted.",
        );
      case PermissionStatus.permanentlyDenied:
        throw PermissionException(
          PermissionsExceptionStatus.permanentlyDenied,
          """$label permission permanently denied. Please enable it from settings.""",
        );
      case PermissionStatus.limited:
      case PermissionStatus.provisional:
      case PermissionStatus.restricted:
        throw PermissionException(
          PermissionsExceptionStatus.restricted,
          "$label access restricted or not fully granted.",
        );
    }
  }
}
