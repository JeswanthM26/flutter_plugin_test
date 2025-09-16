import "package:apz_peripherals/apz_peripherals_method_channel.dart";
import "package:plugin_platform_interface/plugin_platform_interface.dart";

/// The platform interface for the APZ Peripherals plugin.
abstract class ApzPeripheralsPlatform extends PlatformInterface {
  /// Constructs a ApzPeripheralsPlatform.
  ApzPeripheralsPlatform() : super(token: _token);

  static final Object _token = Object();

  static ApzPeripheralsPlatform _instance = MethodChannelApzPeripherals();

  /// The default instance of [ApzPeripheralsPlatform] to use.
  ///
  /// Defaults to [MethodChannelApzPeripherals].
  static ApzPeripheralsPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ApzPeripheralsPlatform] when
  /// they register themselves.
  static set instance(final ApzPeripheralsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Gets the platform version.
  /// Throws an [UnimplementedError] if not implemented.
  /// Returns a [Future] that resolves to a [String] representing
  /// the platform version.
  Future<String?> getPlatformVersion() {
    throw UnimplementedError("platformVersion() has not been implemented.");
  }

  /// Gets the battery level.
  /// Throws an [UnimplementedError] if not implemented.
  /// Returns a [Future] that resolves to an [int] representing
  /// the battery level.
  Future<int?> getBatteryLevel() {
    throw UnimplementedError("batteryLevel() has not been implemented.");
  }

  /// Checks if Bluetooth is supported.
  /// Throws an [UnimplementedError] if not implemented.
  /// Returns a [Future] that resolves to a [bool] indicating
  /// whether Bluetooth is supported.
  Future<bool?> isBluetoothSupported() {
    throw UnimplementedError(
      "isBluetoothSupported() has not been implemented.",
    );
  }

  /// Checks if NFC is supported.
  /// Throws an [UnimplementedError] if not implemented.
  /// Returns a [Future] that resolves to a [bool] indicating
  /// whether NFC is supported.
  Future<bool?> isNFCSupported() {
    throw UnimplementedError("isNFCSupported() has not been implemented.");
  }
}
