import "package:flutter_zxing/flutter_zxing.dart";

/// Represents the parameters for decoding a barcode
class DecodeParams {
  /// Creates an instance of [DecodeParams].
  DecodeParams({
    this.imageFormat = ImageFormat.lum,
    this.format = Format.any,
    this.width = 0,
    this.height = 0,
    this.cropLeft = 0,
    this.cropTop = 0,
    this.cropWidth = 0,
    this.cropHeight = 0,
    this.tryHarder = false,
    this.tryRotate = true,
    this.tryInverted = false,
    this.tryDownscale = false,
    this.maxNumberOfSymbols = 10,
    this.maxSize = 768,
    this.isMultiScan = false,
  });

  /// The image format of the image. The default is lum.
  int imageFormat;

  /// Specify a set of BarcodeFormats that should be searched for,
  /// the default is all supported formats.
  int format;

  /// The width of the image to scan, in pixels.
  int width;

  /// The height of the image to scan, in pixels.
  int height;

  /// The left of the area of the image to scan, in pixels.
  int cropLeft;

  /// The top of the area of the image to scan, in pixels.
  int cropTop;

  /// The width of the area of the image to scan, in pixels.
  /// If 0, the entire image width is used.
  int cropWidth;

  /// The height of the area of the image to scan, in pixels.
  /// If 0, the entire image height is used.
  int cropHeight;

  /// Spend more time to try to find a barcode
  bool tryHarder;

  /// Try to detect rotated code
  bool tryRotate;

  /// Try to detect inverted code
  bool tryInverted;

  /// try detecting code in downscaled images.
  bool tryDownscale;

  /// The maximum number of symbols (barcodes) to detect / look for in the image with ReadBarcodes
  int maxNumberOfSymbols;

  /// Resize the image to a smaller size before scanning to
  /// improve performance. Default is 768.
  int maxSize;

  /// Whether to scan multiple barcodes
  bool isMultiScan;
}
