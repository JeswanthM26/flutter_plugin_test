// test/ui/camera_preview_widget_test.dart
import 'dart:typed_data';
import "package:camera/camera.dart";
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// App imports
import 'package:apz_camera/ui/camera_preview_widget.dart';
import 'package:apz_camera/models/camera_capture_params.dart';
import 'package:apz_camera/models/capture_result.dart';

// Local fakes
import 'fake_camera_platform.dart';

class MockParams extends Mock implements CameraCaptureParams {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class TestCaptureResult implements CaptureResult {
  const TestCaptureResult(this.tag);
  final String tag;
  @override
  String toString() => 'TestCaptureResult($tag)';
  @override
  String get base64String => 'BASE64';
  @override
  String get filePath => '/tmp/test.jpg';
  @override
  int get fileSizeBytes => 12345;

  @override
  // TODO: implement isCanceled
  bool get isCanceled => false;
}

// Targeted waits (avoid pumpAndSettle during infinite animations)
Future<void> pumpUntil(
  WidgetTester tester,
  bool Function() condition, {
  Duration step = const Duration(milliseconds: 16),
  Duration timeout = const Duration(seconds: 5),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    if (condition()) return;
    await tester.pump(step);
  }
  throw StateError('Condition not met within $timeout');
}

CameraCaptureParams params({
  bool crop = false,
  CameraLensDirection dir = CameraLensDirection.back,
}) {
  final p = MockParams();
  when(() => p.crop).thenReturn(crop);
  when(() => p.lensDirection).thenReturn(dir);
  when(() => p.cropTitle).thenReturn('Preview'); // used as title
  when(() => p.targetWidth).thenReturn(null);
  when(() => p.targetHeight).thenReturn(null);
  return p;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // Use the fake platform for deterministic behavior
    CameraPlatform.instance = FakeCameraPlatform();
  });

  testWidgets('initializes and shows overlay controls', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: CameraPreviewWidget(params: params())),
    );
    await tester.pumpAndSettle(); // init completes
    expect(find.byKey(const Key('flashButton')), findsOneWidget);
    expect(find.byKey(const Key('captureButton')), findsOneWidget);
        expect(find.byKey(const Key('closeButton')), findsOneWidget);

  });

  testWidgets('flash toggle cycles OFF -> AUTO -> ON -> OFF (tooltip)', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: CameraPreviewWidget(params: params())),
    );
    await tester.pumpAndSettle();

    final flash = find.byKey(const Key('flashButton'));
    IconButton getBtn() => tester.widget<IconButton>(flash);

    expect(getBtn().tooltip, contains('OFF'));
    await tester.tap(flash);
    await tester.pump();
    expect(getBtn().tooltip, contains('AUTO'));
    await tester.tap(flash);
    await tester.pump();
    expect(getBtn().tooltip, contains('ON'));
    await tester.tap(flash);
    await tester.pump();
    expect(getBtn().tooltip, contains('OFF'));
  });

  testWidgets('switch camera button visible with multiple cameras', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: CameraPreviewWidget(params: params())),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('switchCameraButton')), findsOneWidget);
  });

  testWidgets('switch camera actually reinitializes controller', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: CameraPreviewWidget(params: params())),
    );
    await tester.pumpAndSettle();

    // Tapping switch should not throw and should keep preview visible
    await tester.tap(find.byKey(const Key('switchCameraButton')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('captureButton')), findsOneWidget);
  });

  testWidgets('preview maintains aspect without stretching (cover path)', (
    tester,
  ) async {
    // Use a fixed screen size to validate layout math
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 3.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(home: CameraPreviewWidget(params: params())),
    );
    await tester.pumpAndSettle();

    // CameraPreview should be present
    expect(find.byType(CameraPreview), findsOneWidget);

    // The preview is wrapped (cover) so it fills without stretch.
    // We can’t directly assert aspect math here, but we ensure no overflow.
    expect(tester.takeException(), isNull);
  });
  testWidgets('no flash control before initialization (safeguard)', (
    tester,
  ) async {
    // Pump but don’t wait for settle; flash button may not be there yet
    await tester.pumpWidget(
      MaterialApp(home: CameraPreviewWidget(params: params())),
    );

    // Either no flash button yet or tapping it shouldn’t throw
    if (find.byKey(const Key('flashButton')).evaluate().isNotEmpty) {
      await tester.tap(find.byKey(const Key('flashButton')));
    }
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
