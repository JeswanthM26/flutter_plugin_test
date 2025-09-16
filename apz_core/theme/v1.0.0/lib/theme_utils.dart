import "package:apz_theme/app_theme.dart";
import "package:flutter/material.dart";

// Avoid Classes with only static members
// ignore: avoid_classes_with_only_static_members
/// ThemeUtils provides utility functions for theme management
class ThemeUtils {
  /// Creates a color palette based on a single primary color
  /// Returns a map with primary, secondary, tertiary, neutral and error colors
  static Map<String, Color> generatePaletteFromColor(final Color primaryColor) {
    // Generate a complementary color for secondary (180 degrees on color wheel)
    final int complementaryR = 255 - (primaryColor.r * 255.0).round();
    final int complementaryG = 255 - (primaryColor.g * 255.0).round();
    final int complementaryB = 255 - (primaryColor.b * 255.0).round();
    final Color secondaryColor = Color.fromARGB(
      255,
      complementaryR,
      complementaryG,
      complementaryB,
    );

    // Generate a tertiary color (90 degrees on color wheel)
    final HSLColor hslPrimary = HSLColor.fromColor(primaryColor);
    final HSLColor hslTertiary = hslPrimary.withHue(
      (hslPrimary.hue + 90) % 360,
    );
    final Color tertiaryColor = hslTertiary.toColor();

    // Generate a neutral color based on primary but desaturated
    final HSLColor hslNeutral = hslPrimary.withSaturation(0.2);
    final Color neutralColor = Color.lerp(
      hslNeutral.toColor(),
      Colors.grey[800],
      0.5,
    )!;

    // Generate an error color (usually in red spectrum)
    final Color errorColor = Colors.red[700]!;

    return <String, Color>{
      "primary": primaryColor,
      "secondary": secondaryColor,
      "tertiary": tertiaryColor,
      "neutral": neutralColor,
      "error": errorColor,
    };
  }

  /// Creates a custom AppTheme from a brand color
  /// This simplifies theme creation by deriving
  /// all colors from a single brand color
  static AppTheme createThemeFromBrandColor(
    final Color brandColor, {
    final double textScaleFactor = 1.0,
  }) {
    final Map<String, Color> palette = generatePaletteFromColor(brandColor);

    return AppTheme(
      // Light theme colors
      primaryColorLight: palette["primary"],
      secondaryColorLight: palette["secondary"],
      tertiaryColorLight: palette["tertiary"],
      neutralColorLight: palette["neutral"],
      errorColorLight: palette["error"],

      // Dark theme colors - slightly adjusted for dark mode
      primaryColorDark: Color.lerp(palette["primary"], Colors.black, 0.3),
      secondaryColorDark: Color.lerp(palette["secondary"], Colors.black, 0.2),
      tertiaryColorDark: Color.lerp(palette["tertiary"], Colors.black, 0.2),
      neutralColorDark: Colors.white,
      errorColorDark: Color.lerp(palette["error"], Colors.white, 0.2),

      textScaleFactor: textScaleFactor,
    );
  }

  /// Creates a custom AppTheme with Google Material 3 inspired color scheme
  /// This function requires explicit colors for more control
  static AppTheme createMaterial3Theme({
    required final Color primaryColor,
    required final Color secondaryColor,
    required final Color tertiaryColor,
    final Color? neutralColor,
    final Color? errorColor,
    final double textScaleFactor = 1.0,
    final String? headingFontFamily,
    final String? bodyFontFamily,
    final String? displayFontFamily,
  }) {
    final Color neutralColorValue = neutralColor ?? Colors.grey[800]!;
    final Color errorColorValue = errorColor ?? Colors.red[700]!;

    return AppTheme(
      // Light theme colors
      primaryColorLight: primaryColor,
      secondaryColorLight: secondaryColor,
      tertiaryColorLight: tertiaryColor,
      neutralColorLight: neutralColorValue,
      errorColorLight: errorColorValue,

      // Dark theme colors - adjusted for dark mode
      primaryColorDark: Color.lerp(primaryColor, Colors.black, 0.3),
      secondaryColorDark: Color.lerp(secondaryColor, Colors.black, 0.2),
      tertiaryColorDark: Color.lerp(tertiaryColor, Colors.black, 0.2),
      neutralColorDark: Colors.white,
      errorColorDark: Color.lerp(errorColorValue, Colors.white, 0.2),

      // Font families if specified
      headingFontFamily: headingFontFamily,
      bodyFontFamily: bodyFontFamily,
      displayFontFamily: displayFontFamily,

      textScaleFactor: textScaleFactor,
    );
  }
}
