import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:apz_device_fingerprint/apz_device_fingerprint.dart';
import 'package:apz_device_fingerprint/utils/fingerprint_utils.dart';
import 'package:mocktail/mocktail.dart';
import "package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart";

import "fake_shared_preferences_async.dart";

class MockFingerprintUtils extends Mock implements FingerprintUtils {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    registerFallbackValue(MockFingerprintUtils());
    SharedPreferencesAsyncPlatform.instance = FakeSharedPreferencesAsync();
  });

  group('ApzDeviceFingerprint', () {
    test('getFingerprint returns a string', () async {
      final methodChannel = MethodChannel('com.iexceed/apz_device_fingerprint');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        methodChannel,
        (MethodCall methodCall) async {
          return {
            'source': 'android',
            'secureId': 'secureId',
            'deviceManufacturer': 'Google',
            'deviceModel': 'Pixel',
            'screenResolution': '1080x1920',
            'deviceType': 'phone',
            'totalDiskSpace': '128GB',
            'totalRAM': '4GB',
            'cpuCount': '8',
            'cpuArchitecture': 'arm64',
            'cpuEndianness': 'little',
            'deviceName': 'Pixel',
            'glesVersion': '3.2',
            'osVersion': '12',
            'osBuildNumber': 'RQ3A.210705.001',
            'kernelVersion': '5.4.0',
            'enabledKeyboardLanguages': 'en',
            'installId': 'installId',
            'timeZone': 'UTC',
            'connectionType': 'wifi',
            'freeDiskSpace': '64GB',
          };
        },
      );
      final apz = ApzDeviceFingerprint();
      final result = await apz.getFingerprint();
      expect(result, isA<String>());
      expect(result, isNotEmpty);
    });
  });
}
