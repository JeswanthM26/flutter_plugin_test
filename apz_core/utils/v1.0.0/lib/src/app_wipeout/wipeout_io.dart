import "dart:io";
import "package:apz_preference/apz_preference.dart";
import "package:apz_utils/src/app_wipeout/wipeout_platform.dart";
import "package:flutter_cache_manager/flutter_cache_manager.dart";
import "package:path_provider/path_provider.dart";

/// A class that provides methods to wipe out application data.
class WipeoutIo implements WipeoutPlatform {
  /// Wipeout Constructor which takes below as params
  WipeoutIo({
    final ApzPreference? prefs,
    final Future<Directory> Function()? getTempDir,
    final Future<Directory> Function()? getDocDir,
    final CacheManager? cacheManager,
  }) : prefs = prefs ?? ApzPreference(),
       getTempDir = getTempDir ?? getTemporaryDirectory,
       getDocDir = getDocDir ?? getApplicationDocumentsDirectory,
       cacheManager = cacheManager ?? DefaultCacheManager();

  /// The preference instance to clear preferences. 
  final ApzPreference prefs;

  /// A function to get the temporary directory.
  final Future<Directory> Function() getTempDir;

  /// A function to get the application documents directory.
  final Future<Directory> Function() getDocDir;

  /// The cache manager instance to clear cache.
  final CacheManager cacheManager;

  /// Clears all preferences stored in local storage.
  @override
  Future<void> clearPreferences() async {
    try {
      // final ApzPreference prefs = ApzPreference();
      await prefs.clearAllData();
      await prefs.clearAllData(isSecure: true);
    } catch (e) {
      throw Exception(e);
    }
  }

  /// Clears all files stored in the application.
  @override
  Future<void> clearFiles() async {
    try {
      final Directory tempDir = await getTempDir();
      final Directory docDir = await getDocDir();
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
        // Recreate the directory to avoid issues
        await tempDir.create();
      }
      if (docDir.existsSync()) {
        await docDir.delete(recursive: true);
        // Recreate the directory to avoid issues
        await docDir.create();
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  /// Clears all cache stored in the application.
  @override
  Future<void> clearCache() async {
    try {
      await DefaultCacheManager().emptyCache();
    } catch (e) {
      rethrow;
    }
  }
}

///Creates an instance of WipeoutPlatform for use in the application.
WipeoutPlatform createPlatform() => WipeoutIo();
