@TestOn('browser')
import 'package:flutter_test/flutter_test.dart';
import 'package:apz_device_fingerprint/src/web_fingerprint.dart';
import 'package:apz_device_fingerprint/utils/fingerprint_utils.dart';
import 'package:universal_html/html.dart' as html;


class MockFingerprintUtils extends FingerprintUtils {
  @override
  String generateRandomString() => 'mockRandomString';

  @override
  String generateDigest(List<String> deviceFingerprintList) => 'mockDigest';

  @override
  Future<String?> getLatLong() async => '12.34,56.78';
}

class TestableFingerprintData extends FingerprintData {
  @override
  Future<Map<String, String>> getFullWebGLProfile() async {
    // Return a fake profile to avoid CanvasElement.getContext error
    return {
      'UNMASKED_RENDERER_WEBGL': 'FakeRenderer',
      'VERSION': 'FakeVersion',
    };
  }
}

void main() {
  group('Web FingerprintData', () {
    late TestableFingerprintData fingerprintData;
    late MockFingerprintUtils mockUtils;

    setUp(() {
      fingerprintData = TestableFingerprintData();
      mockUtils = MockFingerprintUtils();
      html.window.localStorage.clear();
      html.window.sessionStorage.clear();
    });

    test('getFingerprint returns digest', () async {
      final result = await fingerprintData.getFingerprint(mockUtils);
      expect(result, 'mockDigest');
    });
  });
}
