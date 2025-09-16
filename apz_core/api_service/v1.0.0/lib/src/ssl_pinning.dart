import "dart:async";
import "dart:convert";
import "dart:io";
import "package:apz_utils/apz_utils.dart";
import "package:dio/dio.dart";
import "package:dio/io.dart";
import "package:flutter/services.dart";
import "package:pointycastle/export.dart";

/// A utility class for SSL pinning in Dio HTTP client.
class SslPinning {
  final APZLoggerProvider _logger = APZLoggerProvider();

  /// Configures SSL pinning using certificate paths.
  Future<void> sslPinningCertificates(
    final Dio dio,
    final List<String> certificatePaths,
  ) async {
    if (certificatePaths.isNotEmpty) {
      final SecurityContext securityContext = SecurityContext();

      try {
        for (final String certPath in certificatePaths) {
          final ByteData bytes = await rootBundle.load(certPath);
          securityContext.setTrustedCertificatesBytes(
            bytes.buffer.asUint8List(),
          );
        }
      } catch (e) {
        throw Exception(
          """Failed to load SSL certificates for pinning: $e. Halting Dio setup.""",
        );
      }

      if (dio.httpClientAdapter is IOHttpClientAdapter) {
        (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
          final HttpClient client = HttpClient(context: securityContext)
            ..badCertificateCallback =
                (
                  final X509Certificate cert,
                  final String host,
                  final int port,
                ) {
                  _logger.error(
                    """Bad certificate encountered for host $host:$port. Rejecting connection.""",
                  );
                  return false;
                };
          return client;
        };
        _logger.debug(
          "SSL Pinning enabled with certificates: "
          "${certificatePaths.join(", ")}",
        );
      }
    }
  }

  /// Configures SSL pinning using public key hashes (SPKI).
  void sslPinningPublicKeyHashes(
    final Dio dio,
    final List<String> trustedSpkiSha256Hashes,
  ) {
    final SecurityContext securityContext = SecurityContext();

    // 2. Configure Dio's HttpClientAdapter to use the custom validation.
    if (dio.httpClientAdapter is IOHttpClientAdapter) {
      (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final HttpClient client = HttpClient(context: securityContext)
          ..badCertificateCallback = getHashBadCertificateCallback(
            trustedSpkiSha256Hashes,
          );
        return client;
      };
      _logger.debug(
        """Dio configured with custom HttpClient for Public Key (SPKI) hash pinning""",
      );
    }
  }

  /// Returns a callback for validating certificates against SPKI hashes.
  bool Function(X509Certificate cert, String host, int port)
  getHashBadCertificateCallback(
    final List<String> trustedSpkiSha256Hashes,
  ) => (final X509Certificate cert, final String host, final int port) {
    if (trustedSpkiSha256Hashes.isEmpty) {
      _logger.debug(
        "No SPKI hashes provided for pinning. Rejecting certificate.",
      );
      return false;
    }

    try {
      final Uint8List derBytes = cert.der;
      if (derBytes.isEmpty) {
        _logger.debug("Received certificate DER bytes are empty. Rejecting.");
        return false;
      }

      // Extract SPKI using manual DER parsing
      final Uint8List? spkiBytes = extractSubjectPublicKeyInfo(derBytes);

      if (spkiBytes == null || spkiBytes.isEmpty) {
        _logger.debug("Could not extract SPKI from certificate. Rejecting.");
        return false;
      }

      // Compute the SHA-256 hash of the SPKI using PointyCastle
      final SHA256Digest digestAlgorithm = SHA256Digest();
      final Uint8List hashOutputBytes = digestAlgorithm.process(spkiBytes);
      final String receivedSpkiHashBase64 = base64Encode(hashOutputBytes);

      _logger.debug("Received SPKI Hash (Base64): $receivedSpkiHashBase64");

      for (final String trustedHash in trustedSpkiSha256Hashes) {
        if (constantTimeEquals(receivedSpkiHashBase64, trustedHash)) {
          _logger.debug(
            """Server public key matches trusted SPKI hash: $trustedHash. Accepting certificate.""",
          );
          return true;
        }
      }

      _logger.debug(
        """Server public key does not match any trusted SPKI hashes. Rejecting certificate.""",
      );
      return false;
    } on Exception catch (e, stackTrace) {
      _logger
        ..debug("Error during public key pinning validation: $e")
        ..debug("Stack trace: $stackTrace")
        ..debug("Certificate validation failed. Rejecting certificate.");
      return false;
    }
  };

