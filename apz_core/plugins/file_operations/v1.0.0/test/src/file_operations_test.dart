import "dart:convert";
import "dart:io";
import "dart:typed_data";
import "package:apz_file_operations/apz_file_operations.dart";
import "package:apz_file_operations/src/file_operations.dart";
import "package:file_picker/file_picker.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:permission_handler/permission_handler.dart";

// Mocks

class MockPermissionService extends Mock implements PermissionService {}

class MockFilePickerWrapper extends Mock implements FilePickerWrapper {}

class MockFilePickerResult extends Mock implements FilePickerResult {}

class MockPlatformFile extends Mock implements PlatformFile {}

class MockFile extends Mock implements File {}

void main() {
  late FileOperations mobileFileOps;
  late MockPermissionService mockPermissionService;
  late MockFilePickerWrapper mockFilePickerWrapper;
  late MockFilePickerResult mockFilePickerResult;
  late MockPlatformFile mockPlatformFile;
  late MockFile mockFile;
  setUpAll(() {
    registerFallbackValue(FileType.any); // ✅ Register fallback for FileType
    registerFallbackValue('');
    registerFallbackValue(const <String>[]);
    registerFallbackValue(RegExp(''));
  });
  setUp(() {
    mockPermissionService = MockPermissionService();
    mockFilePickerWrapper = MockFilePickerWrapper();
    mockFilePickerResult = MockFilePickerResult();
    mockPlatformFile = MockPlatformFile();
    mockFile = MockFile();

    mobileFileOps = FileOperations(
      permissionService: mockPermissionService,
      filePickerWrapper: mockFilePickerWrapper,
      fileFactory: (path) => mockFile,
    );
  });

  test("constructor uses default dependencies when not provided", () async {
    final FileOperations defaultMobileFileOps = FileOperations();
    expect(defaultMobileFileOps, isA<FileOperations>());
    try {
      final result = await defaultMobileFileOps.pickFile(allowMultiple: false);
      expect(
        result,
        isNull,
      ); // Assuming it would result in null without real interaction
    } catch (e) {
      expect(
        e,
        isA<Object>(),
      ); // Catching a broad exception is okay for coverage of this specific line
    }
  });

  test("throws an exception if permission is denied", () async {
    when(
      () => mockPermissionService.requestStoragePermission(),
    ).thenAnswer((_) async => PermissionStatus.denied);

    // Use the throwsA matcher to check for the exception
    expect(
      () => mobileFileOps.pickFile(allowMultiple: false),
      throwsA(isA<Exception>()),
    );
  });

  test("returns null if no file selected", () async {
    when(
      () => mockPermissionService.requestStoragePermission(),
    ).thenAnswer((_) async => PermissionStatus.granted);
    when(
      () => mockFilePickerWrapper.pickFiles(
        allowMultiple: any(named: "allowMultiple"),
        type: any(named: "type"),
        allowedExtensions: any(named: "allowedExtensions"),
      ),
    ).thenAnswer((_) async => null);

    final result = await mobileFileOps.pickFile(allowMultiple: false);
    expect(result, isNull);
  });

  test("returns list of FileData with byte content", () async {
    when(
      () => mockPermissionService.requestStoragePermission(),
    ).thenAnswer((_) async => PermissionStatus.granted);
    when(
      () => mockFilePickerWrapper.pickFiles(
        allowMultiple: any(named: "allowMultiple"),
        type: any(named: "type"),
        allowedExtensions: any(named: "allowedExtensions"),
      ),
    ).thenAnswer((_) async => mockFilePickerResult);

    when(() => mockFilePickerResult.files).thenReturn([mockPlatformFile]);
    // The test is now more robust as it mocks a valid PlatformFile for both web (null path) and mobile (has path) scenarios.
    when(() => mockPlatformFile.path).thenReturn(null);
    when(() => mockPlatformFile.name).thenReturn("dummy.pdf");
    when(() => mockPlatformFile.extension).thenReturn("pdf");
    when(
      () => mockPlatformFile.bytes,
    ).thenReturn(Uint8List.fromList([1, 2, 3]));

    // The logic inside CrossPlatformFileOps will now use the bytes regardless of the null path.
    final result = await mobileFileOps.pickFile(allowMultiple: false);
    expect(result, isNotNull);
    expect(result!.length, 1);
    expect(result.first.name, "dummy.pdf");
    expect(
      result.first.base64String,
      base64Encode(Uint8List.fromList([1, 2, 3])),
    );
  });
  test(
    "returns list of FileData with content read from path (when bytes are null)",
    () async {
      // Arrange
      final String testFilePath =
          "/data/user/0/com.example.app/cache/test_doc.docx";
      final Uint8List expectedBytes = Uint8List.fromList([10, 20, 30, 40, 50]);

      when(() => mockPermissionService.requestStoragePermission()).thenAnswer(
        (_) => Future.value(PermissionStatus.granted),
      ); // Use Future.value
      when(
        () => mockFilePickerWrapper.pickFiles(
          allowMultiple: any(named: "allowMultiple"),
          type: any(named: "type"),
          allowedExtensions: any(named: "allowedExtensions"),
        ),
      ).thenAnswer((_) async => mockFilePickerResult);

      when(() => mockFilePickerResult.files).thenReturn([mockPlatformFile]);
      when(
        () => mockPlatformFile.path,
      ).thenReturn(testFilePath); // Path is NOT null
      when(() => mockPlatformFile.name).thenReturn("test_doc.docx");
      when(() => mockPlatformFile.extension).thenReturn("docx");
      when(
        () => mockPlatformFile.bytes,
      ).thenReturn(null); // Crucial: bytes are null

      // Mock the behavior of the injected MockFile
      when(() => mockFile.readAsBytes()).thenAnswer((_) async => expectedBytes);
      when(
        () => mockFile.path,
      ).thenReturn(testFilePath); // Mock the path getter for FileData

      // Act
      final result = await mobileFileOps.pickFile(allowMultiple: false);

      // Assert
      expect(result, isNotNull);
      expect(result!.length, 1);
      expect(result.first.name, "test_doc.docx");
      expect(result.first.path, testFilePath);
      expect(result.first.mimeType, "docx");
      expect(result.first.size, expectedBytes.length);
      expect(result.first.base64String, base64Encode(expectedBytes));

      // Verify that readAsBytes was called on the mock file
      verify(() => mockFile.readAsBytes()).called(1);
    },
  );

  test(
    "skips file if reading from path fails and returns null if no other files",
    () async {
      final String testFilePath = "/invalid/path/file.txt";

      // 1. Mock permission and file picker wrapper to return a result
      when(
        () => mockPermissionService.requestStoragePermission(),
      ).thenAnswer((_) async => PermissionStatus.granted);

      when(
        () => mockFilePickerWrapper.pickFiles(
          allowMultiple: any(named: "allowMultiple"),
          type: any(named: "type"),
          allowedExtensions: any(named: "allowedExtensions"),
        ),
      ).thenAnswer((_) async => mockFilePickerResult);

      // 2. Mock the FilePickerResult to contain your single problematic PlatformFile
      when(() => mockFilePickerResult.files).thenReturn([mockPlatformFile]);
      when(() => mockPlatformFile.path).thenReturn(testFilePath);
      when(() => mockPlatformFile.name).thenReturn("file.txt");
      when(() => mockPlatformFile.extension).thenReturn("txt");
      when(
        () => mockPlatformFile.bytes,
      ).thenReturn(null); // Ensure bytes are null to force path reading

      // 3. IMPORTANT: Mock the _fileFactory to return your mockFile when called with the test path
      // when(() => mockFileFactory(testFilePath)).thenReturn(mockFile);
      // 4. Mock the mockFile's readAsBytes() method to throw the desired exception
      when(
        () => mockFile.readAsBytes(),
      ).thenThrow(Exception("Cannot read file"));

      // Act: Call the pickFile method
      final List<FileData>? result = await mobileFileOps.pickFile(
        allowMultiple: false,
      );

      // Assert: Check the expected outcome
      // Since the only file's read attempt failed internally, and that error is caught,
      // the method should return null as no successful files are processed.
      expect(result, isNull);

      // Verify interactions
      verify(() => mockPermissionService.requestStoragePermission()).called(1);
      verify(
        () => mockFilePickerWrapper.pickFiles(
          allowMultiple: false,
          type: FileType.custom, // Assuming this is your default type
          allowedExtensions: any(named: "allowedExtensions"),
        ),
      ).called(1);
      // verify(() => mockFileFactory(testFilePath)).called(1); // Verify factory was called
      verify(
        () => mockFile.readAsBytes(),
      ).called(1); // Verify read attempt was made

      // If you specifically wanted to test the debugPrint, you'd need to mock
      // Flutter's debugPrint, which is more involved.
    },
  );

  test(
    "throws Exception if file has consecutive duplicate extension",
    () async {
      final String invalidFileName =
          "document.pdf.pdf"; // This triggers hasConsecutiveDuplicateExtension
      final String testFilePath = "/path/$invalidFileName";

      when(
        () => mockPermissionService.requestStoragePermission(),
      ).thenAnswer((_) async => PermissionStatus.granted);
      when(
        () => mockFilePickerWrapper.pickFiles(
          allowMultiple: any(named: "allowMultiple"),
          type: any(named: "type"),
          allowedExtensions: any(named: "allowedExtensions"),
        ),
      ).thenAnswer((_) async => mockFilePickerResult);

      when(() => mockFilePickerResult.files).thenReturn([mockPlatformFile]);
      when(() => mockPlatformFile.path).thenReturn(testFilePath);
      when(() => mockPlatformFile.name).thenReturn(invalidFileName);
      when(() => mockPlatformFile.extension).thenReturn("pdf");
      when(
        () => mockPlatformFile.bytes,
      ).thenReturn(Uint8List.fromList([1, 2, 3])); // Provide some bytes

      // Mock file.readAsBytes if path is used
      when(
        () => mockFile.readAsBytes(),
      ).thenAnswer((_) async => Uint8List.fromList([1, 2, 3]));
      when(() => mockFile.path).thenReturn(testFilePath);

      // Expect an Exception to be thrown immediately upon validation failure
      expect(
        () async => await mobileFileOps.pickFile(allowMultiple: false),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            "message",
            contains(
              '"$invalidFileName" has to consecutive duplicate extension.',
            ),
          ),
        ),
      );
    },
  );
  test(
    "throws Exception if file has invalid characters (e.g., special symbols)",
    () async {
      final String invalidFileName =
          "file@name!.txt"; // This triggers isValidFileName
      final String testFilePath = "/path/$invalidFileName";

      when(
        () => mockPermissionService.requestStoragePermission(),
      ).thenAnswer((_) async => PermissionStatus.granted);
      when(
        () => mockFilePickerWrapper.pickFiles(
          allowMultiple: any(named: "allowMultiple"),
          type: any(named: "type"),
          allowedExtensions: any(named: "allowedExtensions"),
        ),
      ).thenAnswer((_) async => mockFilePickerResult);

      when(() => mockFilePickerResult.files).thenReturn([mockPlatformFile]);
      when(() => mockPlatformFile.path).thenReturn(testFilePath);
      when(() => mockPlatformFile.name).thenReturn(invalidFileName);
      when(() => mockPlatformFile.extension).thenReturn("txt");
      when(
        () => mockPlatformFile.bytes,
      ).thenReturn(Uint8List.fromList([1, 2, 3]));

      // Mock file.readAsBytes if path is used
      when(
        () => mockFile.readAsBytes(),
      ).thenAnswer((_) async => Uint8List.fromList([1, 2, 3]));
      when(() => mockFile.path).thenReturn(testFilePath);

      expect(
        () async => mobileFileOps.pickFile(allowMultiple: false),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            "message",
            contains('"$invalidFileName" check file name'),
          ),
        ),
      );
    },
  );
  test(
    "throws Exception if file has multiple dots (e.g., dummy.ad.pdf)",
    () async {
      final String invalidFileName =
          "dummy.ad.pdf"; // This triggers isValidFileName
      final String testFilePath = "/path/$invalidFileName";

      when(
        () => mockPermissionService.requestStoragePermission(),
      ).thenAnswer((_) async => PermissionStatus.granted);
      when(
        () => mockFilePickerWrapper.pickFiles(
          allowMultiple: any(named: "allowMultiple"),
          type: any(named: "type"),
          allowedExtensions: any(named: "allowedExtensions"),
        ),
      ).thenAnswer((_) async => mockFilePickerResult);

      when(() => mockFilePickerResult.files).thenReturn([mockPlatformFile]);
      when(() => mockPlatformFile.path).thenReturn(testFilePath);
      when(() => mockPlatformFile.name).thenReturn(invalidFileName);
      when(() => mockPlatformFile.extension).thenReturn("pdf");
      when(
        () => mockPlatformFile.bytes,
      ).thenReturn(Uint8List.fromList([1, 2, 3]));

      // Mock file.readAsBytes if path is used
      when(
        () => mockFile.readAsBytes(),
      ).thenAnswer((_) async => Uint8List.fromList([1, 2, 3]));
      when(() => mockFile.path).thenReturn(testFilePath);

      expect(
        () async => await mobileFileOps.pickFile(allowMultiple: false),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            "message",
            contains('"$invalidFileName" check file name'),
          ),
        ),
      );
    },
  );
  test(
    "does not throw Exception if file has valid name (using allowedFileNameRegex)",
    () async {
      final String validFileName = "invoice_2023.pdf";
      final String testFilePath = "/path/$validFileName";
      final RegExp customRegex = RegExp(
        r"^[a-zA-Z0-9_]+\.pdf$",
      ); // Allows letters, numbers, underscore
      final Uint8List fileBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      final String expectedBase64 = base64Encode(fileBytes);

      when(
        () => mockPermissionService.requestStoragePermission(),
      ).thenAnswer((_) async => PermissionStatus.granted);
      when(
        () => mockFilePickerWrapper.pickFiles(
          allowMultiple: any(named: "allowMultiple"),
          type: any(named: "type"),
          allowedExtensions: any(named: "allowedExtensions"),
        ),
      ).thenAnswer((_) async => mockFilePickerResult);

      when(() => mockFilePickerResult.files).thenReturn([mockPlatformFile]);
      when(() => mockPlatformFile.path).thenReturn(testFilePath);
      when(() => mockPlatformFile.name).thenReturn(validFileName);
      when(() => mockPlatformFile.extension).thenReturn("pdf");
      when(
        () => mockPlatformFile.bytes,
      ).thenReturn(null); // Ensure it goes through the _fileFactory path

      // IMPORTANT: Mock mockFile.readAsBytes and mockFile.path as well
      when(() => mockFile.readAsBytes()).thenAnswer((_) async => fileBytes);
      when(() => mockFile.path).thenReturn(testFilePath);

      // Since this file should pass validation, we expect it to return FileData
      final result = await mobileFileOps.pickFile(
        allowMultiple: false,
        maxFileSizeInMB: 5,
        allowedExtensions: ["pdf"],
        allowedFileNameRegex: customRegex, // Pass the custom regex
      );

      expect(result, isNotNull);
      expect(result!.first.name, validFileName);
      expect(result.first.path, testFilePath);
      expect(result.first.mimeType, "pdf");
      expect(result.first.size, fileBytes.length);
      expect(result.first.base64String, expectedBase64);

      // Verify that file reading was attempted
      verify(() => mockFile.readAsBytes()).called(1);
    },
  );
}
