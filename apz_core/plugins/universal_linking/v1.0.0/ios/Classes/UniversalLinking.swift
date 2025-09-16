import Flutter
import UIKit

public class UniversalLinking: NSObject, FlutterPlugin {
  public static var channel: FlutterMethodChannel?
  public static var initialLink: String?

 public  func handleIncomingLink(_ link: String) {
  UniversalLinking.initialLink = link 
  if let url = URL(string: link) {
     var queryParams = [String: String]()
      if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
         let queryItems = components.queryItems {
        for item in queryItems {
          queryParams[item.name] = item.value ?? ""
        }
      }
    let linkData: [String: Any] = [
      "host": url.host ?? "",
      "path": url.path,
      "scheme": url.scheme ?? "",
      "fullUrl": url.absoluteString,
      "queryParams": queryParams
    ]
    UniversalLinking.channel?.invokeMethod("onLinkReceived", arguments: linkData)
  }
}


  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = UniversalLinking()
    channel = FlutterMethodChannel(name: "apz_universal_linking", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(instance, channel: channel!)

    NotificationCenter.default.addObserver(
    forName: NSNotification.Name("ApzUniversalLinkReceived"),  // match the name your AppDelegate posts
    object: nil,
    queue: .main
  ) { notification in
    if let url = notification.object as? URL {
      instance.handleIncomingLink(url.absoluteString)
    }
  }
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
  if call.method == "getInitialLink" {
    if let link = UniversalLinking.initialLink,
       let url = URL(string: link) {
        var queryParams = [String: String]()
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let queryItems = components.queryItems {
          for item in queryItems {
            queryParams[item.name] = item.value ?? ""
          }
        }
      result([
        "host": url.host ?? "",
        "path": url.path,
        "scheme": url.scheme ?? "",
        "fullUrl": url.absoluteString,
        "queryParams": queryParams
      ])
    } else {
      result(nil)
    }
  } else {
    result(FlutterMethodNotImplemented)
  }
}

}
