/// Model to hold the result of a capture operation
class CaptureResult {
  /// Constructor
  CaptureResult({
    this.filePath,
    this.base64String,
    this.fileSizeBytes,
    this.isCanceled = false,
  });

  /// image file path
  final String? filePath;

  /// Base64 representation of the image
  final String? base64String;

  /// Size of the image file in bytes
  final int? fileSizeBytes;
  /// is canceled
  final bool isCanceled; 
}
