import "dart:async";

import "package:apz_api_service/model/certificate_pinning_model.dart";
import "package:apz_api_service/src/custom_interceptor.dart";
import "package:apz_api_service/src/encryption_decryption.dart";
import "package:apz_api_service/src/replay_prevention.dart";
import "package:apz_api_service/src/ssl_pinning.dart";
import "package:apz_api_service/utils/print_utils.dart";
import "package:apz_crypto/apz_crypto.dart";
import "package:apz_utils/apz_utils.dart";
import "package:dio/dio.dart";
import "package:flutter/foundation.dart";

/// A class to manage Dio client for making HTTP requests.
class DioClient {
  /// Creates a new instance of DioClient.
  DioClient({
    required final String baseUrl,
    required final int timeoutDuration,
    required final bool isDebugModeEnabled,
    required final bool sslPinningEnabled,
    required final bool dataIntegrityEnabled,
    required final CertificatePinningModel? certificatePinningModel,
    required final bool payloadEncryption,
    required final String publicKeyPath,
    required final String privateKeyPath,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: Duration(seconds: timeoutDuration),
        receiveTimeout: Duration(seconds: timeoutDuration),
      ),
    );
    if (isDebugModeEnabled) {
      _dio.interceptors.add(
        LogInterceptor(responseBody: true, requestBody: true),
      );
    }

    final ApzCrypto apzCrypto = ApzCrypto();

    final PrintUtils printUtils = PrintUtils(
      isDebugModeEnabled: isDebugModeEnabled,
    );

    final EncryptionDecryption encryptionDecryption = EncryptionDecryption(
      printUtils: printUtils,
      dioClient: this,
      apzCrypto: apzCrypto,
      publicKeyPath: publicKeyPath,
      privateKeyPath: privateKeyPath,
    );

    final ReplayPrevention replayPrevention = ReplayPrevention(
      apzCrypto: apzCrypto,
    );

    _dio.interceptors.add(
      CustomInterceptor(
        printUtils: printUtils,
        payloadEncEnabled: payloadEncryption,
        encryptionDecryption: encryptionDecryption,
        dataIntegrityEnabled: dataIntegrityEnabled,
        replayPrevention: replayPrevention,
      ),
    );

