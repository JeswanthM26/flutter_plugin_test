import "package:apz_photopicker/photopicker_image_model.dart";
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apz_photopicker/enum.dart';

void main() {
  // 1) Initialize bindings
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    
  });

  tearDownAll(() {
    // clean up
  });


  group('ImageModel', () {
    test('all properties hold the values passed to the constructor', () {
      final model = PhotopickerImageModel(
        fileName: 'test_file',
        crop: true,
        quality: 85,
        targetWidth: 800,
        targetHeight: 600,
        format: PhotopickerImageFormat.png,
        cropTitle: 'Please crop',
      );

      expect(model.fileName, 'test_file');
      expect(model.crop, isTrue);
      expect(model.quality, 85);
      expect(model.targetWidth, 800);
      expect(model.targetHeight, 600);
      expect(model.format, PhotopickerImageFormat.png);
      expect(model.cropTitle, 'Please crop');
    });
  });
}
