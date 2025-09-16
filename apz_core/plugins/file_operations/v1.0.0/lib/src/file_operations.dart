import "dart:async";
import "dart:convert";
import "dart:io";
import "package:apz_device_info/apz_device_info.dart";
import "package:apz_device_info/device_info_model.dart";
import "package:apz_file_operations/src/file_data.dart";
import "package:apz_file_operations/src/utils.dart";
import "package:file_picker/file_picker.dart";
import "package:flutter/foundation.dart";
import "package:permission_handler/permission_handler.dart";

/// This allows injecting a mock File creator in tests.
typedef FileFactory = File Function(String path);

/// Testing puprose
class FilePickerWrapper {
  /// Testing
  Future<FilePickerResult?> pickFiles({
    final bool allowMultiple = false,
    final FileType type = FileType.any,
    final List<String>? allowedExtensions,
    final int? maxFileSizeInMB,
  }) => FilePicker.platform.pickFiles(
    allowMultiple: allowMultiple,
    type: type,
    allowedExtensions: allowedExtensions,
  );
}

/// class for Android and ios implementation
class FileOperations {
  /// Constructor for FileOperations, injection of dependencies for testing.
  FileOperations({
    final PermissionService? permissionService,
    final FilePickerWrapper? filePickerWrapper,
    final FileFactory? fileFactory,
  }) : _permissionService = permissionService ?? PermissionService(),
       _filePickerWrapper = filePickerWrapper ?? FilePickerWrapper(),
       _fileFactory = fileFactory ?? File.new;
  PermissionService _permissionService;
  final FilePickerWrapper _filePickerWrapper;
  final FileFactory _fileFactory;

  /// testing purpose
  @visibleForTesting
  PermissionService setPermissionService(final PermissionService service) =>
      _permissionService = service;

/// pickFile Method
  Future<List<FileData>?> pickFile({
    final bool? allowMultiple,
    final List<String>? allowedExtensions,
    final int? maxFileSizeInMB,
    final RegExp? allowedFileNameRegex,
  }) async {
    final int maxFileSize = maxFileSizeInMB ?? 5;
    final int convertedMaxFileSizeInMB = maxFileSize * 1024 * 1024;

    final PermissionStatus status = await _permissionService
        .requestStoragePermission();
    if (!status.isGranted) {
      throw Exception("Storage permission is not granted.");
    }

    final FilePickerResult? result = await _filePickerWrapper.pickFiles(
      type: FileType.custom,
      allowMultiple: allowMultiple ?? false,
      allowedExtensions: allowedExtensions,
    );

    if (result == null || result.files.isEmpty) {
      return null;
    }

    final List<FileData> pickedFiles = <FileData>[];
    for (final PlatformFile platformFile in result.files) {
      final Uint8List? bytes;
      final String? filePath;
      // Handle file content differently for mobile and web
      // Prioritize bytes, which are always available on web and often on mobile
      if (platformFile.bytes != null) {
        bytes = platformFile.bytes;
        filePath = platformFile.path ?? platformFile.name;
      } else if (!kIsWeb && platformFile.path != null) {
        // Fallback to reading from path on mobile/desktop if bytes are not available
        filePath = platformFile.path ?? "";
        try {
          final File file = _fileFactory(filePath);
          bytes = await file.readAsBytes();
        } on Object catch (_) {
          continue; // Skip file if there's an error reading it
        }
      } else {
        continue; // Skip file if neither bytes nor a valid path are available
      }

      if (bytes != null) {
        pickedFiles.add(
          FileData(
            name: platformFile.name,
            path: filePath,
            mimeType: platformFile.extension ?? "",
            size: bytes.length,
            base64String: base64Encode(bytes),
          ),
        );
      }
    }

    // Apply the validation checks
    final List<FileData> filteredFiles = <FileData>[];
    for (final FileData file in pickedFiles) {
      // 1. Check for consecutive duplicate extensions
      if (hasConsecutiveDuplicateExtension(file.name)) {
        throw Exception(
          '"${file.name}" has to consecutive duplicate extension.',
        );
      }

      // 2. Check for allowed characters and double dots in the filename
      if (!isValidFileName(
        file.name,
        allowedFileNameRegex: allowedFileNameRegex,
      )) {
        throw Exception('"${file.name}" check file name');
      }

      // 3. Check file size
      if (file.size > convertedMaxFileSizeInMB) {
        throw Exception(
          '"${file.name} "has exceeded size.Max Size:${maxFileSizeInMB}MB',
        );
      }

      // If all checks pass, add the file
      filteredFiles.add(file);
    }

    return filteredFiles.isEmpty ? null : filteredFiles;
  }
}

/// Getter fileOps
FileOperations get fileOps => FileOperations();

/// storage permision class
class PermissionService {
  /// Request contacts permission.
  Future<PermissionStatus> requestStoragePermission() async {
    final APZDeviceInfoManager deviceInfoManager = APZDeviceInfoManager();
    if (!kIsWeb && Platform.isAndroid) {
      final DeviceInfoModel? deviceInfo = await deviceInfoManager
          .loadDeviceInfo();
      final int? sdkInt = deviceInfo?.version?.sdkInt;
      if (sdkInt == null) {
        return PermissionStatus.denied;
      }
      if (sdkInt < 33) {
        return Permission.storage.request();
      }
    }
    return PermissionStatus.granted;
  }
}
