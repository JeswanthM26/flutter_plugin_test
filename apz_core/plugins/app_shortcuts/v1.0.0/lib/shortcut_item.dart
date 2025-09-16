/// This file is part of the APZ App Shortcuts plugin.
/// It defines the `ShortcutItem` class used to represent individual
/// shortcut items.
class ShortcutItem {
  /// Creates a new instance of `ShortcutItem`.
  ShortcutItem({required this.id, required this.title, required this.icon});

  /// The id of the shortcut item, used to identify it when tapped.
  final String id;

  /// the title of the shortcut item, displayed to the user.
  final String title;

  /// Icon for the shortcut item, displayed alongside the title.
  final String icon;

  /// Converts the `ShortcutItem` to a JSON representation.
  Map<String, dynamic> toJson() => <String, dynamic>{
    "id": id,
    "title": title,
    "icon": icon,
  };
}
