import "package:apz_qr/models/code.dart"; // Assuming these are in your package
/// ApzQrScannerCallbacks wrapper class
class ApzQrScannerCallbacks {
///
  const ApzQrScannerCallbacks({
    this.onScanSuccess,
    this.onScanFailure,
    this.onMultiScanSuccess,
    this.onMultiScanFailure,
    this.onMultiScanModeChanged,
    this.onError,
  });
  /// onScanSuccess callback
  final void Function(Code?)? onScanSuccess;
  /// onScanFailure callback
  final void Function(Code?)? onScanFailure;
  /// onMultiScanSuccess callback
  final void Function(Codes)? onMultiScanSuccess;
  /// onMultiScanFailure callback
  final void Function(Codes)? onMultiScanFailure;
  /// onMultiScanModeChanged callback
  final void Function({required bool isEnabled})? onMultiScanModeChanged;
  /// onError callback
  final void Function(Exception)? onError;
}
