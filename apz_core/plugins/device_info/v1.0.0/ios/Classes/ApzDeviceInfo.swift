import Flutter
import UIKit

public class ApzDeviceInfo: NSObject, FlutterPlugin {
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "com.iexceed/device_info", binaryMessenger: registrar.messenger())
        let instance = ApzDeviceInfo()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "getDeviceInfo" {
            let device = UIDevice.current
            
            // Determine if running on a physical device (false if simulator)
            let isPhysicalDevice: Bool = {
                #if targetEnvironment(simulator)
                return false
                #else
                return true
                #endif
            }()
            
            let info: [String: Any] = [
                "board": "",
                "bootloader": "",
                "brand": "Apple",
                "deviceName": device.name,
                "display": "",
                "fingerprint": "",
                "hardware": "",
                "host": "",
                "id": "",
                "manufacturer": "Apple",
                "model": device.model,
                "product": device.localizedModel,
                "name": device.name,
                "tags": "",
                "type": device.systemName,
                "isIosAppOnMac": ProcessInfo.processInfo.isiOSAppOnMac,
                "isPhysicalDevice": isPhysicalDevice,
                "identifierForVendor": device.identifierForVendor?.uuidString ?? "",
                "version": [
                    "baseOS": "",
                    "previewSdkInt": 0,
                    "securityPatch": "",
                    "codename": "",
                    "incremental": "",
                    "release": device.systemVersion,
                    "sdkInt": 0
                ]
            ]
            result(info)
        } else {
            result(FlutterMethodNotImplemented)
        }
    }
}