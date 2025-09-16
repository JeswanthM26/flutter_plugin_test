import "dart:convert";
import "dart:io";
import "dart:typed_data";
import "package:apz_camera/models/camera_capture_params.dart";
import "package:apz_camera/models/capture_result.dart";
import "package:image/image.dart" as img;
import "package:path_provider/path_provider.dart";

/// Utility class for processing images
class ImageProcessor {
  /// Process the image
  Future<CaptureResult> processImage({
    required final Uint8List imageBytes,
    required final CameraCaptureParams params,
    final Uint8List? croppedImageBytes,
  }) async {
    try {
      // Use cropped image if available, otherwise use original
      final Uint8List processedBytes = croppedImageBytes ?? imageBytes;

      // Decode image for processing
      img.Image? image = img.decodeImage(processedBytes);
      if (image == null) {
        throw Exception("Failed to decode image");
      }

      // Resize if target dimensions are provided
      if (params.targetWidth != null || params.targetHeight != null) {
        image = img.copyResize(
          image,
          width: params.targetWidth,
          height: params.targetHeight,
        );
      }

      // Encode with specified format and quality
      List<int> encodedBytes;
      String fileExtension;

      if (params.format == ImageFormat.png) {
        encodedBytes = img.encodePng(image);
        fileExtension = "png";
      } else {
        encodedBytes = img.encodeJpg(image, quality: params.quality);
        fileExtension = "jpg";
      }

      // Generate file path
      final Directory directory = await getApplicationDocumentsDirectory();
      final String fileName =
          '${(params.fileName ??
                  "captured_${DateTime.now().millisecondsSinceEpoch}")
              .replaceAll(
                RegExp(r'\.(jpg|png)$'),
                '',
              )}.$fileExtension';
      final String filePath = "${directory.path}/$fileName";

      // Save file
      final File file = File(filePath);
      await file.writeAsBytes(encodedBytes);

      // Convert to base64
      final String base64String = base64Encode(encodedBytes);

      return CaptureResult(
        filePath: filePath,
        base64String: base64String,
        fileSizeBytes: encodedBytes.length,
      );
    } catch (e) {
      throw Exception("Failed to process image: $e");
    }
  }
}
