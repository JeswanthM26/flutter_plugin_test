import "package:apz_text_to_speech/config.dart";
import "package:flutter/foundation.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("minRate", () {
    // Tests for mobile and desktop platforms
    test("returns 0.1 for Android", () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      expect(minRate, 0.1);
    });

    test("returns 0.1 for iOS", () {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      expect(minRate, 0.1);
    });

    test("returns 0.5 for macOS", () {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      expect(minRate, 0.5);
    });

    test("returns 0.5 for Windows", () {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      expect(minRate, 0.5);
    });

    test("returns 0.5 for Linux", () {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      expect(minRate, 0.5);
    });

    test("returns 0.5 for Fuchsia", () {
      debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
      expect(minRate, 0.5);
    });
  });

  group("maxRate", () {
    // Tests for mobile and desktop platforms
    test("returns 2 for Android", () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      expect(maxRate, 2);
    });

    test("returns 1 for iOS", () {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      expect(maxRate, 1);
    });

    test("returns 2 for macOS", () {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      expect(maxRate, 2);
    });

    test("returns 2 for Windows", () {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      expect(maxRate, 2);
    });

    test("returns 2 for Linux", () {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      expect(maxRate, 2);
    });

    test("returns 2 for Fuchsia", () {
      debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
      expect(maxRate, 2);
    });
  });
  group("isLocalePresent", () {
    final Map<String, List<String>> testData = {
      "VoiceA": ["en-US", "es-ES"],
      "VoiceB": ["fr-FR"],
      "VoiceC": ["ja-JP", "en-GB"],
    };

    test("returns true when locale is present in a list", () {
      expect(isLocalePresent(testData, "es-ES"), isTrue);
    });

    test("returns false when locale is not present", () {
      expect(isLocalePresent(testData, "de-DE"), isFalse);
    });

    test("returns true for a locale in a multi-language voice", () {
      expect(isLocalePresent(testData, "ja-JP"), isTrue);
    });

    test("returns false for an empty map", () {
      expect(isLocalePresent({}, "en-US"), isFalse);
    });
  });

  // Ensure the override is cleared after all tests in this file
  tearDownAll(() {
    debugDefaultTargetPlatformOverride = null;
  });
}
