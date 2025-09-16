import "package:apz_theme/app_theme.dart";
import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

/// ThemeProvider manages theme state and persistence using ChangeNotifier
class ThemeProvider extends ChangeNotifier {
  /// Constructor with optional custom AppTheme
  ThemeProvider({final AppTheme? theme})
    : _appTheme = theme ?? AppTheme.defaultTheme;
  // Theme mode (light, dark, system)
  ThemeMode _themeMode = ThemeMode.system;

  // Instance of AppTheme that manages both light and dark themes
  AppTheme _appTheme;

  // Default text scale factor
  double? _deviceTextScaleFactor;

  // Keys for shared preferences
  static const String _darkModeKey = "dark_mode";
  static const String _textScaleFactorKey = "text_scale_factor";

  // Getters
  /// Current theme mode and properties
  ThemeMode get themeMode => _themeMode;

  /// True if dark mode is active
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Current text scale factor
  double get textScaleFactor => _appTheme.textScaleFactor;

  /// Device text scale factor
  double? get deviceTextScaleFactor => _deviceTextScaleFactor;

  /// Current AppTheme instance
  AppTheme get appTheme => _appTheme;

  // Get light and dark themes based on current app theme
  /// Light theme data
  ThemeData get lightTheme => _appTheme.lightTheme;

  /// Dark theme data
  ThemeData get darkTheme => _appTheme.darkTheme;

  /// Set light mode
  Future<void> setLightMode() async {
    _themeMode = ThemeMode.light;
    await _saveSettings();
    notifyListeners();
  }

  /// Set dark mode
  Future<void> setDarkMode() async {
    _themeMode = ThemeMode.dark;
    await _saveSettings();
    notifyListeners();
  }

  /// Toggle between light and dark themes
  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    await _saveSettings();
    notifyListeners();
  }

  /// Set text scale factor
  Future<void> setTextScaleFactor(final double value) async {
    _appTheme.setTextScaleFactor(value);
    await _saveSettings();
    notifyListeners();
  }

  /// Update the app theme (for custom themes)
  Future<void> updateTheme(final AppTheme newTheme) async {
    _appTheme = newTheme;
    await _saveSettings();
    notifyListeners();
  }

  /// Update specific theme properties
  Future<void> updateThemeProperties({
    // Light theme colors
    final Color? primaryColorLight,
    final Color? secondaryColorLight,
    final Color? tertiaryColorLight,
    final Color? neutralColorLight,
    final Color? errorColorLight,
    final Color? backgroundColorLight,
    final Color? surfaceColorLight,

    // Dark theme colors
    final Color? primaryColorDark,
    final Color? secondaryColorDark,
    final Color? tertiaryColorDark,
    final Color? neutralColorDark,
    final Color? errorColorDark,
    final Color? backgroundColorDark,
    final Color? surfaceColorDark,

    // Font families
    final String? headingFontFamily,
    final String? bodyFontFamily,
    final String? displayFontFamily,

    // Text scale
    final double? textScaleFactor,
  }) async {
    _appTheme = _appTheme.copyWith(
      primaryColorLight: primaryColorLight,
      secondaryColorLight: secondaryColorLight,
      tertiaryColorLight: tertiaryColorLight,
      neutralColorLight: neutralColorLight,
      errorColorLight: errorColorLight,
      backgroundColorLight: backgroundColorLight,
      surfaceColorLight: surfaceColorLight,
      primaryColorDark: primaryColorDark,
      secondaryColorDark: secondaryColorDark,
      tertiaryColorDark: tertiaryColorDark,
      neutralColorDark: neutralColorDark,
      errorColorDark: errorColorDark,
      backgroundColorDark: backgroundColorDark,
      surfaceColorDark: surfaceColorDark,
      headingFontFamily: headingFontFamily,
      bodyFontFamily: bodyFontFamily,
      displayFontFamily: displayFontFamily,
      textScaleFactor: textScaleFactor,
    );

    await _saveSettings();
    notifyListeners();
  }

  /// Reset to default theme
  Future<void> resetToDefaultTheme() async {
    _appTheme = AppTheme.defaultTheme;
    await _saveSettings();
    notifyListeners();
  }

  /// Load settings from SharedPreferences
  Future<void> loadSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool isDarkModePref = prefs.getBool(_darkModeKey) ?? false;
    _themeMode = isDarkModePref ? ThemeMode.dark : ThemeMode.light;

    // Check if we have a saved text scale factor preference
    final double? savedTextScale = prefs.getDouble(_textScaleFactorKey);

    // If we have a saved preference, use it;
    // otherwise use device scale if available
    if (savedTextScale != null) {
      _appTheme.setTextScaleFactor(savedTextScale);
    } else if (_deviceTextScaleFactor != null) {
      _appTheme.setTextScaleFactor(_deviceTextScaleFactor!);
      // Save this as the user's preference
      await _saveSettings();
    }

    notifyListeners();
  }

  /// Initialize with device text scale factor
  Future<void> initWithDeviceTextScale(final double deviceScale) async {
    _deviceTextScaleFactor = deviceScale;

    // If no explicit text scale has been set yet, use the device scale
    if (_appTheme.textScaleFactor == 1.0 &&
        !await _hasExplicitTextScaleBeenSet()) {
      _appTheme.setTextScaleFactor(deviceScale);
      await _saveSettings();
      notifyListeners();
    }
  }

  // Check if an explicit text scale has been set
  Future<bool> _hasExplicitTextScaleBeenSet() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_textScaleFactorKey);
    } on Exception catch (_) {
      return false;
    }
  }

  // Save settings to SharedPreferences
  Future<void> _saveSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, _themeMode == ThemeMode.dark);
    await prefs.setDouble(_textScaleFactorKey, _appTheme.textScaleFactor);
  }
}
