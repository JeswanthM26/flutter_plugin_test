import "package:apz_peripherals/apz_peripherals_platform_interface.dart";
import "package:flutter/foundation.dart";
import "package:flutter/services.dart";

/// An implementation of [ApzPeripheralsPlatform] that uses method channels.
class MethodChannelApzPeripherals extends ApzPeripheralsPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final MethodChannel methodChannel = const MethodChannel("apz_peripherals");

  @override
  Future<String?> getPlatformVersion() async {
    final String? version = 
      await methodChannel.invokeMethod<String>("getPlatformVersion");
    return version;
  }

  @override
  Future<int?> getBatteryLevel() async {
    if(kIsWeb) {
      throw Exception("Battery level not available on web platform");
    }
    final int? batteryLevel = 
      await methodChannel.invokeMethod<int>("getBatteryLevel");
    return batteryLevel;
  }

  @override
  Future<bool?> isBluetoothSupported() async {
    if(kIsWeb) {
      throw Exception("Bluetooth support not available on web platform");
    }
    final bool? isBluetoothSupported = 
      await methodChannel.invokeMethod<bool>("isBluetoothSupported");
    return isBluetoothSupported;
  }

  @override
  Future<bool?> isNFCSupported() async {
    if(kIsWeb) {
      throw Exception("NFC support not available on web platform");
    }
    final bool? isNFCSupported = 
      await methodChannel.invokeMethod<bool>("isNFCSupported");
    return isNFCSupported;
  }
}
