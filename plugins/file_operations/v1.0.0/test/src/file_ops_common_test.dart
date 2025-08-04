import "dart:convert";
import "dart:typed_data";
import "package:apz_file_operations/apz_file_operations.dart"; // Ensure this imports FileData and FileOps
import "package:flutter_test/flutter_test.dart";

// --- Mock Implementation of FileOps for Testing ---
class MockFileOps implements FileOps {
  // Variables to control behavior and capture arguments for verification
  bool pickFileShouldReturnNull = false;
  List<FileData>? pickFileReturnValue;

  // No longer needed since writeFile is not in the new FileOps abstract class
  // bool writeFileShouldFail = false;
  // String? writeFileCapturedPath;
  // Uint8List? writeFileCapturedBytes;

  @override
  Future<List<FileData>?> pickFile({
    bool allowMultiple = false,
    List<String> allowedExtensions = const [],
    // These are now required parameters, ensure they have default values in the mock
    RegExp? allowedFileNameRegex,
    int maxFileSizeInMB = 0,
  }) async {
    if (pickFileShouldReturnNull) {
      return null;
    }
    if (pickFileReturnValue != null) {
      return pickFileReturnValue;
    }
    // Default return value if not explicitly set
    return [
      FileData(
        name: "mock_picked_file.txt",
        path: "/mock/path/mock_picked_file.txt",
        mimeType: "text/plain",
        size: 100,
        // base64String is now a String
        base64String: base64Encode(
          Uint8List.fromList([1, 2, 3]),
        ),
      ),
    ];
  }

  // --- Helper methods to set up mock behavior for specific test cases ---
  void setPickFileResult(List<FileData>? result) {
    pickFileReturnValue = result;
    pickFileShouldReturnNull = result == null;
  }

  // writeFile related mock setup methods are no longer needed as per new FileOps
  // void setWriteFileFailure(bool fail) {
  //   writeFileShouldFail = fail;
  // }
}
// --- End of Mock Implementation ---

void main() {
  group("FileData", () {
    test("FileData constructor assigns values correctly", () {
      final Uint8List testBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      final String testBase64 = base64Encode(testBytes);
      final FileData fileData = FileData(
        name: "test_file.txt",
        path: "/path/to/test_file.txt",
        mimeType: "text/plain",
        size: 5,
        base64String: testBase64, // Now a String
      );

      expect(fileData.name, "test_file.txt");
      expect(fileData.path, "/path/to/test_file.txt");
      expect(fileData.mimeType, "text/plain");
      expect(fileData.size, 5);
      expect(fileData.base64String, testBase64); // Compare strings
    });

    test("FileData properties are final", () {
      final Uint8List originalBytes = Uint8List.fromList([10, 20]);
      final String originalBase64 = base64Encode(originalBytes);
      final FileData fileData = FileData(
        name: "immutable.pdf",
        path: "/tmp/immutable.pdf",
        mimeType: "application/pdf",
        size: 2,
        base64String: originalBase64, // Now a String
      );

      // Attempting to reassign will cause a compile-time error,
      // confirming they are final. This test mainly serves as documentation.
      // fileData.name = "new_name.pdf"; // Uncommenting this line will show a compile error.

      // Verify that the base64String is indeed a String and its value is correct
      expect(fileData.base64String, originalBase64);
    });

    test("FileData with empty/zero values", () {
      final Uint8List emptyBytes = Uint8List(0);
      final String emptyBase64 = base64Encode(emptyBytes);
      final FileData fileData = FileData(
        name: "",
        path: "",
        mimeType: "",
        size: 0,
        base64String: emptyBase64, // Now a String
      );

      expect(fileData.name, "");
      expect(fileData.path, "");
      expect(fileData.mimeType, "");
      expect(fileData.size, 0);
      expect(fileData.base64String, isEmpty);
      expect(fileData.base64String, emptyBase64);
    });
  });

  group("FileOps (Mock Implementation)", () {
    late MockFileOps mockFileOps;

    setUp(() {
      // Initialize a new mock instance before each test
      mockFileOps = MockFileOps();
    });

    group("pickFile method", () {
      test("should return FileData when picking a file successfully", () async {
        final Uint8List testBytes = Uint8List.fromList([10, 20, 30]);
        final String testBase64 = base64Encode(testBytes);

        final List<FileData> expectedFileData = [
          FileData(
            name: "test.pdf",
            path: "/temp/test.pdf",
            mimeType: "application/pdf",
            size: 1024,
            base64String: testBase64, // Now a String
          ),
        ];
        mockFileOps.setPickFileResult(expectedFileData); // Configure mock behavior

        final List<FileData>? result = await mockFileOps.pickFile(
          allowMultiple: false,
          allowedExtensions: const ["pdf"],
          maxFileSizeInMB: 5,
          allowedFileNameRegex: null,
        );

        expect(result, isNotNull);
        expect(result!.first.name, expectedFileData.first.name);
        expect(result.first.path, expectedFileData.first.path);
        expect(result.first.mimeType, expectedFileData.first.mimeType);
        expect(result.first.size, expectedFileData.first.size);
        expect(result.first.base64String, expectedFileData.first.base64String);
      });

      test(
        "should return null when file picking is cancelled or fails",
        () async {
          mockFileOps.setPickFileResult(null); // Configure mock to return null

          final List<FileData>? result = await mockFileOps.pickFile(
            allowMultiple: false,
            allowedExtensions: const [],
            maxFileSizeInMB: 0,
            allowedFileNameRegex: null,
          );

          expect(result, isNull);
        },
      );

      test("pickFile method handles new parameters correctly", () async {
        final List<FileData> expectedFileData = [
          FileData(
            name: "document.docx",
            path: "/path/document.docx",
            mimeType: "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
            size: 2000,
            base64String: base64Encode(Uint8List.fromList([1, 2, 3, 4])),
          ),
        ];
        mockFileOps.setPickFileResult(expectedFileData);

        final List<FileData>? result = await mockFileOps.pickFile(
          allowMultiple: true,
          allowedExtensions: const ["docx", "txt"],
          maxFileSizeInMB: 10,
          allowedFileNameRegex: RegExp(r"^[a-zA-Z0-9]+\.docx$"),
        );

        expect(result, isNotNull);
        expect(result!.first.name, "document.docx");
        // We can't directly verify the passed parameters within MockFileOps without making it more complex
        // (e.g., storing the parameters in local variables within the mock).
        // However, the test passes if the call doesn't throw a compile error due to missing parameters.
        // For more robust parameter verification in mocks, libraries like `mocktail` or `mockito` are preferred.
      });
    });
  });
}