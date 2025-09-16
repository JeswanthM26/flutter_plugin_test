import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apz_device_fingerprint/src/mobile_fingerprint.dart';
import 'package:apz_device_fingerprint/utils/fingerprint_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart";

import "../fake_shared_preferences_async.dart";

class MockFingerprintUtils extends FingerprintUtils {
  @override
  String generateRandomString() => 'mockRandomString';

  @override
  String generateDigest(List<String> deviceFingerprintList) => 'mockDigest';

  @override
  Future<String?> getLatLong() async => '12.34,56.78';
}

// Remove MockApzPreference, not used in tests

void main() {
  SharedPreferences.setMockInitialValues({});
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FingerprintData', () {
    late FingerprintData fingerprintData;
    late MockFingerprintUtils mockUtils;
    const methodChannel = MethodChannel('com.iexceed/apz_device_fingerprint');

    setUp(() {
      fingerprintData = FingerprintData();
      mockUtils = MockFingerprintUtils();
      SharedPreferencesAsyncPlatform.instance = FakeSharedPreferencesAsync();
    });

    test('returns digest for Android', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(methodChannel, (
            MethodCall methodCall,
          ) async {
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
          });
      final result = await fingerprintData.getFingerprint(mockUtils);
      expect(result, 'mockDigest');
    });

    test('returns digest for iOS', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(methodChannel, (
            MethodCall methodCall,
          ) async {
            return {
              'source': 'ios',
              'secureId': 'secureId',
              'deviceManufacturer': 'Apple',
              'deviceModel': 'iPhone',
              'screenResolution': '1170x2532',
              'deviceType': 'phone',
              'totalDiskSpace': '256GB',
              'totalRAM': '6GB',
              'cpuCount': '6',
              'cpuArchitecture': 'arm64',
              'cpuEndianness': 'little',
              'deviceName': 'iPhone',
              'glesVersion': '3.2',
              'osVersion': '15',
              'osBuildNumber': '19A346',
              'kernelVersion': 'Darwin',
              'enabledKeyboardLanguages': 'en',
              'installId': 'installId',
              'timeZone': 'UTC',
              'connectionType': 'wifi',
              'freeDiskSpace': '128GB',
            };
          });
      final result = await fingerprintData.getFingerprint(mockUtils);
      expect(result, 'mockDigest');
    });

    test('throws exception on method channel error', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(methodChannel, (
            MethodCall methodCall,
          ) async {
            throw PlatformException(code: 'ERROR', message: 'Failed');
          });
      expect(
        () async => await fingerprintData.getFingerprint(mockUtils),
        throwsException,
      );
    });
  });
}
