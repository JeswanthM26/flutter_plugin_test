part of "../apz_crypto.dart";

class _Hashing {
  Uint8List generate({
    required final Uint8List data,
    required final HashType type,
  }) {
    final Digest digest = _getDigest(type);
    return digest.process(data);
  }

  Uint8List generateHashWithSalt({
    required final Uint8List data,
    required final Uint8List salt,
    required final HashType type,
    required final int iterationCount,
    required final int outputKeyLength,
  }) {
    final Digest digest = _getDigest(type);
    final int blockSize;

    switch (type) {
      case HashType.sha256:
        blockSize = 64;
      case HashType.sha384:
      case HashType.sha512:
        blockSize = 128;
    }

    final PBKDF2KeyDerivator derivator = PBKDF2KeyDerivator(
      HMac(digest, blockSize),
    );
    final Pbkdf2Parameters params = Pbkdf2Parameters(
      salt,
      iterationCount,
      outputKeyLength,
    );
    derivator.init(params);

    final Uint8List hashedKey = derivator.process(data);
    return hashedKey;
  }

  Digest _getDigest(final HashType type) {
    Digest digest;
    switch (type) {
      case HashType.sha256:
        digest = Digest("SHA-256");
      case HashType.sha384:
        digest = Digest("SHA-384");
      case HashType.sha512:
        digest = Digest("SHA-512");
    }

    return digest;
  }
}
