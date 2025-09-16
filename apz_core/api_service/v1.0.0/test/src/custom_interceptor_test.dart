import "dart:convert";
import "dart:typed_data";

import "package:apz_api_service/src/custom_interceptor.dart";
import "package:apz_api_service/src/dio_client.dart";
import "package:apz_api_service/src/encryption_decryption.dart";
import "package:apz_api_service/src/replay_prevention.dart";
import "package:apz_api_service/utils/constants.dart" as api_service_constants;
import "package:apz_api_service/utils/print_utils.dart";
import "package:apz_crypto/apz_crypto.dart" as crypto;
import "package:dio/dio.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";

class FakeRequestInterceptorHandler extends Fake
    implements RequestInterceptorHandler {
  bool calledNext = false;
  bool calledReject = false;
  RequestOptions? passedOptions;
  DioException? passedException;

  @override
  void next(final RequestOptions options) {
    calledNext = true;
    passedOptions = options;
  }

  @override
  void reject(
    final DioException err, [
    final bool callFollowingErrorInterceptor = false,
  ]) {
    calledReject = true;
    passedException = err;
  }
}

class FakeResponseInterceptorHandler extends Fake
    implements ResponseInterceptorHandler {
  bool calledNext = false;
  bool calledReject = false;
  Response<dynamic>? passedResponse;
  DioException? passedException;

  @override
  void next(final Response<dynamic> response) {
    calledNext = true;
    passedResponse = response;
  }

  @override
  void reject(
    final DioException err, [
    final bool callFollowingErrorInterceptor = false,
  ]) {
    calledReject = true;
    passedException = err;
  }
}

class MockApzCrypto extends Mock implements crypto.ApzCrypto {}

class MockReplayPrevention extends Mock implements ReplayPrevention {}

