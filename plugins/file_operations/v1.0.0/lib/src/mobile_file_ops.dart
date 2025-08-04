import "dart:async";
import "dart:convert";
import "dart:io";
import "package:apz_file_operations/src/file_ops_common.dart";
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
class MobileFileOps implements FileOps {
  /// Constructor for MobileFileOps, injection of dependencies for testing.
  MobileFileOps({
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

  @override
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
      return null;
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
      if (platformFile.path == null) {
        if (platformFile.bytes != null) {
          pickedFiles.add(
            FileData(
              name: platformFile.name,
              path: platformFile.name,
              mimeType: platformFile.extension ?? "",
              size: platformFile.bytes?.length ?? 0,
              base64String: base64Encode(platformFile.bytes ?? Uint8List(0)),
            ),
          );
        }
        continue;
      }
      try {
        final File file = _fileFactory(platformFile.path ?? "");
        final Uint8List bytes = await file.readAsBytes();

        pickedFiles.add(
          FileData(
            name: platformFile.name,
            path: file.path,
            mimeType: platformFile.extension ?? "",
            size: bytes.length,
            base64String: base64Encode(bytes),
          ),
        );
      } on Object catch (_) {
        continue;
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
FileOps get fileOps => MobileFileOps();

/// storage permision class
class PermissionService {
  /// Request contacts permission.
  Future<PermissionStatus> requestStoragePermission() =>
      Permission.storage.request();
}
