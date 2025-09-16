import "package:apz_utils/src/exception/permission_exception.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("PermissionException", () {
    test("should create instance with correct properties", () {
      final PermissionException exception = PermissionException(
        PermissionsExceptionStatus.denied,
        "Permission denied",
      );

      expect(exception.status, equals(PermissionsExceptionStatus.denied));
      expect(exception.message, equals("Permission denied"));
    });

    test("toString should return formatted message", () {
      final PermissionException exception = PermissionException(
        PermissionsExceptionStatus.denied,
        "Permission denied",
      );

      expect(
        exception.toString(),
        equals(
          """PermissionException: Permission denied (PermissionsExceptionStatus.denied)""",
        ),
      );
    });

    test("should handle all enum values", () {
      final Map<PermissionsExceptionStatus, String> testCases =
          <PermissionsExceptionStatus, String>{
            PermissionsExceptionStatus.denied: "Access denied",
            PermissionsExceptionStatus.permanentlyDenied: "Permanently denied",
            PermissionsExceptionStatus.restricted: "Access restricted",
            PermissionsExceptionStatus.limited: "Limited access",
            PermissionsExceptionStatus.provisional: "Provisional access",
          };

      for (final MapEntry<PermissionsExceptionStatus, String> entry
          in testCases.entries) {
        final PermissionException exception = PermissionException(
          entry.key,
          entry.value,
        );
        expect(exception.status, equals(entry.key));
        expect(exception.message, equals(entry.value));
        expect(
          exception.toString(),
          equals(
            """PermissionException: ${entry.value} (PermissionsExceptionStatus.${entry.key.name})""",
          ),
        );
      }
    });

    test("implements Exception interface", () {
      final PermissionException exception = PermissionException(
        PermissionsExceptionStatus.denied,
        "Permission denied",
      );

      expect(exception, isA<Exception>());
    });
  });
}
