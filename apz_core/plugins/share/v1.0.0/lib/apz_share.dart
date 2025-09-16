import "dart:io";

import "package:flutter/foundation.dart";
import "package:flutter/services.dart";
import "package:path_provider/path_provider.dart";
import "package:share_plus/share_plus.dart";

/// ApzShare is a singleton class that provides methods to share text and files
class ApzShare {
  SharePlus _sharePlus = SharePlus.instance;

  @visibleForTesting
  /// Allows setting a custom SharePlus instance for testing purposes.
  // ignore: public_member_api_docs, use_setters_to_change_properties
  void setSharePlusForTest(final SharePlus sharePlus) {
    _sharePlus = sharePlus;
  }

  /// Share plain text with optional subject  (Used as email subject
  /// When using the email fallback, this will be the subject of the email).
  Future<void> shareText({
    required final String text,
    required final String title,
    final String? subject,
  }) async {
    await _sharePlus.share(
      ShareParams(text: text, title: title, subject: subject),
    );
  }

  /// Share a single file with optional message
  Future<void> shareFile({
    required final String filePath,
    required final String title,
    final String? text,
  }) async {
    final ShareParams params = ShareParams(
      title: title,
      text: text,
      files: <XFile>[XFile(filePath)],
    );
    await _sharePlus.share(params);
  }

  /// Share multiple files
  Future<void> shareMultipleFiles({
    required final List<String> filePaths,
    required final String title,
    final String? text,
  }) async {
    final List<XFile> files = filePaths.map(XFile.new).toList();
    final ShareParams params = ShareParams(
      files: files,
      title: title,
      text: text,
    );
    await _sharePlus.share(params);
  }

  /// Share an asset file by loading it from the app's assets
  Future<void> shareAssetFile({
    required final String assetPath,
    required final String title,
    final String? text,
    final String mimeType = "application/octet-stream",
  }) async {
    // Extract filename from assetPath
    final String fileName = assetPath.split("/").last;

    // Load the asset
    final ByteData byteData = await rootBundle.load(assetPath);

    // Get temp dir
    final Directory tempDir = await getTemporaryDirectory();

    // Write to temp file
    final File file = File("${tempDir.path}/$fileName");
    await file.writeAsBytes(byteData.buffer.asUint8List());

    // Share it
    final XFile xFile = XFile(file.path, mimeType: mimeType);
    await _sharePlus.share(
      ShareParams(title: title, text: text, files: <XFile>[xFile]),
    );
  }
}
