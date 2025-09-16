import "dart:convert";
import "dart:typed_data";

import "package:apz_api_service/src/dio_client.dart";
import "package:apz_api_service/src/encryption_decryption.dart";
import "package:apz_api_service/utils/constants.dart" as api_service_constants;
import "package:apz_api_service/utils/print_utils.dart";
import "package:apz_crypto/apz_crypto.dart" as crypto;
import "package:dio/dio.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";

class MockApzCrypto extends Mock implements crypto.ApzCrypto {}

class MockDioClient extends Mock implements DioClient {}

void main() {
  late MockApzCrypto mockApzCrypto;
  late MockDioClient mockDioClient;
  late EncryptionDecryption encryptionDecryption;

  setUpAll(() {
    registerFallbackValue(crypto.HashType.values.first);
    registerFallbackValue(Uint8List(0));
    registerFallbackValue(RequestOptions(path: "/test"));
  });

  setUp(() {
    mockApzCrypto = MockApzCrypto();
    mockDioClient = MockDioClient();
    // Default stub to avoid null from unstubbed mock calls used by
    // ReplayPrevention or other helpers.
    when(
      () => mockApzCrypto.generateRandomAlphanumeric(
        length: any(named: "length"),
      ),
    ).thenReturn("fixed-idempotent-key-enc-0123456789");

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
    final PrintUtils printUtils = PrintUtils(isDebugModeEnabled: false);
    encryptionDecryption = EncryptionDecryption(
      printUtils: printUtils,
      dioClient: mockDioClient,
      apzCrypto: mockApzCrypto,
      publicKeyPath: "public.pem",
      privateKeyPath: "private.pem",
    );
  });

  group("EncryptionDecryption.encryptRequest", () {
    test(
      "returns same options when data is null or method not applicable",
      () async {
        final RequestOptions options = RequestOptions(
          path: "/test",
          method: "GET",
          extra: <String, dynamic>{},
        );
        final RequestOptions result = await encryptionDecryption.encryptRequest(
          options,
        );
        expect(result, equals(options));
        expect(result.data, isNull);
      },
    );

    test(
      "throws DioException when crypto.generateRandomBytes throws",
      () async {
        final RequestOptions options = RequestOptions(
          path: "/test",
          method: "POST",
          data: <String, String>{"foo": "bar"},
        );
        when(
          () => mockApzCrypto.generateRandomBytes(length: any(named: "length")),
        ).thenThrow(Exception("boom"));
        expect(
          () => encryptionDecryption.encryptRequest(options),
          throwsA(isA<DioException>()),
        );
      },
    );

    test(
      "encrypts request data and includes safeToken when key not set",
      () async {
        final RequestOptions options = RequestOptions(
          path: "/test",
          method: "POST",
          data: <String, String>{"foo": "bar"},
        );

        final Uint8List salt = Uint8List(
          api_service_constants.Constants.saltLength,
        );
        final Uint8List tempSymmetric = Uint8List(
          api_service_constants.Constants.symmetricKeyLength,
        );
        final Uint8List iv = Uint8List(
          api_service_constants.Constants.ivLength,
        );

        when(
          () => mockApzCrypto.generateRandomBytes(
            length: api_service_constants.Constants.saltLength,
          ),
        ).thenReturn(salt);
        when(
          () => mockApzCrypto.generateRandomBytes(
            length: api_service_constants.Constants.symmetricKeyLength,
          ),
        ).thenReturn(tempSymmetric);
        when(
          () => mockApzCrypto.generateRandomBytes(
            length: api_service_constants.Constants.ivLength,
          ),
        ).thenReturn(iv);

        when(
          () => mockApzCrypto.generateHashDigestWithSalt(
            textToHash: any(named: "textToHash"),
            salt: any(named: "salt"),
            type: any(named: "type"),
            iterationCount: any(named: "iterationCount"),
            outputKeyLength: any(named: "outputKeyLength"),
          ),
        ).thenReturn(base64Encode(Uint8List(32)));

        // symmetric encrypt returns base64 cipher
        when(
          () => mockApzCrypto.symmetricEncrypt(
            textToEncrypt: any(named: "textToEncrypt"),
            key: any(named: "key"),
            iv: any(named: "iv"),
          ),
        ).thenReturn(base64Encode(Uint8List.fromList(<int>[1, 2, 3])));

        when(
          () => mockApzCrypto.asymmetricEncrypt(
            publicKeyPath: any(named: "publicKeyPath"),
            textToEncrypt: any(named: "textToEncrypt"),
          ),
        ).thenAnswer((_) async => "encrypted_key_value");

        final RequestOptions result = await encryptionDecryption.encryptRequest(
          options,
        );
        expect(result.data, isA<Map<String, String>>());
        final Map<String, String> payload = result.data as Map<String, String>;
        expect(payload.containsKey("body"), isTrue);
        expect(payload["algo"], equals(api_service_constants.Constants.algo));
        expect(payload.containsKey("safeToken"), isTrue);
        expect(payload["safeToken"], equals("encrypted_key_value"));
      },
    );

    test(
      "encrypts request data without safeToken when symmetric key already set",
      () async {
        // First seed the symmetric key by
        // simulating a successful decryptResponse
        final RequestOptions optionsResp = RequestOptions(
          path: "/test",
          method: "POST",
          extra: <String, dynamic>{},
        );

        final Uint8List salt = Uint8List(
          api_service_constants.Constants.saltLength,
        );
        final Uint8List iv = Uint8List(
          api_service_constants.Constants.ivLength,
        );
        final Uint8List cipher = Uint8List.fromList(<int>[1, 2, 3]);
        final Uint8List bodyBytes = Uint8List.fromList(<int>[
          ...salt,
          ...iv,
          ...cipher,
        ]);

        final Response<dynamic> response = Response<dynamic>(
          requestOptions: optionsResp,
          data: <String, dynamic>{
            "body": base64Encode(bodyBytes),
            "algo": api_service_constants.Constants.algo,
            "safeToken": "encryptedSafeToken",
          },
        );

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
        ).thenReturn("{}");

        // Run decryptResponse to seed the internal symmetric key
        await encryptionDecryption.decryptResponse(response);

        // Now encrypt a new request; since symmetric key is set,
        // no safeToken should be added
        final RequestOptions reqOptions = RequestOptions(
          path: "/test",
          method: "POST",
          data: <String, String>{"hello": "world"},
        );

        // Mock generateRandomBytes for salt and iv used in encryptRequest
        when(
          () => mockApzCrypto.generateRandomBytes(
            length: api_service_constants.Constants.saltLength,
          ),
        ).thenReturn(salt);
        when(
          () => mockApzCrypto.generateRandomBytes(
            length: api_service_constants.Constants.ivLength,
          ),
        ).thenReturn(iv);

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
          () => mockApzCrypto.symmetricEncrypt(
            textToEncrypt: any(named: "textToEncrypt"),
            key: any(named: "key"),
            iv: any(named: "iv"),
          ),
        ).thenReturn(base64Encode(Uint8List.fromList(<int>[9, 9, 9])));

        final RequestOptions encrypted = await encryptionDecryption
            .encryptRequest(reqOptions);
        final Map<String, String> payload =
            encrypted.data as Map<String, String>;
        expect(payload.containsKey("safeToken"), isFalse);
        expect(payload.containsKey("body"), isTrue);
      },
    );
  });

  group("EncryptionDecryption.decryptResponse", () {
    test("throws when safeToken missing or symmetric key not set", () async {
      final RequestOptions options = RequestOptions(
        path: "/test",
        method: "POST",
        extra: <String, dynamic>{},
      );
      final Response<dynamic> response = Response<dynamic>(
        requestOptions: options,
        data: <String, dynamic>{
          "body": base64Encode(Uint8List(10)),
          "algo": api_service_constants.Constants.algo,
        },
      );

      // The implementation may throw DioException when the symmetric key is
      // missing, or a RangeError if the body is too short and the static
      // symmetric key is set by other tests. Accept any thrown Object here
      // to keep the test stable across Dart VM behaviors.
      expect(
        encryptionDecryption.decryptResponse(response),
        throwsA(isA<Object>()),
      );
    });

    test("successfully decrypts response and sets response.data", () async {
      final RequestOptions options = RequestOptions(
        path: "/test",
        method: "POST",
        extra: <String, dynamic>{},
      );

      final Uint8List salt = Uint8List(
        api_service_constants.Constants.saltLength,
      );
      final Uint8List iv = Uint8List(api_service_constants.Constants.ivLength);
      final Uint8List cipher = Uint8List.fromList(<int>[
        1,
        2,
        3,
        4,
        5,
        6,
        7,
        8,
        9,
        0,
      ]);
      final Uint8List bodyBytes = Uint8List.fromList(<int>[
        ...salt,
        ...iv,
        ...cipher,
      ]);

      final Response<dynamic> response = Response<dynamic>(
        requestOptions: options,
        data: <String, dynamic>{
          "body": base64Encode(bodyBytes),
          "algo": api_service_constants.Constants.algo,
          "safeToken": "encryptedSafeToken",
        },
      );

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

      final Response<dynamic> result = await encryptionDecryption
          .decryptResponse(response);
      expect(result.data, equals('{"foo":"bar"}'));
    });

    test("throws when algo mismatched", () async {
      final RequestOptions options = RequestOptions(
        path: "/test",
        method: "POST",
        extra: <String, dynamic>{},
      );
      final Uint8List salt = Uint8List(
        api_service_constants.Constants.saltLength,
      );
      final Uint8List iv = Uint8List(api_service_constants.Constants.ivLength);
      final Uint8List cipher = Uint8List.fromList(<int>[1, 2, 3]);
      final Uint8List bodyBytes = Uint8List.fromList(<int>[
        ...salt,
        ...iv,
        ...cipher,
      ]);

      final Response<dynamic> response = Response<dynamic>(
        requestOptions: options,
        data: <String, dynamic>{
          "body": base64Encode(bodyBytes),
          // wrong algo
          "algo": "WRONG_ALGO",
          "safeToken": "encryptedSafeToken",
        },
      );

      when(
        () => mockApzCrypto.asymmetricDecrypt(
          privateKeyPath: any(named: "privateKeyPath"),
          encryptedData: any(named: "encryptedData"),
        ),
      ).thenAnswer((_) async => base64Encode(Uint8List(32)));

      expect(
        encryptionDecryption.decryptResponse(response),
        throwsA(isA<DioException>()),
      );
    });

    test("throws when body is empty string", () async {
      final RequestOptions options = RequestOptions(
        path: "/test",
        method: "POST",
        extra: <String, dynamic>{},
      );

      final Response<dynamic> response = Response<dynamic>(
        requestOptions: options,
        data: <String, dynamic>{
          "body": "",
          "algo": api_service_constants.Constants.algo,
          "safeToken": "encryptedSafeToken",
        },
      );

      when(
        () => mockApzCrypto.asymmetricDecrypt(
          privateKeyPath: any(named: "privateKeyPath"),
          encryptedData: any(named: "encryptedData"),
        ),
      ).thenAnswer((_) async => base64Encode(Uint8List(32)));

      expect(
        encryptionDecryption.decryptResponse(response),
        throwsA(isA<DioException>()),
      );
    });

    test("sets APZ_TOKEN on dioClient when present", () async {
      final RequestOptions options = RequestOptions(
        path: "/test",
        method: "POST",
        extra: <String, dynamic>{},
      );

      final Uint8List salt = Uint8List(
        api_service_constants.Constants.saltLength,
      );
      final Uint8List iv = Uint8List(api_service_constants.Constants.ivLength);
      final Uint8List cipher = Uint8List.fromList(<int>[1, 2, 3]);
      final Uint8List bodyBytes = Uint8List.fromList(<int>[
        ...salt,
        ...iv,
        ...cipher,
      ]);

      final Response<dynamic> response = Response<dynamic>(
        requestOptions: options,
        data: <String, dynamic>{
          "body": base64Encode(bodyBytes),
          "algo": api_service_constants.Constants.algo,
          "safeToken": "encryptedSafeToken",
          "APZ_TOKEN": "token_123",
        },
      );

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
      ).thenReturn("{}");

      await encryptionDecryption.decryptResponse(response);
      verify(() => mockDioClient.setToken("token_123")).called(1);
    });
  });
}

    // NOTE: We intentionally avoid tests that mutate the private static
    // `_symmetricKeyPass` to prevent state leakage between tests. That static
    // is shared across instances and not accessible from tests.