    if (!kIsWeb && sslPinningEnabled) {
      _doSslPinning(certificatePinningModel);
    } else {
      _logger.debug(
        """SSL Pinning is disabled or not applicable for web. No certificates will be pinned.""",
      );
    }
  }

  late final Dio _dio;
  final SslPinning _sslPinning = SslPinning();
  final APZLoggerProvider _logger = APZLoggerProvider();

  void _doSslPinning(final CertificatePinningModel? certificatePinningModel) {
    if (certificatePinningModel?.type ==
        CertificatePinningType.certificatePaths) {
      unawaited(
        _sslPinning
            .sslPinningCertificates(
              _dio,
              certificatePinningModel?.certificatePaths ?? <String>[],
            )
            .then((final _) {
              _logger.debug(
                "SSL Pinning configured successfully. Certificates: "
                "${certificatePinningModel?.certificatePaths?.join(", ")}",
              );
            })
            .catchError((final Object error) {
              _logger.error("SSL Pinning configuration failed: $error");
              throw Exception("SSL Pinning configuration failed: $error");
            }),
      );
    } else if (certificatePinningModel?.type ==
        CertificatePinningType.trustedSpkiSha256Hashes) {
      _sslPinning.sslPinningPublicKeyHashes(
        _dio,
        certificatePinningModel?.trustedSpkiSha256Hashes ?? <String>[],
      );
    }
  }

  /// Sets the token for authorization in the headers.
  void setToken(final String token) {
    if (token.isNotEmpty) {
      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest:
              (
                final RequestOptions options,
                final RequestInterceptorHandler handler,
              ) {
                options.headers["Authorization"] = "Bearer $token";
                return handler.next(options);
              },
        ),
      );
    }
  }

  /// Get method to make a GET request.
  Future<Response<dynamic>> get(
    final String path,
    final Map<String, dynamic>? queryParameters,
    final Map<String, String>? headers,
  ) async {
    try {
      final Map<String, String> defaultHeader = <String, String>{
        "Accept": "application/json",
        "Access-Control-Allow-Origin": "*",
      };
      if (headers != null) {
        defaultHeader.addAll(headers);
      }
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: Options(headers: defaultHeader),
      );
    } catch (error) {
      rethrow;
    }
  }

  /// Post method to make a POST request.
  Future<Response<dynamic>> post(
    final String path,
    final Map<String, dynamic> body,
    final Map<String, dynamic>? queryParameters,
    final Map<String, String>? headers,
  ) async {
    try {
      final Map<String, String> defaultHeader = <String, String>{
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Access-Control-Allow-Origin": "*",
      };
      if (headers != null) {
        defaultHeader.addAll(headers);
      }
      return await _dio.post(
        path,
        data: body,
        queryParameters: queryParameters,
        options: Options(headers: defaultHeader),
      );
    } catch (error) {
      rethrow;
    }
  }

  /// PostStream method to make a POST request and get a streamed response.
  Future<Response<ResponseBody>> postStream(
    final String path,
    final Map<String, dynamic> body,
    final Map<String, dynamic>? queryParameters,
    final Map<String, String>? headers,
  ) async {
    try {
      final Map<String, String> defaultHeader = <String, String>{
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Access-Control-Allow-Origin": "*",
      };
      if (headers != null) {
        defaultHeader.addAll(headers);
      }
      return await _dio.post<ResponseBody>(
        path,
        data: body,
        queryParameters: queryParameters,
        options: Options(
          headers: defaultHeader,
          responseType: ResponseType.stream,
        ),
      );
    } catch (error) {
      rethrow;
    }
  }

  /// Put method to make a PUT request.
  Future<Response<dynamic>> put(
    final String path,
    final Map<String, dynamic> body,
    final Map<String, dynamic>? queryParameters,
    final Map<String, String>? headers,
  ) async {
    try {
      final Map<String, String> defaultHeader = <String, String>{
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Access-Control-Allow-Origin": "*",
      };
      if (headers != null) {
        defaultHeader.addAll(headers);
      }
      return await _dio.put(
        path,
        data: body,
        queryParameters: queryParameters,
        options: Options(headers: defaultHeader),
      );
    } catch (error) {
      rethrow;
    }
  }

  /// Delete method to make a DELETE request.
  Future<Response<dynamic>> delete(
    final String path,
    final Map<String, dynamic>? queryParameters,
    final Map<String, String>? headers,
  ) async {
    try {
      final Map<String, String> defaultHeader = <String, String>{
        "Accept": "application/json",
        "Access-Control-Allow-Origin": "*",
      };
      if (headers != null) {
        defaultHeader.addAll(headers);
      }
      return await _dio.delete(
        path,
        queryParameters: queryParameters,
        options: Options(headers: defaultHeader),
      );
    } catch (error) {
      rethrow;
    }
  }

  /// Uploads a file to the server.
  Future<Response<dynamic>> uploadFile(
    final String path,
    final Map<String, dynamic>? queryParameters,
    final Map<String, String>? headers,
    final void Function(int count, int total)? progressCallback,
  ) async {
    try {
      final String fileName = path.split("/").last;
      final FormData formData = FormData.fromMap(<String, MultipartFile>{
        "file": await MultipartFile.fromFile(path, filename: fileName),
      });
      return await _dio.post(
        path,
        data: formData,
        queryParameters: queryParameters,
        options: Options(headers: headers),
        onSendProgress: progressCallback,
      );
    } catch (error) {
      rethrow;
    }
  }

  /// Downloads a file from the server.
  Future<Response<dynamic>> downloadFile(
    final String fileUrl,
    final String savePath,
    final Map<String, dynamic>? queryParameters,
    final Map<String, String>? headers,
    final void Function(int count, int total)? progressCallback,
  ) async {
    try {
      return await _dio.download(
        fileUrl,
        savePath,
        queryParameters: queryParameters,
        options: Options(headers: headers),
        onReceiveProgress: progressCallback,
      );
    } catch (error) {
      rethrow;
    }
  }
}
