import "dart:convert";
import "dart:typed_data";
import "package:apz_api_service/src/dio_client.dart";
import "package:apz_api_service/utils/constants.dart" as api_service_constants;
import "package:apz_api_service/utils/print_utils.dart";
import "package:apz_crypto/apz_crypto.dart" as crypto;
import "package:dio/dio.dart";

/// A utility class for encrypting and decrypting request and response data.
/// This class uses symmetric and asymmetric encryption methods to ensure secure
/// communication between the client and server.
class EncryptionDecryption {
  /// Constructor for [EncryptionDecryption].
  /// Requires instances of [PrintUtils], [DioClient], [crypto.ApzCrypto],
  /// and paths for the public and private keys.
  /// These dependencies are injected to facilitate testing and modularity.
  /// - [printUtils]: An instance of [PrintUtils] for logging.
  /// - [dioClient]: An instance of [DioClient] for managing HTTP requests.
  /// - [apzCrypto]: An instance of [crypto.ApzCrypto] for
  ///   cryptographic operations.
  /// - [publicKeyPath]: The file path to the public key used for
  ///    asymmetric encryption.
  /// - [privateKeyPath]: The file path to the private key used for
  ///    asymmetric decryption.
  EncryptionDecryption({
    required final PrintUtils printUtils,
    required final DioClient dioClient,
    required final crypto.ApzCrypto apzCrypto,
    required final String publicKeyPath,
    required final String privateKeyPath,
  }) : _dioClient = dioClient,
       _apzCrypto = apzCrypto,
       _publicKeyPath = publicKeyPath,
       _privateKeyPath = privateKeyPath,
       _printUtils = printUtils;

  final DioClient _dioClient;
  final crypto.ApzCrypto _apzCrypto;
  final String _publicKeyPath;
  final String _privateKeyPath;
  final PrintUtils _printUtils;

  static Uint8List _symmetricKeyPass = Uint8List(0);

  /// Encrypts the request data if the HTTP method is POST, PUT, or PATCH.
  /// The data is encrypted using a symmetric key derived from a passphrase.
  /// If the symmetric key passphrase is not set, a new random passphrase is
  /// generated and encrypted using asymmetric encryption with the provided
  /// public key.
  /// The encrypted data, along with the salt, IV, and algorithm information,
  /// is then set as the request body.
  Future<RequestOptions> encryptRequest(final RequestOptions options) async {
    if (options.data != null &&
        options.data is Map &&
        (options.method == "POST" ||
            options.method == "PUT" ||
            options.method == "PATCH")) {
      try {
        final Uint8List saltBytes = _apzCrypto.generateRandomBytes(
          length: api_service_constants.Constants.saltLength,
        );

        Uint8List tempSymmetricKeyPassBytes = _symmetricKeyPass;
        if (tempSymmetricKeyPassBytes.isEmpty) {
          tempSymmetricKeyPassBytes = _apzCrypto.generateRandomBytes(
            length: api_service_constants.Constants.symmetricKeyLength,
          );
        }

        final String hashedSymmetricKey = _apzCrypto.generateHashDigestWithSalt(
          textToHash: utf8.decode(tempSymmetricKeyPassBytes),
          salt: utf8.decode(saltBytes),
          type: api_service_constants.Constants.symmetricKeyHashingType,
          iterationCount:
              api_service_constants.Constants.symmetricKeyHashingIterationCount,
          outputKeyLength:
              api_service_constants.Constants.hashedSymmetricKeyOutputLength,
        );
        final Uint8List hashedSymmetricKeyBytes = base64Decode(
          hashedSymmetricKey,
        );

        final Uint8List ivBytes = _apzCrypto.generateRandomBytes(
          length: api_service_constants.Constants.ivLength,
        );

        final String payloadToEncrypt = json.encode(options.data);

        final String cipherText = _apzCrypto.symmetricEncrypt(
          textToEncrypt: payloadToEncrypt,
          key: base64Encode(hashedSymmetricKeyBytes),
          iv: base64Encode(ivBytes),
        );
        final Uint8List cipherBytes = base64Decode(cipherText);

        final Uint8List bodyBytes = Uint8List.fromList(<int>[
          ...saltBytes,
          ...ivBytes,
          ...cipherBytes,
        ]);

        final Map<String, String> finalPayload = <String, String>{
          "body": base64Encode(bodyBytes),
          "algo": api_service_constants.Constants.algo,
        };

        if (_symmetricKeyPass.isEmpty) {
          final String encryptedKey = await _apzCrypto.asymmetricEncrypt(
            publicKeyPath: _publicKeyPath,
            textToEncrypt: utf8.decode(tempSymmetricKeyPassBytes),
          );
          finalPayload["safeToken"] = encryptedKey;
        }

        options.data = finalPayload;
        _printUtils.printCompleteStringUsingDebugPrint(
          "Request data encrypted successfully: ${options.data}",
        );
      } on Exception catch (error) {
        throw DioException(
          requestOptions: options,
          error: "Failed to encrypt request data: $error",
        );
      }
    }

    return options;
  }

