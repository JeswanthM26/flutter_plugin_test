import "package:apz_play_integrity/apz_play_integrity.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";

class MockAndroidPlatform implements ApzPlatform {
  @override
  bool get isAndroid => true;
  @override
  bool get isWeb => false;
}

class MockWebPlatform implements ApzPlatform {
  @override
  bool get isAndroid => false;
  @override
  bool get isWeb => true;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel("play_integrity_plugin");

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group("ApzPlayIntegrity", () {
    test("is singleton", () {
      final ApzPlayIntegrity instance1 = ApzPlayIntegrity(
        platform: MockAndroidPlatform(),
      );
      final ApzPlayIntegrity instance2 = ApzPlayIntegrity(
        platform: MockAndroidPlatform(),
      );
      expect(instance1, same(instance2));
    });

    test("prepareStandardIntegrityToken returns true", () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (final MethodCall call) async {
            if (call.method == "prepareStandardIntegrityToken") {
              return true;
            }
            return null;
          });
      final bool result = await ApzPlayIntegrity(
        platform: MockAndroidPlatform(),
      ).prepareStandardIntegrityToken(cloudProjectNumber: "1234567890");
      expect(result, isTrue);
    });

    test(
      "prepareStandardIntegrityToken throws on empty cloudProjectNumber",
      () async {
        expect(
          () => ApzPlayIntegrity(
            platform: MockAndroidPlatform(),
          ).prepareStandardIntegrityToken(cloudProjectNumber: ""),
          throwsException,
        );
      },
    );

