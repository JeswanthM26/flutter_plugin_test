import "dart:io";
import "package:apz_share/apz_share.dart";
import "package:flutter/foundation.dart";
import "package:path_provider/path_provider.dart";

/// This file is for saving screenshots on iOS and Android platforms
class ScreenshotSaver {
  ApzShare _apzShare = ApzShare();

  /// For test mocking
  @visibleForTesting
  /// Sets the share instance for testing purposes.
  // ignore: use_setters_to_change_properties
  void setShareInstance(final ApzShare instance) {
    _apzShare = instance;
  }

  /// Saves the screenshot bytes to a file with the given file name.
  Future<void> save(
    final Uint8List imageBytes,
    final String fileName,
    final String? text,
  ) async {
    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final String imagePath = "${directory.path}/$fileName.jpg";
      final File imageFile = File(imagePath);
      await imageFile.writeAsBytes(imageBytes);

      /// Share the saved screenshot file
      // ignore: unawaited_futures
      _apzShare.shareFile(
        filePath: imageFile.path,
        title: fileName,
        text: text,
      );

      /// delete the file after sharing
      // ignore: avoid_slow_async_io
      if (await imageFile.exists()) {
        await imageFile.delete();
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print("Error saving screenshot: $e");
      }
    }
  }
}
