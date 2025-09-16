import "package:apz_qr/models/code.dart";
import 'package:flutter_test/flutter_test.dart';
import 'dart:typed_data';

import 'package:apz_qr/models/position.dart'; // Adjust import path as needed

void main() {
  group('Code class', () {
    test('creates Code with default values', () {
      final code = Code();

      expect(code.text, isNull);
      expect(code.isValid, false);
      expect(code.error, isNull);
      expect(code.rawBytes, isNull);
      expect(code.format, isNull);
      expect(code.position, isNull);
      expect(code.isInverted, false);
      expect(code.isMirrored, false);
      expect(code.duration, 0);
      expect(code.imageBytes, isNull);
      expect(code.imageWidth, isNull);
      expect(code.imageHeight, isNull);
    });

    test('creates Code with all parameters', () {
      final position = Position(
        100, // imageWidth
        200, // imageHeight
        10, // topLeftX
        20, // topLeftY
        30, // topRightX
        40, // topRightY
        50, // bottomLeftX
        60, // bottomLeftY
        70, // bottomRightX
        80,
      );
      final rawBytes = Uint8List.fromList([1, 2, 3]);
      final imageBytes = Uint8List.fromList([4, 5, 6]);

      final code = Code(
        text: 'Sample',
        isValid: true,
        error: null,
        rawBytes: rawBytes,
        format: 1,
        position: position,
        isInverted: true,
        isMirrored: true,
        duration: 123,
        imageBytes: imageBytes,
        imageWidth: 100,
        imageHeight: 50,
      );

      expect(code.text, 'Sample');
      expect(code.isValid, true);
      expect(code.error, isNull);
      expect(code.rawBytes, rawBytes);
      expect(code.format, 1);
      expect(code.position, position);
      expect(code.isInverted, true);
      expect(code.isMirrored, true);
      expect(code.duration, 123);
      expect(code.imageBytes, imageBytes);
      expect(code.imageWidth, 100);
      expect(code.imageHeight, 50);
    });
  });

  group('Codes class', () {
    test('creates empty list of codes', () {
      final codes = Codes();

      expect(codes.codes, isEmpty);
      expect(codes.duration, 0);
      expect(codes.error, isNull);
    });

    test('creates list with multiple codes', () {
      final code1 = Code(text: 'A', error: null);
      final code2 = Code(text: 'B', error: 'Error in code');
      final code3 = Code(text: 'C');

      final codes = Codes(codes: [code1, code2, code3], duration: 200);

      expect(codes.codes.length, 3);
      expect(codes.duration, 200);
      expect(codes.error, 'Error in code');
    });

    test('returns null if no code has error', () {
      final code1 = Code(text: 'A', error: null);
      final code2 = Code(text: 'B', error: null);
      final codes = Codes(codes: [code1, code2]);

      expect(codes.error, isNull);
    });
  });
}
