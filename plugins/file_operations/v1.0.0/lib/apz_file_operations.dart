import "package:apz_file_operations/src/file_ops_common.dart";
import "package:apz_file_operations/src/mobile_file_ops.dart"
    if (dart.library.html) "src/web_file_ops.dart";
import "package:flutter/material.dart";

export "src/file_ops_common.dart";

/// ApzFileOperations is a library for file operations
class ApzFileOperations {
  /// Public constructor (no singleton)
  ApzFileOperations();

  FileOps _ops = fileOps;

  /// Getter
  @visibleForTesting
  FileOps get fileOpsOverride => _ops;

  /// Setter
  /// For testing: override the default implementation
  @visibleForTesting
  set fileOpsOverride(final FileOps ops) {
    _ops = ops;
  }

  /// File Picker method
  Future<List<FileData>?> pickFile({
    final bool allowMultiple = false,
    final List<String> additionalExtensions = const <String>[],
    final int maxFileSizeInMB = 5, // 10 MB
    final RegExp? allowedFileNameRegex,
  }) {
    const List<String> defaultExtensions = <String>[
      "pdf",
      "docx",
      "txt",
      "xlsx",
      "csv",
    ];
    final Set<String> combinedExtensionsSet = Set<String>.from(
      defaultExtensions,
    )..addAll(additionalExtensions);
    final List<String> finalAllowedExtensions = combinedExtensionsSet.toList();
    return _ops.pickFile(
      allowMultiple: allowMultiple,
      allowedExtensions: finalAllowedExtensions,
      maxFileSizeInMB: maxFileSizeInMB,
      allowedFileNameRegex: allowedFileNameRegex,
    );
  }
}
