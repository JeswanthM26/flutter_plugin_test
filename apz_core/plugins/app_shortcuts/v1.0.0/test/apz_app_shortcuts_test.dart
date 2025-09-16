import "package:apz_app_shortcuts/apz_app_shortcuts.dart";
import "package:apz_app_shortcuts/shortcut_item.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group("ApzAppShortcuts", () {
    const MethodChannel channel = MethodChannel(
      "com.iexceed/apz_app_shortcuts",
    );
    final List<MethodCall> log = <MethodCall>[];

    setUp(() {
      log.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (
            final MethodCall methodCall,
          ) async {
            log.add(methodCall);
            if (methodCall.method == "setShortcutItems") {
              return null;
            }
            if (methodCall.method == "clearShortcutItems") {
              return null;
            }
            return null;
          });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test(
      "setShortcutItems invokes method channel with correct arguments",
      () async {
        final List<ShortcutItem> items = <ShortcutItem>[
          ShortcutItem(id: "1", title: "Test", icon: "icon.png"),
          ShortcutItem(id: "2", title: "Another", icon: "icon2.png"),
        ];
        await ApzAppShortcuts().setShortcutItems(items);
        expect(log, isNotEmpty);
        expect(log.first.method, "setShortcutItems");
        expect(log.first.arguments, <Map<String, String>>[
          <String, String>{"id": "1", "title": "Test", "icon": "icon.png"},
          <String, String>{"id": "2", "title": "Another", "icon": "icon2.png"},
        ]);
      },
    );

    test("clearShortcutItems invokes method channel", () async {
      await ApzAppShortcuts().clearShortcutItems();
      expect(log, isNotEmpty);
      expect(log.first.method, "clearShortcutItems");
    });

    test(
      "registerShortcutCallback sets callback and handles shortcut tap",
      () async {
        String? tappedId;
        ApzAppShortcuts().registerShortcutCallback((final String id) {
          tappedId = id;
        });
        // Simulate method call from platform by directly calling the handler
        await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .handlePlatformMessage(
              channel.name,
              const StandardMethodCodec().encodeMethodCall(
                const MethodCall("onShortcutItemTapped", "shortcut_123"),
              ),
              (final ByteData? data) {},
            );
        expect(tappedId, "shortcut_123");
      },
    );
  });
}
