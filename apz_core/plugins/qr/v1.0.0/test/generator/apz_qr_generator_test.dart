import "dart:typed_data";

import "package:apz_qr/generator/apz_qr_generator.dart";
import "package:flutter_test/flutter_test.dart";
import "package:image/image.dart" as img;

void main() {
  group("ApzQRGenerator", () {
    late ApzQRGenerator generator;

    setUp(() {
      generator = ApzQRGenerator();
    });

    test("generates QR code without logo", () async {
      final result = await generator.generate(text: "Hello World");

      expect(result, isA<Uint8List>());
      expect(result.length, greaterThan(0));

      // Check if the result is a PNG by verifying PNG header bytes
      expect(result.sublist(0, 8), equals([137, 80, 78, 71, 13, 10, 26, 10]));
    });

    test("generates QR code with logo", () async {
      // Create a dummy logo image (small red square)
      final logoBytes = _createDummyLogoBytes();

      final result = await generator.generate(
        text: "With logo",
        logoBytes: logoBytes,
      );

      expect(result, isA<Uint8List>());
      expect(result.length, greaterThan(0));
      expect(result.sublist(0, 8), equals([137, 80, 78, 71, 13, 10, 26, 10]));
    });

    test("throws if logo decoding fails", () async {
      // Pass invalid logo bytes
      final invalidLogoBytes = Uint8List.fromList([
        137,
        80,
        78,
        71,
        13,
        10,
        26,
        10,
        0,
        0,
        0,
        13,
        73,
        72,
        68,
        82,
        0,
        0,
        0,
        1,
        0,
        0,
        0,
        1,
        8,
        6,
        0,
        0,
        0,
        31,
        21,
        196,
        137,
        0,
        0,
        0,
        13,
        73,
        68,
        65,
        84,
        120,
        218,
        99,
        96,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        2,
        0,
        1,
        239,
        116,
        219,
        240,
        0,
        0,
        0,
        0,
        73,
        69,
        78,
        68,
        174,
        66,
        96,
        130,
      ]);

      expect(
        () => generator.generate(
          text: "Invalid logo",
          logoBytes: invalidLogoBytes,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test("handles empty logo bytes gracefully", () async {
      final result = await generator.generate(
        text: "Empty logo bytes",
        logoBytes: Uint8List(0),
      );

      expect(result, isA<Uint8List>());
    });
  });
}

/// Helper to create a dummy logo image as PNG bytes
Uint8List _createDummyLogoBytes() {
  final img.Image logo = img.Image(width: 10, height: 10);
  // Fill with red color
  for (int y = 0; y < 10; y++) {
    for (int x = 0; x < 10; x++) {
      logo.setPixel(x, y, img.ColorRgb8(255, 0, 0));
    }
  }
  return img.encodePng(logo);
}