  /// Extracts SubjectPublicKeyInfo from DER-encoded
  /// certificate using manual parsing.
  Uint8List? extractSubjectPublicKeyInfo(final Uint8List derBytes) {
    try {
      // Parse the top-level certificate SEQUENCE
      final DerObject? certificate = parseDerObject(derBytes, 0);
      if (certificate == null || certificate.tag != 0x30) {
        _logger.debug("Invalid certificate: not a SEQUENCE");
        return null;
      }

      // Parse the TBSCertificate (first element of certificate)
      final DerObject? tbsCertificate = parseDerObject(certificate.content, 0);
      if (tbsCertificate == null || tbsCertificate.tag != 0x30) {
        _logger.debug("Invalid TBSCertificate: not a SEQUENCE");
        return null;
      }

      // Find the SubjectPublicKeyInfo within TBSCertificate
      return findSubjectPublicKeyInfoInTbs(tbsCertificate.content);
    } on Exception catch (e) {
      _logger.debug("Error parsing DER certificate: $e");
      return null;
    }
  }

  /// Finds and extracts the SubjectPublicKeyInfo from TBSCertificate content.
  Uint8List? findSubjectPublicKeyInfoInTbs(final Uint8List tbsContent) {
    int offset = 0;
    int fieldIndex = 0;

    while (offset < tbsContent.length) {
      final DerObject? obj = parseDerObject(tbsContent, offset);
      if (obj == null) {
        break;
      }

      // Check if this could be SubjectPublicKeyInfo
      // SPKI is a SEQUENCE containing AlgorithmIdentifier and BIT STRING
      if (obj.tag == 0x30 && isLikelySubjectPublicKeyInfo(obj.content)) {
        _logger.debug(
          "Found potential SubjectPublicKeyInfo at field index $fieldIndex",
        );

        // Return the complete SPKI (tag + length + content)
        final int spkiLength = obj.totalLength;
        return tbsContent.sublist(offset, offset + spkiLength);
      }

      offset += obj.totalLength;
      fieldIndex++;

      // Stop searching after reasonable number of fields
      if (fieldIndex > 10) {
        break;
      }
    }

    _logger.debug("SubjectPublicKeyInfo not found in TBSCertificate");
    return null;
  }

  /// Checks if the content looks like SubjectPublicKeyInfo structure.
  bool isLikelySubjectPublicKeyInfo(final Uint8List content) {
    int offset = 0;

    // First element should be AlgorithmIdentifier (SEQUENCE)
    final DerObject? algorithm = parseDerObject(content, offset);
    if (algorithm == null || algorithm.tag != 0x30) {
      return false;
    }
    offset += algorithm.totalLength;

    // Second element should be subjectPublicKey (BIT STRING)
    final DerObject? publicKey = parseDerObject(content, offset);
    if (publicKey == null || publicKey.tag != 0x03) {
      return false;
    }

    return true;
  }

  /// Parses a DER object at the given offset.
  DerObject? parseDerObject(final Uint8List data, final int offset) {
    if (offset >= data.length) {
      return null;
    }

    try {
      // Return null if data is too short
      if (data.length < 2) {
        return null;
      }

      // Read tag
      final int tag = data[offset];
      int pos = offset + 1;

      // Check if we have enough data for length
      if (pos >= data.length) {
        return null;
      }

      // Read length
      int length;
      if (data[pos] & 0x80 == 0) {
        // Short form
        length = data[pos];
        pos++;
      } else {
        // Long form
        final int lengthOfLength = data[pos] & 0x7F;
        if (lengthOfLength == 0 || lengthOfLength > 4) {
          return null; // Invalid or too long
        }
        pos++;

        // Check if we have enough bytes for the length
        if (pos + lengthOfLength > data.length) {
          return null;
        }

        length = 0;
        for (int i = 0; i < lengthOfLength; i++) {
          length = (length << 8) | data[pos];
          pos++;
        }
      }

      // Check if we have enough data for the content
      if (pos + length > data.length) {
        return null;
      }

      final Uint8List content = data.sublist(pos, pos + length);
      final int totalLength = pos + length - offset;

      return DerObject(tag, content, totalLength);
    } on Exception catch (_) {
      return null;
    }
  }

  /// Performs constant-time string comparison to prevent timing attacks.
  bool constantTimeEquals(final String a, final String b) {
    if (a.length != b.length) {
      return false;
    }

    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }

    return result == 0;
  }
}

/// Simple DER object representation.
class DerObject {
  /// Including tag and length bytes
  DerObject(this.tag, this.content, this.totalLength);

  /// tag of the DER object.
  final int tag;

  /// content bytes of the DER object.
  final Uint8List content;

  /// total length including tag and length bytes.
  final int totalLength;
}
