import "package:apz_preference/apz_preference.dart";
import "package:apz_utils/src/app_wipeout/wipeout_platform.dart";
import "package:js/js_util.dart";
import "package:web/web.dart" as html;

/// A class that provides methods to wipe out application data.
class WipeoutWeb implements WipeoutPlatform {
  /// Clears all preferences stored in local storage.
  @override
  Future<void> clearPreferences() async {
    try {
      final ApzPreference prefs = ApzPreference();
      await prefs.clearAllData();
      await prefs.clearAllData(isSecure: true);
    } catch (e) {
      throw Exception(e);
    }
  }

  /// Clears all files stored in the application.
  @override
  Future<void> clearFiles() async {
    // There will be no sandboxed file system in web, so this method is a no-op.
    // No file system to clear on web.
  }

  /// Clears all cache stored in the application.
  @override
  Future<void> clearCache() async {
    try {
      final List<String> keys = List<String>.from(
        await promiseToFuture(html.window.caches.keys()),
      );

      for (final String key in keys) {
        await promiseToFuture(html.window.caches.delete(key));
      }
    } catch (e) {
      throw Exception(e);
    }
  }
}

/// Creates an instance of WipeoutPlatform for use in the application.
WipeoutPlatform createPlatform() => WipeoutWeb();
