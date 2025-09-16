import "package:apz_observability/apz_observability.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("AppBreadcrumb", () {
    test("should create with required message only", () {
      final AppBreadcrumb breadcrumb = AppBreadcrumb(message: "Test message");
      expect(breadcrumb.message, "Test message");
      expect(breadcrumb.category, isNull);
      expect(breadcrumb.level, isNull);
      expect(breadcrumb.data, isNull);
    });

    test("should create with all fields", () {
      final AppBreadcrumb breadcrumb = AppBreadcrumb(
        message: "User clicked button",
        category: BreadcrumbCategory.user,
        level: BreadcrumbLevel.info,
        data: <String, dynamic>{"button": "login", "success": true},
      );
      expect(breadcrumb.message, "User clicked button");
      expect(breadcrumb.category, BreadcrumbCategory.user);
      expect(breadcrumb.level, BreadcrumbLevel.info);
      expect(breadcrumb.data, isA<Map<String, dynamic>>());
      expect(breadcrumb.data?["button"], "login");
      expect(breadcrumb.data?["success"], true);
    });

    test("should allow null data map", () {
      final AppBreadcrumb breadcrumb = AppBreadcrumb(
        message: "No data",
        category: BreadcrumbCategory.manual,
        level: BreadcrumbLevel.debug,
      );
      expect(breadcrumb.data, isNull);
    });
  });
}
