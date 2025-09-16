import "dart:io";

/// Photopicker result
class PhotopickerResult {
  /// Constructor for ApzPhotopickerResult
  PhotopickerResult({
    this.imageFile,
    this.base64String,
    this.base64ImageSizeInKB,
  });

  /// image file
  final File? imageFile;

  /// base64 string
  final String? base64String;

  /// image size in kb
  final double? base64ImageSizeInKB;
}
