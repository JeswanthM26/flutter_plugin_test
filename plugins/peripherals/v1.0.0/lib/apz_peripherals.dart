
import "package:apz_peripherals/apz_peripherals_platform_interface.dart";

/// The main entry point for the APZ Peripherals plugin.
class APZPeripherals {

  /// Gets the platform version.
  Future<String?> getPlatformVersion() => 
    ApzPeripheralsPlatform.instance.getPlatformVersion();

  /// Gets the battery level.
  /// Throws an exception if called on web platform.
  Future<int?> getBatteryLevel() => 
    ApzPeripheralsPlatform.instance.getBatteryLevel();

  /// Checks if Bluetooth is supported.
  /// Throws an exception if called on web platform.
  Future<bool?> isBluetoothSupported() => 
    ApzPeripheralsPlatform.instance.isBluetoothSupported();

  /// Checks if NFC is supported.
  /// Throws an exception if called on web platform.
  Future<bool?> isNFCSupported() => 
    ApzPeripheralsPlatform.instance.isNFCSupported();
}
