
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:apz_screenshot/apz_screenshot.dart';
import 'package:apz_screenshot/screenshot_model.dart';
import 'package:apz_screenshot/screenshot_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// --- Mocks ---
class MockBuildContext extends Mock implements BuildContext {}

class MockRenderRepaintBoundary extends Mock implements RenderRepaintBoundary {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) =>
      'MockRenderRepaintBoundary';
}

class MockRenderObjectWithParent extends Mock implements RenderObject {
  RenderObject? _parent;

  MockRenderObjectWithParent({RenderObject? parent}) {
    _parent = parent;
  }

  @override
  RenderObject? get parent => _parent;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) =>
      'MockRenderObjectWithParent';
}

class MockUiImage extends Mock implements ui.Image {}

class MockScreenshotSaver extends Mock {
  Future<void> save(Uint8List bytes, String fileName);
}

class FakeBuildContext extends Fake implements BuildContext {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    registerFallbackValue(FakeBuildContext());
    registerFallbackValue(ui.ImageByteFormat.png);
  });

  group('ApzScreenshot', () {
    final apzScreenshot = ApzScreenshot();

    test('capture returns null when RenderObject is null', () async {
      final mockContext = MockBuildContext();
      when(() => mockContext.findRenderObject()).thenReturn(null);

      final result = await apzScreenshot.capture(mockContext);
      expect(result, isNull);
    });

    test('capture returns null when no RepaintBoundary found', () async {
      final mockContext = MockBuildContext();
      final mockRenderObject = MockRenderObjectWithParent(parent: null);
      when(() => mockContext.findRenderObject()).thenReturn(mockRenderObject);

      final result = await apzScreenshot.capture(mockContext);
      expect(result, isNull);
    });

    test('capture returns ScreenshotResult when context is RepaintBoundary', () async {
      final mockContext = MockBuildContext();
      final mockBoundary = MockRenderRepaintBoundary();
      final mockImage = MockUiImage();
      final mockByteData = ByteData(8);

      when(() => mockContext.findRenderObject()).thenReturn(mockBoundary);
      when(() => mockBoundary.toImage(pixelRatio: any(named: 'pixelRatio')))
          .thenAnswer((_) async => mockImage);
      when(() => mockImage.toByteData(format: ui.ImageByteFormat.png))
          .thenAnswer((_) async => mockByteData);

      final result = await apzScreenshot.capture(mockContext);
      expect(result, isA<ScreenshotResult>());
      expect(result!.bytes, equals(mockByteData.buffer.asUint8List()));
      expect(result.image, isA<Image>());
    });

    test('capture returns ScreenshotResult when ancestor is RepaintBoundary', () async {
      final mockContext = MockBuildContext();
      final mockBoundary = MockRenderRepaintBoundary();
      final mockIntermediate = MockRenderObjectWithParent(parent: mockBoundary);
      final mockStart = MockRenderObjectWithParent(parent: mockIntermediate);
      final mockImage = MockUiImage();
      final mockByteData = ByteData(8);

      when(() => mockContext.findRenderObject()).thenReturn(mockStart);
      when(() => mockBoundary.toImage(pixelRatio: any(named: 'pixelRatio')))
          .thenAnswer((_) async => mockImage);
      when(() => mockImage.toByteData(format: ui.ImageByteFormat.png))
          .thenAnswer((_) async => mockByteData);

      final result = await apzScreenshot.capture(mockContext);
      expect(result, isA<ScreenshotResult>());
      expect(result!.bytes, equals(mockByteData.buffer.asUint8List()));
      expect(result.image, isA<Image>());
    });



    test('captureAndSave executes capture and then saves the result', () async {
      final mockContext = MockBuildContext();
      final mockBoundary = MockRenderRepaintBoundary();
      final mockImage = MockUiImage();
      final mockByteData = ByteData(8);

      when(() => mockContext.findRenderObject()).thenReturn(mockBoundary);
      when(() => mockBoundary.toImage(pixelRatio: any(named: 'pixelRatio')))
          .thenAnswer((_) async => mockImage);
      when(() => mockImage.toByteData(format: ui.ImageByteFormat.png))
          .thenAnswer((_) async => mockByteData);

      final result = await apzScreenshot.captureAndShare(mockContext,text: "Test Screenshot", customFileName: "test_screenshot.png");
      expect(result, isA<ScreenshotResult>());
      expect(result!.bytes, equals(mockByteData.buffer.asUint8List()));
      expect(result.image, isA<Image>());
    });
  });
}
