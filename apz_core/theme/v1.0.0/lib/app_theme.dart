import "package:flutter/material.dart";

/// AppTheme provides default themes and theme customization options
class AppTheme {
  /// Constructor with default values
  AppTheme({
    final Color? primaryColorLight,
    final Color? secondaryColorLight,
    final Color? tertiaryColorLight,
    final Color? neutralColorLight,
    final Color? errorColorLight,
    final Color? backgroundColorLight,
    final Color? surfaceColorLight,
    final Color? primaryColorDark,
    final Color? secondaryColorDark,
    final Color? tertiaryColorDark,
    final Color? neutralColorDark,
    final Color? errorColorDark,
    final Color? backgroundColorDark,
    final Color? surfaceColorDark,
    final String? headingFontFamily,
    final String? bodyFontFamily,
    final String? displayFontFamily,
    final double textScaleFactor = defaultTextScaleFactor,
  }) : _primaryColorLight = primaryColorLight ?? defaultPrimaryColorLight,
       _secondaryColorLight = secondaryColorLight ?? defaultSecondaryColorLight,
       _tertiaryColorLight = tertiaryColorLight ?? defaultTertiaryColorLight,
       _neutralColorLight = neutralColorLight ?? defaultNeutralColorLight,
       _errorColorLight = errorColorLight ?? defaultErrorColorLight,
       _backgroundColorLight =
           backgroundColorLight ?? defaultBackgroundColorLight,
       _surfaceColorLight = surfaceColorLight ?? defaultSurfaceColorLight,
       _primaryColorDark = primaryColorDark ?? defaultPrimaryColorDark,
       _secondaryColorDark = secondaryColorDark ?? defaultSecondaryColorDark,
       _tertiaryColorDark = tertiaryColorDark ?? defaultTertiaryColorDark,
       _neutralColorDark = neutralColorDark ?? defaultNeutralColorDark,
       _errorColorDark = errorColorDark ?? defaultErrorColorDark,
       _backgroundColorDark = backgroundColorDark ?? defaultBackgroundColorDark,
       _surfaceColorDark = surfaceColorDark ?? defaultSurfaceColorDark,
       _headingFontFamily = headingFontFamily ?? defaultHeadingFontFamily,
       _bodyFontFamily = bodyFontFamily ?? defaultBodyFontFamily,
       _displayFontFamily = displayFontFamily ?? defaultDisplayFontFamily,
       _textScaleFactor = textScaleFactor;

  /// Default text scale factor
  static const double defaultTextScaleFactor = 1;

  // Default colors - Light theme
  /// Primary color for light theme
  static const Color defaultPrimaryColorLight = Colors.orange;

  /// Secondary color for light theme
  static const Color defaultSecondaryColorLight = Colors.orange;

  /// Tertiary color for light theme
  static const Color defaultTertiaryColorLight = Colors.orangeAccent;

  /// Neutral color for light theme
  static const Color defaultNeutralColorLight = Color(0xFF121212);

  /// Error color for light theme
  static const Color defaultErrorColorLight = Color(0xFFB00020);

  /// Background color for light theme
  static const Color defaultBackgroundColorLight = Color(0xFFF5F5F5);

  /// Surface color for light theme
  static const Color defaultSurfaceColorLight = Colors.white;

  // Default colors - Dark theme
  /// Primary color for dark theme
  static const Color defaultPrimaryColorDark = Colors.orange;

  /// Secondary color for dark theme
  static const Color defaultSecondaryColorDark = Colors.orange;

  /// Tertiary color for dark theme
  static const Color defaultTertiaryColorDark = Colors.orangeAccent;

  /// Neutral color for dark theme
  static const Color defaultNeutralColorDark = Color(0xFF121212);

  /// Error color for dark theme
  static const Color defaultErrorColorDark = Color(0xFFCF6679);

  /// Background color for dark theme
  static const Color defaultBackgroundColorDark = Color(0xFFFFFFFF);

  /// Surface color for dark theme
  static const Color defaultSurfaceColorDark = Colors.black;

  // Default font families
  /// Default font family for headings
  static const String defaultHeadingFontFamily = "Roboto";

  /// Default font family for body text
  static const String defaultBodyFontFamily = "Roboto";

  /// Default font family for display text
  static const String defaultDisplayFontFamily = "Roboto";

  // Theme properties
  final Color _primaryColorLight;
  final Color _secondaryColorLight;
  final Color _tertiaryColorLight;
  final Color _neutralColorLight;
  final Color _errorColorLight;
  final Color _backgroundColorLight;
  final Color _surfaceColorLight;

  final Color _primaryColorDark;
  final Color _secondaryColorDark;
  final Color _tertiaryColorDark;
  final Color _neutralColorDark;
  final Color _errorColorDark;
  final Color _backgroundColorDark;
  final Color _surfaceColorDark;

