import "dart:async";
import "dart:io";
import "package:apz_digi_scan/platform_wrapper.dart";
import "package:apz_utils/apz_utils.dart";
import "package:flutter/foundation.dart";
import "package:flutter_doc_scanner/flutter_doc_scanner.dart";

/// This class provides methods to scan documents and return images or PDFs
class ApzDigiScan {
  /// Creates an instance for testing purposes.
  ApzDigiScan();

  /// Creates an instance of [ApzDigiScan] with the default [PlatformWrapper].
  PlatformWrapper _platformWrapper = RealPlatformWrapper();

  /// Overrides the [platformWrapper] for testing purposes.
  @visibleForTesting
  ///for testing purposes
  // ignore: use_setters_to_change_properties
  void overridePlatformWrapper(final PlatformWrapper platform) {
    _platformWrapper = platform;
  }

  /// Scans a document and returns a images file path
  Future<List<Map<String, dynamic>>> scanAsImage(
    final double maxSizeInMB, {
    final int pages = 5,
  }) async {
    if (kIsWeb) {
      throw UnsupportedPlatformException(
        "This plugin is not supported on the web platform",
      );
    }
    try {
      final Object scanResult = await FlutterDocScanner()
          .getScannedDocumentAsImages(page: pages);
      List<String> extractedUris = <String>[];
      if (_platformWrapper.isIOS) {
        if (scanResult is List) {
          extractedUris = List<String>.from(scanResult);
        }
      } else if (_platformWrapper.isAndroid) {
        if (scanResult is Map<dynamic, dynamic>) {
          final String uriString = scanResult["Uri"];
          extractedUris = RegExp("imageUri=([^}]+)")
              .allMatches(uriString)
              .map((final RegExpMatch match) => match.group(1))
              .whereType<String>()
              .toList();
        }
      }

      final List<Map<String, dynamic>> images = <Map<String, dynamic>>[];
      int totalBytes = 0;
      for (final String uriString in extractedUris) {
        final String filePath = Uri.parse(uriString).toFilePath();
        final File imgFile = File(filePath);
        final int fileSize = await imgFile.length();
        totalBytes += fileSize;
        images.add(<String, dynamic>{"imageUri": uriString, "bytes": fileSize});
      }
      final double totalMB = totalBytes / (1024 * 1024);
      if (totalMB > maxSizeInMB) {
        throw Exception(
          "Scanned image size (${totalMB.toStringAsFixed(2)} MB)"
          " exceeds limit of $maxSizeInMB MB.",
        );
      }
      return images;
    } on Exception {
      rethrow;
    }
  }

  /// Scans a document and returns a single PDF file path
  Future<dynamic> scanAsPdf(
    final double maxSizeInMB, {
    final int pages = 20,
  }) async {
    if (kIsWeb) {
      throw UnsupportedPlatformException(
        "This plugin is not supported on the web platform",
      );
    }
    try {
      final Object result = await FlutterDocScanner().getScannedDocumentAsPdf(
        page: pages,
      );
      String? pdfUriString;
      if (_platformWrapper.isIOS) {
        pdfUriString = result as String;
      } else if (_platformWrapper.isAndroid) {
        if (result is Map) {
          pdfUriString = result["pdfUri"] as String?;
        }
      }
      if (pdfUriString != null) {
        final String filePath = Uri.parse(pdfUriString).toFilePath();
        final File pdfFile = File(filePath);
        final int fileSizeBytes = await pdfFile.length();
        final double fileSizeMB = fileSizeBytes / (1024 * 1024);

        if (fileSizeMB > maxSizeInMB) {
          throw Exception(
            "Scanned PDF size (${fileSizeMB.toStringAsFixed(2)} MB) "
            "exceeds limit of $maxSizeInMB MB.",
          );
        }
        return pdfUriString;
      }
    } on Exception {
      rethrow;
    }
  }
}