void main() {
  late MockApzCrypto mockApzCrypto;
  late CustomInterceptor interceptor;
  const String publicKeyPath = "public.pem";
  const String privateKeyPath = "private.pem";

  setUpAll(() {
    registerFallbackValue(crypto.HashType.values.first);
    registerFallbackValue(Uint8List(0));
    registerFallbackValue(RequestOptions(path: "/test"));
    // Fallback for Response used when mocking verifyQOP(Response)
    registerFallbackValue(
      Response<dynamic>(requestOptions: RequestOptions(path: "/test")),
    );
    // No QOPModel type is defined here; tests mock addQOP/verifyQOP directly.
  });

  setUp(() {
    mockApzCrypto = MockApzCrypto();
    // Provide defaults so ReplayPrevention and other code using apzCrypto
    // don't receive null from unstubbed mocked methods.
    when(
      () => mockApzCrypto.generateRandomAlphanumeric(
        length: any(named: "length"),
      ),
    ).thenReturn("fixed-idempotent-key-0123456789abcdef");

    when(
      () => mockApzCrypto.generateHashDigestWithSalt(
        textToHash: any(named: "textToHash"),
        salt: any(named: "salt"),
        type: any(named: "type"),
        iterationCount: any(named: "iterationCount"),
        outputKeyLength: any(named: "outputKeyLength"),
      ),
    ).thenAnswer((final Invocation i) {
      final String textToHash = i.namedArguments[#textToHash] as String;
      final String salt = i.namedArguments[#salt] as String;
      return base64Encode(utf8.encode("$textToHash|$salt"));
    });
    final DioClient dioClient = DioClient(
      baseUrl: "https://example.com",
      timeoutDuration: 5,
      isDebugModeEnabled: false,
      dataIntegrityEnabled: false,
      sslPinningEnabled: false,
      certificatePinningModel: null,
      payloadEncryption: false,
      publicKeyPath: "",
      privateKeyPath: "",
    );
    final PrintUtils printUtils = PrintUtils(isDebugModeEnabled: false);
    final EncryptionDecryption encryptionDecryption = EncryptionDecryption(
      printUtils: printUtils,
      dioClient: dioClient,
      apzCrypto: mockApzCrypto,
      publicKeyPath: publicKeyPath,
      privateKeyPath: privateKeyPath,
    );
    final ReplayPrevention replayPrevention = ReplayPrevention(
      apzCrypto: mockApzCrypto,
    );

    interceptor = CustomInterceptor(
      printUtils: printUtils,
      dataIntegrityEnabled: false,
      payloadEncEnabled: true,
      encryptionDecryption: encryptionDecryption,
      replayPrevention: replayPrevention,
    );
  });

  group("EncryptionInterceptor.onRequest", () {
    test("adds QOP headers when dataIntegrityEnabled is true", () async {
      final MockReplayPrevention mockRp = MockReplayPrevention();
      // Stub addQOP to inject headers into the RequestOptions and return it
      when(() => mockRp.addQOP(any())).thenAnswer((final Invocation inv) {
        final RequestOptions req = inv.positionalArguments[0] as RequestOptions;
        final Map<String, dynamic> headers = Map<String, dynamic>.from(
          req.headers,
        );
        headers["N-Timestamp"] = "TSTAMP";
        headers["N-IDEMPOTENTKEY"] = "IDEMP";
        headers["N-QOP"] = "QOPVAL";
        req.headers = headers;
        return req;
      });

      final DioClient dioClientLocal = DioClient(
        baseUrl: "https://example.com",
        timeoutDuration: 5,
        isDebugModeEnabled: false,
        dataIntegrityEnabled: true, // Changed to true to match the test case
        sslPinningEnabled: false,
        certificatePinningModel: null,
        payloadEncryption: false,
        publicKeyPath: "",
        privateKeyPath: "",
      );
      final PrintUtils printUtilsLocal = PrintUtils(isDebugModeEnabled: false);
      final EncryptionDecryption encryptionDecryptionLocal =
          EncryptionDecryption(
            printUtils: printUtilsLocal,
            dioClient: dioClientLocal,
            apzCrypto: mockApzCrypto,
            publicKeyPath: publicKeyPath,
            privateKeyPath: privateKeyPath,
          );

      final CustomInterceptor interceptorWithQOP = CustomInterceptor(
        printUtils: printUtilsLocal,
        dataIntegrityEnabled: true,
        payloadEncEnabled: false,
        encryptionDecryption: encryptionDecryptionLocal,
        replayPrevention: mockRp,
      );

      final RequestOptions options = RequestOptions(
        path: "/test",
        method: "POST",
        data: <String, String>{"foo": "bar"},
        extra: <String, dynamic>{},
      );
      final FakeRequestInterceptorHandler handler =
          FakeRequestInterceptorHandler();
      await interceptorWithQOP.onRequest(options, handler);
      expect(options.headers["N-Timestamp"], equals("TSTAMP"));
      expect(options.headers["N-IDEMPOTENTKEY"], equals("IDEMP"));
      expect(options.headers["N-QOP"], equals("QOPVAL"));
    });
    test("should call super.onRequest if data is null", () async {
      final RequestOptions options = RequestOptions(
        path: "/test",
        method: "POST",
        extra: <String, dynamic>{},
      );
      final FakeRequestInterceptorHandler handler =
          FakeRequestInterceptorHandler();
      await interceptor.onRequest(options, handler);
      expect(handler.calledReject, isFalse);
      expect(options.data, isNull);
    });

    test("should reject if encryption throws", () async {
      final RequestOptions options = RequestOptions(
        path: "/test",
        method: "POST",
        data: <String, String>{"foo": "bar"},
        extra: <String, dynamic>{},
      );
      final FakeRequestInterceptorHandler handler =
          FakeRequestInterceptorHandler();
      when(
        () => mockApzCrypto.generateRandomBytes(length: any(named: "length")),
      ).thenThrow(Exception("fail"));
      await interceptor.onRequest(options, handler);
      expect(handler.calledReject, isTrue);
      expect(
        handler.passedException?.error,
        contains("Failed to encrypt request data"),
      );
    });

    test("should reject if asymmetricEncrypt throws", () async {
      final RequestOptions options = RequestOptions(
        path: "/test",
        method: "POST",
        data: <String, String>{"foo": "bar"},
        extra: <String, dynamic>{},
      );
      final FakeRequestInterceptorHandler handler =
          FakeRequestInterceptorHandler();
      final Uint8List salt = Uint8List(16);
      final String hashedKey = base64Encode(Uint8List(32));
      final String cipherText = base64Encode(Uint8List(10));
      when(
        () => mockApzCrypto.generateRandomBytes(length: any(named: "length")),
      ).thenReturn(salt);
      when(
        () => mockApzCrypto.generateHashDigestWithSalt(
          textToHash: any(named: "textToHash"),
          salt: any(named: "salt"),
          type: any(named: "type"),
          iterationCount: any(named: "iterationCount"),
          outputKeyLength: any(named: "outputKeyLength"),
        ),
      ).thenReturn(hashedKey);
      when(
        () => mockApzCrypto.symmetricEncrypt(
          textToEncrypt: any(named: "textToEncrypt"),
          key: any(named: "key"),
          iv: any(named: "iv"),
        ),
      ).thenReturn(cipherText);
      when(
        () => mockApzCrypto.asymmetricEncrypt(
          publicKeyPath: any(named: "publicKeyPath"),
          textToEncrypt: any(named: "textToEncrypt"),
        ),
      ).thenThrow(Exception("asym fail"));

      await interceptor.onRequest(options, handler);
      expect(handler.calledReject, isTrue);
      expect(
        handler.passedException?.error,
        contains("Failed to encrypt request data"),
      );
    });

    test("should set encrypted payload and safeToken", () async {
      final RequestOptions options = RequestOptions(
        path: "/test",
        method: "POST",
        data: <String, String>{"foo": "bar"},
        extra: <String, dynamic>{},
      );
      final FakeRequestInterceptorHandler handler =
          FakeRequestInterceptorHandler();
      final Uint8List salt = Uint8List(16);
      final String hashedKey = base64Encode(Uint8List(32));
      final String cipherText = base64Encode(Uint8List(10));
      const String encryptedKey = "encryptedKeyString";
      when(
        () => mockApzCrypto.generateRandomBytes(length: any(named: "length")),
      ).thenReturn(salt);
      when(
        () => mockApzCrypto.generateHashDigestWithSalt(
          textToHash: any(named: "textToHash"),
          salt: any(named: "salt"),
          type: any(named: "type"),
          iterationCount: any(named: "iterationCount"),
          outputKeyLength: any(named: "outputKeyLength"),
        ),
      ).thenReturn(hashedKey);
      when(
        () => mockApzCrypto.symmetricEncrypt(
          textToEncrypt: any(named: "textToEncrypt"),
          key: any(named: "key"),
          iv: any(named: "iv"),
        ),
      ).thenReturn(cipherText);
      when(
        () => mockApzCrypto.asymmetricEncrypt(
          publicKeyPath: any(named: "publicKeyPath"),
          textToEncrypt: any(named: "textToEncrypt"),
        ),
      ).thenAnswer((_) async => encryptedKey);
      await interceptor.onRequest(options, handler);
      expect(options.data, isA<Map<String, String>>());
      final Map<String, String> data = options.data as Map<String, String>;
      expect(data["body"], isNotEmpty);
      expect(data["algo"], isNotEmpty);
      expect(data["safeToken"], encryptedKey);
      expect(handler.calledReject, isFalse);
    });
  });

  group("EncryptionInterceptor.onResponse", () {
    test(
      "rejects when QOP headers are missing and dataIntegrityEnabled is true",
      () async {
        final MockReplayPrevention mockRp = MockReplayPrevention();
        // Make verifyQOP throw the same DioException that production code
        // would throw when headers are missing.
        when(() => mockRp.verifyQOP(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: "/test"),
            response: Response<dynamic>(
              requestOptions: RequestOptions(path: "/test"),
            ),
            error: "QOP data is not proper",
          ),
        );
        final DioClient dioClientLocal = DioClient(
          baseUrl: "https://example.com",
          timeoutDuration: 5,
          isDebugModeEnabled: false,
          dataIntegrityEnabled: true,
          sslPinningEnabled: false,
          certificatePinningModel: null,
          payloadEncryption: false,
          publicKeyPath: "",
          privateKeyPath: "",
        );
        final PrintUtils printUtilsLocal = PrintUtils(
          isDebugModeEnabled: false,
        );
        final EncryptionDecryption encryptionDecryptionLocal =
            EncryptionDecryption(
              printUtils: printUtilsLocal,
              dioClient: dioClientLocal,
              apzCrypto: mockApzCrypto,
              publicKeyPath: publicKeyPath,
              privateKeyPath: privateKeyPath,
            );

        final CustomInterceptor interceptorWithQOP = CustomInterceptor(
          printUtils: printUtilsLocal,
          dataIntegrityEnabled: true,
          payloadEncEnabled: false,
          encryptionDecryption: encryptionDecryptionLocal,
          replayPrevention: mockRp,
        );

        final RequestOptions options = RequestOptions(path: "/test");
        final Response<dynamic> response = Response<dynamic>(
          requestOptions: options,
          data: <String, dynamic>{"hello": "world"},
        );
        final FakeResponseInterceptorHandler handler =
            FakeResponseInterceptorHandler();
        await interceptorWithQOP.onResponse(response, handler);
        expect(handler.calledReject, isTrue);
        expect(
          handler.passedException?.error,
          contains("QOP data is not proper"),
        );
      },
    );

    test(
      "accepts response when QOP headers present and verifyQOP returns true",
      () async {
        final MockReplayPrevention mockRp = MockReplayPrevention();
        // For success, verifyQOP should not throw. Stub to do nothing.
        when(() => mockRp.verifyQOP(any())).thenAnswer((_) {});

        final RequestOptions options = RequestOptions(path: "/test");
        final Response<dynamic> response = Response<dynamic>(
          requestOptions: options,
          data: <String, dynamic>{"a": 1},
          headers: Headers.fromMap(<String, List<String>>{
            "N-Timestamp": <String>["ts"],
            "N-IDEMPOTENTKEY": <String>["idemp"],
            "N-QOP": <String>["qopval"],
          }),
        );

        final DioClient dioClientLocal = DioClient(
          baseUrl: "https://example.com",
          timeoutDuration: 5,
          isDebugModeEnabled: false,
          dataIntegrityEnabled: true,
          sslPinningEnabled: false,
          certificatePinningModel: null,
          payloadEncryption: false,
          publicKeyPath: "",
          privateKeyPath: "",
        );
        final PrintUtils printUtilsLocal = PrintUtils(
          isDebugModeEnabled: false,
        );
        final EncryptionDecryption encryptionDecryptionLocal =
            EncryptionDecryption(
              printUtils: printUtilsLocal,
              dioClient: dioClientLocal,
              apzCrypto: mockApzCrypto,
              publicKeyPath: publicKeyPath,
              privateKeyPath: privateKeyPath,
            );

        final CustomInterceptor interceptorWithQOP = CustomInterceptor(
          printUtils: printUtilsLocal,
          dataIntegrityEnabled: true,
          payloadEncEnabled: false,
          encryptionDecryption: encryptionDecryptionLocal,
          replayPrevention: mockRp,
        );

        final FakeResponseInterceptorHandler handler =
            FakeResponseInterceptorHandler();
        await interceptorWithQOP.onResponse(response, handler);
        expect(handler.calledReject, isFalse);
        expect(handler.calledNext, isTrue);
      },
    );

    test("rejects when QOP verify fails", () async {
      final MockReplayPrevention mockRp = MockReplayPrevention();
      // Simulate verification failure by throwing the same DioException
      when(() => mockRp.verifyQOP(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: "/test"),
          response: Response<dynamic>(
            requestOptions: RequestOptions(path: "/test"),
          ),
          error: "QOP didn't matched",
        ),
      );

      final RequestOptions options = RequestOptions(path: "/test");
      final Response<dynamic> response = Response<dynamic>(
        requestOptions: options,
        data: <String, dynamic>{"a": 1},
        headers: Headers.fromMap(<String, List<String>>{
          "N-Timestamp": <String>["ts"],
          "N-IDEMPOTENTKEY": <String>["idemp"],
          "N-QOP": <String>["qopval"],
        }),
      );

      final DioClient dioClientLocal = DioClient(
        baseUrl: "https://example.com",
        timeoutDuration: 5,
        isDebugModeEnabled: false,
        dataIntegrityEnabled: true,
        sslPinningEnabled: false,
        certificatePinningModel: null,
        payloadEncryption: false,
        publicKeyPath: "",
        privateKeyPath: "",
      );
      final PrintUtils printUtilsLocal = PrintUtils(isDebugModeEnabled: false);
      final EncryptionDecryption encryptionDecryptionLocal =
          EncryptionDecryption(
            printUtils: printUtilsLocal,
            dioClient: dioClientLocal,
            apzCrypto: mockApzCrypto,
            publicKeyPath: publicKeyPath,
            privateKeyPath: privateKeyPath,
          );

      final CustomInterceptor interceptorWithQOP = CustomInterceptor(
        printUtils: printUtilsLocal,
        dataIntegrityEnabled: true,
        payloadEncEnabled: false,
        encryptionDecryption: encryptionDecryptionLocal,
        replayPrevention: mockRp,
      );

      final FakeResponseInterceptorHandler handler =
          FakeResponseInterceptorHandler();
      await interceptorWithQOP.onResponse(response, handler);
      expect(handler.calledReject, isTrue);
      expect(handler.passedException?.error, contains("QOP didn't matched"));
    });
    test("should reject if safeToken missing", () async {
      final RequestOptions options = RequestOptions(
        path: "/test",
        method: "POST",
        extra: <String, dynamic>{},
      );
      final Response<Map<String, String>> response =
          Response<Map<String, String>>(
            requestOptions: options,
            data: <String, String>{"body": "abc", "algo": "AES"},
          );
      final FakeResponseInterceptorHandler handler =
          FakeResponseInterceptorHandler();
      await interceptor.onResponse(response, handler);
      expect(handler.calledReject, isTrue);
      expect(handler.passedException, isA<DioException>());
      expect((handler.passedException!).error, contains("safeToken missing"));
    });

    test("should set decrypted data on success", () async {
      final RequestOptions options = RequestOptions(
        path: "/test",
        method: "POST",
        extra: <String, dynamic>{},
      );
      final Uint8List salt = Uint8List(16);
      final Uint8List iv = Uint8List(12);
      final Uint8List cipherBytes = Uint8List(10);
      final Uint8List bodyBytes = Uint8List.fromList(<int>[
        ...salt,
        ...iv,
        ...cipherBytes,
      ]);
      final Response<dynamic> response = Response<dynamic>(
        requestOptions: options,
        data: <String, dynamic>{
          "body": base64Encode(bodyBytes),
          "algo": api_service_constants.Constants.algo,
          "safeToken": "token",
        },
      );
      final FakeResponseInterceptorHandler handler =
          FakeResponseInterceptorHandler();
      when(
        () => mockApzCrypto.asymmetricDecrypt(
          privateKeyPath: any(named: "privateKeyPath"),
          encryptedData: any(named: "encryptedData"),
        ),
      ).thenAnswer((_) async => base64Encode(Uint8List(32)));
      when(
        () => mockApzCrypto.generateHashDigestWithSalt(
          textToHash: any(named: "textToHash"),
          salt: any(named: "salt"),
          type: any(named: "type"),
          iterationCount: any(named: "iterationCount"),
          outputKeyLength: any(named: "outputKeyLength"),
        ),
      ).thenReturn(base64Encode(Uint8List(32)));
      when(
        () => mockApzCrypto.symmetricDecrypt(
          cipherText: any(named: "cipherText"),
          key: any(named: "key"),
          iv: any(named: "iv"),
        ),
      ).thenReturn('{"foo":"bar"}');
      await interceptor.onResponse(response, handler);
      debugPrint("Decrypted response: ${response.data}");
      expect(response.data, equals('{"foo":"bar"}'));
      expect(handler.calledReject, isFalse);
    });

    test("should reject on algo mismatch", () async {
      final RequestOptions options = RequestOptions(
        path: "/test",
        method: "POST",
        extra: <String, dynamic>{},
      );
      final Uint8List salt = Uint8List(16);
      final Uint8List iv = Uint8List(12);
      final Uint8List cipherBytes = Uint8List(10);
      final Uint8List bodyBytes = Uint8List.fromList(<int>[
        ...salt,
        ...iv,
        ...cipherBytes,
      ]);
      final Response<dynamic> response = Response<dynamic>(
        requestOptions: options,
        data: <String, dynamic>{
          "body": base64Encode(bodyBytes),
          "algo": "WRONG",
          "safeToken": "token",
        },
      );
      final FakeResponseInterceptorHandler handler =
          FakeResponseInterceptorHandler();
      when(
        () => mockApzCrypto.asymmetricDecrypt(
          privateKeyPath: any(named: "privateKeyPath"),
          encryptedData: any(named: "encryptedData"),
        ),
      ).thenAnswer((_) async => base64Encode(Uint8List(32)));

      await interceptor.onResponse(response, handler);
      expect(handler.calledReject, isTrue);
      expect(handler.passedException?.error, contains("algo didn't matched"));
    });

    test("should reject when body missing or empty", () async {
      final RequestOptions options = RequestOptions(
        path: "/test",
        method: "POST",
        extra: <String, dynamic>{},
      );
      final Response<dynamic> response = Response<dynamic>(
        requestOptions: options,
        data: <String, dynamic>{
          "algo": api_service_constants.Constants.algo,
          "safeToken": "token",
        },
      );
      final FakeResponseInterceptorHandler handler =
          FakeResponseInterceptorHandler();
      when(
        () => mockApzCrypto.asymmetricDecrypt(
          privateKeyPath: any(named: "privateKeyPath"),
          encryptedData: any(named: "encryptedData"),
        ),
      ).thenAnswer((_) async => base64Encode(Uint8List(32)));

      await interceptor.onResponse(response, handler);
      expect(handler.calledReject, isTrue);
      expect(
        handler.passedException?.error,
        contains("body or error is empty"),
      );
    });

    test(
      "should reject when body field is not proper (missing cipher)",
      () async {
        final RequestOptions options = RequestOptions(
          path: "/test",
          method: "POST",
          extra: <String, dynamic>{},
        );
        // Create body bytes with salt + iv
        // exactly matching lengths so cipherBytes is empty
        final Uint8List salt = Uint8List(
          api_service_constants.Constants.saltLength,
        );
        final Uint8List iv = Uint8List(
          api_service_constants.Constants.ivLength,
        );
        final Uint8List bodyBytes = Uint8List.fromList(<int>[...salt, ...iv]);
        final Response<dynamic> response = Response<dynamic>(
          requestOptions: options,
          data: <String, dynamic>{
            "body": base64Encode(bodyBytes),
            "algo": api_service_constants.Constants.algo,
            "safeToken": "token",
          },
        );
        final FakeResponseInterceptorHandler handler =
            FakeResponseInterceptorHandler();
        when(
          () => mockApzCrypto.asymmetricDecrypt(
            privateKeyPath: any(named: "privateKeyPath"),
            encryptedData: any(named: "encryptedData"),
          ),
        ).thenAnswer((_) async => base64Encode(Uint8List(32)));

        await interceptor.onResponse(response, handler);
        expect(handler.calledReject, isTrue);
        expect(
          handler.passedException!.error,
          contains("body or error field is not proper"),
        );
      },
    );

    test("should reject when asymmetricDecrypt throws", () async {
      final RequestOptions options = RequestOptions(
        path: "/test",
        method: "POST",
        extra: <String, dynamic>{},
      );
      final Uint8List salt = Uint8List(16);
      final Uint8List iv = Uint8List(12);
      final Uint8List cipherBytes = Uint8List(10);
      final Uint8List bodyBytes = Uint8List.fromList(<int>[
        ...salt,
        ...iv,
        ...cipherBytes,
      ]);
      final Response<dynamic> response = Response<dynamic>(
        requestOptions: options,
        data: <String, dynamic>{
          "body": base64Encode(bodyBytes),
          "algo": api_service_constants.Constants.algo,
          "safeToken": "token",
        },
      );
      final FakeResponseInterceptorHandler handler =
          FakeResponseInterceptorHandler();
      // Make asymmetricDecrypt return a valid symmetric key,
      // but make symmetricDecrypt fail
      when(
        () => mockApzCrypto.asymmetricDecrypt(
          privateKeyPath: any(named: "privateKeyPath"),
          encryptedData: any(named: "encryptedData"),
        ),
      ).thenAnswer((_) async => base64Encode(Uint8List(32)));

      when(
        () => mockApzCrypto.generateHashDigestWithSalt(
          textToHash: any(named: "textToHash"),
          salt: any(named: "salt"),
          type: any(named: "type"),
          iterationCount: any(named: "iterationCount"),
          outputKeyLength: any(named: "outputKeyLength"),
        ),
      ).thenReturn(base64Encode(Uint8List(32)));

      when(
        () => mockApzCrypto.symmetricDecrypt(
          cipherText: any(named: "cipherText"),
          key: any(named: "key"),
          iv: any(named: "iv"),
        ),
      ).thenThrow(Exception("boom"));

      await interceptor.onResponse(response, handler);
      expect(handler.calledReject, isTrue);
      expect(
        handler.passedException?.error,
        contains("Failed to decrypt response data"),
      );
    });
  });
}
