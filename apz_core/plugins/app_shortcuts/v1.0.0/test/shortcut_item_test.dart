import "package:apz_app_shortcuts/shortcut_item.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("ShortcutItem", () {
    test("should create a ShortcutItem with correct properties", () {
      final ShortcutItem item = ShortcutItem(
        id: "1",
        title: "Test",
        icon: "icon.png",
      );
      expect(item.id, "1");
      expect(item.title, "Test");
      expect(item.icon, "icon.png");
    });

    test("should convert ShortcutItem to JSON correctly", () {
      final ShortcutItem item = ShortcutItem(
        id: "2",
        title: "Another",
        icon: "icon2.png",
      );
      final Map<String, dynamic> json = item.toJson();
      expect(json, <String, String>{
        "id": "2",
        "title": "Another",
        "icon": "icon2.png",
      });
    });
  });
}
