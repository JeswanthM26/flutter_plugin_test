import "dart:async";
import "package:apz_contact_picker/native_wrapper.dart";
import "package:apz_contact_picker/picked_contact_model.dart";
import "package:apz_utils/apz_utils.dart";
import "package:flutter/foundation.dart";
import "package:permission_handler/permission_handler.dart";

/// This class is a singleton that fetches contacts from the device.
class ApzContactPicker {

  final NativeWrapper _nativeWrapper = NativeWrapper();

  /// Fetch contacts from the native code
  Future<PickedContact?> pickContacts() async {
    if (kIsWeb) {
      throw UnsupportedPlatformException(
        "Contacts plugin is not supported on Web.",
      );
    }
     // 1. Request Contact Permission
    final PermissionStatus status = await Permission.contacts.request();
      _evaluatePermission(status, "Contacts");
    
    final PickedContact? infoMap = await _nativeWrapper.pickContact();
    return infoMap;
  }
  
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
