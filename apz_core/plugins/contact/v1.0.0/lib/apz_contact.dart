import "package:apz_contact/contacts_model.dart";
import "package:apz_contact/native_wrapper.dart";
import "package:apz_utils/apz_utils.dart";
import "package:flutter/foundation.dart";
import "package:permission_handler/permission_handler.dart";

/// This class is a singleton that fetches contacts from the device.
class ApzContact {
  NativeWrapperContacts _nativeWrapper = NativeWrapperContacts();
  PermissionService _permissionService = PermissionService();

  @visibleForTesting
  /// Set NativeWrapper and PermissionService for testing purposes.
  // ignore: use_setters_to_change_properties
  void setNativeWrapper(final NativeWrapperContacts nativeWrapper) {
    _nativeWrapper = nativeWrapper;
  }

  @visibleForTesting
  /// Set NativeWrapper and PermissionService for testing purposes.
  // ignore: use_setters_to_change_properties
  void setPermissionService(final PermissionService permissionService) {
    _permissionService = permissionService;
  }

  /// Load contacts only if permission granted, else return error.
  Future<ContactsModel> loadContacts({
    final bool? fetchEmail,
    final bool? fetchPhoto,
    final String? searchQuery,
  }) async {
    if (kIsWeb) {
      throw UnsupportedPlatformException(
        "Contacts plugin is not supported on Web.",
      );
    }

    final PermissionStatus status = await _permissionService
        .requestContactsPermission();
    _evaluatePermission(status, "Contacts");

    final ContactsModel contacts = await _fetchContacts(
      fetchEmail,
      fetchPhoto,
      searchQuery,
    );
    return contacts;
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
          """$label permission permanently denied. Please enable it from settings.""",
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

  /// Fetch contacts from the native code.
  Future<ContactsModel> _fetchContacts(
    final bool? fetchEmail,
    final bool? fetchPhoto,
    final String? searchQuery,
  ) async {
    final List<Map<String, dynamic>> infoMap = await _nativeWrapper.getContacts(
      fetchEmail: fetchEmail,
      fetchPhoto: fetchPhoto,
      searchQuery: searchQuery,
    );
    return ContactsModel.fromJson(infoMap);
  }
}

/// This class is responsible for managing permissions.
class PermissionService {
  /// Request contacts permission.
  Future<PermissionStatus> requestContactsPermission() =>
      Permission.contacts.request();
}
