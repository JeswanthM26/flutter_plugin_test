import "package:flutter/foundation.dart"
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// Configuration class for speech parameters based on platform.

double get minRate {
  if (kIsWeb) {
    return 0.5; // Web safe minimum
  }
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return 0.1;
    case TargetPlatform.iOS:
      return 0.1;
    case TargetPlatform.macOS:
      return 0.5;
    case TargetPlatform.windows:
      return 0.5;
    case TargetPlatform.linux:
      return 0.5;
    case TargetPlatform.fuchsia:
      return 0.5;
  }
}

/// Configuration class for speech parameters based on platform.
double get maxRate {
  if (kIsWeb) {
    return 10;
  }
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return 2;
    case TargetPlatform.iOS:
      return 1;
    case TargetPlatform.macOS:
      return 2;
    case TargetPlatform.windows:
      return 2;
    case TargetPlatform.linux:
      return 2;
    case TargetPlatform.fuchsia:
      return 2;
  }
}

/// check localePresent or not
bool isLocalePresent(
  final Map<String, List<String>> voices,
  final String localeToCheck,
) {
  // Iterate through each list of locales in the map's values.
  for (final List<String> locales in voices.values) {
    // Check if the current list contains the locale you're looking for.
    if (locales.contains(localeToCheck)) {
      return true; // Found it! Return true immediately.
    }
  }
  return false; // Searched all lists, and the locale was not found.
}
