import Flutter
import UIKit 

public class ApzScreenSecurity: NSObject, FlutterPlugin {
  private var channel: FlutterMethodChannel?
  private var secureOverlayTextField: UITextField?
  private var isSecureScreenActive: Bool = false
  private var keyWindow: UIWindow? {
    return UIApplication.shared.delegate?.window as? UIWindow
  }
  /// Registers the plugin with the Flutter engine.
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "apz_screen_security", binaryMessenger: registrar.messenger())
    // Create an instance of the plugin.
    let instance = ApzScreenSecurity()
    // Store the channel reference to be used in handle method.
    instance.channel = channel
    // Set this instance as the delegate for handling method calls from Flutter.
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  /// Handles method calls from the Flutter side.
  /// This method is invoked when `channel.invokeMethod` is called from Dart.
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "enableSecure":
      self.enableSecure(result: result)
    case "disableSecure":
      self.disableSecure(result: result)
    case "isScreenCaptured":
      result(isSecureScreenActive)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func enableSecure(result: @escaping FlutterResult) {
    if let window = keyWindow {
        if isSecureScreenActive && secureOverlayTextField != nil {
            result(true)
            return
        }

        secureOverlayTextField = UITextField()

        window.addSubview(secureOverlayTextField!)
        secureOverlayTextField?.centerYAnchor.constraint(equalTo: window.centerYAnchor).isActive = true
        secureOverlayTextField?.centerXAnchor.constraint(equalTo: window.centerXAnchor).isActive = true
        window.layer.superlayer?.addSublayer(secureOverlayTextField!.layer)
        if #available(iOS 17.0, *) {
          secureOverlayTextField?.layer.sublayers?.last?.addSublayer(window.layer)
        } else {
          secureOverlayTextField?.layer.sublayers?.first?.addSublayer(window.layer)
        }

        secureOverlayTextField?.isSecureTextEntry = true

        isSecureScreenActive = true
        result(true)
      } else {
        // If no key window could be found, return an error to Flutter.
        result(FlutterError(code: "NO_WINDOW", message: "Could not find a key window to apply screen security.", details: nil))
      }
  }

  private func disableSecure(result: @escaping FlutterResult) {

    secureOverlayTextField?.isSecureTextEntry = false
    isSecureScreenActive = false
    result(true)
  }
}
