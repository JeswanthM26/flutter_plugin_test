import "dart:convert";
import "dart:math";
import "package:apz_crypto/utils/constants.dart";
import "package:apz_crypto/utils/hash_type.dart";
import "package:asn1lib/asn1lib.dart" as asn1lib;
import "package:flutter/services.dart";
import "package:pointycastle/export.dart";

export "utils/constants.dart";
export "utils/hash_type.dart";

part "src/asymmetric.dart";
part "src/hashing.dart";
part "src/symmetric.dart";

/// The main class for APZ Crypto operations.
/// Singleton class for APZ Crypto operations.
/// Provides methods for symmetric and asymmetric encryption/decryption,
/// signature generation/verification and random byte generation.
class ApzCrypto {
  /// Returns the singleton instance of [ApzCrypto].
  factory ApzCrypto() => _instance;
  // Private constructor
  ApzCrypto._internal();

  static final ApzCrypto _instance = ApzCrypto._internal();

  /// Encrypts the given text using symmetric encryption.
  /// Parameters:
  /// - [textToEncrypt]: The text to encrypt.
  /// - [key]: The base64 encoded symmetric key.
  /// - [iv]: The base64 encoded initialization vector (IV).
  /// Returns a cipher text base64 encoded.
  /// Throws an exception if the input data is invalid.
  /// Throws:
  /// - Exception if the text to encrypt is empty.
  /// - Exception if the key length is not equal to [Constants.symtKeyLength].
  /// - Exception if the IV length is not equal to [Constants.symtIVLength].
  String symmetricEncrypt({
    required final String textToEncrypt,
    required final String key,
    required final String iv,
  }) {
    try {
      final Uint8List dataToEncrypt = utf8.encode(textToEncrypt);
      final Uint8List keyBytes = base64Decode(key);
      final Uint8List ivBytes = base64Decode(iv);

      if (dataToEncrypt.isEmpty) {
        throw Exception("Text to encrypt should not be empty");
      } else if (keyBytes.length != Constants.symtKeyLength) {
        throw Exception("Key length should be ${Constants.symtKeyLength}");
      } else if (ivBytes.length != Constants.symtIVLength) {
        throw Exception("IV length should be ${Constants.symtIVLength}");
      }

      final Uint8List cipherData = _Symmetric().encrypt(
        textBytes: dataToEncrypt,
        symtKey: keyBytes,
        symtIV: ivBytes,
      );
      return base64Encode(cipherData);
    } on Exception catch (_) {
      rethrow;
    }
  }

  /// Decrypts the given encrypted data using symmetric decryption.
  /// Parameters:
  /// - [cipherText]: The base64 encoded cipher text.
  /// - [key]: The base64 encoded symmetric key.
  /// - [iv]: The base64 encoded initialization vector (IV).
  /// Returns the decrypted text as a string.
  /// Throws an exception if the input data is invalid.
  /// Throws:
  /// - Exception if the cipher text is empty.
  /// - Exception if the key length is not equal to [Constants.symtKeyLength].
  /// - Exception if the IV length is not equal to [Constants.symtIVLength].
  String symmetricDecrypt({
    required final String cipherText,
    required final String key,
    required final String iv,
  }) {
    try {
      final Uint8List cipherData = base64Decode(cipherText);
      final Uint8List keyBytes = base64Decode(key);
      final Uint8List ivBytes = base64Decode(iv);

      if (cipherData.isEmpty) {
        throw Exception("Cipher Text should not be empty");
      } else if (keyBytes.length != Constants.symtKeyLength) {
        throw Exception("Key length should be ${Constants.symtKeyLength}");
      } else if (ivBytes.length != Constants.symtIVLength) {
        throw Exception("IV length should be ${Constants.symtIVLength}");
      }

      final Uint8List decryptedData = _Symmetric().decrypt(
        cipherData: cipherData,
        symtKey: keyBytes,
        symtIV: ivBytes,
      );
      return utf8.decode(decryptedData);
    } on Exception catch (_) {
      rethrow;
    }
  }

