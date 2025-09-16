import 'package:apz_file_operations/src/file_data.dart';
import "package:flutter_test/flutter_test.dart";


void main() {
  group('FileData', () {
    // Test case 1: Ensure all properties are correctly assigned when the path is not null.
    test('should create a FileData object with all properties set correctly', () {
      final fileData = FileData(
        name: 'test_document.pdf',
        path: '/user/documents/test_document.pdf',
        mimeType: 'application/pdf',
        size: 1024,
        base64String: 'JVBERi0xLjQKJcO',
      );

      expect(fileData.name, 'test_document.pdf');
      expect(fileData.path, '/user/documents/test_document.pdf');
      expect(fileData.mimeType, 'application/pdf');
      expect(fileData.size, 1024);
      expect(fileData.base64String, 'JVBERi0xLjQKJcO');
    });

    // Test case 2: Ensure the path can be null, which is common for web platforms.
    test('should handle a null path gracefully', () {
      final fileData = FileData(
        name: 'web_image.jpg',
        path: "", // Path is null for web platforms
        mimeType: 'image/jpeg',
        size: 2048,
        base64String: 'aGVsbG8gYmFzZTY0',
      );

      expect(fileData.name, 'web_image.jpg');
      expect(fileData.path, "");
      expect(fileData.mimeType, 'image/jpeg');
      expect(fileData.size, 2048);
      expect(fileData.base64String, 'aGVsbG8gYmFzZTY0');
    });

    // Test case 3: Verify behavior with empty or zero-value properties.
    test('should handle empty name, mimeType, and base64String and zero size', () {
      final fileData = FileData(
        name: '',
        path: "",
        mimeType: '',
        size: 0,
        base64String: '',
      );

      expect(fileData.name, '');
      expect(fileData.path, "");
      expect(fileData.mimeType, '');
      expect(fileData.size, 0);
      expect(fileData.base64String, '');
    });
  });
}
