import "dart:convert";
import "dart:io";
import "package:apz_photopicker/apz_photopicker.dart";
import "package:apz_photopicker/enum.dart";
import "package:apz_photopicker/photopicker_image_model.dart";
import "package:apz_utils/apz_utils.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:image_cropper_platform_interface/image_cropper_platform_interface.dart";
import "package:image_picker/image_picker.dart";
import "package:permission_handler_platform_interface/permission_handler_platform_interface.dart";
import "package:plugin_platform_interface/plugin_platform_interface.dart";

/// Fake ImageCropperPlatform that returns null (i.e. user cancelled).
class _FakeCropper extends ImageCropperPlatform
    with MockPlatformInterfaceMixin {
  @override
  @override
  Future<CroppedFile?> cropImage({
    final CropAspectRatio? aspectRatio,
    final ImageCompressFormat? compressFormat,
    final int? compressQuality,
    final int? maxWidth,
    final int? maxHeight,
    required final String sourcePath,
    final List<PlatformUiSettings>? uiSettings,
  }) async {
    return null;
  }
}

/// Fake PermissionHandlerPlatform that always grants.
class _FakePermissionHandler extends PermissionHandlerPlatform
    with MockPlatformInterfaceMixin {
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

  // 1) Stub DeviceVersionInfo channel so SDK < 33:
  const MethodChannel _deviceChannel = MethodChannel(
    "com.iexceed/device_version",
  );
  _deviceChannel.setMockMethodCallHandler((final call) async {
    if (call.method == "getSdkInt") return 0;
    return null;
  });

  // 2) Stub path_provider's getTemporaryDirectory → return raw String
  const MethodChannel _pathChannel = MethodChannel(
    "plugins.flutter.io/path_provider",
  );
  _pathChannel.setMockMethodCallHandler((final call) async {
    if (call.method == "getTemporaryDirectory") {
      return Directory.systemTemp.path;
    }
    return null;
  });

  // Stub image_picker channel:
  const imagePickerChannel = MethodChannel("plugins.flutter.io/image_picker");

  // 3) Swap in our fake permission handler BEFORE any tests run:
  setUpAll(() {
    PermissionHandlerPlatform.instance = _FakePermissionHandler();
    ImageCropperPlatform.instance = _FakeCropper();
  });

  tearDownAll(() {
    _deviceChannel.setMockMethodCallHandler(null);
    _pathChannel.setMockMethodCallHandler(null);
    imagePickerChannel.setMockMethodCallHandler(null);
  });

  group("ApzPhotopicker", () {
    final picker = ApzPhotopicker();

    test("mapFormat maps both png and jpeg", () {
      expect(
        picker.mapFormat(PhotopickerImageFormat.png),
        ImageCompressFormat.png,
      );
      expect(
        picker.mapFormat(PhotopickerImageFormat.jpeg),
        ImageCompressFormat.jpg,
      );
    });

    test("evaluatePermission behavior for all statuses", () {
      // granted → no exception
      expect(
        () => picker.evaluatePermission(PermissionStatus.granted, "X"),
        returnsNormally,
      );

      // all other statuses throw
      for (final status in [
        PermissionStatus.denied,
        PermissionStatus.permanentlyDenied,
        PermissionStatus.restricted,
        PermissionStatus.limited,
        PermissionStatus.provisional,
      ]) {
        expect(
          () => picker.evaluatePermission(status, "X"),
          throwsA(isA<PermissionException>()),
        );
      }
    });

    test("handlePickedFile(crop: false) preserves bytes & extension", () async {
      final data = Uint8List.fromList(
        List.generate(20, (final i) => (i * 7) % 256),
      );
      final inFile = await File(
        "${Directory.systemTemp.path}/in1.bin",
      ).writeAsBytes(data, flush: true);

      final result = await picker.handlePickedFile(
        XFile(inFile.path),
        crop: false,
        quality: 75,
        fileName: "foo",
        format: PhotopickerImageFormat.jpeg,
        cropTitle: "CROP",
        targetWidth: 100,
        targetHeight: 100,
      );

      expect(base64Decode(result.base64String!), data);
      expect(result.imageFile!.path.endsWith(".jpg"), isTrue);
    });

    test(
      "handlePickedFile(crop: true) skips cropping when fake returns null",
      () async {
        final data = Uint8List.fromList(List.generate(10, (final i) => i));
        final inFile = await File(
          "${Directory.systemTemp.path}/in2.bin",
        ).writeAsBytes(data, flush: true);

        final result = await picker.handlePickedFile(
          XFile(inFile.path),
          crop: true,
          quality: 50,
          fileName: "bar",
          format: PhotopickerImageFormat.png,
          cropTitle: "TITLE",
          targetWidth: 100,
          targetHeight: 100,
        );

        expect(base64Decode(result.base64String!), data);
        expect(result.imageFile!.path.endsWith(".png"), isTrue);
      },
    );

    group("pickFromGallery", () {
      late bool cancelled;
      late PhotopickerImageModel model;

      setUp(() {
        cancelled = false;
        model = PhotopickerImageModel(
          fileName: "test",
          crop: false,
          quality: 80,
          targetWidth: 100,
          targetHeight: 100,
          format: PhotopickerImageFormat.jpeg,
          cropTitle: "crop",
        );
      });

      test(
        "returns a valid PhotopickerResult when user picks an image",
        () async {
          // 1) create a safe-named temp file
          final data = Uint8List.fromList(
            List.generate(15, (final i) => (i * 3) % 256),
          );
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final tempPath =
              "${Directory.systemTemp.path}${Platform.pathSeparator}pick_$timestamp.jpg";
          final inFile = await File(tempPath).writeAsBytes(data, flush: true);

          // 2) stub pickImage → return map matching XFile
          imagePickerChannel.setMockMethodCallHandler((final call) async {
            if (call.method == "pickImage") {
              return inFile.path;
            }
            return null;
          });

          // 3) exercise pickFromGallery
          final result = await picker.pickFromGallery(
            cancelCallback: () => cancelled = true,
            imagemodel: model,
          );

          // 4) assertions
          expect(cancelled, isFalse, reason: "should not call cancelCallback");
          expect(result, isNotNull, reason: "should return a result");

          // base64 round-trip
          final decoded = base64Decode(result!.base64String!);
          expect(decoded, data, reason: "round-trip base64 mismatch");

          // correct extension
          expect(result.imageFile!.path.endsWith(".jpg"), isTrue);
        },
      );
    });
    test("checkStoragePermissions succeeds via storage branch", () async {
      // With our fake, storage (and media) requests always grant
      await picker.checkStoragePermissions();
    });
  });
}
