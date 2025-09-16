import "package:apz_app_shortcuts/shortcut_item.dart";
import "package:flutter/services.dart";

/// Callback type for handling shortcut item taps
typedef ShortcutCallback = void Function(String id);

/// Class to manage app shortcuts
/// This class allows setting shortcut items and handling their tap events.
class ApzAppShortcuts {
  /// Singleton instance of ApzAppShortcuts
  /// Use `ApzAppShortcuts()` to access the instance.
  factory ApzAppShortcuts() => _instance;

  ApzAppShortcuts._internal();
  static final ApzAppShortcuts _instance = ApzAppShortcuts._internal();

  static const MethodChannel _channel = MethodChannel(
    "com.iexceed/apz_app_shortcuts",
  );

  ShortcutCallback? _callback;

  /// Registers a callback to handle shortcut tap events
  void registerShortcutCallback(final ShortcutCallback callback) {
    _callback = callback;

    _channel.setMethodCallHandler((final MethodCall call) async {
      if (call.method == "onShortcutItemTapped") {
        final String type = call.arguments as String;
        _callback?.call(type);
      }
    });
  }

  /// Set shortcut items to be shown on long press of app icon
  Future<void> setShortcutItems(final List<ShortcutItem> items) async {
    await _channel.invokeMethod(
      "setShortcutItems",
      items.map((final ShortcutItem item) => item.toJson()).toList(),
    );
  }

  /// Removes all dynamic app shortcuts from the launcher icon
  Future<void> clearShortcutItems() async {
    await _channel.invokeMethod("clearShortcutItems");
  }
}
