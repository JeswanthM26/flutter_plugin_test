import 'package:apz_camera/models/camera_capture_params.dart';
import 'package:apz_camera/models/capture_result.dart';
import 'package:apz_camera/services/camera_service.dart';
import 'package:apz_camera/utils/permission_handler.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// Testable wrapper around CameraService that allows dependency injection for testing
class TestableCameraService extends CameraService {
  final CameraPermissionHandler Function()? _mockPermissionHandlerFactory;
  final Future<List<CameraDescription>> Function()? _mockAvailableCamerasFunction;

  TestableCameraService({
    CameraPermissionHandler Function()? permissionHandlerFactory,
    Future<List<CameraDescription>> Function()? availableCamerasFunction,
  }) : _mockPermissionHandlerFactory = permissionHandlerFactory,
       _mockAvailableCamerasFunction = availableCamerasFunction;

  @override
  Future<CaptureResult?> showCameraCapture({
    required BuildContext context,
    required CameraCaptureParams params,
  }) async {
    // Store original functions to restore later
    final originalPermissionFactory = cameraPermissionHandlerFactory;
    final originalCamerasFunction = availableCamerasFunction;

    try {
      // Override global functions with mocks if provided
      if (_mockPermissionHandlerFactory != null) {
        cameraPermissionHandlerFactory = _mockPermissionHandlerFactory!;
      }
      if (_mockAvailableCamerasFunction != null) {
        availableCamerasFunction = _mockAvailableCamerasFunction!;
      }

      // Call the parent implementation which will now use our mocked functions
      return await super.showCameraCapture(context: context, params: params);
    } finally {
      // Always restore original functions to avoid affecting other tests
      cameraPermissionHandlerFactory = originalPermissionFactory;
      availableCamerasFunction = originalCamerasFunction;
    }
  }
}
