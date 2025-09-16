/// A customizable set of text labels used in the Apz QR Scanner UI.
///
/// This class allows the host app to override default user-facing text,
/// such as permission messages shown in the scanner interface.
class ApzQrScannerTexts {

  /// Creates a set of customizable text labels for the Apz QR Scanner.
  ///
  /// [cameraPermissionText]
  ///  is optional and defaults to a standard permission message.
  const ApzQrScannerTexts({
    this.cameraPermissionText = "Camera permission is required.",
    this.waitingText = "Waiting for permissions..."

  });
  /// The message displayed when the app does not have camera permission.
  ///
  /// Defaults to `"Camera permission is required."`.
  final String cameraPermissionText;
  /// waiting text 
  final String waitingText;
}
