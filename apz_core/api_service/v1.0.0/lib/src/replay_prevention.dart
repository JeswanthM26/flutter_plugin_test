import "dart:convert";
import "package:apz_crypto/apz_crypto.dart" as crypto;
import "package:apz_crypto/utils/hash_type.dart";
import "package:dio/dio.dart";

/// A class to prevent replay attacks by generating and verifying
/// QOP (Quality of Protection) tokens.
class ReplayPrevention {
  /// Creates a [ReplayPrevention] instance.
  ReplayPrevention({required final crypto.ApzCrypto apzCrypto})
    : _apzCrypto = apzCrypto;

  final crypto.ApzCrypto _apzCrypto;

  /// Generates a QOP token based on the provided payload string.
  RequestOptions addQOP(final RequestOptions options) {
    final String timeStamp = _getCurrentTimeStamp();
    final String idempotentKey = _apzCrypto.generateRandomAlphanumeric(
      length: 32,
    );
    final String payloadStr = json.encode(options.data);
    final String base64TimeStamp = base64Encode(utf8.encode(timeStamp));

    final String hashedIdempotentKey = _apzCrypto.generateHashDigestWithSalt(
      textToHash: idempotentKey,
      salt: base64TimeStamp,
      type: HashType.sha512,
      iterationCount: 10000,
      outputKeyLength: 32,
    );
    final String hashedPayloadStr = _apzCrypto.generateHashDigestWithSalt(
      textToHash: payloadStr,
      salt: hashedIdempotentKey,
      type: HashType.sha512,
      iterationCount: 10000,
      outputKeyLength: 32,
    );

    final Map<String, dynamic> headers = options.headers;
    headers["N-Timestamp"] = timeStamp;
    headers["N-IDEMPOTENTKEY"] = idempotentKey;
    headers["N-QOP"] = hashedPayloadStr;
    options.headers = headers;

    return options;
  }

  /// Verifies the provided QOP token against the payload string.
  void verifyQOP(final Response<dynamic> response) {
    final Map<String, List<String>> headers = response.headers.map;
    final String responsePayloadStr = json.encode(response.data);
    final String timeStamp = headers["N-Timestamp"]?.first ?? "";
    final String idempotentKey = headers["N-IDEMPOTENTKEY"]?.first ?? "";
    final String qopStr = headers["N-QOP"]?.first ?? "";

    if (timeStamp.isEmpty || idempotentKey.isEmpty || qopStr.isEmpty) {
      final DioException dioException = DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: "QOP data is not proper",
      );
      throw dioException;
    }

    final String base64TimeStamp = base64Encode(utf8.encode(timeStamp));

    final String hashedIdempotentKey = _apzCrypto.generateHashDigestWithSalt(
      textToHash: idempotentKey,
      salt: base64TimeStamp,
      type: HashType.sha512,
      iterationCount: 10000,
      outputKeyLength: 32,
    );
    final String hashedPayloadStr = _apzCrypto.generateHashDigestWithSalt(
      textToHash: responsePayloadStr,
      salt: hashedIdempotentKey,
      type: HashType.sha512,
      iterationCount: 10000,
      outputKeyLength: 32,
    );

    if (qopStr != hashedPayloadStr) {
      final DioException dioException = DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: "QOP didn't matched",
      );
      throw dioException;
    }
  }

  String _getCurrentTimeStamp() {
    final DateTime now = DateTime.now();
    final DateTime nowUtc = now.toUtc();
    final String timestamp = nowUtc.toIso8601String();
    return timestamp;
  }
}
