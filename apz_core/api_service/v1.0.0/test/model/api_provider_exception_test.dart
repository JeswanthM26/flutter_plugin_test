import "package:apz_api_service/model/api_provider_exception.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("ApiProviderException", () {
    test("should create instance with all fields", () {
      final ApiProviderException exception = ApiProviderException(
        statusCode: 404,
        message: "Not Found",
        errorType: "ClientError",
        response: "Response",
      );

      expect(exception.statusCode, 404);
      expect(exception.message, "Not Found");
      expect(exception.errorType, "ClientError");
      expect(
        exception.toString(),
        """{"statusCode":404,"message":"Not Found","errorType":"ClientError","response":"Response","type":null,"title":null,"detail":null,"instance":null,"status":null,"timetamp":null}""",
      );
    });

    test("should create instance with nullable errorType", () {
      final ApiProviderException exception = ApiProviderException(
        statusCode: 500,
        message: "Internal Server Error",
      );

      expect(exception.statusCode, 500);
      expect(exception.message, "Internal Server Error");
      expect(exception.errorType, isNull);
      expect(
        exception.toString(),
        """{"statusCode":500,"message":"Internal Server Error","errorType":null,"response":null,"type":null,"title":null,"detail":null,"instance":null,"status":null,"timetamp":null}""",
      );
    });
  });
}
