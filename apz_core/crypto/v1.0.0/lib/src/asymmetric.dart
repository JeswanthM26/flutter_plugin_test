part of "../apz_crypto.dart";

class _Asymmetric {
  static final Map<String, RSAPublicKey> _publicKeyCache =
      <String, RSAPublicKey>{};
  static final Map<String, RSAPrivateKey> _privateKeyCache =
      <String, RSAPrivateKey>{};

  Future<Uint8List> encrypt({
    required final String publicKeyPath,
    required final Uint8List dataToEncrypt,
  }) async {
    try {
      final RSAPublicKey rsaPublicKey = await _getPublicKey(publicKeyPath);
      final AsymmetricBlockCipher cipher = AsymmetricBlockCipher(
        Constants.asymtAlgo,
      )..init(true, PublicKeyParameter<RSAPublicKey>(rsaPublicKey));
      final OAEPEncoding oaepEncoding = cipher as OAEPEncoding
        ..hash = Digest(Constants.asymtHash);
      final Uint8List encryptedBytes = oaepEncoding.process(dataToEncrypt);
      return encryptedBytes;
    } on Exception catch (_) {
      rethrow;
    }
  }

  Future<Uint8List> decrypt({
    required final String privateKeyPath,
    required final Uint8List encryptedData,
  }) async {
    try {
      final RSAPrivateKey rsaPrivateKey = await _getPrivateKey(privateKeyPath);
      final AsymmetricBlockCipher cipher = AsymmetricBlockCipher(
        Constants.asymtAlgo,
      )..init(false, PrivateKeyParameter<RSAPrivateKey>(rsaPrivateKey));
      final OAEPEncoding oaepEncoding = cipher as OAEPEncoding
        ..hash = Digest(Constants.asymtHash);
      final Uint8List decryptedBytes = oaepEncoding.process(encryptedData);
      return decryptedBytes;
    } on Exception catch (_) {
      rethrow;
    }
  }

  Future<Uint8List> sign({
    required final String privateKeyPath,
    required final Uint8List dataToSign,
  }) async {
    try {
      final RSAPrivateKey rsaPrivateKey = await _getPrivateKey(privateKeyPath);
      final Signer signer = Signer(Constants.asymtSigner)
        ..init(true, PrivateKeyParameter<RSAPrivateKey>(rsaPrivateKey));
      final RSASignature signature =
          signer.generateSignature(dataToSign) as RSASignature;
      return signature.bytes;
    } on Exception catch (_) {
      rethrow;
    }
  }

  Future<bool> verify({
    required final String publicKeyPath,
    required final Uint8List originalData,
    required final Uint8List signedData,
  }) async {
    try {
      final RSAPublicKey rsaPublicKey = await _getPublicKey(publicKeyPath);
      final Signer verifier = Signer(Constants.asymtSigner)
        ..init(false, PublicKeyParameter<RSAPublicKey>(rsaPublicKey));
      final RSASignature sig = RSASignature(signedData);
      return verifier.verifySignature(originalData, sig);
    } on Exception catch (_) {
      rethrow;
    }
  }

  Future<RSAPublicKey> _getPublicKey(final String publicKeyPath) async {
    try {
      RSAPublicKey? rsaPublicKey;
      if (_publicKeyCache.containsKey(publicKeyPath)) {
        rsaPublicKey = _publicKeyCache[publicKeyPath];
      } else {
        rsaPublicKey = await _parsePublicKeyFromPem(publicKeyPath);
      }

      if (rsaPublicKey == null) {
        throw Exception("Public key is not proper");
      } else {
        _publicKeyCache[publicKeyPath] = rsaPublicKey;
        return rsaPublicKey;
      }
    } on Exception catch (_) {
      rethrow;
    }
  }

  Future<RSAPrivateKey> _getPrivateKey(final String privateKeyPath) async {
    try {
      RSAPrivateKey? rsaPrivateKey;
      if (_privateKeyCache.containsKey(privateKeyPath)) {
        rsaPrivateKey = _privateKeyCache[privateKeyPath];
      } else {
        rsaPrivateKey = await _parsePrivateKeyFromPem(privateKeyPath);
      }

      if (rsaPrivateKey == null) {
        throw Exception("Private key is not proper");
      } else {
        _privateKeyCache[privateKeyPath] = rsaPrivateKey;
        return rsaPrivateKey;
      }
    } on Exception catch (_) {
      rethrow;
    }
  }

