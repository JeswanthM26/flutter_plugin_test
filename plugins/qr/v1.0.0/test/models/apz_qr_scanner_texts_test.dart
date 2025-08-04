import "package:apz_qr/models/apz_qr_scanner_texts.dart";
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApzQrScannerTexts', () {
    test('uses default cameraPermissionText when not provided', () {
      const texts = ApzQrScannerTexts();

      expect(texts.cameraPermissionText, 'Camera permission is required.');
      expect(texts.waitingText, 'Waiting for permissions...');
    });

    test('overrides cameraPermissionText when provided', () {
      const customMessage = 'Please enable your camera to scan QR codes.';
      const customWaitingMessage  = "Waiting untill permission given";
      const texts = ApzQrScannerTexts(cameraPermissionText: customMessage, waitingText:customWaitingMessage );

      expect(texts.cameraPermissionText, customMessage);
      expect(texts.waitingText, customWaitingMessage);
    });
  });
}
