import "package:apz_camera/models/camera_capture_params.dart";
import "package:apz_camera/models/capture_result.dart";
import "package:apz_camera/ui/camera_preview_widget.dart";
import "package:apz_camera/utils/permission_handler.dart";
import "package:camera/camera.dart";
import "package:flutter/material.dart";

/// Service class to handle camera operations
class CameraService {
  List<CameraDescription>? _cameras;
  CameraController? _controller;

  @visibleForTesting
  /// for testing purposes only
  // ignore: use_setters_to_change_properties
  void mockCameraDisc(
    final List<CameraDescription>? cameras,
    final CameraController? controller,
  ) {
    _cameras = cameras;
    _controller = controller;
  }

  /// Show camera capture interface
  Future<CaptureResult?> showCameraCapture({
    required final BuildContext context,
    required final CameraCaptureParams params,
  }) async {
    final CameraPermissionHandler permissionHandler = CameraPermissionHandler();
    await permissionHandler.checkCameraPermissions();
    _cameras = await availableCameras();

    if (_cameras == null || (_cameras?.isEmpty ?? true)) {
      throw Exception("No cameras available");
    }

    // Find camera with specified lens direction
    CameraDescription? selectedCamera;
    for (final CameraDescription camera in _cameras ?? <CameraDescription>[]) {
      if (camera.lensDirection == params.lensDirection) {
        selectedCamera = camera;
        break;
      }
    }

    selectedCamera ??= _cameras?.first;
    if (!context.mounted) {
      return null;
    }
    return Navigator.of(context).push<CaptureResult>(
      MaterialPageRoute<CaptureResult>(
        builder: (final BuildContext context) =>
            CameraPreviewWidget(params: params),
      ),
    );
  }

  /// Dispose camera resources
  Future<void> dispose() async {
    await _controller?.dispose();
    _controller = null;
  }
}

///added for testing purposes
@visibleForTesting
Future<List<CameraDescription>> Function() availableCamerasFunction =
    availableCameras;

///added for testing purposes
@visibleForTesting
CameraPermissionHandler Function() cameraPermissionHandlerFactory =
    CameraPermissionHandler.new;
