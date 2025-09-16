import "dart:convert";
import "dart:typed_data";
import "package:apz_file_operations/apz_file_operations.dart"; // Imports the public ApzFileOperations class
// Needed to mock the internal interface
import "package:apz_file_operations/src/file_operations.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";

// Mock class for the FileOps interface
class FileOps extends Mock implements FileOperations {}

void main() {
  group("ApzFileOperations", () {
    late ApzFileOperations apzFileOperations;
    late FileOps mockFileOps;

    // Define the default allowed extensions that the public pickFile uses internally
    const List<String> defaultExpectedExtensions = [
      "pdf", "docx", "txt", "xlsx", "csv",
    ];

    setUp(() {
      // NOTE: We now create a new instance of the class because it's no longer a singleton.
      apzFileOperations = ApzFileOperations();
      mockFileOps = FileOps();
      // Inject the mock into the public API's internal _ops using the setter
      apzFileOperations.fileOpsOverride = mockFileOps;

      // Register a fallback value for `any(named:)` for lists and RegExp, as Mocktail sometimes needs it
      registerFallbackValue(const <String>[]);
      registerFallbackValue(RegExp("")); // Register fallback for RegExp
    });

    // Reset the mock after each test to ensure a clean state
    tearDown(() {
      reset(mockFileOps);
    });

    test("returns a list of FileData when a file is picked (default args)", () async {
      final fileData = FileData(
        name: "sample.pdf",
        path: "/dummy/sample.pdf",
        mimeType: "application/pdf",
        size: 100,
        base64String: base64Encode(Uint8List.fromList([1, 2, 3])),
      );

      when(() => mockFileOps.pickFile(
            allowMultiple: false,
            allowedExtensions: defaultExpectedExtensions,
            maxFileSizeInMB: 5,
            allowedFileNameRegex: null,
          )).thenAnswer((_) async => [fileData]);

      final result = await apzFileOperations.pickFile();

      expect(result, isNotNull);
      expect(result!.length, 1);
      expect(result.first.name, "sample.pdf");

      verify(() => mockFileOps.pickFile(
            allowMultiple: false,
            allowedExtensions: defaultExpectedExtensions,
            maxFileSizeInMB: 5,
            allowedFileNameRegex: null,
          )).called(1);
    });

    test("returns a list of FileData when multiple files are picked (with custom args)", () async {
      final fileData = FileData(
        name: "document_123.docx",
        path: "/docs/document_123.docx",
        mimeType: "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
        size: 500,
        base64String: base64Encode(Uint8List.fromList([7, 8, 9])),
      );

      const List<String> additionalExtensions = ["mp4", "png"];
      const int customMaxFileSize = 20;
      final RegExp customRegex = RegExp(r"^[a-zA-Z0-9_\-().]+$");

      // Combine default and additional extensions as the public pickFile would.
      // Sort to ensure consistent order for mocking and verification.
      final List<String> expectedCombinedExtensions = (
          Set<String>.from(defaultExpectedExtensions)..addAll(additionalExtensions)
      ).toList()..sort();

      when(() => mockFileOps.pickFile(
            allowMultiple: true,
            allowedExtensions: any(named: "allowedExtensions", that: containsAll(expectedCombinedExtensions)),
            maxFileSizeInMB: customMaxFileSize,
            allowedFileNameRegex: any(named: "allowedFileNameRegex", that: equals(customRegex)),
          )).thenAnswer((_) async => [fileData]);

      final result = await apzFileOperations.pickFile(
        allowMultiple: true,
        additionalExtensions: additionalExtensions,
        maxFileSizeInMB: customMaxFileSize,
        allowedFileNameRegex: customRegex,
      );

      expect(result, isNotNull);
      expect(result!.length, 1);
      expect(result.first.name, "document_123.docx");

      verify(() => mockFileOps.pickFile(
            allowMultiple: true,
            allowedExtensions: any(named: "allowedExtensions", that: containsAll(expectedCombinedExtensions)),
            maxFileSizeInMB: customMaxFileSize,
            allowedFileNameRegex: any(named: "allowedFileNameRegex", that: equals(customRegex)),
          )).called(1);
    });

    test("returns null when no file is picked", () async {
      when(() => mockFileOps.pickFile(
            allowMultiple: false,
            allowedExtensions: defaultExpectedExtensions,
            maxFileSizeInMB: 5,
            allowedFileNameRegex: null,
          )).thenAnswer((_) async => null);

      final result = await apzFileOperations.pickFile();

      expect(result, isNull);

      verify(() => mockFileOps.pickFile(
            allowMultiple: false,
            allowedExtensions: defaultExpectedExtensions,
            maxFileSizeInMB: 5,
            allowedFileNameRegex: null,
          )).called(1);
    });

    test("throws an Exception when the internal FileOps throws an Exception", () async {
      final String errorMessage = "File 'invalid.name.pdf' contains disallowed characters.";
      final RegExp customRegex = RegExp(r"^[a-zA-Z0-9_\-().]+$");

      when(() => mockFileOps.pickFile(
            allowMultiple: any(named: "allowMultiple"),
            allowedExtensions: any(named: "allowedExtensions"),
            maxFileSizeInMB: any(named: "maxFileSizeInMB"),
            allowedFileNameRegex: any(named: "allowedFileNameRegex"),
          )).thenThrow(Exception(errorMessage));

      expect(
        () async => await apzFileOperations.pickFile(
          allowMultiple: true,
          additionalExtensions: ["zip"],
          maxFileSizeInMB: 10,
          allowedFileNameRegex: customRegex,
        ),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          "toString()",
          contains(errorMessage),
        )),
      );

      verify(() => mockFileOps.pickFile(
            allowMultiple: true,
            allowedExtensions: any(named: "allowedExtensions"),
            maxFileSizeInMB: 10,
            allowedFileNameRegex: any(named: "allowedFileNameRegex"),
          )).called(1);
    });
  });
}
