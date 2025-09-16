import "package:apz_utils/apz_utils.dart";
import "package:flutter/foundation.dart";
import "package:permission_handler/permission_handler.dart";

/// Test wrapper around Permission.camera.request so tests can override it.
@visibleForTesting
Future<PermissionStatus> Function() cameraPermissionRequest = () =>
    Permission.camera.request();

/// Handles camera permission requests
class CameraPermissionHandler {
  /// Checks and requests camera permissions
  Future<void> checkCameraPermissions() async {
    try {
      if (kIsWeb) {
        throw UnsupportedPlatformException(
          "This plugin is not supported on the web platform",
        );
      } else {
        final PermissionStatus cameraStatus = await cameraPermissionRequest();
        evaluatePermission(cameraStatus, "Camera");
      }
    } on PermissionException {
      rethrow;
    }
  }

  /// Evaluates the permission status and throws exceptions if non-granted
  void evaluatePermission(final PermissionStatus status, final String label) {
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
          "$label permission permanently denied. "
          "Please enable it from settings.",
        );
      case PermissionStatus.restricted:
        throw PermissionException(
          PermissionsExceptionStatus.restricted,
          "$label access restricted or not fully granted. "
          "Please check your device settings.",
        );
      case PermissionStatus.limited:
        throw PermissionException(
          PermissionsExceptionStatus.limited,
          "$label access restricted or not fully granted. "
          "Please check your device settings.",
        );
      case PermissionStatus.provisional:
        throw PermissionException(
          PermissionsExceptionStatus.provisional,
          "$label access restricted or not fully granted. "
          "Please check your device settings.",
        );
    }
  }
}
