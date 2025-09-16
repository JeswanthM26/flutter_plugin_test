import Flutter
import UIKit
import ContactsUI // Required for CNContactPickerViewController
import Contacts // Required for CNContact, CNContactFormatter, CNContactStore

public class ApzContactPicker: NSObject, FlutterPlugin, CNContactPickerDelegate {

  private var channel: FlutterMethodChannel!
  private var pendingResult: FlutterResult? // Holds the Flutter Result callback

  // MARK: - FlutterPlugin Registration

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "contact_picker_plugin", binaryMessenger: registrar.messenger())
    let instance = ApzContactPicker()
    instance.channel = channel
    registrar.addMethodCallDelegate(instance, channel: channel)
    // No need for ActivityAware equivalent on iOS like Android.
    // CNContactPickerDelegate handles the UI presentation and dismissal.
  }

  // MARK: - MethodCallHandler (Flutter to Native)

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if call.method == "pickContact" {
      self.pendingResult = result // Store the result callback for later use
      launchContactPicker()
    } else {
      result(FlutterMethodNotImplemented)
    }
  }

  // MARK: - Contact Picker Launch Logic

  private func launchContactPicker() {
    let contactPicker = CNContactPickerViewController()
    contactPicker.delegate = self // Set the plugin as the delegate to receive callbacks

    // Present the contact picker from the currently active UIViewController.
    // This is typically the rootViewController of the key window.
    if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
      rootViewController.present(contactPicker, animated: true, completion: nil)
    } else {
      pendingResult?(FlutterError(code: "VIEW_CONTROLLER_NOT_FOUND",
                              message: "Could not find a UIViewController to present the contact picker.",
                              details: nil))
      pendingResult = nil
    }
  }

  // MARK: - CNContactPickerDelegate Methods (Contact Picker Callbacks)

  // This method is called when the user successfully selects a contact.
  public func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
    picker.dismiss(animated: true, completion: nil) // Dismiss the picker UI

    // Extract details and send them back to Flutter.
    let contactMap: [String: Any?] = extractContactDetails(contact: contact)
    pendingResult?(contactMap)
    pendingResult = nil // Clear the pending result
  }

  // This method is called when the user cancels the contact picker.
  public func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
    picker.dismiss(animated: true, completion: nil) // Dismiss the picker UI
    pendingResult?(nil) // Send nil back to Flutter to indicate cancellation
    pendingResult = nil // Clear the pending result
  }

  // MARK: - Helper to Extract Contact Details

  private func extractContactDetails(contact: CNContact) -> [String: Any?] {
    var contactInfo: [String: Any?] = [:]

    // Full Name
    let formatter = CNContactFormatter()
    formatter.style = .fullName
    if let fullName = formatter.string(from: contact) {
        contactInfo["fullName"] = fullName
    } else {
        contactInfo["fullName"] = nil
    }

    // Phone Number (get the first one if available)
    if let phoneNumber = contact.phoneNumbers.first?.value.stringValue {
      contactInfo["phoneNumber"] = phoneNumber
    } else {
      contactInfo["phoneNumber"] = nil
    }

    // Email (get the first one if available)
    if let email = contact.emailAddresses.first?.value as? String {
      contactInfo["email"] = email
    } else {
      contactInfo["email"] = nil
    }

    // Thumbnail Image Data
    // CNContact.thumbnailImageData is already an Optional<Data> (Data? in Swift).
    // If there's no thumbnail, it will be nil, which is directly handled.
    if let imageData = contact.thumbnailImageData {
        // Convert Swift's Data to Flutter's expected FlutterStandardTypedData (Uint8List on Dart side)
        contactInfo["thumbnail"] = FlutterStandardTypedData(bytes: imageData)
    } else {
        contactInfo["thumbnail"] = nil // Explicitly set to nil if no thumbnail
    }

    return contactInfo
  }
}