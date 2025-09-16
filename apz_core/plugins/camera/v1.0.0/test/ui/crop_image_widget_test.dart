// test/crop_image_widget_ui_test.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:crop_your_image/crop_your_image.dart';

// App imports (adjust paths):
import 'package:apz_camera/models/camera_capture_params.dart';
import 'package:apz_camera/ui/crop_image_widget.dart';

Uint8List onePxPng() => base64Decode(
  // 1x1 transparent PNG
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR4nGNgYAAAAAMAAWgmWQ0AAAAASUVORK5CYII=',
);

// Mock for CameraCaptureParams so we don't need the real constructor.
class MockCameraCaptureParams extends Mock implements CameraCaptureParams {}

CameraCaptureParams mockParams({
  String cropTitle = 'Crop',
  int? targetWidth,
  int? targetHeight,
}) {
  final m = MockCameraCaptureParams();
  when(() => m.cropTitle).thenReturn(cropTitle);
  when(() => m.targetWidth).thenReturn(targetWidth);
  when(() => m.targetHeight).thenReturn(targetHeight);
  return m;
}

void main() {
  testWidgets('renders title, buttons, Crop, and aspectRatio', (tester) async {
    final params = mockParams(
      cropTitle: 'My Crop',
      targetWidth: 400,
      targetHeight: 300,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: CropImageWidget(imageBytes: onePxPng(), params: params),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('My Crop'), findsOneWidget);
    expect(find.byKey(const Key('cropButton')), findsOneWidget);
    expect(find.byKey(const Key('cancelCropButton')), findsOneWidget);

    final crop = tester.widget<Crop>(find.byType(Crop));
    expect(crop.aspectRatio, 400 / 300);
  });

  testWidgets('onCropped failure throws and does not show spinner', (
    tester,
  ) async {
    final params = mockParams(cropTitle: 'Crop');

    await tester.pumpWidget(
      MaterialApp(
        home: CropImageWidget(imageBytes: onePxPng(), params: params),
      ),
    );
    await tester.pumpAndSettle();

    // Do NOT tap the crop button (that would call controller.crop()).
    // Instead, trigger the child callback directly with a failure.
    final crop = tester.widget<Crop>(find.byType(Crop));
    await expectLater(
      () async => crop.onCropped.call(CropFailure('test-failure')),
      throwsA(isA<Exception>()),
    );

    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
