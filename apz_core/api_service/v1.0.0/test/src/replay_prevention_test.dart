import "dart:convert";
import "dart:typed_data";

import "package:apz_api_service/src/replay_prevention.dart";
import "package:apz_crypto/apz_crypto.dart" as crypto;
import "package:dio/dio.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";

class MockApzCrypto extends Mock implements crypto.ApzCrypto {}

void main() {
  late MockApzCrypto mockApzCrypto;
  late ReplayPrevention replayPrevention;

  setUpAll(() {
    registerFallbackValue(crypto.HashType.values.first);
    registerFallbackValue(Uint8List(0));
    registerFallbackValue(RequestOptions(path: "/test"));
  });

  setUp(() {
    mockApzCrypto = MockApzCrypto();
    replayPrevention = ReplayPrevention(apzCrypto: mockApzCrypto);

    when(
      () => mockApzCrypto.generateRandomAlphanumeric(
        length: any(named: "length"),
      ),
    ).thenReturn("IDEMPOTENT123");

    when(
      () => mockApzCrypto.generateHashDigestWithSalt(
        textToHash: any(named: "textToHash"),
        salt: any(named: "salt"),
        type: any(named: "type"),
        iterationCount: any(named: "iterationCount"),
        outputKeyLength: any(named: "outputKeyLength"),
      ),
    ).thenAnswer((final Invocation i) {
      final String text = i.namedArguments[#textToHash] as String;
      final String salt = i.namedArguments[#salt] as String;
      return base64Encode(utf8.encode("$text|$salt"));
    });
  });

  test("addQOP injects headers and returns same RequestOptions", () {
    final RequestOptions options = RequestOptions(
      path: "/test",
      data: <String, int>{"a": 1},
    );
    final RequestOptions out = replayPrevention.addQOP(options);
    expect(out.headers.containsKey("N-Timestamp"), isTrue);
    expect(out.headers["N-IDEMPOTENTKEY"], equals("IDEMPOTENT123"));
    expect(out.headers.containsKey("N-QOP"), isTrue);
    // Ensure N-QOP value is present and non-empty
    final String qop = out.headers["N-QOP"] as String;
    expect(qop, isNotEmpty);
  });

  test("verifyQOP throws when headers missing", () {
    final Response<dynamic> response = Response<dynamic>(
      requestOptions: RequestOptions(path: "/test"),
      data: <String, int>{"a": 1},
    );
    expect(
      () => replayPrevention.verifyQOP(response),
      throwsA(isA<DioException>()),
    );
  });

  test("verifyQOP succeeds when hashes match", () {
    // Prepare options and compute expected qop using same stub behavior
    final RequestOptions req = RequestOptions(
      path: "/test",
      data: <String, int>{"a": 1},
    );
    final RequestOptions withHeaders = replayPrevention.addQOP(req);

    final Response<dynamic> response = Response<dynamic>(
      requestOptions: RequestOptions(path: "/test"),
      data: <String, int>{"a": 1},
      headers: Headers.fromMap(<String, List<String>>{
        "N-Timestamp": <String>[withHeaders.headers["N-Timestamp"] as String],
        "N-IDEMPOTENTKEY": <String>[
          withHeaders.headers["N-IDEMPOTENTKEY"] as String,
        ],
        "N-QOP": <String>[withHeaders.headers["N-QOP"] as String],
      }),
    );

    // Should not throw
    expect(() => replayPrevention.verifyQOP(response), returnsNormally);
  });

  test("verifyQOP throws when qop mismatch", () {
    final Response<dynamic> response = Response<dynamic>(
      requestOptions: RequestOptions(path: "/test"),
      data: <String, int>{"a": 1},
      headers: Headers.fromMap(<String, List<String>>{
        "N-Timestamp": <String>["ts"],
        "N-IDEMPOTENTKEY": <String>["id"],
        "N-QOP": <String>["wrong"],
      }),
    );

    // Stub hashing to return a different value than 'wrong'
    when(
      () => mockApzCrypto.generateHashDigestWithSalt(
        textToHash: any(named: "textToHash"),
        salt: any(named: "salt"),
        type: any(named: "type"),
        iterationCount: any(named: "iterationCount"),
        outputKeyLength: any(named: "outputKeyLength"),
      ),
    ).thenReturn("mismatch");

    expect(
      () => replayPrevention.verifyQOP(response),
      throwsA(isA<DioException>()),
    );
  });
}