  /// Encrypts the given data using asymmetric encryption
  /// with the public key.
  /// Parameters:
  /// - [publicKeyPath]: The path to the public key file in PEM format.
  /// - [textToEncrypt]: The text to encrypt.
  /// Returns the encrypted data as a base64 encoded string.
  /// Throws an exception if the input data is invalid.
  /// Throws:
  /// - Exception if the public key path is empty.
  /// - Exception if the text to encrypt is empty.
  /// - Exception if the public key is not properly formatted.
  /// - Exception if the encryption fails.
  Future<String> asymmetricEncrypt({
    required final String publicKeyPath,
    required final String textToEncrypt,
  }) async {
    try {
      final Uint8List dataToEncrypt = utf8.encode(textToEncrypt);

      if (publicKeyPath.isEmpty) {
        throw Exception("Public key path should not be empty");
      } else if (dataToEncrypt.isEmpty) {
        throw Exception("Text to encrypt should not be empty");
      } else {
        final Uint8List encryptedData = await _Asymmetric().encrypt(
          publicKeyPath: publicKeyPath,
          dataToEncrypt: dataToEncrypt,
        );
        return base64Encode(encryptedData);
      }
    } on Exception catch (_) {
      rethrow;
    }
  }

  /// Decrypts the given encrypted data using asymmetric decryption
  /// with the private key.
  /// Parameters:
  /// - [privateKeyPath]: The path to the private key file in PEM format.
  /// - [encryptedData]: The base64 encoded encrypted data.
  /// Returns the decrypted text as a string.
  /// Throws an exception if the input data is invalid.
  /// Throws:
  /// - Exception if the private key path is empty.
  /// - Exception if the encrypted data is empty.
  /// - Exception if the private key is not properly formatted.
  Future<String> asymmetricDecrypt({
    required final String privateKeyPath,
    required final String encryptedData,
  }) async {
    try {
      final Uint8List encryptedDataBytes = base64Decode(encryptedData);

      if (privateKeyPath.isEmpty) {
        throw Exception("Private key path should not be empty");
      } else if (encryptedDataBytes.isEmpty) {
        throw Exception("Encrypted data should not be empty");
      } else {
        final Uint8List decryptedData = await _Asymmetric().decrypt(
          privateKeyPath: privateKeyPath,
          encryptedData: encryptedDataBytes,
        );
        return utf8.decode(decryptedData);
      }
    } on Exception catch (_) {
      rethrow;
    }
  }

  /// Generates a digital signature for the given data using the private key.
  /// Parameters:
  /// - [privateKeyPath]: The path to the private key file in PEM format.
  /// - [textToSign]: The text to sign.
  /// Returns the signature as a base64 encoded string.
  /// Throws an exception if the input data is invalid.
  /// Throws:
  /// - Exception if the private key path is empty.
  /// - Exception if the text to sign is empty.
  /// - Exception if the private key is not properly formatted.
  Future<String> generateSignature({
    required final String privateKeyPath,
    required final String textToSign,
  }) async {
    try {
      final Uint8List dataToSign = utf8.encode(textToSign);

      if (privateKeyPath.isEmpty) {
        throw Exception("Private key path should not be empty");
      } else if (dataToSign.isEmpty) {
        throw Exception("Text to sign should not be empty");
      } else {
        final Uint8List signedData = await _Asymmetric().sign(
          privateKeyPath: privateKeyPath,
          dataToSign: dataToSign,
        );
        return base64Encode(signedData);
      }
    } on Exception catch (_) {
      rethrow;
    }
  }

  /// Verifies the digital signature for the given data using the public key.
  /// Parameters:
  /// - [publicKeyPath]: The path to the public key file in PEM format.
  /// - [originalText]: The original text that was signed.
  /// - [signature]: The base64 encoded signature to verify.
  /// Returns true if the signature is valid, false otherwise.
  /// Throws an exception if the input data is invalid.
  /// Throws:
  /// - Exception if the public key path is empty.
  /// - Exception if the original text is empty.
  /// - Exception if the signature is empty.
  Future<bool> verifySignature({
    required final String publicKeyPath,
    required final String originalText,
    required final String signature,
  }) async {
    try {
      final Uint8List originalTextBytes = utf8.encode(originalText);
      final Uint8List signatureBytes = base64Decode(signature);

      if (publicKeyPath.isEmpty) {
        throw Exception("Public key path should not be empty");
      } else if (originalTextBytes.isEmpty) {
        throw Exception("Original text should not be empty");
      } else if (signatureBytes.isEmpty) {
        throw Exception("Signature should not be empty");
      } else {
        final bool matched = await _Asymmetric().verify(
          publicKeyPath: publicKeyPath,
          originalData: originalTextBytes,
          signedData: signatureBytes,
        );
        return matched;
      }
    } on Exception catch (_) {
      rethrow;
    }
  }

