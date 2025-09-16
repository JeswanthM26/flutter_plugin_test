import Flutter
import UIKit
import CoreBluetooth
import CoreNFC

public class ApzPeripheralsPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "apz_peripherals", binaryMessenger: registrar.messenger())
    let instance = ApzPeripheralsPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "getBatteryLevel":
      let batteryLevel = getBatteryLevel()
      if batteryLevel != -1 {
        result(batteryLevel)
      } else {
        result(FlutterError(code: "UNAVAILABLE", message: "Battery level not available.", details: nil))
      }
    case "isBluetoothSupported":
      result(isBluetoothSupported())
    case "isNFCSupported":
      result(isNFCSupported())
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func getBatteryLevel() -> Int {
    UIDevice.current.isBatteryMonitoringEnabled = true
    let batteryLevel = UIDevice.current.batteryLevel
    if batteryLevel < 0 {
      return -1
    } else {
      return Int(batteryLevel * 100)
    }
  }

  private func isBluetoothSupported() -> Bool {
    let manager = CBCentralManager()
    // CBCentralManagerState.unknown means not determined yet, but if manager is nil, not supported
    // On iOS, all devices since iPhone 4S support Bluetooth LE, so this is a basic check
    return manager.state != .unsupported
  }

  private func isNFCSupported() -> Bool {
    return NFCNDEFReaderSession.readingAvailable
  }
}
