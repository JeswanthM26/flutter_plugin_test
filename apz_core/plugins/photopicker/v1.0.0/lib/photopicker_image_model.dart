import "package:apz_photopicker/enum.dart";

/// image model class
class PhotopickerImageModel {
  /// image model constructor
  PhotopickerImageModel({
    required this.crop,
    required this.cropTitle,
    required this.fileName,
    this.targetWidth = 1280,
    this.targetHeight = 1080,
    this.quality = 100,
    this.format = PhotopickerImageFormat.png,
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
  final PhotopickerImageFormat format;

  /// cropTitle
  final String cropTitle;
}
