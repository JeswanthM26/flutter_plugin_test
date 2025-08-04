import "package:flutter/material.dart";
import "package:flutter_zxing/flutter_zxing.dart" as zxing;

/// Configuration options for customizing the behavior and appearance
/// of the Apz QR Scanner.
///
/// This class allows you to control camera settings, cropping, and UI
/// appearance for the scanner view.
class ApzQrScannerConfig {

  /// Creates a configuration object for the Apz QR Scanner.
  ///
  /// All parameters are optional and have sensible defaults.
  const ApzQrScannerConfig({
    this.isMultiScan = false,
    this.resolution = zxing.ResolutionPreset.high,
    this.lensDirection = zxing.CameraLensDirection.back,
    this.verticalCropOffset = -0.7,
    this.horizontalCropOffset = 0,
    this.cropPercent = 0.8,
    this.scannerLineColor = Colors.redAccent,
  });
  /// Whether to enable **multi-scan** mode.
  ///
  /// When `true`, the scanner continues
  ///  scanning without closing after detecting a code.
  /// Defaults to `false`.
  final bool isMultiScan;

  /// The camera **resolution preset** to use for scanning.
  ///
  /// Defaults to [zxing.ResolutionPreset.high].
  final zxing.ResolutionPreset resolution;

  /// The **initial lens direction** of the camera.
  ///
  /// Can be front or back. Defaults to [zxing.CameraLensDirection.back].
  final zxing.CameraLensDirection lensDirection;

  /// Vertical **offset** for the cropping area, ranging from -1 to 1.
  ///
  /// Useful for adjusting the position of the scan area vertically.
  /// Defaults to `-0.7`.
  final double verticalCropOffset;

  /// Horizontal **offset** for the cropping area, ranging from -1 to 1.
  ///
  /// Useful for adjusting the position of the scan area horizontally.
  /// Defaults to `0`.
  final double horizontalCropOffset;

  /// Percentage of the camera preview to be used 
  /// as the **crop** area for scanning.
  ///
  /// Ranges from 0 to 1. A smaller value narrows the scan region.
  /// Defaults to `0.5` (50% of the preview).
  final double cropPercent;

  /// The color of the **scanner line** drawn in the scan area.
  ///
  /// Defaults to [Colors.redAccent].
  final Color scannerLineColor;
}
