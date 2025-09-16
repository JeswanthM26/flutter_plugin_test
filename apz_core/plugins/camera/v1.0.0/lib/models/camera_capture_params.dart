import "package:camera/camera.dart";

/// Enum to specify camera device sensor
enum CameraDeviceSensor {
  ///back
  back,

  ///front
  front,
}

/// Enum to specify image format
enum ImageFormat {
  ///jpeg
  jpeg,

  ///png
  png,
}

/// Class to hold camera capture parameters
class CameraCaptureParams {
  /// Constructor with optional parameters and assertions
  CameraCaptureParams({
    required this.crop,
    this.cameraDeviceSensor = CameraDeviceSensor.back,
    this.targetWidth,
    this.targetHeight,
    this.quality = 100,
    this.format = ImageFormat.jpeg,
    this.fileName,
    this.cropTitle = "Crop Image",
    this.previewTitle = "Preview",
  }) : assert(
         quality >= 1 && quality <= 100,
         "Quality must be between 1 and 100",
       );

  /// Camera device sensor (back or front)
  final CameraDeviceSensor cameraDeviceSensor;

  ///target width
  final int? targetWidth;

  ///target height
  final int? targetHeight;

  ///image quality
  final int quality; // 1-100
  ///image format
  final ImageFormat format;

  ///file name
  final String? fileName;

  /// crop option
  final bool crop;

  /// crop screen title
  final String cropTitle;

  ///preview title
  final String previewTitle;

  /// Get the corresponding CameraLensDirection
  CameraLensDirection get lensDirection =>
      cameraDeviceSensor == CameraDeviceSensor.back
      ? CameraLensDirection.back
      : CameraLensDirection.front;
}