  /// Generates a hash digest for the given data using the specified hash type.
  /// Parameters:
  /// - [textToHash]: The text to hash.
  /// - [type]: The type of hash to generate (SHA-256, SHA-384, SHA-512).
  /// Returns the hash digest as a base64 encoded string.
  /// Throws an exception if the input data is invalid.
  /// Throws:
  /// - Exception if the text to hash is empty.
  String generateHashDigest({
    required final String textToHash,
    required final HashType type,
  }) {
    final Uint8List dataToHash = utf8.encode(textToHash);

    if (dataToHash.isEmpty) {
      throw Exception("Text to hash should not be empty");
    } else {
      final Uint8List hashDigest = _Hashing().generate(
        data: dataToHash,
        type: type,
      );
      return base64Encode(hashDigest);
    }
  }

  /// Generates a hash digest with salt for the given data
  /// using the specified hash type.
  /// Parameters:
  /// - [textToHash]: The text to hash.
  /// - [salt]: The base64 encoded salt.
  /// - [type]: The type of hash to generate (SHA-256, SHA-384, SHA-512).
  /// - [iterationCount]: The number of iterations for the
  /// key derivation function.
  /// - [outputKeyLength]: The desired length of the output key in bytes.
  /// Returns the hash digest as a base64 encoded string.
  /// Throws an exception if the input data is invalid.
  /// Throws:
  /// - Exception if the text to hash is empty.
  /// - Exception if the salt is empty.
  /// - Exception if the iteration count is less than or equal to 0.
  /// - Exception if the output key length is less than or equal to 0.
  String generateHashDigestWithSalt({
    required final String textToHash,
    required final String salt,
    required final HashType type,
    required final int iterationCount,
    required final int outputKeyLength,
  }) {
    final Uint8List dataToHash = utf8.encode(textToHash);
    final Uint8List saltBytes = base64Decode(salt);

    if (dataToHash.isEmpty) {
      throw Exception("Text to hash should not be empty");
    } else if (saltBytes.isEmpty) {
      throw Exception("Salt should not be empty");
    } else if (iterationCount <= 0) {
      throw Exception("Iteration count should be greater than 0");
    } else if (outputKeyLength <= 0) {
      throw Exception("Output key length should be greater than 0");
    } else {
      final Uint8List hashDigest = _Hashing().generateHashWithSalt(
        data: dataToHash,
        salt: saltBytes,
        type: type,
        iterationCount: iterationCount,
        outputKeyLength: outputKeyLength,
      );
      return base64Encode(hashDigest);
    }
  }

  /// Generates a random byte array of the specified length.
  /// Parameters:
  /// - [length]: The length of the byte array to generate.
  /// Returns a [Uint8List] containing random bytes.
  Uint8List generateRandomBytes({required final int length}) {
    final Random rand = Random.secure();
    final Uint8List bytes = Uint8List(length);
    for (int index = 0; index < length; index++) {
      bytes[index] = rand.nextInt(256);
    }
    return bytes;
  }

  /// Generates a random alphanumeric string of the specified length.
  /// Parameters:
  /// - [length]: The length of the string to generate.
  /// Returns a random alphanumeric string.
  String generateRandomAlphanumeric({required final int length}) {
    const String chars =
        "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    final Random rnd = Random.secure();

    return String.fromCharCodes(
      Iterable<int>.generate(
        length,
        (_) => chars.codeUnitAt(rnd.nextInt(chars.length)),
      ),
    );
  }
}
