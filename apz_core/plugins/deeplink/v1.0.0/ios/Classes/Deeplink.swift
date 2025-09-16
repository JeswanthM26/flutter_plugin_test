import Flutter
import UIKit

public class Deeplink: NSObject, FlutterPlugin, FlutterStreamHandler {
  var eventSink: FlutterEventSink?
  var initialLink: String?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = Deeplink()

    let methodChannel = FlutterMethodChannel(name: "apz_deeplink/method", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(instance, channel: methodChannel)

    let eventChannel = FlutterEventChannel(name: "apz_deeplink/events", binaryMessenger: registrar.messenger())
    eventChannel.setStreamHandler(instance)

    NotificationCenter.default.addObserver(instance, selector: #selector(instance.handleOpenURL(_:)), name: .init("ApzDeeplinkReceived"), object: nil)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if call.method == "getInitialLink" {
      result(initialLink)
    } else {
      result(FlutterMethodNotImplemented)
    }
  }

  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    eventSink = events
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    eventSink = nil
    return nil
  }

  @objc func handleOpenURL(_ notification: Notification) {
    if let url = notification.object as? URL {
      if initialLink == nil {
        initialLink = url.absoluteString
      }
      eventSink?(url.absoluteString)
    }
  }
}
