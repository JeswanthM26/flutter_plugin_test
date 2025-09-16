import "package:apz_webview/models/error_data.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("ErrorData", () {
    test("should create with correct values", () {
      final ErrorData error = ErrorData(
        description: "Network error",
        code: "404",
        type: "network",
      );
      expect(error.description, "Network error");
      expect(error.code, "404");
      expect(error.type, "network");
    });

    test("should support value equality", () {
      final ErrorData error1 = ErrorData(
        description: "desc",
        code: "c",
        type: "t",
      );
      final ErrorData error2 = ErrorData(
        description: "desc",
        code: "c",
        type: "t",
      );
      expect(
        error1 == error2,
        isFalse,
      ); // Not equal by default (no == override)
    });

    test("should allow different values", () {
      final ErrorData error = ErrorData(description: "A", code: "B", type: "C");
      expect(error.description, isNot("X"));
      expect(error.code, isNot("Y"));
      expect(error.type, isNot("Z"));
    });
  });
}
