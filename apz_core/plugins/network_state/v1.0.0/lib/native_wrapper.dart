import "dart:async";
import "package:apz_network_state/network_state_model.dart";
import "package:flutter/services.dart";

//// Wrapper class to interact with native platform code for network details.
class NativeWrapper {
  static const MethodChannel _channel = MethodChannel("network_info_plugin");

  /// Fetch network details from the native platform.
  Future<NetworkStateModel> getNetworkDetails(final String url) async {
    final Map<String, String> inputData = <String, String>{"url": url};
    final Map<Object?, Object?>? result = await _channel
        .invokeMethod<Map<Object?, Object?>>("getNetworkDetails", inputData);
    final Map<Object?, Object?> map = Map<Object?, Object?>.from(
      result ?? <Object?, Object?>{},
    );
    return NetworkStateModel.fromMap(map);
  }
}