  Future<RSAPublicKey?> _parsePublicKeyFromPem(
    final String publicKeyPath,
  ) async {
    final ByteData publicKeyData = await rootBundle.load(publicKeyPath);
    final Uint8List publicKeyBytes = publicKeyData.buffer.asUint8List();
    final String pemString = utf8.decode(publicKeyBytes);

    // Convert PEM to DER by removing header/footer and base64 decoding
    final List<String> lines = pemString.split("\n");
    final List<String> base64Lines = lines
        .where(
          (final String line) =>
              !line.startsWith("-----BEGIN") && !line.startsWith("-----END"),
        )
        .toList();
    final String base64Str = base64Lines.join();
    final Uint8List derBytes = base64.decode(base64Str);

    // Parse ASN.1 structure for PKCS#8 format (SubjectPublicKeyInfo)
    final asn1lib.ASN1Parser parser = asn1lib.ASN1Parser(derBytes);
    final asn1lib.ASN1Object topLevel = parser.nextObject();

    final asn1lib.ASN1Sequence topLevelSeq = topLevel as asn1lib.ASN1Sequence;

    // Get the bit string that contains the actual public key
    final asn1lib.ASN1BitString publicKeyBitString =
        topLevelSeq.elements[1] as asn1lib.ASN1BitString;

    final Uint8List valueBytes = publicKeyBitString.valueBytes();

    // Skip first byte which is the number of unused bits
    final asn1lib.ASN1Parser publicKeyParser = asn1lib.ASN1Parser(
      valueBytes.sublist(1),
    );

    final asn1lib.ASN1Object pkObject = publicKeyParser.nextObject();

    final asn1lib.ASN1Sequence publicKeySeq = pkObject as asn1lib.ASN1Sequence;

    final asn1lib.ASN1Integer rsaModulus =
        publicKeySeq.elements[0] as asn1lib.ASN1Integer;
    final asn1lib.ASN1Integer rsaExponent =
        publicKeySeq.elements[1] as asn1lib.ASN1Integer;

    return RSAPublicKey(
      rsaModulus.valueAsBigInteger,
      rsaExponent.valueAsBigInteger,
    );
  }

  Future<RSAPrivateKey> _parsePrivateKeyFromPem(
    final String privateKeyPath,
  ) async {
    final ByteData privateKeyData = await rootBundle.load(privateKeyPath);
    final Uint8List privateKeyBytes = privateKeyData.buffer.asUint8List();
    final String pemString = utf8.decode(privateKeyBytes);
    // Convert PEM to DER by removing header/footer and base64 decoding
    final List<String> lines = pemString.split("\n");
    final List<String> base64Lines = lines
        .where(
          (final String line) =>
              !line.startsWith("-----BEGIN") && !line.startsWith("-----END"),
        )
        .toList();
    final String base64Str = base64Lines.join();
    final Uint8List derBytes = base64.decode(base64Str);

    // Parse ASN.1 structure
    final asn1lib.ASN1Parser parser = asn1lib.ASN1Parser(derBytes);
    final asn1lib.ASN1Sequence topLevelSeq =
        parser.nextObject() as asn1lib.ASN1Sequence;
    asn1lib.ASN1Sequence privateKeySeq;
    if (topLevelSeq.elements.length == 3) {
      // PKCS#8 format
      final asn1lib.ASN1OctetString octetString =
          topLevelSeq.elements[2] as asn1lib.ASN1OctetString;
      final asn1lib.ASN1Parser pkParser = asn1lib.ASN1Parser(
        octetString.valueBytes(),
      );
      privateKeySeq = pkParser.nextObject() as asn1lib.ASN1Sequence;
    } else {
      // PKCS#1 format
      privateKeySeq = topLevelSeq;
    }

    final asn1lib.ASN1Integer modulus =
        privateKeySeq.elements[1] as asn1lib.ASN1Integer;
    final asn1lib.ASN1Integer privateExponent =
        privateKeySeq.elements[3] as asn1lib.ASN1Integer;
    final asn1lib.ASN1Integer p =
        privateKeySeq.elements[4] as asn1lib.ASN1Integer;
    final asn1lib.ASN1Integer q =
        privateKeySeq.elements[5] as asn1lib.ASN1Integer;
    return RSAPrivateKey(
      modulus.valueAsBigInteger,
      privateExponent.valueAsBigInteger,
      p.valueAsBigInteger,
      q.valueAsBigInteger,
    );
  }
}
