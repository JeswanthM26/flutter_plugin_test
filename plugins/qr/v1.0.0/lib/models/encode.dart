import "dart:typed_data";

/// Encapsulates the result of encoding a barcode.
class Encode {
  /// Creates an instance of [Encode].
  Encode({
    required this.isValid,
    this.format,
    this.text,
    this.data,
    this.length,
    this.error,
  });

  /// Whether the code is valid
  bool isValid;

  /// The format of the code
  int? format;

  /// The text of the code
  String? text;

  /// The raw bytes of the code
  Uint8List? data;

  /// The length of the raw bytes
  int? length;

  /// The error message
  String? error;
}
