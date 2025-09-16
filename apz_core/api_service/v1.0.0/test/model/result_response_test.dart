import "package:apz_api_service/model/api_provider_exception.dart";
import "package:apz_api_service/model/result_response.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("Result", () {
    test("Result.success returns Success with correct value", () {
      final Result<int> result = Result<int>.success(42);
      expect(result, isA<Success<int>>());
      expect((result as Success<int>).value, 42);
    });

    test("Result.error returns Error with correct error", () {
      final ApiProviderException error = ApiProviderException(
        statusCode: -1,
        message: "Test error",
      );
      final Result<int> result = Result<int>.error(error);
      expect(result, isA<Error<int>>());
      expect((result as Error<int>).errorValue, error);
    });

    test("Success holds the correct value", () {
      const Success<String> success = Success<String>("ok");
      expect(success.value, "ok");
    });

    test("Error holds the correct error", () {
      final ApiProviderException error = ApiProviderException(
        statusCode: -1,
        message: "Another error",
      );
      final Error<String> errorResult = Error<String>(error);
      expect(errorResult.errorValue, error);
    });

    test("Result is generic and type safe", () {
      final Result<int> intResult = Result<int>.success(123);
      final Result<String> stringResult = Result<String>.success("abc");
      expect(intResult, isA<Success<int>>());
      expect(stringResult, isA<Success<String>>());
    });
  });
}
