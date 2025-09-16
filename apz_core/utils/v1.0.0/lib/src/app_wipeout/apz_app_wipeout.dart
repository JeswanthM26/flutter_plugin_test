// Conditional imports
import "package:apz_utils/src/app_wipeout/wipeout_io.dart"
    if (dart.library.html) "package:apz_utils/src/app_wipeout/wipeout_web.dart";
import "package:apz_utils/src/app_wipeout/wipeout_platform.dart";

/// Create an instance of WipeoutPlatform for use in the application.
WipeoutPlatform platform = createPlatform();

/// A class that provides methods to wipe out application data.
class ApzAppWipeOut {
  /// Wipes all application data.
  factory ApzAppWipeOut() => _instance;
  ApzAppWipeOut._();
  static final ApzAppWipeOut _instance = ApzAppWipeOut._();

  ///
  final List<Exception> errors = <Exception>[];

  /// Wipes all application data.
  Future<void> wipeAllData() async {
    try {
      await platform.clearPreferences();
    } on Exception catch (e) {
      errors.add(e);
    }

    try {
      await platform.clearFiles();
    } on Exception catch (e) {
      errors.add(e);
    }

    try {
      await platform.clearCache();
    } on Exception catch (e) {
      errors.add(e);
    }
    if (errors.isNotEmpty) {
      throw Exception(
        "Wipeout failed: ${errors.length} error(s). $errors",
      );
    }
  }
}
