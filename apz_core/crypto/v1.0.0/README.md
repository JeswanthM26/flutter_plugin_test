# APZ Crypto Dart Library

A Dart library for symmetric and asymmetric cryptography, hashing, digital signatures and secure random byte generation. Built on top of PointyCastle, this library provides a simple API for secure encryption, decryption, hashing and random byte/string generation in your Flutter or Dart projects.

## Features

- AES-GCM symmetric encryption/decryption
- RSA-OAEP asymmetric encryption/decryption
- Digital signature generation and verification (RSA/SHA-256)
- SHA-256, SHA-384, SHA-512 hashing with or without salt.
- Secure random byte generation
- Secure random alphanumeric string generation

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  apz_crypto:
    git:
      url: http://prodgit.i-exceed.com:8009/appzillon-neu/core.git
      ref: develop
      path: apz_core/crypto/v1.0.0
```

## Importing

```dart
import 'package:apz_crypto/apz_crypto.dart';
```

## Usage

### Singleton Access

```dart
final crypto = ApzCrypto();
```

### Symmetric Encryption/Decryption (AES-GCM)

```dart
final text = "Hello World";
final key = base64Encode(crypto.generateRandomBytes(length: 32));
final iv = base64Encode(crypto.generateRandomBytes(length: 12));

final encrypted = crypto.symmetricEncrypt(
  textToEncrypt: text,
  key: key,
  iv: iv,
);
// encrypted is String with base64

final decrypted = crypto.symmetricDecrypt(
  cipherText: encrypted,
  key: key,
  iv: iv,
);
// decrypted is String
```

### Asymmetric Encryption/Decryption (RSA-OAEP)

```dart
final text = "Hello World";
final encrypted = await crypto.asymmetricEncrypt(
  publicKeyPath: 'assets/public.pem',
  textToEncrypt: text,
);
// encrypted is base64 String

final decrypted = await crypto.asymmetricDecrypt(
  privateKeyPath: 'assets/private.pem',
  encryptedData: encrypted,
);
// decrypted is String
```

### Digital Signature

```dart
final text = "Hello World";
final signature = await crypto.generateSignature(
  privateKeyPath: 'assets/private.pem',
  textToSign: text,
);
// signature is base64 String

final isValid = await crypto.verifySignature(
  publicKeyPath: 'assets/public.pem',
  originalText: text,
  signature: signature,
);
// isValid is bool
```

### Hashing

```dart
final text = "Hello World";
final hash = crypto.generateHashDigest(
  textToHash: text,
  type: HashType.sha256,
);
// hash is base64 String

final salt = base64Encode(crypto.generateRandomBytes(length: 16));
final hashWithSalt = crypto.generateHashDigestWithSalt(
  textToHash: text,
  salt: salt,
  type: HashType.sha256,
  iterationCount: 1000,
  outputKeyLength: 32,
);
// hashWithSalt is base64 String
```

### Generate Secure Random Bytes

```dart
final random = crypto.generateRandomBytes(length: 32);
```

### Generate Secure Random Alphanumeric String

Generate a cryptographically secure random string containing only
alphanumeric characters (a-zA-Z0-9). Useful for non-sensitive
identifiers, temporary tokens, or test data.

```dart
final token = crypto.generateRandomAlphanumeric(length: 24);
// token is a String containing 24 alphanumeric characters
```

## Constants

Access cryptographic constants:

```dart
Constants.symtKeyLength;
Constants.symtIVLength;
Constants.symtTagLength;
Constants.symtAlgo;
Constants.asymtAlgo;
Constants.asymtHash;
Constants.asymtSigner;
```

If you generate keys using OpenSSL, use:

- For private key: `openssl genpkey -algorithm RSA -out rsa_2048_private.pem -pkeyopt rsa_keygen_bits:2048`
- For public key: `openssl rsa -pubout -in rsa_2048_private.pem -out rsa_2048_public.pem`

> **Note:** Only PEM-encoded keys are supported. DER or other formats are not supported directly.

## Notes

- Always import only `apz_crypto.dart` in your project.
- Do not import part files directly.
- All cryptographic operations throw exceptions on invalid input.

## Jira Link

- https://appzillon.atlassian.net/browse/AN-165
