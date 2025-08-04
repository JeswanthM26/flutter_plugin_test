import "package:apz_photopicker/photopicker_image_model.dart";
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apz_photopicker/device_version_info.dart';
import 'package:apz_photopicker/enum.dart';

void main() {
  // 1) Initialize bindings
  TestWidgetsFlutterBinding.ensureInitialized();

  // 2) Stub out the MethodChannel your plugin uses
  const MethodChannel deviceChannel = MethodChannel(
    'com.iexceed/device_version',
  );

  setUpAll(() {
    deviceChannel.setMockMethodCallHandler((MethodCall call) async {
      if (call.method == 'getSdkInt') {
        // pretend the device is Android SDK 29
        return 29;
      }
      return null;
    });
  });

  tearDownAll(() {
    // clean up
    deviceChannel.setMockMethodCallHandler(null);
  });

  group('DeviceVersionInfo', () {
    test('getSdkInt returns the mocked Android SDK version', () async {
      final info = DeviceVersionInfo();
      final sdk = await info.getSdkInt();
      expect(sdk, 29);
    });
  });

  group('ImageModel', () {
    test('all properties hold the values passed to the constructor', () {
      final model = PhotopickerImageModel(
        fileName: 'test_file',
        crop: true,
        quality: 85,
        targetWidth: 800,
        targetHeight: 600,
        format: PhotopickerImageFormat.png,
        cropTitle: 'Please crop',
      );

      expect(model.fileName, 'test_file');
      expect(model.crop, isTrue);
      expect(model.quality, 85);
      expect(model.targetWidth, 800);
      expect(model.targetHeight, 600);
      expect(model.format, PhotopickerImageFormat.png);
      expect(model.cropTitle, 'Please crop');
    });
  });

  test('returns null when the channel throws a PlatformException', () async {
    // Stub the channel to throw a PlatformException
    deviceChannel.setMockMethodCallHandler((_) async {
      throw PlatformException(code: 'ERROR', message: 'simulated');
    });

    final info = DeviceVersionInfo();
    final sdk = await info.getSdkInt();
    expect(sdk, isNull);
  });
}
