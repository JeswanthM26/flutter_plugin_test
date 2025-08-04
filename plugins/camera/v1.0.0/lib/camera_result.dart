import "dart:io";

/// camera result
class CameraResult {
  /// Constructor for ApzCameraResult
  CameraResult({
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
