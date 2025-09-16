import 'package:flutter_test/flutter_test.dart';
import 'package:apz_camera/models/camera_capture_params.dart';
import 'package:camera/camera.dart' hide ImageFormat;

void main() {
  test('Default values are set correctly', () {
    final params = CameraCaptureParams(crop: true);
    expect(params.cameraDeviceSensor, CameraDeviceSensor.back);
    expect(params.quality, 100);
    expect(params.format, ImageFormat.jpeg);
    expect(params.crop, true);
    expect(params.cropTitle, "Crop Image");
    expect(params.lensDirection, CameraLensDirection.back);
  });

  test('Quality assertion throws for invalid value', () {
    expect(
      () => CameraCaptureParams(quality: 0, crop: true),
      throwsA(isA<AssertionError>()),
    );
    expect(
      () => CameraCaptureParams(quality: 101, crop: true),
      throwsA(isA<AssertionError>()),
    );
  });

  test('lensDirection returns correct value', () {
    final frontParams = CameraCaptureParams(
      cameraDeviceSensor: CameraDeviceSensor.front,
      crop: true,
    );
    expect(frontParams.lensDirection, CameraLensDirection.front);
  });
}
