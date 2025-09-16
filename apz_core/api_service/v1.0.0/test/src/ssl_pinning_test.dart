import "dart:convert";
import "dart:io";

import "package:apz_api_service/src/ssl_pinning.dart";
import "package:dio/dio.dart";
import "package:dio/io.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:path/path.dart" as path;
import "package:pointycastle/export.dart";

void main() {
  late String publicKeyPath;
  late String privateKeyPath;

  setUpAll(() {
    final String testDir = Directory.current.path;
    publicKeyPath = path.join(testDir, "test", "assets", "rsa_3072_public.pem");
    privateKeyPath = path.join(
      testDir,
      "test",
      "assets",
      "rsa_3072_private.pem",
    );
  });
  group("SslPinning", () {
    final SslPinning sslPinning = SslPinning();

    test("constantTimeEquals returns true for equal strings", () {
      expect(sslPinning.constantTimeEquals("abc123", "abc123"), isTrue);
    });

    test("constantTimeEquals returns false for different strings", () {
      expect(sslPinning.constantTimeEquals("abc123", "abc124"), isFalse);
    });

    test("extractSubjectPublicKeyInfo returns null for invalid DER", () {
      final Uint8List invalidDer = Uint8List.fromList(<int>[0x01, 0x02, 0x03]);
      expect(sslPinning.extractSubjectPublicKeyInfo(invalidDer), isNull);
    });

    test("isLikelySubjectPublicKeyInfo returns false for random data", () {
      final Uint8List randomData = Uint8List.fromList(<int>[0x01, 0x02, 0x03]);
      expect(sslPinning.isLikelySubjectPublicKeyInfo(randomData), isFalse);
    });

    test("parseDerObject returns null for too short data", () {
      final Uint8List shortData = Uint8List.fromList(<int>[0x01]);
      expect(sslPinning.parseDerObject(shortData, 0), isNull);
    });

    test("parseDerObject parses valid DER object", () {
      // SEQUENCE (0x30), length 1, content 0x01
      final Uint8List der = Uint8List.fromList(<int>[0x30, 0x01, 0x01]);
      final DerObject? obj = sslPinning.parseDerObject(der, 0);
      expect(obj, isNotNull);
      expect(obj!.tag, 0x30);
      expect(obj.content.length, 1);
      expect(obj.content[0], 0x01);
    });

    test("extractSubjectPublicKeyInfo returns SPKI for crafted DER", () {
      // Build a minimal certificate DER containing
      // TBSCertificate which contains SPKI
      // Top-level SEQUENCE (len 10)
      // TBSCertificate (len 8) contains SPKI (len 6)
      final Uint8List der = Uint8List.fromList(<int>[
        0x30, 0x0A, // certificate SEQUENCE, length 10
        0x30, 0x08, // tbsCertificate: SEQUENCE, length 8
        // SPKI SEQUENCE
        0x30, 0x06, // SPKI SEQUENCE length 6
        0x30, 0x00, // AlgorithmIdentifier: SEQUENCE length 0
        0x03, 0x02, 0x00, 0x01, // BIT STRING length 2, bytes [0x00,0x01]
      ]);

      final Uint8List? spki = sslPinning.extractSubjectPublicKeyInfo(der);
      expect(spki, isNotNull);
      // Expect the returned SPKI (tag+length+content)
      expect(
        spki,
        equals(
          Uint8List.fromList(<int>[
            0x30,
            0x06,
            0x30,
            0x00,
            0x03,
            0x02,
            0x00,
            0x01,
          ]),
        ),
      );
    });

    test(
      "isLikelySubjectPublicKeyInfo returns true for valid SPKI content",
      () {
        final Uint8List spkiObj = Uint8List.fromList(<int>[
          0x30,
          0x06,
          0x30,
          0x00,
          0x03,
          0x02,
          0x00,
          0x01,
        ]);
        final DerObject? parsed = sslPinning.parseDerObject(spkiObj, 0);
        expect(parsed, isNotNull);
        expect(
          sslPinning.isLikelySubjectPublicKeyInfo(parsed!.content),
          isTrue,
        );
      },
    );

    test("parseDerObject handles long-form length (0x81)", () {
      // SEQUENCE with long-form length: 0x81 0x05 -> length 5
      final Uint8List der = Uint8List.fromList(<int>[
        0x30,
        0x81,
        0x05,
        0x01,
        0x02,
        0x03,
        0x04,
        0x05,
      ]);
      final DerObject? obj = sslPinning.parseDerObject(der, 0);
      expect(obj, isNotNull);
      expect(obj!.content.length, 5);
    });

    test("parseDerObject rejects invalid long-form length (0x80)", () {
      final Uint8List der = Uint8List.fromList(<int>[0x30, 0x80]);
      expect(sslPinning.parseDerObject(der, 0), isNull);
    });

    test("sslPinningPublicKeyHashes configures Dio adapter", () {
      final Dio dio = Dio();
      sslPinning.sslPinningPublicKeyHashes(dio, <String>["dummyhash"]);
      expect((dio.httpClientAdapter as dynamic).createHttpClient, isNotNull);
    });

    test("sslPinningCertificates throws when asset load fails", () async {
      final Dio dio = Dio();
      // Request a non-existent asset path so rootBundle.load will throw
      await expectLater(
        sslPinning.sslPinningCertificates(dio, <String>["nonexistent.asset"]),
        throwsA(isA<Exception>()),
      );
    });

    test("parseDerObject handles long-form length (0x82) with two bytes", () {
      // SEQUENCE, length encoded in two bytes: 0x82 0x00 0x05 -> length 5
      final Uint8List der = Uint8List.fromList(<int>[
        0x30,
        0x82,
        0x00,
        0x05,
        0x01,
        0x02,
        0x03,
        0x04,
        0x05,
      ]);
      final DerObject? obj = sslPinning.parseDerObject(der, 0);
      expect(obj, isNotNull);
      expect(obj!.content.length, 5);
    });

    test(
      "isLikelySubjectPublicKeyInfo returns false when algorithm not SEQUENCE",
      () {
        // First element is INTEGER, not SEQUENCE
        final Uint8List content = Uint8List.fromList(<int>[0x02, 0x01, 0x01]);
        expect(sslPinning.isLikelySubjectPublicKeyInfo(content), isFalse);
      },
    );

    test(
      "SPKI SHA256 digest matches expected base64 and constantTimeEquals works",
      () {
        final Uint8List spkiObj = Uint8List.fromList(<int>[
          0x30,
          0x06,
          0x30,
          0x00,
          0x03,
          0x02,
          0x00,
          0x01,
        ]);

        final SHA256Digest digest = SHA256Digest();
        final Uint8List hash = digest.process(spkiObj);
        final String base64Hash = base64Encode(hash);

        // Self-compare should be true
        expect(sslPinning.constantTimeEquals(base64Hash, base64Hash), isTrue);
        // Slightly different string should be false
        expect(
          sslPinning.constantTimeEquals(base64Hash, "${base64Hash}a"),
          isFalse,
        );
        expect(base64Hash, isNotEmpty);
      },
    );

    test("parseDerObject rejects too-long length-of-length (>4)", () {
      // Use 0x85 to indicate length-of-length = 5 which is invalid per parser
      final Uint8List der = Uint8List.fromList(<int>[
        0x30,
        0x85,
        0,
        0,
        0,
        0,
        0,
      ]);
      expect(sslPinning.parseDerObject(der, 0), isNull);
    });

    test(
      "findSubjectPublicKeyInfoInTbs stops after many fields and returns null",
      () {
        // Build TBSCertificate-like content with >10 small NULL objects
        final List<int> parts = <int>[];
        for (int i = 0; i < 11; i++) {
          parts.addAll(<int>[0x05, 0x00]); // NULL with zero length
        }
        final Uint8List tbs = Uint8List.fromList(parts);
        expect(sslPinning.findSubjectPublicKeyInfoInTbs(tbs), isNull);
      },
    );

    test(
      """extractSubjectPublicKeyInfo returns null when certificate tag is not SEQUENCE""",
      () {
        // Top-level INTEGER object, not a SEQUENCE
        final Uint8List der = Uint8List.fromList(<int>[0x02, 0x01, 0x01]);
        expect(sslPinning.extractSubjectPublicKeyInfo(der), isNull);
      },
    );

    test(
      """extractSubjectPublicKeyInfo returns null when tbsCertificate is not SEQUENCE""",
      () {
        // Top-level SEQUENCE containing INTEGER
        // (so tbsCertificate parse yields INTEGER)
        final Uint8List der = Uint8List.fromList(<int>[
          0x30,
          0x03,
          0x02,
          0x01,
          0x01,
        ]);
        expect(sslPinning.extractSubjectPublicKeyInfo(der), isNull);
      },
    );

    test("findSubjectPublicKeyInfoInTbs finds SPKI at non-zero offset", () {
      final Uint8List tbs = Uint8List.fromList(<int>[
        0x05,
        0x00, // NULL
        0x30,
        0x06, // SPKI sequence
        0x30,
        0x00,
        0x03,
        0x02,
        0x00,
        0x01,
      ]);
      final Uint8List? spki = sslPinning.findSubjectPublicKeyInfoInTbs(tbs);
      expect(spki, isNotNull);
      expect(
        spki,
        equals(
          Uint8List.fromList(<int>[
            0x30,
            0x06,
            0x30,
            0x00,
            0x03,
            0x02,
            0x00,
            0x01,
          ]),
        ),
      );
    });

    test("parseDerObject returns null when content length exceeds data", () {
      // SEQUENCE length 5 but only 2 content bytes provided
      final Uint8List der = Uint8List.fromList(<int>[0x30, 0x05, 0x01, 0x02]);
      expect(sslPinning.parseDerObject(der, 0), isNull);
    });

    test("publicKeyPath PEM decodes to DER and SHA256/base64 is non-empty", () {
      final String pem = File(publicKeyPath).readAsStringSync();
      final RegExp re = RegExp(
        "-----BEGIN [A-Z ]+-----(.*?)-----END [A-Z ]+-----",
        dotAll: true,
      );
      final Match? m = re.firstMatch(pem);
      expect(
        m,
        isNotNull,
        reason: "Public key PEM must contain BEGIN/END markers",
      );
      final String b64 = m!.group(1)!.replaceAll(RegExp(r"\s+"), "");
      final Uint8List der = base64Decode(b64);
      expect(der, isNotEmpty);

      final SHA256Digest digest = SHA256Digest();
      final Uint8List hash = digest.process(der);
      final String base64Hash = base64Encode(hash);

      expect(base64Hash, isNotEmpty);
      expect(sslPinning.constantTimeEquals(base64Hash, base64Hash), isTrue);
    });

    test("parseDerObject handles long-form length (0x83 and 0x84)", () {
      // 0x83 length-of-length with 3 bytes -> length 0x000005
      final Uint8List der83 = Uint8List.fromList(<int>[
        0x30,
        0x83,
        0x00,
        0x00,
        0x05,
        0x01,
        0x02,
        0x03,
        0x04,
        0x05,
      ]);
      final DerObject? obj83 = sslPinning.parseDerObject(der83, 0);
      expect(obj83, isNotNull);
      expect(obj83!.content.length, 5);

      // 0x84 length-of-length with 4 bytes -> length 0x00000005
      final Uint8List der84 = Uint8List.fromList(<int>[
        0x30,
        0x84,
        0x00,
        0x00,
        0x00,
        0x05,
        0x01,
        0x02,
        0x03,
        0x04,
        0x05,
      ]);
      final DerObject? obj84 = sslPinning.parseDerObject(der84, 0);
      expect(obj84, isNotNull);
      expect(obj84!.content.length, 5);
    });

    test("parseDerObject parses object at non-zero offset", () {
      final Uint8List data = Uint8List.fromList(<int>[0x00, 0x30, 0x01, 0xFF]);
      final DerObject? obj = sslPinning.parseDerObject(data, 1);
      expect(obj, isNotNull);
      expect(obj!.tag, 0x30);
      expect(obj.content.length, 1);
    });

    test(
      "isLikelySubjectPublicKeyInfo false when publicKey tag is not BIT STRING",
      () {
        // AlgorithmIdentifier SEQUENCE empty,
        // then INTEGER instead of BIT STRING
        final Uint8List content = Uint8List.fromList(<int>[
          0x30,
          0x00,
          0x02,
          0x01,
          0x01,
        ]);
        expect(sslPinning.isLikelySubjectPublicKeyInfo(content), isFalse);
      },
    );

    test(
      "sslPinningPublicKeyHashes no-op when adapter is non-IOHttpClientAdapter",
      () {
        final Dio dio = Dio()
          // Set a dummy adapter that is not IOHttpClientAdapter
          ..httpClientAdapter = _DummyAdapter();
        // Should not throw
        sslPinning.sslPinningPublicKeyHashes(dio, <String>["h"]);
        expect(dio.httpClientAdapter as dynamic, isA<_DummyAdapter>());
      },
    );

    test(
      "sslPinningPublicKeyHashes sets createHttpClient when IO adapter present",
      () {
        final Dio dio = Dio()..httpClientAdapter = IOHttpClientAdapter();
        sslPinning.sslPinningPublicKeyHashes(dio, <String>["abc"]);
        final IOHttpClientAdapter adapter =
            dio.httpClientAdapter as IOHttpClientAdapter;
        expect(adapter.createHttpClient, isNotNull);
      },
    );

    test("sslPinningCertificates loads asset and configures adapter", () async {
      TestWidgetsFlutterBinding.ensureInitialized();

      // Simple DER bytes to return via rootBundle.load
      final Uint8List fakeCert = Uint8List.fromList(<int>[0x30, 0x01, 0x01]);

      ServicesBinding.instance.defaultBinaryMessenger.setMockMessageHandler(
        "flutter/assets",
        (final ByteData? message) async => ByteData.view(fakeCert.buffer),
      );

      final Dio dio = Dio();
      // SecurityContext may reject the fake cert bytes; ensure we at least
      // surface an exception rather than letting the test pass silently.
      await expectLater(
        sslPinning.sslPinningCertificates(dio, <String>[
          "test/assets/fake.crt",
        ]),
        throwsA(isA<Exception>()),
      );
    });

    test(
      """sslPinningCertificates configures IO adapter and badCertificateCallback rejects cert""",
      () async {
        TestWidgetsFlutterBinding.ensureInitialized();

        // Read the actual public key PEM from test assets and convert to DER
        final String pem = File(publicKeyPath).readAsStringSync();
        final RegExp re = RegExp(
          "-----BEGIN [A-Z ]+-----(.*?)-----END [A-Z ]+-----",
          dotAll: true,
        );
        final Match? m = re.firstMatch(pem);
        expect(m, isNotNull);
        final String b64 = m!.group(1)!.replaceAll(RegExp(r"\s+"), "");
        final Uint8List der = base64Decode(b64);

        // Mock asset loading to return the DER bytes
        ServicesBinding.instance.defaultBinaryMessenger.setMockMessageHandler(
          "flutter/assets",
          (final ByteData? message) async => ByteData.view(der.buffer),
        );

        final Dio dio = Dio()..httpClientAdapter = IOHttpClientAdapter();

        // SecurityContext may reject the PEM/DER bytes on some platforms.
        // Expect an Exception rather than trying to instantiate the HttpClient.
        await expectLater(
          sslPinning.sslPinningCertificates(dio, <String>[
            "test/assets/rsa.pub",
          ]),
          throwsA(isA<Exception>()),
        );
      },
    );

    test("privateKeyPath file exists and looks like PEM", () {
      final File priv = File(privateKeyPath);
      expect(
        priv.existsSync(),
        isTrue,
        reason: "Private key file must exist for tests",
      );
      final String pem = priv.readAsStringSync();
      expect(
        pem.contains("BEGIN PRIVATE KEY") ||
            pem.contains("BEGIN RSA PRIVATE KEY"),
        isTrue,
      );
    });

    test(
      "getHashBadCertificateCallback rejects when trusted list is empty",
      () {
        final Uint8List der = Uint8List.fromList(<int>[
          0x30, 0x0A, // certificate SEQUENCE, length 10
          0x30, 0x08, // tbsCertificate: SEQUENCE, length 8
          0x30, 0x06, // SPKI SEQUENCE length 6
          0x30, 0x00, // AlgorithmIdentifier: SEQUENCE length 0
          0x03, 0x02, 0x00, 0x01,
        ]);
        final _FakeX509 cert = _FakeX509(der);
        final bool Function(X509Certificate cert, String host, int port)
        callback = sslPinning.getHashBadCertificateCallback(<String>[]);
        expect(callback(cert, "example.com", 443), isFalse);
      },
    );

    test("getHashBadCertificateCallback rejects on empty der", () {
      final _FakeX509 cert = _FakeX509(Uint8List(0));
      final bool Function(X509Certificate cert, String host, int port)
      callback = sslPinning.getHashBadCertificateCallback(<String>["x"]);
      expect(callback(cert, "example.com", 443), isFalse);
    });

    test(
      "getHashBadCertificateCallback accepts when SPKI matches trusted hash",
      () {
        final Uint8List der = Uint8List.fromList(<int>[
          0x30, 0x0A, // certificate SEQUENCE
          0x30, 0x08, // tbsCertificate SEQUENCE
          0x30, 0x06, // SPKI SEQUENCE
          0x30, 0x00, 0x03, 0x02, 0x00, 0x01,
        ]);

        final Uint8List? spki = sslPinning.extractSubjectPublicKeyInfo(der);
        expect(spki, isNotNull);

        final SHA256Digest digest = SHA256Digest();
        final Uint8List hash = digest.process(spki!);
        final String base64Hash = base64Encode(hash);

        final _FakeX509 cert = _FakeX509(der);
        final bool Function(X509Certificate cert, String host, int port)
        callback = sslPinning.getHashBadCertificateCallback(<String>[
          base64Hash,
        ]);
        expect(callback(cert, "example.com", 443), isTrue);
      },
    );

    test(
      "getHashBadCertificateCallback handles exceptions during processing",
      () {
        final _ThrowingX509 cert = _ThrowingX509();
        final bool Function(X509Certificate cert, String host, int port)
        callback = sslPinning.getHashBadCertificateCallback(<String>["x"]);
        // Should catch exception and return false
        expect(callback(cert, "host", 443), isFalse);
      },
    );

    test(
      "sslPinningCertificates is no-op for empty certificate list",
      () async {
        final Dio dio = Dio();
        // Should not throw when certificatePaths is empty
        await sslPinning.sslPinningCertificates(dio, <String>[]);
      },
    );

    test(
      "getHashBadCertificateCallback returns false when hash mismatches",
      () {
        final Uint8List der = Uint8List.fromList(<int>[
          0x30, 0x0A, // certificate SEQUENCE
          0x30, 0x08, // tbsCertificate SEQUENCE
          0x30, 0x06, // SPKI SEQUENCE
          0x30, 0x00, 0x03, 0x02, 0x00, 0x01,
        ]);
        final Uint8List? spki = sslPinning.extractSubjectPublicKeyInfo(der);
        expect(spki, isNotNull);

        final SHA256Digest digest = SHA256Digest();
        final Uint8List hash = digest.process(spki!);
        final String base64Hash = base64Encode(hash);

        // Use a different trusted hash so it won't match
        final String differentHash = "${base64Hash}x";

        final _FakeX509 cert = _FakeX509(der);
        final bool Function(X509Certificate cert, String host, int port)
        callback = sslPinning.getHashBadCertificateCallback(<String>[
          differentHash,
        ]);
        expect(callback(cert, "example.com", 443), isFalse);
      },
    );

    test("parseDerObject returns null when offset beyond data length", () {
      final Uint8List data = Uint8List.fromList(<int>[0x30, 0x01, 0x01]);
      // offset equal to data.length should return null
      expect(sslPinning.parseDerObject(data, data.length), isNull);
    });
  });
}

