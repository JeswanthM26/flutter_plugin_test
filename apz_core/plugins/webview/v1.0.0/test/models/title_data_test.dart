import "package:apz_webview/models/title_data.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("TitleData", () {
    test("should create TitleData with correct properties", () {
      const String testTitle = "Test Title";
      const Color testColor = Colors.blue;

      const TitleData titleData = TitleData(
        title: testTitle,
        titleColor: testColor,
      );

      expect(titleData.title, equals(testTitle));
      expect(titleData.titleColor, equals(testColor));
    });

    test("should create TitleData with different colors", () {
      const String testTitle = "Test Title";
      const List<Color> testColors = <Color>[
        Colors.red,
        Colors.green,
        Colors.black,
        Colors.white,
      ];

      for (final Color color in testColors) {
        final TitleData titleData = TitleData(
          title: testTitle,
          titleColor: color,
        );

        expect(titleData.title, equals(testTitle));
        expect(titleData.titleColor, equals(color));
      }
    });

    test("should handle empty title", () {
      const String emptyTitle = "";
      const Color testColor = Colors.blue;

      const TitleData titleData = TitleData(
        title: emptyTitle,
        titleColor: testColor,
      );

      expect(titleData.title, isEmpty);
      expect(titleData.titleColor, equals(testColor));
    });

    test("should handle long titles", () {
      const String longTitle =
          """This is a very long title that could potentially be used in the application""";
      const Color testColor = Colors.blue;

      const TitleData titleData = TitleData(
        title: longTitle,
        titleColor: testColor,
      );

      expect(titleData.title, equals(longTitle));
      expect(titleData.titleColor, equals(testColor));
    });
  });
}
