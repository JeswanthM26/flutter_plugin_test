import "dart:convert";
import "dart:io";
import "package:apz_photopicker/enum.dart";
import "package:apz_photopicker/photopicker_image_model.dart";
import "package:apz_photopicker/photopicker_result.dart";
import "package:apz_utils/apz_utils.dart";
import "package:flutter/foundation.dart";
import "package:image/image.dart" as img;
import "package:image_cropper/image_cropper.dart";
import "package:image_picker/image_picker.dart";
import "package:path/path.dart" as p;
import "package:path_provider/path_provider.dart";
import "package:permission_handler/permission_handler.dart";

/// plugin for picking images from the gallery with optional cropping
class ApzPhotopicker {
  /// check storage permission
  Future<void> checkStoragePermissions() async {
    try {
      if (kIsWeb) {
        throw UnsupportedPlatformException(
          "This plugin is not supported on the web platform",
        );
      }
      if (Platform.isIOS) {
        final PermissionStatus photosPermissionStatus = await Permission.photos
            .request();
        evaluatePermission(photosPermissionStatus, "Media");
      }
    } on PermissionException {
      rethrow;
    }
  }

  /// image format
  ImageCompressFormat mapFormat(final PhotopickerImageFormat format) {
    switch (format) {
      case PhotopickerImageFormat.png:
        return ImageCompressFormat.png;
      case PhotopickerImageFormat.jpeg:
        return ImageCompressFormat.jpg;
    }
  }

  /// Picks an image from the gallery and crops it if required.
  Future<PhotopickerResult?> pickFromGallery({
    required final VoidCallback cancelCallback,
    required final PhotopickerImageModel imagemodel,
  }) async {
    try {
      await checkStoragePermissions();
      final ImagePicker picker = ImagePicker();
      final XFile? picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: imagemodel.quality,
        maxWidth: imagemodel.targetWidth.toDouble(),
        maxHeight: imagemodel.targetHeight.toDouble(),
      );
      if (picked == null) {
        cancelCallback.call();
        return null;
      }
      final PhotopickerResult result = await handlePickedFile(
        picked,
        crop: imagemodel.crop,
        quality: imagemodel.quality,
        fileName: imagemodel.fileName,
        format: imagemodel.format,
        cropTitle: imagemodel.cropTitle,
        targetWidth: imagemodel.targetWidth,
        targetHeight: imagemodel.targetHeight,
      );

      return result;
    } on UnsupportedPlatformException {
      rethrow;
    } on PermissionException {
      rethrow;
    }
  }

  ///handel picked image
  Future<PhotopickerResult> handlePickedFile(
    final XFile picked, {
    required final bool crop,
    required final int quality,
    required final String fileName,
    required final PhotopickerImageFormat format,
    required final String cropTitle,
    required final int targetWidth,
    required final int targetHeight,
  }) async {
    Uint8List bytes = await picked.readAsBytes();
    if (crop) {
      final Directory tempDir = await getTemporaryDirectory();
      final String tempPath = p.join(
        tempDir.path,
        "temp_${DateTime.now().millisecondsSinceEpoch}.png",
      );
      final File tempFile = await File(tempPath).writeAsBytes(bytes);

      final CroppedFile? cropped = await ImageCropper().cropImage(
        sourcePath: tempFile.path,
        compressFormat: mapFormat(format),
        compressQuality: quality,
        uiSettings: <PlatformUiSettings>[
          AndroidUiSettings(toolbarTitle: cropTitle, lockAspectRatio: false),
          IOSUiSettings(title: cropTitle),
        ],
      );

      if (cropped != null) {
        bytes = await File(cropped.path).readAsBytes();
      }
    }

    bytes = await _reencodeBytes(
      bytes,
      format,
      targetWidth,
      targetHeight,
      quality,
    );

    final String ext = format == PhotopickerImageFormat.png ? "png" : "jpg";
    final Directory tempDir = Directory.systemTemp;
    final String savedPath = p.join(tempDir.path, "$fileName.$ext");
    final File savedFile = await File(savedPath).writeAsBytes(bytes);

    final String base64 = base64Encode(bytes);
    final double base64ImageSizeInKB = (base64.length * 3 / 4) / 1024;

    return PhotopickerResult(
      imageFile: savedFile,
      base64String: base64,
      base64ImageSizeInKB: base64ImageSizeInKB,
    );
  }

  /// Re-encode image bytes into the requested format (PNG/JPEG)
  Future<Uint8List> _reencodeBytes(
    final Uint8List inputBytes,
    final PhotopickerImageFormat format,
    final int targetWidth,
    final int targetHeight,
    final int quality,
  ) async {
    final img.Image? decoded = img.decodeImage(inputBytes);
    if (decoded == null) {
      return inputBytes;
    }

    // Resize to exact dimensions
    final img.Image resized = img.copyResize(
      decoded,
      width: targetWidth,
      height: targetHeight,
    );

    switch (format) {
      case PhotopickerImageFormat.png:
        return Uint8List.fromList(img.encodePng(resized));
      case PhotopickerImageFormat.jpeg:
        return Uint8List.fromList(img.encodeJpg(resized, quality: quality));
    }
  }

  /// Evaluates the permission status and throws an exception if not granted.
  void evaluatePermission(final PermissionStatus status, final String label) {
    switch (status) {
      case PermissionStatus.granted:
        return;
      case PermissionStatus.denied:
        throw PermissionException(
          PermissionsExceptionStatus.denied,
          "$label permission not granted.",
        );
      case PermissionStatus.permanentlyDenied:
        throw PermissionException(
          PermissionsExceptionStatus.permanentlyDenied,
          "$label permission permanently denied. "
          "Please enable it from settings.",
        );
      case PermissionStatus.restricted:
        throw PermissionException(
          PermissionsExceptionStatus.restricted,
          "$label access restricted or not fully granted. "
          "Please check your device settings.",
        );
      case PermissionStatus.limited:
        throw PermissionException(
          PermissionsExceptionStatus.limited,
          "$label access restricted or not fully granted. "
          "Please check your device settings.",
        );
      case PermissionStatus.provisional:
        throw PermissionException(
          PermissionsExceptionStatus.provisional,
          "$label access restricted or not fully granted. "
          "Please check your device settings.",
        );
    }
  }
}
