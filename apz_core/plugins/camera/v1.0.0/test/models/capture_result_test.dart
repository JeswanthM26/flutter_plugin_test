import 'package:flutter_test/flutter_test.dart';
import 'package:apz_camera/models/capture_result.dart';

void main() {
  test('CaptureResult assigns properties correctly', () {
    final result = CaptureResult(
      filePath: '/tmp/test.jpg',
      base64String: 'abc123',
      fileSizeBytes: 1234,
      isCanceled: false,
    );
    expect(result.filePath, '/tmp/test.jpg');
    expect(result.base64String, 'abc123');
    expect(result.fileSizeBytes, 1234);
    expect(result.isCanceled, false);
  });
}
