import "package:apz_observability/apz_observability.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("BreadcrumbCategory", () {
    test("should contain all expected enum values", () {
      expect(BreadcrumbCategory.values.length, 8);
      expect(
        BreadcrumbCategory.navigation.toString(),
        "BreadcrumbCategory.navigation",
      );
      expect(
        BreadcrumbCategory.request.toString(),
        "BreadcrumbCategory.request",
      );
      expect(
        BreadcrumbCategory.process.toString(),
        "BreadcrumbCategory.process",
      );
      expect(BreadcrumbCategory.log.toString(), "BreadcrumbCategory.log");
      expect(BreadcrumbCategory.user.toString(), "BreadcrumbCategory.user");
      expect(BreadcrumbCategory.state.toString(), "BreadcrumbCategory.state");
      expect(BreadcrumbCategory.error.toString(), "BreadcrumbCategory.error");
      expect(BreadcrumbCategory.manual.toString(), "BreadcrumbCategory.manual");
    });

    test("should have correct index for each value", () {
      expect(BreadcrumbCategory.navigation.index, 0);
      expect(BreadcrumbCategory.request.index, 1);
      expect(BreadcrumbCategory.process.index, 2);
      expect(BreadcrumbCategory.log.index, 3);
      expect(BreadcrumbCategory.user.index, 4);
      expect(BreadcrumbCategory.state.index, 5);
      expect(BreadcrumbCategory.error.index, 6);
      expect(BreadcrumbCategory.manual.index, 7);
    });
  });
}