  final String _headingFontFamily;
  final String _bodyFontFamily;
  final String _displayFontFamily;

  double _textScaleFactor;

  /// Create a copy with updated properties
  AppTheme copyWith({
    final Color? primaryColorLight,
    final Color? secondaryColorLight,
    final Color? tertiaryColorLight,
    final Color? neutralColorLight,
    final Color? errorColorLight,
    final Color? backgroundColorLight,
    final Color? surfaceColorLight,
    final Color? primaryColorDark,
    final Color? secondaryColorDark,
    final Color? tertiaryColorDark,
    final Color? neutralColorDark,
    final Color? errorColorDark,
    final Color? backgroundColorDark,
    final Color? surfaceColorDark,
    final String? headingFontFamily,
    final String? bodyFontFamily,
    final String? displayFontFamily,
    final double? textScaleFactor,
  }) => AppTheme(
    primaryColorLight: primaryColorLight ?? _primaryColorLight,
    secondaryColorLight: secondaryColorLight ?? _secondaryColorLight,
    tertiaryColorLight: tertiaryColorLight ?? _tertiaryColorLight,
    neutralColorLight: neutralColorLight ?? _neutralColorLight,
    errorColorLight: errorColorLight ?? _errorColorLight,
    backgroundColorLight: backgroundColorLight ?? _backgroundColorLight,
    surfaceColorLight: surfaceColorLight ?? _surfaceColorLight,
    primaryColorDark: primaryColorDark ?? _primaryColorDark,
    secondaryColorDark: secondaryColorDark ?? _secondaryColorDark,
    tertiaryColorDark: tertiaryColorDark ?? _tertiaryColorDark,
    neutralColorDark: neutralColorDark ?? _neutralColorDark,
    errorColorDark: errorColorDark ?? _errorColorDark,
    backgroundColorDark: backgroundColorDark ?? _backgroundColorDark,
    surfaceColorDark: surfaceColorDark ?? _surfaceColorDark,
    headingFontFamily: headingFontFamily ?? _headingFontFamily,
    bodyFontFamily: bodyFontFamily ?? _bodyFontFamily,
    displayFontFamily: displayFontFamily ?? _displayFontFamily,
    textScaleFactor: textScaleFactor ?? _textScaleFactor,
  );

  /// Static instance with default values
  static final AppTheme defaultTheme = AppTheme();

  /// Get the text scale factor
  double get textScaleFactor => _textScaleFactor;

  /// Set the text scale factor
  // ignore: use_setters_to_change_properties
  void setTextScaleFactor(final double value) {
    _textScaleFactor = value;
  }

