import "dart:typed_data";
import "dart:ui" as ui;
import "package:apz_screenshot/screenshot_model.dart";
import "package:apz_screenshot/screenshot_saver.dart";
import "package:flutter/material.dart";
import "package:flutter/rendering.dart";
import "package:image/image.dart" as img;

/// apzscreenshot
/// A Flutter plugin to capture screenshots of specific widgets.
class ApzScreenshot {
  /// Capture screenshot of a specific widget by automatically wrapping it
  Future<ScreenshotResult?> capture(
    final BuildContext context, {
    final double pixelRatio = 3.0,
    final int jpegQuality = 90,
  }) async {
    try {
      final RenderObject? renderObject = context.findRenderObject();
      if (renderObject == null) {
        return null;
      }

      RenderRepaintBoundary? boundary;
      RenderObject? current = renderObject;

      while (current != null && boundary == null) {
        if (current is RenderRepaintBoundary) {
          boundary = current;
          break;
        }
        current = current.parent;
      }

      if (boundary != null) {
        final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
        final ByteData? byteData = await image.toByteData(
          format: ui.ImageByteFormat.png,
        );
        final Uint8List? bytes = byteData?.buffer.asUint8List();

        if (bytes != null) {
          // Decode the PNG image using the 'image' package
          final img.Image? decodedImage = img.decodePng(bytes);
          if (decodedImage != null) {
            final Uint8List jpegBytes = Uint8List.fromList(
              img.encodeJpg(decodedImage, quality: jpegQuality),
            );
            return ScreenshotResult(
              bytes: jpegBytes,
              image: Image.memory(bytes, fit: BoxFit.contain),
            );
          }
        }
      }
    } on Exception catch (_) {
      return null;
    }
    return null;
  }

  /// Capture and save screenshot with platform-specific handling
  /// text is the text to be shared with the screenshot
  Future<ScreenshotResult?> captureAndShare(
    final BuildContext context, {
    final String? text,
    final double pixelRatio = 3.0,
    final String? customFileName,
  }) async {
    final ScreenshotResult? result = await capture(
      context,
      pixelRatio: pixelRatio,
    );
    if (result != null) {
      final ScreenshotSaver screenshotSaver = ScreenshotSaver();
      final String fileName =
          customFileName ?? "${DateTime.now().millisecondsSinceEpoch}";
      final String? shareText = text;
      await screenshotSaver.save(result.bytes, fileName, shareText);
    }
    return result;
  }
}
