import "package:apz_qr/models/apz_qr_scanner_icons.dart";
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApzQrScannerIcons', () {
    test('uses default icons when no values are provided', () {
      const icons = ApzQrScannerIcons();

      expect(icons.flashOnIcon.icon, Icons.flash_on);
      expect(icons.flashOffIcon.icon, Icons.flash_off);
      expect(icons.flashAlwaysIcon.icon, Icons.flash_on);
      expect(icons.flashAutoIcon.icon, Icons.flash_auto);
      expect(icons.galleryIcon.icon, Icons.photo_library);
      expect(icons.toggleCameraIcon.icon, Icons.cameraswitch);
    });

    test('overrides icons when custom icons are provided', () {
      const customIcon = Icon(Icons.star);

      const icons = ApzQrScannerIcons(
        flashOnIcon: customIcon,
        flashOffIcon: customIcon,
        flashAlwaysIcon: customIcon,
        flashAutoIcon: customIcon,
        galleryIcon: customIcon,
        toggleCameraIcon: customIcon,
      );

      expect(icons.flashOnIcon.icon, Icons.star);
      expect(icons.flashOffIcon.icon, Icons.star);
      expect(icons.flashAlwaysIcon.icon, Icons.star);
      expect(icons.flashAutoIcon.icon, Icons.star);
      expect(icons.galleryIcon.icon, Icons.star);
      expect(icons.toggleCameraIcon.icon, Icons.star);
    });
  });
}
