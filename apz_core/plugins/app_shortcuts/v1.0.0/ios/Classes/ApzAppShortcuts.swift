import Flutter
import UIKit

public class ApzAppShortcuts: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "com.iexceed/apz_app_shortcuts",
                                       binaryMessenger: registrar.messenger())
    let instance = ApzAppShortcuts()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if call.method == "setShortcutItems", let args = call.arguments as? [[String: Any]] {
      var shortcuts: [UIApplicationShortcutItem] = []

      for item in args {
        let id = item["id"] as! String
        let title = item["title"] as! String
        let iconName = item["icon"] as? String

        let icon = iconName != nil ? UIApplicationShortcutIcon(templateImageName: iconName!) : nil
        let shortcut = UIApplicationShortcutItem(type: id, localizedTitle: title,localizedSubtitle: nil, icon: icon, userInfo: nil)
        shortcuts.append(shortcut)
      }

      UIApplication.shared.shortcutItems = shortcuts
      result(nil)
    } else if call.method == "clearShortcutItems" {
      UIApplication.shared.shortcutItems = []
      result(nil)
    } else {
      result(FlutterMethodNotImplemented)
    }
  }
}