  // Helper method to calculate automatic contrast colors
  static Color _calculateTextColor(final Color backgroundColor) {
    // Calculate the relative luminance of the color
    // Formula: 0.299*R + 0.587*G + 0.114*B
    final double luminance =
        (0.299 * (backgroundColor.r * 255.0).round() +
            0.587 * (backgroundColor.g * 255.0).round() +
            0.114 * (backgroundColor.b * 255.0).round()) /
        255;

    // If luminance is > 0.5, the color is considered light, so use dark text
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  // Helper method to scale font size
  static double _scaleFontSize(
    final double fontSize,
    final double scaleFactor,
  ) => fontSize * scaleFactor;

  /// Light theme
  ThemeData get lightTheme => _createLightTheme();

  /// Dark theme
  ThemeData get darkTheme => _createDarkTheme();

  // Create light theme with the current properties
  ThemeData _createLightTheme() {
    final Color onPrimary = _calculateTextColor(_primaryColorLight);
    final Color onSecondary = _calculateTextColor(_secondaryColorLight);
    final Color onTertiary = _calculateTextColor(_tertiaryColorLight);
    final Color onError = _calculateTextColor(_errorColorLight);
    final Color onBackground = _neutralColorLight;
    final Color onSurface = _neutralColorLight;

    return ThemeData(
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: _primaryColorLight,
        secondary: _secondaryColorLight,
        tertiary: _tertiaryColorLight,
        surface: _surfaceColorLight,
        error: _errorColorLight,
        onPrimary: onPrimary,
        onSecondary: onSecondary,
        onTertiary: onTertiary,
        onSurface: onSurface,
        onError: onError,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _primaryColorLight,
        foregroundColor: onPrimary,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: _scaleFontSize(20, _textScaleFactor),
          fontWeight: FontWeight.bold,
          color: onPrimary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: onPrimary,
          backgroundColor: _primaryColorLight,
          textStyle: TextStyle(
            fontSize: _scaleFontSize(16, _textScaleFactor),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _primaryColorLight,
        foregroundColor: onPrimary,
      ),
      textTheme: _createTextTheme(onBackground, isLightTheme: true),
      cardTheme: CardThemeData(
        color: _surfaceColorLight,
        elevation: 2,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
    );
  }

  // Create dark theme with the current properties
  ThemeData _createDarkTheme() {
    final Color onPrimary = _calculateTextColor(_primaryColorDark);
    final Color onSecondary = _calculateTextColor(_secondaryColorDark);
    final Color onTertiary = _calculateTextColor(_tertiaryColorDark);
    final Color onError = _calculateTextColor(_errorColorDark);
    final Color onBackground = _calculateTextColor(_neutralColorDark);
    final Color onSurface = _calculateTextColor(_neutralColorDark);

    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: _primaryColorDark,
        secondary: _secondaryColorDark,
        tertiary: _tertiaryColorDark,
        surface: _surfaceColorDark,
        error: _errorColorDark,
        onPrimary: onPrimary,
        onSecondary: onSecondary,
        onTertiary: onTertiary,
        onSurface: onSurface,
        onError: onError,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _surfaceColorDark,
        foregroundColor: onSurface,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: _scaleFontSize(20, _textScaleFactor),
          fontWeight: FontWeight.bold,
          color: onSurface,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: onPrimary,
          backgroundColor: _primaryColorDark,
          textStyle: TextStyle(
            fontSize: _scaleFontSize(16, _textScaleFactor),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _primaryColorDark,
        foregroundColor: onPrimary,
      ),
      textTheme: _createTextTheme(onBackground, isLightTheme: false),
      cardTheme: CardThemeData(
        color: _surfaceColorDark,
        elevation: 2,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        // shadowColor: _primaryColorDark,
        surfaceTintColor: _primaryColorDark.withValues(alpha: 0.2),
      ),
    );
  }

  // Create text theme with the given base color
  TextTheme _createTextTheme(
    final Color textColor, {
    required final bool isLightTheme,
  }) => TextTheme(
    // Display styles
    displayLarge: TextStyle(
      fontSize: _scaleFontSize(57, _textScaleFactor),
      fontWeight: FontWeight.bold,
      color: textColor,
    ),
    displayMedium: TextStyle(
      fontSize: _scaleFontSize(45, _textScaleFactor),
      fontWeight: FontWeight.bold,
      color: textColor,
    ),
    displaySmall: TextStyle(
      fontSize: _scaleFontSize(36, _textScaleFactor),
      fontWeight: FontWeight.bold,
      color: textColor,
    ),

    // Headline styles
    headlineLarge: TextStyle(
      fontSize: _scaleFontSize(32, _textScaleFactor),
      fontWeight: FontWeight.bold,
      color: textColor,
    ),
    headlineMedium: TextStyle(
      fontSize: _scaleFontSize(28, _textScaleFactor),
      fontWeight: FontWeight.bold,
      color: textColor,
    ),
    headlineSmall: TextStyle(
      fontSize: _scaleFontSize(24, _textScaleFactor),
      fontWeight: FontWeight.bold,
      color: textColor,
    ),

    // Title styles
    titleLarge: TextStyle(
      fontSize: _scaleFontSize(22, _textScaleFactor),
      fontWeight: FontWeight.w600,
      color: textColor,
    ),
    titleMedium: TextStyle(
      fontSize: _scaleFontSize(16, _textScaleFactor),
      fontWeight: FontWeight.w600,
      color: textColor,
    ),
    titleSmall: TextStyle(
      fontSize: _scaleFontSize(14, _textScaleFactor),
      fontWeight: FontWeight.w600,
      color: textColor,
    ),

    // Body styles
    bodyLarge: TextStyle(
      fontSize: _scaleFontSize(16, _textScaleFactor),
      fontWeight: FontWeight.normal,
      color: textColor,
    ),
    bodyMedium: TextStyle(
      fontSize: _scaleFontSize(14, _textScaleFactor),
      fontWeight: FontWeight.normal,
      color: textColor,
    ),
    bodySmall: TextStyle(
      fontSize: _scaleFontSize(12, _textScaleFactor),
      fontWeight: FontWeight.normal,
      color: textColor,
    ),

    // Label styles
    labelLarge: TextStyle(
      fontSize: _scaleFontSize(14, _textScaleFactor),
      fontWeight: FontWeight.w500,
      color: textColor,
    ),
    labelMedium: TextStyle(
      fontSize: _scaleFontSize(12, _textScaleFactor),
      fontWeight: FontWeight.w500,
      color: textColor,
    ),
    labelSmall: TextStyle(
      fontSize: _scaleFontSize(11, _textScaleFactor),
      fontWeight: FontWeight.w500,
      color: textColor,
    ),
  );
}
