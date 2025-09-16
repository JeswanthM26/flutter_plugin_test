import "package:apz_camera/apz_camera.dart";
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

/// Mock class
class MockCameraService extends Mock implements CameraService {}

/// Fake params for fallback
class FakeCameraParams extends Fake implements CameraCaptureParams {}

void main() {
  setUpAll(() {
    // Needed when using any(named: 'params') with non-nullable types
    registerFallbackValue(FakeCameraParams());
  });

  late ApzCamera apzCamera;
  late MockCameraService mockCameraService;

  setUp(() {
    apzCamera = ApzCamera();
    mockCameraService = MockCameraService();
    apzCamera.mockCamera(mockCameraService);
  });

  testWidgets('openCamera delegates to CameraService.showCameraCapture', (
    WidgetTester tester,
  ) async {
    // Need a real BuildContext from the widget tree
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SizedBox())),
    );
    final BuildContext context = tester.element(find.byType(SizedBox));

    // Stub the mock (use real context instead of any)
    when(
      () => mockCameraService.showCameraCapture(
        context: context,
        params: any(named: 'params'),
      ),
    ).thenAnswer(
      (_) async => CaptureResult(
        filePath: "mocked",
        base64String: "mocked",
        fileSizeBytes: 2,
      ),
    );

    // Call method
    final result = await apzCamera.openCamera(
      context: context,
      params: CameraCaptureParams(crop: true),
    );

    // Verify return
    expect(result, isA<CaptureResult>());
    expect(result!.filePath, equals('mocked'));

    // Verify interaction (again, pass real context)
    verify(
      () => mockCameraService.showCameraCapture(
        context: context,
        params: any(named: 'params'),
      ),
    ).called(1);
  });

  test('dispose calls CameraService.dispose', () async {
    when(() => mockCameraService.dispose()).thenAnswer((_) async {});

    await apzCamera.dispose();

    verify(() => mockCameraService.dispose()).called(1);
  });
}
