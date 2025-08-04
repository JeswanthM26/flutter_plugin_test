import "dart:convert";
import "dart:io";
import "dart:typed_data";
import "package:apz_camera/apz_camera.dart";
import "package:apz_camera/camera_result.dart";
import "package:apz_camera/enum.dart";
import "package:flutter_test/flutter_test.dart";
import "package:image_cropper/image_cropper.dart";
import "package:image_picker/image_picker.dart";
import "package:mocktail/mocktail.dart";
import "package:permission_handler_platform_interface/permission_handler_platform_interface.dart";
import "package:path_provider_platform_interface/path_provider_platform_interface.dart";

class MockImagePicker extends Mock implements ImagePicker {}

class MockXFile extends Mock implements XFile {}

class MockImageCropper extends Mock implements ImageCropper {}

class MockCroppedFile extends Mock implements CroppedFile {}

class MockPathProviderPlatform extends Fake implements PathProviderPlatform {}

class FakePermissionHandler extends PermissionHandlerPlatform {
  @override
  Future<PermissionStatus> checkPermissionStatus(
    final Permission permission,
  ) async {
    return PermissionStatus.granted;
  }

  @override
  Future<Map<Permission, PermissionStatus>> requestPermissions(
    final List<Permission> permissions,
  ) async {
    return {for (var p in permissions) p: PermissionStatus.granted};
  }

  @override
  Future<bool> isLocationServiceEnabled() async => true;

  @override
  Future<ServiceStatus> checkServiceStatus(final Permission permission) async =>
      ServiceStatus.enabled;

  @override
  Future<bool> openAppSettings() async => true;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ApzCamera apzCamera;
  late MockImagePicker mockPicker;
  late MockImageCropper mockCropper;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
    registerFallbackValue(ImageSource.camera);
    registerFallbackValue(CameraDevice.front);
  });

  setUp(() {
    mockPicker = MockImagePicker();
    mockCropper = MockImageCropper();
    PermissionHandlerPlatform.instance = FakePermissionHandler();
    apzCamera = ApzCamera();
  });

  test("successfully picks image without cropping", () async {
    final mockFile = MockXFile();
    final dummyBytes = Uint8List.fromList([0, 1, 2]);

    // Mock image picker return
    when(
      () => mockPicker.pickImage(
        source: ImageSource.camera,
        imageQuality: any(named: "imageQuality"),
        preferredCameraDevice: any(named: "preferredCameraDevice"),
        maxHeight: any(named: "maxHeight"),
        maxWidth: any(named: "maxWidth"),
      ),
    ).thenAnswer((_) async => mockFile);

    // Mock XFile bytes
    when(() => mockFile.readAsBytes()).thenAnswer((_) async => dummyBytes);

    // Mock file writing
    final tempFile = File("${Directory.systemTemp.path}/test.jpg");
    if (!await tempFile.exists()) {
      await tempFile.create(recursive: true);
    }

    // Act
    final result = await apzCamera.handlePickedFile(
      mockFile,
      crop: false,
      quality: 80,
      fileName: "test",
      format: ImageFormat.jpeg,
      cropTitle: "Crop Image",
    );

    // Assert
    expect(result, isA<CameraResult>());
    expect(result.base64String, base64Encode(dummyBytes));
    expect(result.imageFile!.existsSync(), isTrue);
  });

  test('Convert file to base64 string', () async {
    final plugin = ApzCamera();

    final tempDir = await Directory.systemTemp.createTemp('base64_test_');
    final tempFile = File('${tempDir.path}/test.txt');
    await tempFile.writeAsString('Hello World');

    final expected = base64Encode(utf8.encode('Hello World'));
    final actual = await plugin.convertToBase64(tempFile);

    expect(actual, equals(expected));
  });

  test('Convert empty file to base64 string', () async {
    final plugin = ApzCamera();

    final tempDir = await Directory.systemTemp.createTemp('base64_test_');
    final emptyFile = File('${tempDir.path}/empty.txt');
    await emptyFile.writeAsString(''); // Write empty content

    final expected = base64Encode(utf8.encode(''));
    final actual = await plugin.convertToBase64(emptyFile);

    expect(actual, equals(expected));
  });

  test('Convert non-existent file returns null', () async {
    final plugin = ApzCamera();

    final nonExistentFile = File('/path/to/nonexistent/file.txt');
    final actual = await plugin.convertToBase64(nonExistentFile);

    expect(actual, isNull);
  });

  test('Convert file with special characters to base64 string', () async {
    final plugin = ApzCamera();

    final tempDir = await Directory.systemTemp.createTemp('base64_test_');
    final file = File('${tempDir.path}/special.txt');
    const content = '¡Hola! Привет! 你好';
    await file.writeAsString(content);

    final expected = base64Encode(utf8.encode(content));
    final actual = await plugin.convertToBase64(file);

    expect(actual, equals(expected));
  });

  test('Convert binary file to base64 string', () async {
    final plugin = ApzCamera();

    final tempDir = await Directory.systemTemp.createTemp('base64_test_');
    final binaryFile = File('${tempDir.path}/binary.dat');

    final bytes = List<int>.generate(256, (i) => i); // 0x00 to 0xFF
    await binaryFile.writeAsBytes(bytes);

    final expected = base64Encode(bytes);
    final actual = await plugin.convertToBase64(binaryFile);

    expect(actual, equals(expected));
  });
}
