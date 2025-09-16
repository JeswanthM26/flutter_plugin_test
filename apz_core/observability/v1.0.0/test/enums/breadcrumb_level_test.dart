import "package:apz_observability/apz_observability.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("BreadcrumbLevel", () {
    test("should contain all expected enum values", () {
      expect(BreadcrumbLevel.values.length, 5);
      expect(BreadcrumbLevel.fatal.toString(), "BreadcrumbLevel.fatal");
      expect(BreadcrumbLevel.error.toString(), "BreadcrumbLevel.error");
      expect(BreadcrumbLevel.warning.toString(), "BreadcrumbLevel.warning");
      expect(BreadcrumbLevel.info.toString(), "BreadcrumbLevel.info");
      expect(BreadcrumbLevel.debug.toString(), "BreadcrumbLevel.debug");
    });

    test("should have correct index for each value", () {
      expect(BreadcrumbLevel.fatal.index, 0);
      expect(BreadcrumbLevel.error.index, 1);
      expect(BreadcrumbLevel.warning.index, 2);
      expect(BreadcrumbLevel.info.index, 3);
      expect(BreadcrumbLevel.debug.index, 4);
    });
  });
}
