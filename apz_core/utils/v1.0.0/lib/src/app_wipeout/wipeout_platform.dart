
/// Provides methods to wipe out application data on different platforms.
abstract class WipeoutPlatform {
  /// Clears all preferences stored in local storage.
  Future<void> clearPreferences();
  /// Clears all files stored in the application.
  Future<void> clearFiles();
  /// Clears all cache stored in the application.
  Future<void> clearCache();
}