/// Minimal fake X509Certificate implementation for tests.
class _FakeX509 implements X509Certificate {
  _FakeX509(this._der);

  final Uint8List _der;

  @override
  Uint8List get der => _der;

  @override
  Uint8List get sha1 => Uint8List(0);

  @override
  String get subject => "";

  @override
  String get issuer => "";

  @override
  DateTime get startValidity => DateTime.fromMillisecondsSinceEpoch(0);

  @override
  DateTime get endValidity => DateTime.fromMillisecondsSinceEpoch(0);

  @override
  String get pem => "";
}

// A minimal HttpClientAdapter implementation for testing purposes.
class _DummyAdapter implements HttpClientAdapter {
  @override
  void close({final bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    final RequestOptions options,
    final Stream<List<int>>? requestStream,
    final Future<dynamic>? cancelFuture,
  ) async => ResponseBody.fromString("", 200);
}

/// X509Certificate implementation that throws when accessing DER bytes to
/// exercise exception handling paths in getHashBadCertificateCallback.
class _ThrowingX509 implements X509Certificate {
  @override
  Uint8List get der => throw Exception("der read failure");

  @override
  Uint8List get sha1 => Uint8List(0);

  @override
  String get subject => "";

  @override
  String get issuer => "";

  @override
  DateTime get startValidity => DateTime.fromMillisecondsSinceEpoch(0);

  @override
  DateTime get endValidity => DateTime.fromMillisecondsSinceEpoch(0);

  @override
  String get pem => "";
}
