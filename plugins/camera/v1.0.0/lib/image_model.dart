import "package:apz_camera/enum.dart";

/// image model class
class ImageModel {
  /// image model constructor
  ImageModel({
    required this.crop,
    required this.cropTitle,
    required this.fileName,
    this.targetWidth = 1280,
    this.targetHeight = 1080,
    this.quality = 100,
    this.cameraDeviceSensor = CameraDeviceSensor.rear,
    this.format = ImageFormat.png,
  });

  /// crop
  final bool crop;

  /// targetWidth
  final int targetWidth;

  /// targetHeight
  final int targetHeight;

  /// quality
  final int quality;

  /// fileName
  final String fileName;

  /// format
  final ImageFormat format;

  /// cameraDeviceSensor
  final CameraDeviceSensor cameraDeviceSensor;

  /// cropTitle
  final String cropTitle;
}