    test("requestStandardIntegrityToken returns token", () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (final MethodCall call) async {
            if (call.method == "requestStandardIntegrityToken") {
              return "standard_token";
            }
            return null;
          });
      final String? token = await ApzPlayIntegrity(
        platform: MockAndroidPlatform(),
      ).requestStandardIntegrityToken(requestHash: "hash");
      expect(token, "standard_token");
    });

    test("requestClassicIntegrityToken returns token", () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (final MethodCall call) async {
            if (call.method == "requestClassicIntegrityToken") {
              return "classic_token";
            }
            return null;
          });
      final String? token =
          await ApzPlayIntegrity(
            platform: MockAndroidPlatform(),
          ).requestClassicIntegrityToken(
            nonce: "nonce",
            cloudProjectNumber: "1234567890",
          );
      expect(token, "classic_token");
    });

    test("requestClassicIntegrityToken throws on empty nonce", () async {
      expect(
        () => ApzPlayIntegrity(platform: MockAndroidPlatform())
            .requestClassicIntegrityToken(
              nonce: "",
              cloudProjectNumber: "1234567890",
            ),
        throwsException,
      );
    });

    test(
      "requestClassicIntegrityToken throws on empty cloudProjectNumber",
      () async {
        expect(
          () => ApzPlayIntegrity(platform: MockAndroidPlatform())
              .requestClassicIntegrityToken(
                nonce: "nonce",
                cloudProjectNumber: "",
              ),
          throwsException,
        );
      },
    );

    test("throws UnsupportedPlatformException on non-Android", () async {
      final ApzPlayIntegrity instance = ApzPlayIntegrity(
        platform: MockWebPlatform(),
      );
      expect(
        () => instance.prepareStandardIntegrityToken(
          cloudProjectNumber: "1234567890",
        ),
        throwsA(
          predicate(
            (final Object? e) => e.toString().contains(
              "Play Integrity is only supported on Android.",
            ),
          ),
        ),
      );
      expect(
        () => instance.requestStandardIntegrityToken(requestHash: "hash"),
        throwsA(
          predicate(
            (final Object? e) => e.toString().contains(
              "Play Integrity is only supported on Android.",
            ),
          ),
        ),
      );
      expect(
        () => instance.requestClassicIntegrityToken(
          nonce: "nonce",
          cloudProjectNumber: "1234567890",
        ),
        throwsA(
          predicate(
            (final Object? e) => e.toString().contains(
              "Play Integrity is only supported on Android.",
            ),
          ),
        ),
      );
    });

    test("handlePlatformException throws correct errors", () {
      final ApzPlayIntegrity instance = ApzPlayIntegrity(
        platform: MockAndroidPlatform(),
      );
      final Map<String, String> _ =
          <String, String>{
            "INVALID_CLOUD_PROJECT_NUMBER": "custom error",
            "CLASSIC_PLAY_INTEGRITY_ERROR":
                "Classic Integrity API error: custom error",
            "STANDARD_PLAY_INTEGRITY_ERROR":
                "Standard Integrity API error: custom error",
            "TOKEN_PROVIDER_NOT_INITIALISED":
                "Standard Integrity API error: custom error",
            "EMPTY_NONCE": "Nonce can't be empty",
            "EMPTY_CLOUD_PROJECT_NUMBER": "Cloud project number can't be empty",
          }..forEach((final String code, final String expected) {
            expect(
              () {
                // Must throw, not return
                throw instance.handlePlatformException(code, "custom error");
              },
              throwsA(
                predicate((final Object? e) => e.toString().contains(expected)),
              ),
            );
          });
      // Test unknown code separately
      expect(
        () {
          throw instance.handlePlatformException("UNKNOWN", "custom error");
        },
        throwsA(
          predicate(
            (final Object? e) => e.toString().contains("Something Went Wrong"),
          ),
        ),
      );
    });

    test("singleton keeps platform instance", () {
      final ApzPlayIntegrity instance1 = ApzPlayIntegrity(
        platform: MockAndroidPlatform(),
      );
      final ApzPlayIntegrity instance2 = ApzPlayIntegrity(
        platform: MockWebPlatform(),
      );
      expect(instance1, same(instance2));
      // Should keep the last set platform
      expect(instance2.platform, isA<MockWebPlatform>());
    });

    test("requestClassicIntegrityToken propagates generic Exception", () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (final MethodCall call) async {
            throw Exception("generic error");
          });
      await expectLater(
        ApzPlayIntegrity(
          platform: MockAndroidPlatform(),
        ).requestClassicIntegrityToken(
          nonce: "nonce",
          cloudProjectNumber: "1234567890",
        ),
        throwsA(
          predicate(
            (final Object? e) => e.toString().contains("Something Went Wrong"),
          ),
        ),
      );
    });

    test("throws Something Went Wrong for unknown error code", () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (final MethodCall call) async {
            throw PlatformException(code: "UNKNOWN", message: "custom error");
          });
      await expectLater(
        ApzPlayIntegrity(
          platform: MockAndroidPlatform(),
        ).requestClassicIntegrityToken(
          nonce: "nonce",
          cloudProjectNumber: "1234567890",
        ),
        throwsA(
          predicate(
            (final Object? e) => e.toString().contains("Something Went Wrong"),
          ),
        ),
      );
    });

    test(
      "requestStandardIntegrityToken throws Standard Integrity API error",
      () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (final MethodCall call) async {
              throw PlatformException(
                code: "STANDARD_PLAY_INTEGRITY_ERROR",
                message: "custom error",
              );
            });
        await expectLater(
          ApzPlayIntegrity(
            platform: MockAndroidPlatform(),
          ).requestStandardIntegrityToken(requestHash: "hash"),
          throwsA(
            predicate(
              (final Object? e) => e.toString().contains(
                "Standard Integrity API error: custom error",
              ),
            ),
          ),
        );
      },
    );

    test(
      "requestClassicIntegrityToken throws Classic Integrity API error",
      () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (final MethodCall call) async {
              throw PlatformException(
                code: "CLASSIC_PLAY_INTEGRITY_ERROR",
                message: "custom error",
              );
            });
        await expectLater(
          ApzPlayIntegrity(
            platform: MockAndroidPlatform(),
          ).requestClassicIntegrityToken(
            nonce: "nonce",
            cloudProjectNumber: "1234567890",
          ),
          throwsA(
            predicate(
              (final Object? e) => e.toString().contains(
                "Classic Integrity API error: custom error",
              ),
            ),
          ),
        );
      },
    );
  });
}
