import Flutter
import MessageUI
import UIKit

public class ApzSendSMS: NSObject, FlutterPlugin, MFMessageComposeViewControllerDelegate {
    var flutterResult: FlutterResult?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "com.iexceed/apz_send_sms", binaryMessenger: registrar.messenger())
        let instance = ApzSendSMS()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "sendSMS":
            guard let args = call.arguments as? [String: Any],
                let recipients = args["number"] as? String,
                let body = args["message"] as? String
            else {
                result(
                    FlutterError(
                        code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
                return
            }
            sendSMS(recipients: [recipients], body: body, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func sendSMS(recipients: [String], body: String, result: @escaping FlutterResult) {
        if MFMessageComposeViewController.canSendText() {
            let composeVC = MFMessageComposeViewController()
            composeVC.messageComposeDelegate = self
            composeVC.recipients = recipients
            composeVC.body = body
            flutterResult = result

            // Present the message compose view controller
            if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
                rootVC.present(composeVC, animated: true, completion: nil)
            } else {
                result(
                    FlutterError(
                        code: "NO_ROOT_VIEW_CONTROLLER", message: "No root view controller",
                        details: nil))
            }
        } else {
            result(
                FlutterError(
                    code: "CANNOT_SEND_SMS", message: "Device cannot send SMS", details: nil))
        }
    }

    public func messageComposeViewController(
        _ controller: MFMessageComposeViewController, didFinishWith resultCode: MessageComposeResult
    ) {
        controller.dismiss(animated: true) {
            switch resultCode {
            case .sent:
                self.flutterResult?("sent")
            case .cancelled:
                self.flutterResult?("cancelled")
            case .failed:
                self.flutterResult?(
                    FlutterError(code: "FAILED", message: "Failed to send SMS", details: nil))
            @unknown default:
                self.flutterResult?(
                    FlutterError(code: "UNKNOWN", message: "Unknown result", details: nil))
            }
            self.flutterResult = nil
        }
    }
}
