// test/image_processor_test.dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import "package:apz_camera/utils/image_processor.dart";
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:apz_camera/models/camera_capture_params.dart'; // adjust if path differs
import 'package:apz_camera/models/capture_result.dart'; // adjust if path differs

void main() {
  const MethodChannel pathProviderChannel = MethodChannel(
    'plugins.flutter.io/path_provider',
  );

  late Directory tempDir;
  late ImageProcessor imageProcessor;

  setUp(() async {
    // Ensure Flutter bindings initialized for MethodChannel mocking
    TestWidgetsFlutterBinding.ensureInitialized();

    // create temporary directory for test files
    tempDir = await Directory.systemTemp.createTemp('image_processor_test');

    // mock path_provider to return our temp dir path
    pathProviderChannel.setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'getApplicationDocumentsDirectory') {
        return tempDir.path;
      }
      return null;
    });

    imageProcessor = ImageProcessor();
  });

  tearDown(() async {
    // remove the mock handler
    pathProviderChannel.setMockMethodCallHandler(null);
    // cleanup temp dir
    try {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    } catch (_) {}
  });

  test('processImage saves a JPG and returns valid CaptureResult', () async {
    // create a sample image bytes (10x10 red)
    final img.Image sample = img.Image(width: 10, height: 10);
    final Uint8List inputBytes = Uint8List.fromList(img.encodeJpg(sample));

    final params = CameraCaptureParams(
      fileName: null, // let the processor create its own name
      quality: 85,
      crop: true,
      format: ImageFormat.jpeg,
      targetWidth: null,
      targetHeight: null,
    );

    final CaptureResult result = await imageProcessor.processImage(
      imageBytes: inputBytes,
      params: params,
    );

    // file should exist
    final File saved = File(result.filePath!);
    expect(await saved.exists(), isTrue);

    // sizes should match
    final int actualFileLen = await saved.length();
    expect(result.fileSizeBytes, actualFileLen);

    // base64 should decode to the same bytes as the saved file
    final bytesFromBase64 = base64Decode(result.base64String!);
    final savedBytes = await saved.readAsBytes();
    expect(bytesFromBase64, savedBytes);
  });

  test('processImage saves a PNG when requested', () async {
    final img.Image sample = img.Image(width: 6, height: 6);
    final Uint8List inputBytes = Uint8List.fromList(img.encodePng(sample));

    final params = CameraCaptureParams(
      fileName: 'my_test.png',
      quality: 100,
      format: ImageFormat.png,
      targetWidth: null,
      targetHeight: null,
      crop: true,
    );

    final CaptureResult result = await imageProcessor.processImage(
      imageBytes: inputBytes,
      params: params,
    );

    final File saved = File(result.filePath!);
    expect(await saved.exists(), isTrue);
    expect(saved.path.endsWith('.png'), isTrue);
    expect(result.fileSizeBytes, await saved.length());
  });

  test('processImage respects targetWidth/targetHeight (resizing)', () async {
    final img.Image sample = img.Image(width: 50, height: 50);
    final Uint8List inputBytes = Uint8List.fromList(img.encodeJpg(sample));

    final params = CameraCaptureParams(
      fileName: 'resized.jpg',
      quality: 90,
      format: ImageFormat.jpeg,
      targetWidth: 10,
      targetHeight: 10,
      crop: true,
    );

    final CaptureResult result = await imageProcessor.processImage(
      imageBytes: inputBytes,
      params: params,
    );

    final File saved = File(result.filePath!);
    expect(await saved.exists(), isTrue);

    // decode saved bytes to verify dimensions are as requested
    final savedBytes = await saved.readAsBytes();
    final decoded = img.decodeImage(savedBytes);
    expect(decoded, isNotNull);
    expect(decoded!.width, equals(10));
    expect(decoded.height, equals(10));
  });

  test('processImage uses croppedImageBytes when provided', () async {
    // original image 20x20
    final img.Image original = img.Image(width: 20, height: 20);
    final Uint8List originalBytes = Uint8List.fromList(img.encodeJpg(original));

    // cropped image 5x5
    final img.Image cropped = img.Image(width: 5, height: 5);
    final Uint8List croppedBytes = Uint8List.fromList(img.encodeJpg(cropped));

    final params = CameraCaptureParams(
      fileName: 'cropped.jpg',
      quality: 80,
      format: ImageFormat.jpeg,
      targetWidth: null,
      targetHeight: null,
      crop: true,
    );

    final CaptureResult result = await imageProcessor.processImage(
      imageBytes: originalBytes,
      croppedImageBytes: croppedBytes,
      params: params,
    );

    final File saved = File(result.filePath!);
    final savedBytes = await saved.readAsBytes();
    final decoded = img.decodeImage(savedBytes);
    expect(decoded, isNotNull);
    // ensure it used cropped size (5x5)
    expect(decoded!.width, equals(5));
    expect(decoded.height, equals(5));
  });

  test('processImage throws when it cannot decode the image', () async {
    final Uint8List invalidBytes = Uint8List.fromList([0, 1, 2, 3, 4]);

    final params = CameraCaptureParams(
      fileName: null,
      quality: 80,
      format: ImageFormat.jpeg,
      targetWidth: null,
      targetHeight: null,
      crop: true,
    );

    // Expect an exception containing the wrapper text used in the implementation
    await expectLater(
      imageProcessor.processImage(imageBytes: invalidBytes, params: params),
      throwsA(
        predicate(
          (e) =>
              e is Exception &&
              e.toString().toLowerCase().contains('failed to process image'),
        ),
      ),
    );
  });
}
