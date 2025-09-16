import Flutter
import UIKit
import StoreKit

public class ApzInAppReview: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "com.iexceed/in_app_review", binaryMessenger: registrar.messenger())
    let instance = ApzInAppReview()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "requestReview":
      if #available(iOS 16.0, *) {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                DispatchQueue.main.async {
                    AppStore.requestReview(in: scene)
                }
            }
            result(nil)
        } else if #available(iOS 14.0, *) {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
            result(nil)
        } else {
        result(FlutterError(code: "UNAVAILABLE", message: "iOS version too low", details: nil))
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
