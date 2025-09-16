import "package:flutter/material.dart";

/// A customizable set of icons used in the Apz QR Scanner UI.
///
/// This class allows the host app to override the default icons used in the
/// scanner interface such as 
/// flash controls, gallery access, and camera toggling.
class ApzQrScannerIcons {

  /// Creates a set of icons for the Apz QR Scanner.
  ///
  /// All parameters are optional and default to standard Material icons.
  const ApzQrScannerIcons({
    this.flashOnIcon = const Icon(Icons.flash_on),
    this.flashOffIcon = const Icon(Icons.flash_off),
    this.flashAlwaysIcon = const Icon(Icons.flash_on),
    this.flashAutoIcon = const Icon(Icons.flash_auto),
    this.galleryIcon = const Icon(Icons.photo_library),
    this.toggleCameraIcon = const Icon(Icons.cameraswitch),
  });
  /// Icon displayed when the flash is turned **on**.
  ///
  /// Defaults to [Icons.flash_on].
  final Icon flashOnIcon;

  /// Icon displayed when the flash is turned **off**.
  ///
  /// Defaults to [Icons.flash_off].
  final Icon flashOffIcon;

  /// Icon displayed when the flash is set to **always on**.
  ///
  /// Defaults to [Icons.flash_on].
  ///  This can be customized independently from flashOnIcon.
  final Icon flashAlwaysIcon;

  /// Icon displayed when the flash is set to **auto** mode.
  ///
  /// Defaults to [Icons.flash_auto].
  final Icon flashAutoIcon;

  /// Icon used to access the **gallery** for importing QR/barcode images.
  ///
  /// Defaults to [Icons.photo_library].
  final Icon galleryIcon;

  /// Icon used to **toggle between front and back cameras**.
  ///
  /// Defaults to [Icons.cameraswitch].
  final Icon toggleCameraIcon;
}
