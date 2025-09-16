/// Certifivcate pinning types.
enum CertificatePinningType {
  /// Pinning using certificate paths.
  certificatePaths,

  /// Pinning using trusted SPKI SHA-256 hashes.
  trustedSpkiSha256Hashes,
}

/// Model for certificate pinning configuration.
class CertificatePinningModel {
  /// Creates a [CertificatePinningModel] instance.
  CertificatePinningModel({
    required this.type,
    this.certificatePaths,
    this.trustedSpkiSha256Hashes,
  });

  /// The type of certificate pinning to use.
  final CertificatePinningType type;

  /// Optional list of certificate paths for pinning.
  final List<String>? certificatePaths;

  /// Optional list of trusted SPKI SHA-256 hashes for pinning.
  final List<String>? trustedSpkiSha256Hashes;
}