  /// Decrypts the response data if it contains encrypted fields and the HTTP
  /// method is POST, PUT, or PATCH.
  /// The method checks for the presence of a `safeToken` to retrieve the
  /// symmetric key used for decryption. If the `safeToken` is present, it is
  /// decrypted using asymmetric decryption with the provided private key.
  /// The response body or error field is then decrypted using the symmetric key
  /// and the original salt and IV.
  Future<Response<dynamic>> decryptResponse(
    final Response<dynamic> response,
  ) async {
    if (response.data != null &&
        response.data is Map &&
        (response.requestOptions.method == "POST" ||
            response.requestOptions.method == "PUT" ||
            response.requestOptions.method == "PATCH")) {
      try {
        final Map<String, dynamic> responseData = response.data;

        if (responseData.containsKey("APZ_TOKEN")) {
          _dioClient.setToken(responseData["APZ_TOKEN"]);
        }

        Uint8List symmetricKeyBytes = _symmetricKeyPass;

        final String? safeToken = responseData["safeToken"];
        if (safeToken != null && safeToken.isNotEmpty) {
          final String decryptedSafeToken = await _apzCrypto.asymmetricDecrypt(
            privateKeyPath: _privateKeyPath,
            encryptedData: safeToken,
          );
          symmetricKeyBytes = base64Decode(decryptedSafeToken);
          _symmetricKeyPass = symmetricKeyBytes;
        }

        if (_symmetricKeyPass.isEmpty) {
          throw DioException(
            requestOptions: response.requestOptions,
            response: response,
            error:
                """Failed to decrypt response data: safeToken missing or empty""",
          );
        }

        final String? algo = responseData["algo"];
        if (algo != api_service_constants.Constants.algo) {
          throw DioException(
            requestOptions: response.requestOptions,
            response: response,
            error:
                """Failed to decrypt response data: algo didn't matched or missing""",
          );
        }

        String bodyOrErrorString = "";
        if (responseData.containsKey("body")) {
          bodyOrErrorString = responseData["body"];
        } else if (responseData.containsKey("error")) {
          bodyOrErrorString = responseData["error"];
        }

        if (bodyOrErrorString.isEmpty) {
          throw DioException(
            requestOptions: response.requestOptions,
            response: response,
            error: "Failed to decrypt response data: body or error is empty",
          );
        }

        final Uint8List bodyOrErrorBytes = base64Decode(bodyOrErrorString);

        final Uint8List saltBytes = bodyOrErrorBytes.sublist(
          0,
          api_service_constants.Constants.saltLength,
        );

        final Uint8List ivBytes = bodyOrErrorBytes.sublist(
          api_service_constants.Constants.saltLength,
          api_service_constants.Constants.saltLength +
              api_service_constants.Constants.ivLength,
        );

        final Uint8List cipherBytes = bodyOrErrorBytes.sublist(
          api_service_constants.Constants.saltLength +
              api_service_constants.Constants.ivLength,
        );

        if (saltBytes.isEmpty || ivBytes.isEmpty || cipherBytes.isEmpty) {
          throw DioException(
            requestOptions: response.requestOptions,
            response: response,
            error:
                """Failed to decrypt response data: body or error field is not proper""",
          );
        }

        final String hashedSymmetricKey = _apzCrypto.generateHashDigestWithSalt(
          textToHash: utf8.decode(symmetricKeyBytes),
          salt: utf8.decode(saltBytes),
          type: api_service_constants.Constants.symmetricKeyHashingType,
          iterationCount:
              api_service_constants.Constants.symmetricKeyHashingIterationCount,
          outputKeyLength:
              api_service_constants.Constants.hashedSymmetricKeyOutputLength,
        );

        final String decryptedPayload = _apzCrypto.symmetricDecrypt(
          cipherText: base64Encode(cipherBytes),
          key: hashedSymmetricKey,
          iv: base64Encode(ivBytes),
        );

        response.data = decryptedPayload;
        _printUtils.printCompleteStringUsingDebugPrint(
          "Response data decrypted successfully: ${response.data}",
        );

        if (responseData.containsKey("error")) {
          throw DioException(
            requestOptions: response.requestOptions,
            response: response,
            error: "Error response from server",
          );
        }
      } on Exception catch (error) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: "Failed to decrypt response data: $error",
        );
      }
    }

    return response;
  }
}
