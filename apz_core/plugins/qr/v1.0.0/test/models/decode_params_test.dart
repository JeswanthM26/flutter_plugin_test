import "package:apz_qr/models/decode_params.dart";
import 'package:flutter_test/flutter_test.dart';
import "package:flutter_zxing/flutter_zxing.dart" hide DecodeParams;

void main() {
  group('DecodeParams', () {
    test('creates with default values', () {
      final params = DecodeParams();

      expect(params.imageFormat, equals(ImageFormat.lum));
      expect(params.format, equals(Format.any));
      expect(params.width, equals(0));
      expect(params.height, equals(0));
      expect(params.cropLeft, equals(0));
      expect(params.cropTop, equals(0));
      expect(params.cropWidth, equals(0));
      expect(params.cropHeight, equals(0));
      expect(params.tryHarder, isFalse);
      expect(params.tryRotate, isTrue);
      expect(params.tryInverted, isFalse);
      expect(params.tryDownscale, isFalse);
      expect(params.maxNumberOfSymbols, equals(10));
      expect(params.maxSize, equals(768));
      expect(params.isMultiScan, isFalse);
    });

    test('creates with custom values', () {
      final params = DecodeParams(
        imageFormat: ImageFormat.rgb,
        format: Format.qrCode,
        width: 200,
        height: 300,
        cropLeft: 10,
        cropTop: 20,
        cropWidth: 100,
        cropHeight: 150,
        tryHarder: true,
        tryRotate: false,
        tryInverted: true,
        tryDownscale: true,
        maxNumberOfSymbols: 5,
        maxSize: 1024,
        isMultiScan: true,
      );

      expect(params.imageFormat, equals(ImageFormat.rgb));
      expect(params.format, equals(Format.qrCode));
      expect(params.width, equals(200));
      expect(params.height, equals(300));
      expect(params.cropLeft, equals(10));
      expect(params.cropTop, equals(20));
      expect(params.cropWidth, equals(100));
      expect(params.cropHeight, equals(150));
      expect(params.tryHarder, isTrue);
      expect(params.tryRotate, isFalse);
      expect(params.tryInverted, isTrue);
      expect(params.tryDownscale, isTrue);
      expect(params.maxNumberOfSymbols, equals(5));
      expect(params.maxSize, equals(1024));
      expect(params.isMultiScan, isTrue);
    });

    test('allows changing fields after creation', () {
      final params = DecodeParams();

      // Changing some fields
      params.width = 640;
      params.height = 480;
      params.tryHarder = true;

      expect(params.width, equals(640));
      expect(params.height, equals(480));
      expect(params.tryHarder, isTrue);
    });

    test('handles zero and negative values gracefully', () {
      final params = DecodeParams(
        width: 0,
        height: -10,
        maxSize: 0,
      );

      expect(params.width, equals(0));
      expect(params.height, equals(-10));
      expect(params.maxSize, equals(0));
    });
  });
}