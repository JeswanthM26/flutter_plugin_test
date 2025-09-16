import "package:apz_qr/models/position.dart";
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Position class', () {
    test('Constructor initializes all properties correctly', () {
      // Sample values
      const imageWidth = 800;
      const imageHeight = 600;
      const topLeftX = 100;
      const topLeftY = 50;
      const topRightX = 200;
      const topRightY = 50;
      const bottomLeftX = 100;
      const bottomLeftY = 150;
      const bottomRightX = 200;
      const bottomRightY = 150;

      final position = Position(
        imageWidth,
        imageHeight,
        topLeftX,
        topLeftY,
        topRightX,
        topRightY,
        bottomLeftX,
        bottomLeftY,
        bottomRightX,
        bottomRightY,
      );

      // Verify that properties are assigned correctly
      expect(position.imageWidth, equals(imageWidth));
      expect(position.imageHeight, equals(imageHeight));
      expect(position.topLeftX, equals(topLeftX));
      expect(position.topLeftY, equals(topLeftY));
      expect(position.topRightX, equals(topRightX));
      expect(position.topRightY, equals(topRightY));
      expect(position.bottomLeftX, equals(bottomLeftX));
      expect(position.bottomLeftY, equals(bottomLeftY));
      expect(position.bottomRightX, equals(bottomRightX));
      expect(position.bottomRightY, equals(bottomRightY));
    });

    test('Constructor works with different values', () {
      final position = Position(
        1024,
        768,
        300,
        250,
        400,
        250,
        300,
        350,
        400,
        350,
      );

      expect(position.imageWidth, equals(1024));
      expect(position.imageHeight, equals(768));
      expect(position.topLeftX, equals(300));
      expect(position.topLeftY, equals(250));
      expect(position.topRightX, equals(400));
      expect(position.topRightY, equals(250));
      expect(position.bottomLeftX, equals(300));
      expect(position.bottomLeftY, equals(350));
      expect(position.bottomRightX, equals(400));
      expect(position.bottomRightY, equals(350));
    });
  });
}