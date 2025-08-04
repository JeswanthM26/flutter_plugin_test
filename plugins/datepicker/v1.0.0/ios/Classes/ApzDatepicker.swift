import Flutter
import UIKit

public class ApzDatepicker: NSObject, FlutterPlugin {
    
    var result: FlutterResult?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "com.iexceed/date_picker", binaryMessenger: registrar.messenger())
        let instance = ApzDatepicker()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "showDatePicker" {
            self.result = result
            showDatePicker(arguments: call.arguments as? [String: Any])
        } else {
            result(FlutterMethodNotImplemented)
        }
    }

    private func showDatePicker(arguments: [String: Any]?) {

        guard let rootVC = UIApplication.shared.keyWindow?.rootViewController else {
            result?(FlutterError(code: "NO_ROOT_VC", message: "No root view controller", details: nil))
            return
        }

        let title = arguments?["title"] as? String ?? "Select Date"
        let cancelText = arguments?["cancelText"] as? String ?? "Cancel"
        let doneText = arguments?["doneText"] as? String ?? "Done"
        // Parse colors from ARGB Int to UIColor
        let primaryColor = (arguments?["primaryColor"] as? Int).flatMap { UIColor(argb: UInt32($0)) } ?? UIColor.orange
        let errorColor = (arguments?["errorColor"] as? Int).flatMap { UIColor(argb: UInt32($0)) } ?? UIColor.red
        let languageCode = arguments?["languageCode"] as? String ?? "en"

        let locale = Locale(identifier: languageCode)

        let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)

        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .inline
        picker.tintColor = primaryColor
        picker.locale = locale

        if let initial = arguments?["initialDate"] as? Int {
            picker.date = Date(timeIntervalSince1970: TimeInterval(initial / 1000))
        }
        if let min = arguments?["minDate"] as? Int {
            picker.minimumDate = Date(timeIntervalSince1970: TimeInterval(min / 1000))
        }
        if let max = arguments?["maxDate"] as? Int {
            picker.maximumDate = Date(timeIntervalSince1970: TimeInterval(max / 1000))
        }

        let pickerVC = UIViewController()
        pickerVC.view = picker
        
        alert.setValue(pickerVC, forKey: "contentViewController")

        let cancelBtn = UIAlertAction(title: cancelText, style: .cancel) { _ in
            self.result?(nil)
        }
        cancelBtn.setValue(errorColor, forKey: "titleTextColor")
        alert.addAction(cancelBtn)

        let doneBtn = UIAlertAction(title: doneText, style: .default) { _ in
            let dateFormat = (arguments?["dateFormat"] as? String) ?? "yyyy-MM-dd"
            let formatter = DateFormatter()
            formatter.dateFormat = dateFormat
            formatter.locale = Locale(identifier: "en_US_POSIX")
            let formattedDate = formatter.string(from: picker.date)
            self.result?(formattedDate)
        }
        doneBtn.setValue(primaryColor, forKey: "titleTextColor")
        alert.addAction(doneBtn)

        rootVC.present(alert, animated: true, completion: nil)
    }
}
private extension UIColor {
    convenience init(argb: UInt32) {
        let alpha = CGFloat((argb >> 24) & 0xFF) / 255.0
        let red   = CGFloat((argb >> 16) & 0xFF) / 255.0
        let green = CGFloat((argb >> 8) & 0xFF) / 255.0
        let blue  = CGFloat(argb & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
