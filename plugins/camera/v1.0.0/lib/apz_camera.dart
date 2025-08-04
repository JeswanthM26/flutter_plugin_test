import "dart:convert";
import "dart:io";
import "package:apz_camera/camera_result.dart";
import "package:apz_camera/enum.dart";
import "package:apz_camera/image_model.dart";
import "package:apz_utils/apz_utils.dart";
import "package:flutter/foundation.dart";
import "package:image_cropper/image_cropper.dart";
import "package:image_picker/image_picker.dart";
import "package:path/path.dart" as p;
import "package:path_provider/path_provider.dart";
import "package:permission_handler/permission_handler.dart";

/// ApzCamera is class that provides methods to pick images from
/// the camera, crop them, and convert them to base64 format.
class ApzCamera {
  Future<void> _checkCameraPermissions() async {
    try {
      if (kIsWeb) {
        throw UnsupportedPlatformException(
          "This plugin is not supported on the web platform",
        );
      } else {
        final PermissionStatus cameraStatus = await Permission.camera.request();
        _evaluatePermission(cameraStatus, "Camera");
      }
    } on PermissionException {
      rethrow;
    }
  }

  CameraDevice _mapCameraDevice(final CameraDeviceSensor device) {
    switch (device) {
      case CameraDeviceSensor.front:
        return CameraDevice.front;
      case CameraDeviceSensor.rear:
        return CameraDevice.rear;
    }
  }

  ImageCompressFormat _mapFormat(final ImageFormat format) {
    switch (format) {
      case ImageFormat.png:
        return ImageCompressFormat.png;
      case ImageFormat.jpeg:
        return ImageCompressFormat.jpg;
    }
  }

  //// Picks an image from the camera and crops it if required.
  Future<CameraResult?> pickFromCamera({
    required final VoidCallback cancelCallback,
    required final ImageModel imagemodel,
  }) async {
    try {
      await _checkCameraPermissions();
      final ImagePicker picker = ImagePicker();
      final XFile? picked = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: _mapCameraDevice(imagemodel.cameraDeviceSensor),
        imageQuality: imagemodel.quality,
        maxWidth: imagemodel.targetWidth.toDouble(),
        maxHeight: imagemodel.targetHeight.toDouble(),
      );
      if (picked == null) {
        cancelCallback.call();
        return null;
      }
      final CameraResult result = await handlePickedFile(
        picked,
        crop: imagemodel.crop,
        quality: imagemodel.quality,
        fileName: imagemodel.fileName,
        format: imagemodel.format,
        cropTitle: imagemodel.cropTitle,
      );
      return result;
    } on UnsupportedPlatformException {
      rethrow;
    } on PermissionException {
      rethrow;
    }
  }

  ///handel picked image
  Future<CameraResult> handlePickedFile(
    final XFile picked, {
    required final bool crop,
    required final int quality,
    required final String fileName,
    required final ImageFormat format,
    required final String cropTitle,
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
        compressFormat: _mapFormat(format),
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

    final String ext = format == ImageFormat.png ? "png" : "jpg";
    final Directory tempDir = Directory.systemTemp;
    final String savedPath = p.join(tempDir.path, "$fileName.$ext");
    final File savedFile = await File(savedPath).writeAsBytes(bytes);

    final String base64 = base64Encode(bytes);
    final double base64ImageSizeInKB = (base64.length * 3 / 4) / 1024;

    return CameraResult(
      imageFile: savedFile,
      base64String: base64,
      base64ImageSizeInKB: base64ImageSizeInKB,
    );
  }

  void _evaluatePermission(final PermissionStatus status, final String label) {
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

  @visibleForTesting
  /// This method is for testing purposes only.
  Future<String?> convertToBase64(final File file) async {
    try {
      final Uint8List bytes = await file.readAsBytes();

      // Optional: calculate image size in KB for validation
      final String base64 = base64Encode(bytes);

      ///for testing
      // ignore: unused_local_variable
      final double sizeInKB = (base64.length * 3 / 4) / 1024;
      return base64;

      ///for testing
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      return null;
    }
  }
}
