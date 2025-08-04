import "dart:async";
import "dart:convert";
import "dart:html" as html;
import "dart:typed_data";
import "package:apz_file_operations/src/file_ops_common.dart";
import "package:apz_file_operations/src/utils.dart";

/// class is used for web implementation purpose
class WebFileOps implements FileOps {
  // static const int _maxFileSizeInBytes = 10 * 1024 * 1024;
  @override
  Future<List<FileData>?> pickFile({
    final bool? allowMultiple,
    final List<String>? allowedExtensions,
    final int? maxFileSizeInMB,
    final RegExp? allowedFileNameRegex,
  }) async {
    // Default max file size if not provided
    final int maxFileSize = maxFileSizeInMB ?? 5;
    final int convertedMaxFileSizeInMB = maxFileSize * 1024 * 1024;
    final html.FileUploadInputElement input = html.FileUploadInputElement()
      ..accept = allowedExtensions?.map((final String e) => ".$e").join(",")
      ..multiple = allowMultiple ?? false; // Use the parameter
    html.document.body?.append(input); // Append to body to make it clickable
    input.click();
    final Completer<List<FileData>?> allFilesCompleter =
        Completer<List<FileData>?>();
    // Listen for the change event (when files are selected)
    input.onChange.listen((_) async {
      final List<html.File>? files = input.files;
      // Remove the input element from the DOM after selection to clean up
      input.remove();
      if (files == null || files.isEmpty) {
        allFilesCompleter.complete(null); // User cancelled or no files selected
        return;
      }
      final List<FileData> pickedFiles = <FileData>[];
      final List<Future<void>> readFutures = <Future<void>>[];
      for (final html.File file in files) {
        final Completer<FileData> fileDataCompleter = Completer<FileData>();
        final html.FileReader reader = html.FileReader()
          ..readAsArrayBuffer(file);
        reader.onLoadEnd.listen((_) {
          final Object? result = reader.result;
          late final Uint8List bytes;

          if (result is ByteBuffer) {
            bytes = Uint8List.view(result);
          } else if (result is Uint8List) {
            bytes = result;
          } else {
            // Complete with an error if result type is unexpected
            fileDataCompleter.completeError(
              "Unsupported file reader result type for ${file.name}",
            );
            return;
          }
          fileDataCompleter.complete(
            FileData(
              name: file.name,
              path: file.name, // On web, path is typically just the name
              mimeType: file.type,
              size: bytes.length,
              base64String: base64Encode(bytes),
            ),
          );
        });
        // Add the future from each fileDataCompleter to our list of futures
        readFutures.add(fileDataCompleter.future.then(pickedFiles.add));
      }
      try {
        // Wait for all file reading operations to complete
        await Future.wait(readFutures);
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

        allFilesCompleter.complete(
          filteredFiles.isEmpty ? null : filteredFiles,
        );
      } catch (e) {
        // If any file reading fails, complete the main completer with an error
        allFilesCompleter.completeError(e);
      }
    });

    return allFilesCompleter.future;
  }
}

///  Getter fileOps
FileOps get fileOps => WebFileOps();
