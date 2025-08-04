// test/file_ops_test.dart
import "dart:convert";
import "dart:typed_data";
import "package:apz_file_operations/apz_file_operations.dart"; // Imports the public ApzFileOperations class
import "package:apz_file_operations/src/file_ops_common.dart"; // Needed to mock the internal interface
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";

// Mock class for the FileOps interface
class MockFileOps extends Mock implements FileOps {}

void main() {
  group("ApzFileOperations", () {
    late ApzFileOperations apzFileOperations;
    late MockFileOps mockFileOps;

    // Define the default allowed extensions that the public pickFile uses internally
    const List<String> defaultExpectedExtensions = [
      "pdf", "docx", "txt", "xlsx", "csv",
    ];

    setUp(() {
      apzFileOperations = ApzFileOperations(); // Get the singleton instance
      mockFileOps = MockFileOps();
      // Inject the mock into the public API's internal _ops using the setter
      apzFileOperations.fileOpsOverride = mockFileOps;

      // Register a fallback value for `any(named:)` for lists and RegExp, as Mocktail sometimes needs it
      registerFallbackValue(const <String>[]);
      registerFallbackValue(RegExp("")); // Register fallback for RegExp
    });

    // Reset the mock after each test to ensure clean state
    tearDown(() {
      reset(mockFileOps);
    });

    test("returns a list of FileData when file is picked (default args)", () async {
      final fileData = FileData(
        name: "sample.pdf",
        path: "/dummy/sample.pdf",
        mimeType: "application/pdf",
        size: 100,
        base64String: base64Encode(Uint8List.fromList([1, 2, 3])),
      );

      // When the *injected* mockFileOps.pickFile is called by the public pickFile,
      // it should match the arguments that the public pickFile function passes to it.
      // We expect allowMultiple: false and the default extensions, along with new defaults.
      when(() => mockFileOps.pickFile(
            allowMultiple: false,
            allowedExtensions: defaultExpectedExtensions,
            maxFileSizeInMB: 5, // New default
            allowedFileNameRegex: null, // New default
          )).thenAnswer((_) async => [fileData]);

      // Call the public pickFile method from the singleton instance (with default arguments)
      final result = await apzFileOperations.pickFile();

      // Assertions for the returned result
      expect(result, isNotNull);
      expect(result!.length, 1);
      expect(result.first.name, "sample.pdf");

      // Verify that the mock was called exactly once with the correct arguments
      verify(() => mockFileOps.pickFile(
            allowMultiple: false,
            allowedExtensions: defaultExpectedExtensions,
            maxFileSizeInMB: 5,
            allowedFileNameRegex: null,
          )).called(1);
    });

    test("returns a list of FileData when file is picked (with custom args)", () async {
      final fileData = FileData(
        name: "document_123.docx",
        path: "/docs/document_123.docx",
        mimeType: "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
        size: 500,
        base64String: base64Encode(Uint8List.fromList([7, 8, 9])),
      );

      const List<String> additionalExtensions = ["mp4", "png"]; // From your new code
      const int customMaxFileSize = 20; // From your new code
      final RegExp customRegex = RegExp(r"^[a-zA-Z0-9_\-().]+$"); // From your new code

      // Combine default and additional extensions as the public pickFile would.
      // Sort to ensure consistent order for mocking and verification, as Set might reorder elements.
      final List<String> expectedCombinedExtensions = (
        Set<String>.from(defaultExpectedExtensions)..addAll(additionalExtensions)
      ).toList()..sort();

      // Mock the internal pickFile call.
      when(() => mockFileOps.pickFile(
            allowMultiple: true, // Specific argument for this test
            allowedExtensions: any(named: "allowedExtensions", that: containsAll(expectedCombinedExtensions)),
            maxFileSizeInMB: customMaxFileSize,
            allowedFileNameRegex: any(named: "allowedFileNameRegex", that: equals(customRegex)),
          )).thenAnswer((_) async => [fileData]);

      // Call the public pickFile with specific arguments for this test
      final result = await apzFileOperations.pickFile(
        allowMultiple: true,
        additionalExtensions: additionalExtensions,
        maxFileSizeInMB: customMaxFileSize,
        allowedFileNameRegex: customRegex,
      );

      // Assertions for the returned result
      expect(result, isNotNull);
      expect(result!.length, 1);
      expect(result.first.name, "document_123.docx");

      // Verify that the mock was called with the correct arguments
      verify(() => mockFileOps.pickFile(
            allowMultiple: true,
            allowedExtensions: any(named: "allowedExtensions", that: containsAll(expectedCombinedExtensions)),
            maxFileSizeInMB: customMaxFileSize,
            allowedFileNameRegex: any(named: "allowedFileNameRegex", that: equals(customRegex)),
          )).called(1);
    });

    test("returns null when no file picked", () async {
      // Mock the internal pickFile call matching the default arguments, returning null.
      when(() => mockFileOps.pickFile(
            allowMultiple: false,
            allowedExtensions: defaultExpectedExtensions,
            maxFileSizeInMB: 5,
            allowedFileNameRegex: null,
          )).thenAnswer((_) async => null);

      // Call the public pickFile with default arguments
      final result = await apzFileOperations.pickFile();

      // Assert the result is null
      expect(result, isNull);

      // Verify that the mock was called with the correct arguments
      verify(() => mockFileOps.pickFile(
            allowMultiple: false,
            allowedExtensions: defaultExpectedExtensions,
            maxFileSizeInMB: 5,
            allowedFileNameRegex: null,
          )).called(1);
    });

    test("throws Exception when internal FileOps throws an Exception", () async {
      final String errorMessage = "File 'invalid.name.pdf' contains disallowed characters.";
      final RegExp customRegex = RegExp(r"^[a-zA-Z0-9_\-().]+$");

      // Mock the internal pickFile call to throw a generic Exception
      when(() => mockFileOps.pickFile(
            allowMultiple: true, // Arbitrary, could be false too
            allowedExtensions: any(named: "allowedExtensions"), // Match any list of extensions
            maxFileSizeInMB: any(named: "maxFileSizeInMB"), // Match any int
            allowedFileNameRegex: any(named: "allowedFileNameRegex"), // Match any RegExp or null
          )).thenThrow(Exception(errorMessage)); // Make the mock throw the Exception

      // Call the public pickFile and expect it to rethrow the exception
      expect(
        () async => await apzFileOperations.pickFile(
          allowMultiple: true,
          additionalExtensions: ["zip"],
          maxFileSizeInMB: 10,
          allowedFileNameRegex: customRegex,
        ),
        throwsA(isA<Exception>().having(
          (e) => e.toString(), // Access the string representation of the exception
          "toString()",
          contains(errorMessage), // Check if the message contains the expected substring
        )),
      );

      // Verify that the internal mock was called as expected with the passed arguments
      verify(() => mockFileOps.pickFile(
            allowMultiple: true,
            allowedExtensions: any(named: "allowedExtensions"),
            maxFileSizeInMB: 10,
            allowedFileNameRegex: any(named: "allowedFileNameRegex"),
          )).called(1);
    });
  });
}