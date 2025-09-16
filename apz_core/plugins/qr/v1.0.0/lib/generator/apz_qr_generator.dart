import "dart:typed_data";

import "package:image/image.dart" as img;
import "package:qr/qr.dart";

export "apz_qr_generator.dart";

/// ApzQRGenerator class for generating QR codes with optional logo overlay
class ApzQRGenerator {
  /// Generates a QR code with an optional logo overlaid in the center.
  Future<Uint8List> generate({
    required final String text,
    final int height = 200,
    final int width = 200,
    final int margin = 0,
    final int errorCorrectLevel = QrErrorCorrectLevel.H,
    final Uint8List? logoBytes,
  }) async {
    try {
      // 1. Generate QR code data
      final QrCode qrCode = QrCode.fromData(
        data: text,
        errorCorrectLevel: errorCorrectLevel,
      )
      ..make();
      // 2. Calculate cell size
      final int qrSize = qrCode.moduleCount + (2 * margin);
      final double pixelSize = width / qrSize;

      // 3. Create blank image
      final img.Image qrImage = img.Image(width: width, height: height);
      img.fill(
        qrImage,
        color: img.ColorRgb8(255, 255, 255),
      ); // White background

      // 4. Draw QR code onto image
      for (int x = 0; x < qrCode.moduleCount; x++) {
        for (int y = 0; y < qrCode.moduleCount; y++) {
          if (qrCode.isDark(y, x)) {
            final int left = ((x + margin) * pixelSize).round();
            final int top = ((y + margin) * pixelSize).round();
            final int boxSize = pixelSize.ceil();

            img.fillRect(
              qrImage,
              x1: left,
              y1: top,
              x2: left + boxSize,
              y2: top + boxSize,
              color: img.ColorRgb8(0, 0, 0),
            );
          }
        }
      }

      // 5. If no logo, return plain QR code
      if (logoBytes == null || logoBytes.isEmpty) {
        return Uint8List.fromList(img.encodePng(qrImage));
      }

      // 6. Decode logo
      final img.Image? logoImage = img.decodeImage(logoBytes);
      if (logoImage == null) {
        throw Exception("Failed to decode logo image.");
      }

      // 7. Resize logo to ~25% of QR code size
      final img.Image resizedLogo = img.copyResize(
        logoImage,
        width: width ~/ 6,
        height: height ~/ 6,
      );

      // 8. Calculate center position
      final int logoX = (width - resizedLogo.width) ~/ 2;
      final int logoY = (height - resizedLogo.height) ~/ 2;

      // 9. Draw logo with white background
      _drawImageWithBackground(qrImage, resizedLogo, dstX: logoX, dstY: logoY);

      // 10. Return final image
      return Uint8List.fromList(img.encodePng(qrImage));
    } catch (e) {
      rethrow;
    }
  }

  void _drawImageWithBackground(
    final img.Image dst,
    final img.Image src, {
    required final int dstX,
    required final int dstY,
  }) {
    const int bgPadding = 4;
    final int bgX = dstX - bgPadding;
    final int bgY = dstY - bgPadding;
    final int bgW = src.width + 2 * bgPadding;
    final int bgH = src.height + 2 * bgPadding;

    img.fillRect(
      dst,
      x1: bgX,
      y1: bgY,
      x2: bgX + bgW,
      y2: bgY + bgH,
      color: img.ColorRgb8(255, 255, 255),
    );

    for (int y = 0; y < src.height; y++) {
      for (int x = 0; x < src.width; x++) {
        final int dx = dstX + x;
        final int dy = dstY + y;
        if (dx >= 0 && dx < dst.width && dy >= 0 && dy < dst.height) {
          dst.setPixel(dx, dy, src.getPixel(x, y));
        }
      }
    }
  }
}
