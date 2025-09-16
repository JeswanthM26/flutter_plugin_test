import "dart:typed_data";

import "package:apz_qr/models/position.dart";

/// Represents a barcode code
class Code {
  /// Creates a barcode code Constructor
  Code({
    this.text,
    this.isValid = false,
    this.error,
    this.rawBytes,
    this.format,
    this.position,
    this.isInverted = false,
    this.isMirrored = false,
    this.duration = 0,
    this.imageBytes,
    this.imageWidth,
    this.imageHeight,
  });

  /// The text of the code
  String? text;

  /// Whether the code is valid
  bool isValid;

  /// The error of the code
  String? error;

  /// The raw bytes of the code
  Uint8List? rawBytes;

  /// The format of the code
  int? format;

  /// The position of the code
  Position? position;

  /// Whether the code is inverted
  bool isInverted;

  /// Whether the code is mirrored
  bool isMirrored;

  /// The duration of the decoding in milliseconds
  int duration;

  /// The processed image bytes of the code
  Uint8List? imageBytes;

  /// The width of the processed image
  int? imageWidth;

  /// The height of the processed image
  int? imageHeight;
}

/// Represents a list of barcode codes
class Codes {
  /// Creates a list of barcode codes Constructor
  Codes({this.codes = const <Code>[], this.duration = 0});

  /// The list of codes
  List<Code> codes;

  /// The duration of the decoding in milliseconds
  int duration;

  /// Returns the first code error if any
  String? get error {
    for (final Code code in codes) {
      if (code.error != null) {
        return code.error;
      }
    }
    return null;
  }
}
