import "dart:typed_data";

import "package:flutter/material.dart";

/// Represents the result of a screenshot capture operation.
class ScreenshotResult {
 
  /// Creates a new [ScreenshotResult] with the captured bytes and image.
  ScreenshotResult({
    required this.bytes,
    required this.image,
  });
  /// Creates a new [ScreenshotResult] with the captured bytes and image.
  final Uint8List bytes;
  /// The captured image as a Flutter [Image] widget.
  final Image image;
}
