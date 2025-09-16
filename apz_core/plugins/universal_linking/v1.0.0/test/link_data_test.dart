import "package:apz_universal_linking/link_data.dart";
import "package:flutter_test/flutter_test.dart"; // or import "package:test/test.dart"; if not Flutter

void main() {
  group("LinkData", () {
    // Test case 1: Basic constructor functionality
    test("should create a LinkData instance with given values", () {
      final link = LinkData(
        host: "example.com",
        path: "/some/path",
        scheme: "https",
        fullUrl: "https://example.com/some/path",
        queryParams: {"foo": "bar", "baz": "qux"},
      );

      expect(link.host, "example.com");
      expect(link.path, "/some/path");
      expect(link.scheme, "https");
      expect(link.fullUrl, "https://example.com/some/path");
      expect(link.queryParams, {"foo": "bar", "baz": "qux"});
    });

    // Test case 2: fromMap constructor with all valid data
    test("fromMap should correctly parse a map with all valid data", () {
      final map = {
        "host": "test.com",
        "path": "/api/v1/resource",
        "scheme": "http",
        "fullUrl": "http://test.com/api/v1/resource",
      };
      final link = LinkData.fromMap(map);

      expect(link.host, "test.com");
      expect(link.path, "/api/v1/resource");
      expect(link.scheme, "http");
      expect(link.fullUrl, "http://test.com/api/v1/resource");
    });

    // Test case 3: fromMap constructor with missing keys
    test("fromMap should use empty strings for missing keys", () {
      final map = {
        "host": "another.org",
        "fullUrl": "https://another.org/item",
      };
      final link = LinkData.fromMap(map);

      expect(link.host, "another.org");
      expect(link.path, ""); // Should be empty
      expect(link.scheme, ""); // Should be empty
      expect(link.fullUrl, "https://another.org/item");
    });

    // Test case 4: fromMap constructor with null values
    test("fromMap should use empty strings for null values", () {
      final map = {
        "host": null,
        "path": "/null/path",
        "scheme": "https",
        "fullUrl": null,
      };
      final link = LinkData.fromMap(map);

      expect(link.host, ""); // Should be empty
      expect(link.path, "/null/path");
      expect(link.scheme, "https");
      expect(link.fullUrl, ""); // Should be empty
    });

    // Test case 5: fromMap constructor with an empty map
    test(
      "fromMap should return an instance with all empty strings for an empty map",
      () {
        final map = <dynamic, dynamic>{};
        final link = LinkData.fromMap(map);

        expect(link.host, "");
        expect(link.path, "");
        expect(link.scheme, "");
        expect(link.fullUrl, "");
      },
    );

    // Test case 6: fromMap constructor with non-string values (edge case, though Dart"s dynamic handles this)
    test(
      "fromMap should handle non-string values gracefully (defaulting to empty string)",
      () {
        final map = {
          "host": "i-exceed.com", // Non-string
          "path": "product", // Non-string
          "scheme": "https", // Non-string
          "fullUrl": "https://i-exceed.com/product/45.67", // Non-string
        };
        final link = LinkData.fromMap(map);
        expect(link.host, "i-exceed.com");
        expect(link.path, "product");
        expect(link.scheme, "https");
        expect(link.fullUrl, "https://i-exceed.com/product/45.67");
      },
    );
  });
}
