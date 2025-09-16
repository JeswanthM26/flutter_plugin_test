import "package:apz_file_operations/src/file_data.dart";
import "package:apz_file_operations/src/file_operations.dart";
import "package:flutter/material.dart";

export "src/file_data.dart" show FileData;

/// ApzFileOperations is a library for file operations
class ApzFileOperations {
  /// Public constructor (no singleton)
  ApzFileOperations();

  FileOperations _ops = fileOps;

  /// Getter
  @visibleForTesting
  FileOperations get fileOpsOverride => _ops;

  /// Setter
  /// For testing: override the default implementation
  @visibleForTesting
  set fileOpsOverride(final FileOperations ops) {
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
