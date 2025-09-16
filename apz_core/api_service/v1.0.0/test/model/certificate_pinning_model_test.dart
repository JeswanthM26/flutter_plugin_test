import "package:apz_api_service/model/certificate_pinning_model.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("CertificatePinningModel", () {
    test("should create instance with certificatePaths", () {
      final CertificatePinningModel model = CertificatePinningModel(
        type: CertificatePinningType.certificatePaths,
        certificatePaths: <String>["assets/cert1.pem", "assets/cert2.pem"],
      );

      expect(model.type, CertificatePinningType.certificatePaths);
      expect(model.certificatePaths, isNotNull);
      expect(model.certificatePaths, contains("assets/cert1.pem"));
      expect(model.trustedSpkiSha256Hashes, isNull);
    });

    test("should create instance with trustedSpkiSha256Hashes", () {
      final CertificatePinningModel model = CertificatePinningModel(
        type: CertificatePinningType.trustedSpkiSha256Hashes,
        trustedSpkiSha256Hashes: <String>["hash1", "hash2"],
      );

      expect(model.type, CertificatePinningType.trustedSpkiSha256Hashes);
      expect(model.trustedSpkiSha256Hashes, isNotNull);
      expect(model.trustedSpkiSha256Hashes, contains("hash1"));
      expect(model.certificatePaths, isNull);
    });

    test("should allow both lists to be null", () {
      final CertificatePinningModel model = CertificatePinningModel(
        type: CertificatePinningType.certificatePaths,
      );

      expect(model.certificatePaths, isNull);
      expect(model.trustedSpkiSha256Hashes, isNull);
    });
  });

  group("CertificatePinningType", () {
    test("should have correct enum values", () {
      expect(
        CertificatePinningType.certificatePaths.toString(),
        "CertificatePinningType.certificatePaths",
      );
      expect(
        CertificatePinningType.trustedSpkiSha256Hashes.toString(),
        "CertificatePinningType.trustedSpkiSha256Hashes",
      );
    });
  });
}
