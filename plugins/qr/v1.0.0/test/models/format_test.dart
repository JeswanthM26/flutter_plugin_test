import "package:apz_qr/models/format.dart";
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Format constants', () {
    test('all format constants have correct values', () {
      expect(Format.none, equals(0));
      expect(Format.aztec, equals(1 << 0));
      expect(Format.codabar, equals(1 << 1));
      expect(Format.code39, equals(1 << 2));
      expect(Format.code93, equals(1 << 3));
      expect(Format.code128, equals(1 << 4));
      expect(Format.dataBar, equals(1 << 5));
      expect(Format.dataBarExpanded, equals(1 << 6));
      expect(Format.dataMatrix, equals(1 << 7));
      expect(Format.ean8, equals(1 << 8));
      expect(Format.ean13, equals(1 << 9));
      expect(Format.itf, equals(1 << 10));
      expect(Format.maxiCode, equals(1 << 11));
      expect(Format.pdf417, equals(1 << 12));
      expect(Format.qrCode, equals(1 << 13));
      expect(Format.upca, equals(1 << 14));
      expect(Format.upce, equals(1 << 15));
      expect(Format.microQRCode, equals(1 << 16));
      expect(Format.rmqrCode, equals(1 << 17));
    });
  });

  group('CodeFormat extension', () {
    test('name returns correct format name', () {
      expect(Format.none.name, equals('None'));
      expect(Format.aztec.name, equals('Aztec'));
      expect(Format.codabar.name, equals('CodaBar'));
      expect(Format.code39.name, equals('Code39'));
      expect(Format.code93.name, equals('Code93'));
      expect(Format.code128.name, equals('Code128'));
      expect(Format.dataBar.name, equals('DataBar'));
      expect(Format.dataBarExpanded.name, equals('DataBarExpanded'));
      expect(Format.dataMatrix.name, equals('DataMatrix'));
      expect(Format.ean8.name, equals('EAN8'));
      expect(Format.ean13.name, equals('EAN13'));
      expect(Format.itf.name, equals('ITF'));
      expect(Format.maxiCode.name, equals('MaxiCode'));
      expect(Format.pdf417.name, equals('PDF417'));
      expect(Format.qrCode.name, equals('QR Code'));
      expect(Format.upca.name, equals('UPCA'));
      expect(Format.upce.name, equals('UPCE'));
      expect(Format.microQRCode.name, equals('Micro QR Code'));
      expect(Format.rmqrCode.name, equals('Rectangular Micro QR Code'));
    });

    test('ratio returns correct values', () {
      expect(Format.aztec.ratio, closeTo(1.0, 0.001));
      expect(Format.codabar.ratio, closeTo(3.0, 0.001));
      expect(Format.code39.ratio, closeTo(3.0, 0.001));
      expect(Format.code93.ratio, closeTo(3.0, 0.001));
      expect(Format.code128.ratio, closeTo(2.0, 0.001));
      expect(Format.dataBar.ratio, closeTo(3.0, 0.001));
      expect(Format.dataBarExpanded.ratio, closeTo(1.0, 0.001));
      expect(Format.dataMatrix.ratio, closeTo(1.0, 0.001));
      expect(Format.ean8.ratio, closeTo(3.0, 0.001));
      expect(Format.ean13.ratio, closeTo(3.0, 0.001));
      expect(Format.itf.ratio, closeTo(3.0, 0.001));
      expect(Format.maxiCode.ratio, closeTo(1.0, 0.001));
      expect(Format.pdf417.ratio, closeTo(3.0, 0.001));
      expect(Format.qrCode.ratio, closeTo(1.0, 0.001));
      expect(Format.upca.ratio, closeTo(3.0, 0.001));
      expect(Format.upce.ratio, closeTo(1.0, 0.001));
    });

    test('demoText returns correct string', () {
      expect(Format.aztec.demoText, equals('This is an Aztec Code'));
      expect(Format.codabar.demoText, equals('A123456789B'));
      expect(Format.code39.demoText, equals('ABC-1234'));
      expect(Format.code93.demoText, equals('ABC-1234-/+'));
      expect(Format.code128.demoText, equals('ABC-abc-1234'));
      expect(Format.dataBar.demoText, equals('0123456789012'));
      expect(Format.dataBarExpanded.demoText, equals('011234567890123-ABCabc'));
      expect(Format.dataMatrix.demoText, equals('This is a Data Matrix'));
      expect(Format.ean8.demoText, equals('9031101'));
      expect(Format.ean13.demoText, equals('978020137962'));
      expect(Format.itf.demoText, equals('00012345600012'));
      expect(Format.maxiCode.demoText, equals('This is a MaxiCode'));
      expect(Format.pdf417.demoText, equals('This is a PDF417'));
      expect(Format.qrCode.demoText, equals('This is a QR Code'));
      expect(Format.upca.demoText, equals('72527273070'));
      expect(Format.upce.demoText, equals('0123456'));
    });

    test('maxTextLength returns correct values', () {
      expect(Format.aztec.maxTextLength, equals(3832));
      expect(Format.codabar.maxTextLength, equals(20));
      expect(Format.code39.maxTextLength, equals(43));
      expect(Format.code93.maxTextLength, equals(47));
      expect(Format.code128.maxTextLength, equals(2046));
      expect(Format.dataBar.maxTextLength, equals(74));
      expect(Format.dataBarExpanded.maxTextLength, equals(4107));
      expect(Format.dataMatrix.maxTextLength, equals(2335));
      expect(Format.ean8.maxTextLength, equals(8));
      expect(Format.ean13.maxTextLength, equals(13));
      expect(Format.itf.maxTextLength, equals(20));
      expect(Format.maxiCode.maxTextLength, equals(30));
      expect(Format.pdf417.maxTextLength, equals(2953));
      expect(Format.qrCode.maxTextLength, equals(4296));
      expect(Format.upca.maxTextLength, equals(12));
      expect(Format.upce.maxTextLength, equals(8));
    });

    test('supportedEccLevel supports only QR Code', () => {
      expect(Format.qrCode.isSupportedEccLevel, isTrue),
      expect(Format.ean13.isSupportedEccLevel, isFalse)
    });

    test('supportedEncodeFormats contains expected formats', () => {
      expect(CodeFormat.supportedEncodeFormats, containsAll([
        Format.qrCode,
        Format.dataMatrix,
        Format.aztec,
        Format.codabar,
        Format.code39,
        Format.code93,
        Format.code128,
        Format.ean8,
        Format.ean13,
        Format.itf,
        Format.upca,
        Format.upce,
      ]))
    });

    test('predefined groupings', () {
      expect(Format.linearCodes & Format.codabar, isNot(0));
      expect(Format.linearCodes & Format.dataBar, isNot(0));
      expect(Format.matrixCodes & Format.aztec, isNot(0));
      expect(Format.matrixCodes & Format.dataMatrix, isNot(0));
    });
  });
}