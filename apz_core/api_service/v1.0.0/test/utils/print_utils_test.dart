import "package:apz_api_service/utils/print_utils.dart";
import "package:flutter/foundation.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  test(
    "printCompleteStringUsingDebugPrint does nothing when debug disabled",
    () {
      // Capture debugPrint calls by overriding it
      final List<String> printed = <String>[];
      final DebugPrintCallback original = debugPrint;
      debugPrint = (final String? message, {final int? wrapWidth}) {
        printed.add(message ?? "");
      };

      final PrintUtils _ = PrintUtils(isDebugModeEnabled: false)
        ..printCompleteStringUsingDebugPrint("some message");

      // restore
      debugPrint = original;

      expect(printed.length, equals(1));
      // When disabled the implementation
      // prints an empty line via debugPrint("")
      expect(printed.first, equals(""));
    },
  );

  test("printCompleteStringUsingDebugPrint prints chunks when enabled", () {
    final List<String> printed = <String>[];
    final DebugPrintCallback original = debugPrint;
    debugPrint = (final String? message, {final int? wrapWidth}) {
      printed.add(message ?? "");
    };

    final PrintUtils utils = PrintUtils(isDebugModeEnabled: true);
    // create a long message > chunk size (800)
    final String longMessage = "A" * 1800;
    utils.printCompleteStringUsingDebugPrint(longMessage);

    // restore
    debugPrint = original;

    expect(printed.length, greaterThan(1));
    // All printed chunks concatenated should equal original
    expect(printed.join(), equals(longMessage));
  });
}
