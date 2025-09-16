import "package:apz_network_state/native_wrapper.dart";
import "package:apz_network_state/network_state_model.dart";
import "package:apz_utils/apz_utils.dart";
import "package:flutter/foundation.dart";
import "package:permission_handler/permission_handler.dart";



/// Plugin to fetch network state details from the native platform.
class ApzNetworkState {
  final NativeWrapper _nativeWrapper = NativeWrapper();

  /// Fetch network state from the native code
  Future<NetworkStateModel?> getNetworkState({
    final String url = "https://www.i-exceed.com/",
  }) async {
    if (kIsWeb) {
    final NetworkStateModel infoMap = await _nativeWrapper.getNetworkDetails(
      url,
    );
      return infoMap;
    }

     final PermissionStatus phoneStatus = await Permission.location.request();

    // 2. Evaluate permission
    _evaluatePermission(phoneStatus, "Location");

    // 3. Fetch native network details
    final NetworkStateModel infoMap = await _nativeWrapper.getNetworkDetails(
      url,
    );
    return infoMap;
  }

  void _evaluatePermission(final PermissionStatus? status, final String label) {
    if (status == null) {
      return;
    }

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
      case PermissionStatus.limited:
      case PermissionStatus.provisional:
        throw PermissionException(
          PermissionsExceptionStatus.restricted,
          "$label access restricted or not fully granted. "
          "Please check your device settings.",
        );
    }
  }
  
}
