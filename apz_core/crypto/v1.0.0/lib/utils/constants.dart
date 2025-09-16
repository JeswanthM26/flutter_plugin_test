/// Constants used across the APZ Crypto library.
class Constants {
  /// Symmetric encryption/decryption key length
  static const int symtKeyLength = 32;

  /// Symmetric encryption/decryption IV length
  static const int symtIVLength = 12;

  /// Symmetric encryption/decryption algorithm
  static const String symtAlgo = "AES/GCM";

  /// Asymmetric encryption/decryption algorithm
  static const String asymtAlgo = "RSA/OAEP";

  /// Asymmetric encryption/decryption hash algorithm
  static const String asymtHash = "SHA-512";

  /// Asymmetric signer algorithm
  static const String asymtSigner = "SHA-256/RSA";
}
