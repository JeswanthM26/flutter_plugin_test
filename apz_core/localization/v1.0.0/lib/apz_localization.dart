import "package:flutter/material.dart";

/// APZLocalization manages app localization and
/// notifies listeners on locale changes
class APZLocalization extends ChangeNotifier {
  /// Singleton instance
  factory APZLocalization() => _instance;

  APZLocalization._internal();
  static final APZLocalization _instance = APZLocalization._internal();

  String _defaultLanguageCode = "en";

  Locale _locale = const Locale("en");

  /// Current locale
  Locale get locale => _locale;

  /// Default language code
  void setDefaultLocale(final String languageCode) {
    _defaultLanguageCode = languageCode;
    _locale = Locale(languageCode);
  }

  /// Change the app locale
  void changeLocale(final String languageCode) {
    if (_locale.languageCode != languageCode) {
      _locale = Locale(languageCode);
      notifyListeners();
    }
  }

  /// Reset to default locale
  void resetLocale() {
    _locale = Locale(_defaultLanguageCode);
  }
}
