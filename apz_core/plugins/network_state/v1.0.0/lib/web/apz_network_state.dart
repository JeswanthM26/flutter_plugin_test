import "dart:js_interop";
import "package:flutter/services.dart";
import "package:flutter_web_plugins/flutter_web_plugins.dart";

@JS("navigator.connection")
/// Represents the connection property of the Navigator interface.
external NetworkInformation? get networkInformation;

@JS()
@staticInterop
/// Represents the NetworkInformation interface,
///  providing details about the network connection.
class NetworkInformation {}

/// Extension to access properties of the NetworkInformation interface.
extension NetworkInformationExt on NetworkInformation {
  /// The effective type of the connection (e.g., 'wifi', 'cellular').
  external String get effectiveType;

  /// The estimated downlink speed in megabits per second.
  external num get downlink;

  /// The estimated round-trip time in milliseconds.
  external num get rtt;

  /// Indicates whether the user has enabled data saving mode.
  external bool get saveData;
}

/// A web implementation of the network state plugin.
class ApzNetworkState {
  /// The method channel used to communicate with the native platform.
  //MethodChannel? channel;

  /// Registers the plugin with the given registrar.
  // Make this method static

  void clearCache() {}

  /// Registers the plugin with the given registrar.
  static void registerWith(final Registrar registrar) {
    final MethodChannel _ =
        MethodChannel(
            "network_info_plugin",
            const StandardMethodCodec(),
            registrar,
          )
          /// Set the channel name to match the one used in the native code.
          ..setMethodCallHandler((final MethodCall call) async {
            if (call.method == "getNetworkDetails") {
              final NetworkInformation? info = networkInformation;
              if (info == null) {
                return <String, Object>{
                  "connectionType": "unknown",
                  "bandwidthMbps": -1,
                  "latency": -1,
                  "saveData": false,
                };
              }

              return <String, Object>{
                "connectionType": info.effectiveType,
                "bandwidthMbps": info.downlink,
                "latency": info.rtt,
                "saveData": info.saveData,
              };
            } else {
              throw PlatformException(
                code: "Unimplemented",
                details: "Method ${call.method} not implemented on web.",
              );
            }
          });
  }
}
