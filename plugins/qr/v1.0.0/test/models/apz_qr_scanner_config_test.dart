import "package:apz_qr/models/apz_qr_scanner_config.dart";
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_zxing/flutter_zxing.dart' as zxing;

void main() {
  group('ApzQrScannerConfig', () {
    test('uses default values when not provided', () {
      const config = ApzQrScannerConfig();

      expect(config.isMultiScan, false);
      expect(config.resolution, zxing.ResolutionPreset.high);
      expect(config.lensDirection, zxing.CameraLensDirection.back);
      expect(config.verticalCropOffset, -0.7);
      expect(config.horizontalCropOffset, 0);
      expect(config.cropPercent, 0.8);
      expect(config.scannerLineColor, Colors.redAccent);
    });

    test('overrides values when provided', () {
      const customConfig = ApzQrScannerConfig(
        isMultiScan: true,
        resolution: zxing.ResolutionPreset.low,
        lensDirection: zxing.CameraLensDirection.front,
        verticalCropOffset: 0.2,
        horizontalCropOffset: 0.3,
        cropPercent: 0.8,
        scannerLineColor: Colors.green,
      );

      expect(customConfig.isMultiScan, true);
      expect(customConfig.resolution, zxing.ResolutionPreset.low);
      expect(customConfig.lensDirection, zxing.CameraLensDirection.front);
      expect(customConfig.verticalCropOffset, 0.2);
      expect(customConfig.horizontalCropOffset, 0.3);
      expect(customConfig.cropPercent, 0.8);
      expect(customConfig.scannerLineColor, Colors.green);
    });
  });
}
