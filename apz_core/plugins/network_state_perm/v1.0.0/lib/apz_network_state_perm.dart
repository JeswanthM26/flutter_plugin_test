//import "package:apz_network_state/web_network_state.dart";
import "package:apz_network_state_perm/native_wrapper.dart";
import "package:apz_network_state_perm/network_state_model.dart";
import "package:apz_utils/apz_utils.dart";
import "package:flutter/foundation.dart";
import "package:permission_handler/permission_handler.dart";

/// Plugin to fetch network state details from the native platform.
class ApzNetworkStatePerm {
  final NativeWrapper _nativeWrapper = NativeWrapper();

  /// Fetch network state from the native code
  Future<NetworkStateModel?> getNetworkState({
    final String url = "https://www.i-exceed.com/",
  }) async {
    if (kIsWeb) {
      //   final Map<String, dynamic> data = _getWebNetworkInfo();
      //  return NetworkStateModel.fromMap(data);
      final NetworkStateModel infoMap = await _nativeWrapper.getNetworkDetails(
        url,
      );
      return infoMap;
    }

    // 1. Request required permission (Phone only)
    final PermissionStatus phoneStatus = await Permission.phone.request();
    final PermissionStatus phoneLocationStatus = await Permission.location
        .request();

    // 2. Evaluate permission
    _evaluatePermission(phoneStatus, "Phone");
    _evaluatePermission(phoneLocationStatus, "Location");

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

  // Map<String, dynamic> _getWebNetworkInfo() {
  //   final info = navigator.connection;

  //   if (info != null) {
  //     print("Web Network Info:");
  //     print("Connection Type: ${info.effectiveType}");
  //     print("Downlink: ${info.downlink}");
  //     print("RTT: ${info.rtt}");
  //     print("Save Data: ${info.saveData}");

  //     return {
  //       "connectionType": info.effectiveType,
  //       "bandwidthMbps": info.downlink,
  //       "latency": info.rtt,
  //       "saveData": info.saveData,
  //     };
  //   } else {
  //     print("Web Network Info: No network information available.");
  //     return {
  //       "connectionType": "unknown",
  //       "bandwidthMbps": -1,
  //       "latency": -1,
  //       "saveData": false,
  //     };
  //   }
  // }
}
