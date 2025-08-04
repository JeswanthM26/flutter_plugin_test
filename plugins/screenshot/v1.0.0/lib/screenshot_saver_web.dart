import "dart:js_interop";
import "package:flutter/foundation.dart";
import "package:web/web.dart" as web;

/// This file is for saving screenshots on web platform
class ScreenshotSaver {
  /// Saves the screenshot bytes to a file with the given file name.
   Future<void> save(
    final Uint8List imageBytes, 
    final String fileName,
    final String? text) async {
    final web.Blob blob = web.Blob(<JSUint8Array>[imageBytes.toJS].toJS);
    final String url = web.URL.createObjectURL(blob);
    final web.HTMLAnchorElement anchor = web.HTMLAnchorElement()
      ..href = url
      ..download = "$fileName.jpg";
    web.document.body!.appendChild(anchor);
    anchor.click();
    web.document.body!.removeChild(anchor);
    web.URL.revokeObjectURL(url);
  }
 
}
