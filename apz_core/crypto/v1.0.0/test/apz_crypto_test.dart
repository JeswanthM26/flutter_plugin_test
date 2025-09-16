import "dart:convert";
import "dart:io";
import "package:apz_crypto/apz_crypto.dart";
import "package:flutter/foundation.dart";
import "package:flutter_test/flutter_test.dart";
import "package:path/path.dart" as path;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final ApzCrypto crypto = ApzCrypto();
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

  group("Random alphanumeric generation", () {
    test("Generates string of requested length", () {
      final String s = crypto.generateRandomAlphanumeric(length: 16);
      expect(s, isNotNull);
      expect(s.length, 16);
    });

    test("Only contains allowed alphanumeric characters", () {
      final String s = crypto.generateRandomAlphanumeric(length: 64);
      final RegExp allowed = RegExp(r"^[a-zA-Z0-9]+$");
      expect(allowed.hasMatch(s), isTrue);
    });

    test("Generates different values on subsequent calls", () {
      final String s1 = crypto.generateRandomAlphanumeric(length: 32);
      final String s2 = crypto.generateRandomAlphanumeric(length: 32);
      // Extremely unlikely to be equal; assert they are not equal
      expect(s1, isNot(equals(s2)));
    });

    test("Zero length returns empty string", () {
      final String s = crypto.generateRandomAlphanumeric(length: 0);
      expect(s, isEmpty);
    });
  });

  group("Symmetric Encryption/Decryption", () {
    test("Encrypt and decrypt text", () {
      const String text = "Hello World!";
      final String key = base64Encode(crypto.generateRandomBytes(length: 32));
      final String iv = base64Encode(crypto.generateRandomBytes(length: 12));
      final String encrypted = crypto.symmetricEncrypt(
        textToEncrypt: text,
        key: key,
        iv: iv,
      );
      final String decrypted = crypto.symmetricDecrypt(
        cipherText: encrypted,
        key: key,
        iv: iv,
      );
      expect(decrypted, text);
    });

    group("Encryption Validation", () {
      test("Should throw on empty text", () {
        final String key = base64Encode(crypto.generateRandomBytes(length: 32));
        final String iv = base64Encode(crypto.generateRandomBytes(length: 12));
        expect(
          () => crypto.symmetricEncrypt(textToEncrypt: "", key: key, iv: iv),
          throwsA(
            isA<Exception>().having(
              (final Exception e) => e.toString(),
              "message",
              contains("Text to encrypt should not be empty"),
            ),
          ),
        );
      });

      test("Should throw on invalid key length", () {
        final String key = base64Encode(
          crypto.generateRandomBytes(length: 16),
        ); // Wrong length
        final String iv = base64Encode(crypto.generateRandomBytes(length: 12));
        expect(
          () =>
              crypto.symmetricEncrypt(textToEncrypt: "test", key: key, iv: iv),
          throwsA(
            isA<Exception>().having(
              (final Exception e) => e.toString(),
              "message",
              contains("Key length should be ${Constants.symtKeyLength}"),
            ),
          ),
        );
      });

      test("Should throw on invalid IV length", () {
        final String key = base64Encode(crypto.generateRandomBytes(length: 32));
        final String iv = base64Encode(
          crypto.generateRandomBytes(length: 16),
        ); // Wrong length
        expect(
          () =>
              crypto.symmetricEncrypt(textToEncrypt: "test", key: key, iv: iv),
          throwsA(
            isA<Exception>().having(
              (final Exception e) => e.toString(),
              "message",
              contains("IV length should be ${Constants.symtIVLength}"),
            ),
          ),
        );
      });

      test("Should throw on invalid base64 key", () {
        expect(
          () => crypto.symmetricEncrypt(
            textToEncrypt: "test",
            key: "not-base64!",
            iv: base64Encode(crypto.generateRandomBytes(length: 12)),
          ),
          throwsA(isA<FormatException>()),
        );
      });

      test("Should throw on invalid base64 IV", () {
        expect(
          () => crypto.symmetricEncrypt(
            textToEncrypt: "test",
            key: base64Encode(crypto.generateRandomBytes(length: 32)),
            iv: "not-base64!",
          ),
          throwsA(isA<FormatException>()),
        );
      });
    });

    group("Decryption Validation", () {
      test("Should throw on empty encrypted data", () {
        final String key = base64Encode(crypto.generateRandomBytes(length: 32));
        final String iv = base64Encode(crypto.generateRandomBytes(length: 12));
        expect(
          () => crypto.symmetricDecrypt(cipherText: "", key: key, iv: iv),
          throwsA(
            isA<Exception>().having(
              (final Exception e) => e.toString(),
              "message",
              contains("Cipher Text should not be empty"),
            ),
          ),
        );
      });

      test("Should throw on invalid key length", () {
        final String key = base64Encode(
          crypto.generateRandomBytes(length: 16),
        ); // Wrong length
        final String iv = base64Encode(crypto.generateRandomBytes(length: 12));
        expect(
          () => crypto.symmetricDecrypt(
            cipherText: base64Encode(utf8.encode("test")),
            key: key,
            iv: iv,
          ),
          throwsA(
            isA<Exception>().having(
              (final Exception e) => e.toString(),
              "message",
              contains("Key length should be ${Constants.symtKeyLength}"),
            ),
          ),
        );
      });

      test("Should throw on invalid IV length", () {
        final String key = base64Encode(crypto.generateRandomBytes(length: 32));
        final String iv = base64Encode(
          crypto.generateRandomBytes(length: 16),
        ); // Wrong length
        expect(
          () => crypto.symmetricDecrypt(
            cipherText: base64Encode(utf8.encode("test")),
            key: key,
            iv: iv,
          ),
          throwsA(
            isA<Exception>().having(
              (final Exception e) => e.toString(),
              "message",
              contains("IV length should be ${Constants.symtIVLength}"),
            ),
          ),
        );
      });

      test("Should throw on invalid base64 inputs", () {
        expect(
          () => crypto.symmetricDecrypt(
            cipherText: "not-base64!",
            key: base64Encode(crypto.generateRandomBytes(length: 32)),
            iv: base64Encode(crypto.generateRandomBytes(length: 12)),
          ),
          throwsA(isA<FormatException>()),
        );
      });
    });

    test("Should throw on empty text to encrypt", () {
      final String key = base64Encode(crypto.generateRandomBytes(length: 32));
      final String iv = base64Encode(crypto.generateRandomBytes(length: 12));
      expect(
        () => crypto.symmetricEncrypt(textToEncrypt: "", key: key, iv: iv),
        throwsException,
      );
    });

    test("Should throw on invalid key length", () {
      const String text = "Hello World!";
      final String key = base64Encode(
        crypto.generateRandomBytes(length: 16),
      ); // Wrong length
      final String iv = base64Encode(crypto.generateRandomBytes(length: 12));
      expect(
        () => crypto.symmetricEncrypt(textToEncrypt: text, key: key, iv: iv),
        throwsException,
      );
    });

    test("Should throw on invalid IV length", () {
      const String text = "Hello World!";
      final String key = base64Encode(crypto.generateRandomBytes(length: 32));
      final String iv = base64Encode(
        crypto.generateRandomBytes(length: 16),
      ); // Wrong length
      expect(
        () => crypto.symmetricEncrypt(textToEncrypt: text, key: key, iv: iv),
        throwsException,
      );
    });

    test("Should throw on empty encrypted data", () {
      final String key = base64Encode(crypto.generateRandomBytes(length: 32));
      final String iv = base64Encode(crypto.generateRandomBytes(length: 12));
      expect(
        () => crypto.symmetricDecrypt(cipherText: "", key: key, iv: iv),
        throwsException,
      );
    });
  });

  group("Hashing", () {
    test("SHA-256 hash", () {
      const String text = "Hello World!";
      final String hash = crypto.generateHashDigest(
        textToHash: text,
        type: HashType.sha256,
      );
      expect(hash, isNotNull);
      expect(hash, isA<String>());
    });

    test("SHA-384 hash", () {
      const String text = "Hello World!";
      final String hash = crypto.generateHashDigest(
        textToHash: text,
        type: HashType.sha384,
      );
      expect(hash, isNotNull);
      expect(hash, isA<String>());
    });

    test("SHA-512 hash", () {
      const String text = "Hello World!";
      final String hash = crypto.generateHashDigest(
        textToHash: text,
        type: HashType.sha512,
      );
      expect(hash, isNotNull);
      expect(hash, isA<String>());
    });

    test("Should throw on empty text to hash", () {
      expect(
        () => crypto.generateHashDigest(textToHash: "", type: HashType.sha256),
        throwsA(
          isA<Exception>().having(
            (final Exception e) => e.toString(),
            "message",
            contains("Text to hash should not be empty"),
          ),
        ),
      );
    });
  });

  group(
    "Asymmetric encryption with public key and decryption with private key",
    () {
      test("Encrypt and decrypt text", () async {
        const String text = "Hello World!";
        final String encrypted = await crypto.asymmetricEncrypt(
          publicKeyPath: publicKeyPath,
          textToEncrypt: text,
        );
        final String decrypted = await crypto.asymmetricDecrypt(
          privateKeyPath: privateKeyPath,
          encryptedData: encrypted,
        );
        expect(decrypted, text);
      });

      group("Encryption Validation", () {
        test("Should throw on empty public key path", () async {
          expect(
            () => crypto.asymmetricEncrypt(
              publicKeyPath: "",
              textToEncrypt: "test",
            ),
            throwsA(
              isA<Exception>().having(
                (final Exception e) => e.toString(),
                "message",
                contains("Public key path should not be empty"),
              ),
            ),
          );
        });

        test("Should throw on empty text", () async {
          expect(
            () => crypto.asymmetricEncrypt(
              publicKeyPath: publicKeyPath,
              textToEncrypt: "",
            ),
            throwsA(
              isA<Exception>().having(
                (final Exception e) => e.toString(),
                "message",
                contains("Text to encrypt should not be empty"),
              ),
            ),
          );
        });

        test("Should throw on invalid public key path", () async {
          expect(
            () => crypto.asymmetricEncrypt(
              publicKeyPath: "invalid/path.pem",
              textToEncrypt: "test",
            ),
            throwsA(isA<FlutterError>()),
          );
        });
      });

      group("Decryption Validation", () {
        test("Should throw on empty private key path", () async {
          expect(
            () => crypto.asymmetricDecrypt(
              privateKeyPath: "",
              encryptedData: base64Encode(utf8.encode("test")),
            ),
            throwsA(
              isA<Exception>().having(
                (final Exception e) => e.toString(),
                "message",
                contains("Private key path should not be empty"),
              ),
            ),
          );
        });

        test("Should throw on empty encrypted data", () async {
          expect(
            () => crypto.asymmetricDecrypt(
              privateKeyPath: privateKeyPath,
              encryptedData: "",
            ),
            throwsA(
              isA<Exception>().having(
                (final Exception e) => e.toString(),
                "message",
                contains("Encrypted data should not be empty"),
              ),
            ),
          );
        });

        test("Should throw on invalid private key path", () async {
          expect(
            () => crypto.asymmetricDecrypt(
              privateKeyPath: "invalid/path.pem",
              encryptedData: base64Encode(utf8.encode("test")),
            ),
            throwsA(isA<FlutterError>()),
          );
        });

        test("Should throw on invalid base64 encrypted data", () async {
          expect(
            () => crypto.asymmetricDecrypt(
              privateKeyPath: privateKeyPath,
              encryptedData: "not-base64!",
            ),
            throwsA(isA<FormatException>()),
          );
        });
      });

      test("Cache should reuse parsed keys", () async {
        const String text = "Test Cache";
        // First call to parse and cache the key
        await crypto.asymmetricEncrypt(
          publicKeyPath: publicKeyPath,
          textToEncrypt: text,
        );
        // Second call should use cached key
        final String encrypted = await crypto.asymmetricEncrypt(
          publicKeyPath: publicKeyPath,
          textToEncrypt: text,
        );
        expect(encrypted, isNotEmpty);

        // Test private key cache
        await crypto.asymmetricDecrypt(
          privateKeyPath: privateKeyPath,
          encryptedData: encrypted,
        );
        // Second call should use cached key
        final String decrypted = await crypto.asymmetricDecrypt(
          privateKeyPath: privateKeyPath,
          encryptedData: encrypted,
        );
        expect(decrypted, text);
      });

      test("Should throw on invalid public key path for encryption", () async {
        const String text = "Hello World!";
        expect(
          () => crypto.asymmetricEncrypt(
            publicKeyPath: "invalid/path.pem",
            textToEncrypt: text,
          ),
          throwsA(isA<FlutterError>()),
        );
      });

      test("Should throw on invalid private key path for decryption", () async {
        const String text = "Hello World!";
        final String encrypted = await crypto.asymmetricEncrypt(
          publicKeyPath: publicKeyPath,
          textToEncrypt: text,
        );
        expect(
          () => crypto.asymmetricDecrypt(
            privateKeyPath: "invalid/path.pem",
            encryptedData: encrypted,
          ),
          throwsA(isA<FlutterError>()),
        );
      });

      test("Should throw on invalid encrypted data for decryption", () async {
        // Use proper base64 encoding for invalid data
        final String invalidData = base64Encode(
          utf8.encode("invalid encrypted data"),
        );
        expect(
          () => crypto.asymmetricDecrypt(
            privateKeyPath: privateKeyPath,
            encryptedData: invalidData,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test("Should throw on empty text to encrypt", () async {
        expect(
          () => crypto.asymmetricEncrypt(
            publicKeyPath: publicKeyPath,
            textToEncrypt: "",
          ),
          throwsException,
        );
      });
    },
  );

  group("Digital Signature", () {
    test("Sign and verify", () async {
      const String text = "Hello World!";
      final String signature = await crypto.generateSignature(
        privateKeyPath: privateKeyPath,
        textToSign: text,
      );
      final bool isValid = await crypto.verifySignature(
        publicKeyPath: publicKeyPath,
        originalText: text,
        signature: signature,
      );
      expect(isValid, isTrue);
    });

    group("Signature Generation Validation", () {
      test("Should throw on empty private key path", () async {
        expect(
          () =>
              crypto.generateSignature(privateKeyPath: "", textToSign: "test"),
          throwsA(
            isA<Exception>().having(
              (final Exception e) => e.toString(),
              "message",
              contains("Private key path should not be empty"),
            ),
          ),
        );
      });

      test("Should throw on empty text to sign", () async {
        expect(
          () => crypto.generateSignature(
            privateKeyPath: privateKeyPath,
            textToSign: "",
          ),
          throwsA(
            isA<Exception>().having(
              (final Exception e) => e.toString(),
              "message",
              contains("Text to sign should not be empty"),
            ),
          ),
        );
      });

      test("Should throw on invalid private key path", () async {
        expect(
          () => crypto.generateSignature(
            privateKeyPath: "invalid/path.pem",
            textToSign: "test",
          ),
          throwsA(isA<FlutterError>()),
        );
      });
    });

    group("Signature Verification Validation", () {
      test("Should throw on empty public key path", () async {
        expect(
          () => crypto.verifySignature(
            publicKeyPath: "",
            originalText: "test",
            signature: base64Encode(utf8.encode("test")),
          ),
          throwsA(
            isA<Exception>().having(
              (final Exception e) => e.toString(),
              "message",
              contains("Public key path should not be empty"),
            ),
          ),
        );
      });

      test("Should throw on empty original text", () async {
        expect(
          () => crypto.verifySignature(
            publicKeyPath: publicKeyPath,
            originalText: "",
            signature: base64Encode(utf8.encode("test")),
          ),
          throwsA(
            isA<Exception>().having(
              (final Exception e) => e.toString(),
              "message",
              contains("Original text should not be empty"),
            ),
          ),
        );
      });

      test("Should throw on empty signature", () async {
        expect(
          () => crypto.verifySignature(
            publicKeyPath: publicKeyPath,
            originalText: "test",
            signature: "",
          ),
          throwsA(
            isA<Exception>().having(
              (final Exception e) => e.toString(),
              "message",
              contains("Signature should not be empty"),
            ),
          ),
        );
      });

      test("Should throw on invalid base64 signature", () async {
        expect(
          () => crypto.verifySignature(
            publicKeyPath: publicKeyPath,
            originalText: "test",
            signature: "not-base64!",
          ),
          throwsA(isA<FormatException>()),
        );
      });
    });

    test("Should fail verification with wrong signature", () async {
      const String text = "Hello World!";
      // Use proper base64 encoding for fake signature
      final String wrongSignature = base64Encode(utf8.encode("wrongSignature"));
      final bool isValid = await crypto.verifySignature(
        publicKeyPath: publicKeyPath,
        originalText: text,
        signature: wrongSignature,
      );
      expect(isValid, isFalse);
    });

    test("Should fail verification with tampered text", () async {
      const String text = "Hello World!";
      final String signature = await crypto.generateSignature(
        privateKeyPath: privateKeyPath,
        textToSign: text,
      );
      final bool isValid = await crypto.verifySignature(
        publicKeyPath: publicKeyPath,
        originalText: "Tampered text",
        signature: signature,
      );
      expect(isValid, isFalse);
    });

    test("Should throw on invalid private key path for signing", () async {
      const String text = "Hello World!";
      expect(
        () => crypto.generateSignature(
          privateKeyPath: "invalid/path.pem",
          textToSign: text,
        ),
        throwsA(isA<FlutterError>()),
      );
    });

    test("Should throw on invalid public key path for verification", () async {
      const String text = "Hello World!";
      // Use proper base64 encoding for fake signature
      final String fakeSignature = base64Encode(utf8.encode("fakeSignature"));
      expect(
        () => crypto.verifySignature(
          publicKeyPath: "invalid/path.pem",
          originalText: text,
          signature: fakeSignature,
        ),
        throwsA(isA<FlutterError>()),
      );
    });
  });

  group("Hashing with Salt", () {
    test("Generate hash digest with salt (SHA-256)", () {
      const String text = "Hello World!";
      final String salt = base64Encode(
        List<int>.generate(16, (final int i) => i),
      );
      const int outputKeyLength = 32;
      final String hash = crypto.generateHashDigestWithSalt(
        textToHash: text,
        salt: salt,
        type: HashType.sha256,
        iterationCount: 1000,
        outputKeyLength: outputKeyLength,
      );
      final Uint8List decodedHash = base64Decode(hash);
      expect(hash, isNotNull);
      expect(hash, isA<String>());
      expect(decodedHash.length, outputKeyLength);
    });

    test("Generate hash digest with salt (SHA-384)", () {
      const String text = "Hello World!";
      final String salt = base64Encode(
        List<int>.generate(16, (final int i) => i),
      );
      const int outputKeyLength = 32;
      final String hash = crypto.generateHashDigestWithSalt(
        textToHash: text,
        salt: salt,
        type: HashType.sha384,
        iterationCount: 1000,
        outputKeyLength: outputKeyLength,
      );
      final Uint8List decodedHash = base64Decode(hash);
      expect(hash, isNotNull);
      expect(hash, isA<String>());
      expect(decodedHash.length, outputKeyLength);
    });

    test("Generate hash digest with salt (SHA-512)", () {
      const String text = "Hello World!";
      final String salt = base64Encode(
        List<int>.generate(16, (final int i) => i),
      );
      const int outputKeyLength = 32;
      final String hash = crypto.generateHashDigestWithSalt(
        textToHash: text,
        salt: salt,
        type: HashType.sha512,
        iterationCount: 1000,
        outputKeyLength: outputKeyLength,
      );
      final Uint8List decodedHash = base64Decode(hash);
      expect(hash, isNotNull);
      expect(hash, isA<String>());
      expect(decodedHash.length, outputKeyLength);
    });

    test("Should throw on empty text to hash", () {
      final String salt = base64Encode(
        List<int>.generate(16, (final int i) => i),
      );
      expect(
        () => crypto.generateHashDigestWithSalt(
          textToHash: "",
          salt: salt,
          type: HashType.sha256,
          iterationCount: 1000,
          outputKeyLength: 32,
        ),
        throwsA(
          isA<Exception>().having(
            (final Exception e) => e.toString(),
            "message",
            contains("Text to hash should not be empty"),
          ),
        ),
      );
    });

    test("Should throw on empty salt", () {
      expect(
        () => crypto.generateHashDigestWithSalt(
          textToHash: "Hello World!",
          salt: "",
          type: HashType.sha256,
          iterationCount: 1000,
          outputKeyLength: 32,
        ),
        throwsA(
          isA<Exception>().having(
            (final Exception e) => e.toString(),
            "message",
            contains("Salt should not be empty"),
          ),
        ),
      );
    });

    test("Should throw on iteration count <= 0", () {
      final String salt = base64Encode(
        List<int>.generate(16, (final int i) => i),
      );
      expect(
        () => crypto.generateHashDigestWithSalt(
          textToHash: "Hello World!",
          salt: salt,
          type: HashType.sha256,
          iterationCount: 0,
          outputKeyLength: 32,
        ),
        throwsA(
          isA<Exception>().having(
            (final Exception e) => e.toString(),
            "message",
            contains("Iteration count should be greater than 0"),
          ),
        ),
      );
    });

    test("Should throw on output key length <= 0", () {
      final String salt = base64Encode(
        List<int>.generate(16, (final int i) => i),
      );
      expect(
        () => crypto.generateHashDigestWithSalt(
          textToHash: "Hello World!",
          salt: salt,
          type: HashType.sha256,
          iterationCount: 1000,
          outputKeyLength: 0,
        ),
        throwsA(
          isA<Exception>().having(
            (final Exception e) => e.toString(),
            "message",
            contains("Output key length should be greater than 0"),
          ),
        ),
      );
    });
  });
}
