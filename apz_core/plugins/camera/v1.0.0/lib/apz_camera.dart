import "package:apz_camera/models/camera_capture_params.dart";
import "package:apz_camera/models/capture_result.dart";
import "package:apz_camera/services/camera_service.dart";
import "package:flutter/material.dart";
export "models/camera_capture_params.dart";
export "models/capture_result.dart";
export "services/camera_service.dart";
export "ui/crop_image_widget.dart";
export "utils/image_processor.dart";
export "utils/permission_handler.dart";

/// Main plugin class to interact with camera and cropping functionalities
class ApzCamera {
  CameraService _cameraService = CameraService();

  @visibleForTesting
  /// for testing purposes only
  // ignore: use_setters_to_change_properties
  void mockCamera(final CameraService cameraService) {
    _cameraService = cameraService;
  }

  /// Show camera capture screen with optional cropping
  Future<CaptureResult?> openCamera({
    required final BuildContext context,
    final CameraCaptureParams? params,
  }) async => _cameraService.showCameraCapture(
    context: context,
    params: params ?? CameraCaptureParams(crop: true),
  );

  /// Dispose camera resources
  Future<void> dispose() async {
    await _cameraService.dispose();
  }
}
