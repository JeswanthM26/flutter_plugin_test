import "dart:convert";
import "dart:io";

import "package:apz_api_service/model/api_provider_exception.dart";
import "package:apz_api_service/model/certificate_pinning_model.dart";
import "package:apz_api_service/model/result_response.dart";
import "package:apz_api_service/src/dio_client.dart";
import "package:apz_api_service/utils/constants.dart";
import "package:connectivity_plus/connectivity_plus.dart";
import "package:dio/dio.dart";
import "package:flutter/foundation.dart";

///APZApiService is a singleton class that provides methods to make API requests
class APZApiService {
  /// This method is used to create a singleton instance of the APZApiService
  APZApiService({
    required final String baseUrl,
    required final int timeoutDurationInSec,
    required final bool isDebugModeEnabled,
    final bool dataIntegrityEnabled = false,
    final bool sslPinningEnabled = false,
    final CertificatePinningModel? certificatePinningModel,
    final bool payloadEncryption = false,
    final String publicKeyPath = "",
    final String privateKeyPath = "",
  }) {
    int timeoutDuration = 30;
    if (timeoutDurationInSec > 0) {
      timeoutDuration = timeoutDurationInSec;
    }
    _dioClient = DioClient(
      baseUrl: baseUrl,
      timeoutDuration: timeoutDuration,
      isDebugModeEnabled: isDebugModeEnabled,
      dataIntegrityEnabled: dataIntegrityEnabled,
      sslPinningEnabled: sslPinningEnabled,
      certificatePinningModel: certificatePinningModel,
      payloadEncryption: payloadEncryption,
      publicKeyPath: publicKeyPath,
      privateKeyPath: privateKeyPath,
    );
  }

  late DioClient _dioClient;
  Connectivity _connectivity = Connectivity();

  /// This method is used to set the token for the dio client
  void setToken(final String token) {
    _dioClient.setToken(token);
  }

  /// This method is used to make a GET request
  Future<Result<Map<String, dynamic>>> getRequest({
    required final String path,
    final Map<String, dynamic>? queryParameters,
    final Map<String, String>? headers,
  }) async {
    try {
      final bool isConnected = await _isConnected();
      if (!isConnected) {
        return Result<Map<String, dynamic>>.error(
          ApiProviderException(
            statusCode: Constants.noInternetConnectionErrorCode,
            message: Constants.noInternetConnectionErrorMessage,
          ),
        );
      }
      final Response<dynamic> response = await _dioClient.get(
        path,
        queryParameters,
        headers,
      );
      if (response.statusCode == Constants.requestSuccessCode) {
        final Map<String, dynamic> responseMap =
            response.data as Map<String, dynamic>;
        return Result<Map<String, dynamic>>.success(responseMap);
      } else {
        return _getErrorResult(response);
      }
    }
    /// The error is handled at one place with method name "_handleError"
    // ignore: avoid_catches_without_on_clauses
    catch (error) {
      final ApiProviderException errorObject = _handleError(error);
      return Result<Map<String, dynamic>>.error(errorObject);
    }
  }

  /// This method is used to make a POST request
  Future<Result<Map<String, dynamic>>> postRequest({
    required final String path,
    required final Map<String, dynamic> body,
    final Map<String, dynamic>? queryParameters,
    final Map<String, String>? headers,
  }) async {
    try {
      final bool isConnected = await _isConnected();
      if (!isConnected) {
        return Result<Map<String, dynamic>>.error(
          ApiProviderException(
            statusCode: Constants.noInternetConnectionErrorCode,
            message: Constants.noInternetConnectionErrorMessage,
          ),
        );
      }
      final Response<dynamic> response = await _dioClient.post(
        path,
        body,
        queryParameters,
        headers,
      );
      if (response.statusCode == Constants.requestSuccessCode) {
        final Map<String, dynamic> responseMap =
            response.data as Map<String, dynamic>;
        return Result<Map<String, dynamic>>.success(responseMap);
      } else {
        return _getErrorResult(response);
      }
    }
    /// The error is handled at one place with method name "_handleError"
    // ignore: avoid_catches_without_on_clauses
    catch (error) {
      final ApiProviderException errorObject = _handleError(error);
      return Result<Map<String, dynamic>>.error(errorObject);
    }
  }

  /// This method is used to make a POST request and
  /// stream the response (for LLM streaming)
  Stream<String> postStreamRequest({
    required final String path,
    required final Map<String, dynamic> body,
    final Map<String, dynamic>? queryParameters,
    final Map<String, String>? headers,
  }) async* {
    final bool isConnected = await _isConnected();
    if (!isConnected) {
      throw ApiProviderException(
        statusCode: Constants.noInternetConnectionErrorCode,
        message: Constants.noInternetConnectionErrorMessage,
      );
    }
    try {
      final Response<ResponseBody> response = await _dioClient.postStream(
        path,
        body,
        queryParameters,
        headers,
      );
      final Stream<List<int>>? stream = response.data?.stream;
      if (stream == null) {
        throw ApiProviderException(
          statusCode: response.statusCode ?? Constants.requestCommonErrorCode,
          message: "No stream received from server.",
        );
      }
      // Ensure the stream is List<int> for utf8.decoder
      // Convert the stream to Stream<List<int>> if needed
      final Stream<List<int>> byteStream = stream.map(
        (final List<int> e) => e.toList(),
      );
      await for (final String chunk
          in byteStream
              .transform(utf8.decoder)
              .transform(const LineSplitter())) {
        yield chunk;
      }
    } catch (error) {
      throw _handleError(error);
    }
  }

  /// This method is used to make a PUT request
  Future<Result<Map<String, dynamic>>> putRequest({
    required final String path,
    required final Map<String, dynamic> body,
    final Map<String, dynamic>? queryParameters,
    final Map<String, String>? headers,
  }) async {
    try {
      final bool isConnected = await _isConnected();
      if (!isConnected) {
        return Result<Map<String, dynamic>>.error(
          ApiProviderException(
            statusCode: Constants.noInternetConnectionErrorCode,
            message: Constants.noInternetConnectionErrorMessage,
          ),
        );
      }
      final Response<dynamic> response = await _dioClient.put(
        path,
        body,
        queryParameters,
        headers,
      );
      if (response.statusCode == Constants.requestSuccessCode) {
        final Map<String, dynamic> responseMap =
            response.data as Map<String, dynamic>;
        return Result<Map<String, dynamic>>.success(responseMap);
      } else {
        return _getErrorResult(response);
      }
    }
    /// The error is handled at one place with method name "_handleError"
    // ignore: avoid_catches_without_on_clauses
    catch (error) {
      final ApiProviderException errorObject = _handleError(error);
      return Result<Map<String, dynamic>>.error(errorObject);
    }
  }

  /// This method is used to make a DELETE request
  Future<Result<Map<String, dynamic>>> deleteRequest({
    required final String path,
    final Map<String, dynamic>? queryParameters,
    final Map<String, String>? headers,
  }) async {
    try {
      final bool isConnected = await _isConnected();
      if (!isConnected) {
        return Result<Map<String, dynamic>>.error(
          ApiProviderException(
            statusCode: Constants.noInternetConnectionErrorCode,
            message: Constants.noInternetConnectionErrorMessage,
          ),
        );
      }
      final Response<dynamic> response = await _dioClient.delete(
        path,
        queryParameters,
        headers,
      );
      if (response.statusCode == Constants.requestSuccessCode) {
        final Map<String, dynamic> responseMap =
            response.data as Map<String, dynamic>;
        return Result<Map<String, dynamic>>.success(responseMap);
      } else {
        return _getErrorResult(response);
      }
    }
    /// The error is handled at one place with method name "_handleError"
    // ignore: avoid_catches_without_on_clauses
    catch (error) {
      final ApiProviderException errorObject = _handleError(error);
      return Result<Map<String, dynamic>>.error(errorObject);
    }
  }

  /// This method is used to upload a file
  Future<Result<Map<String, dynamic>>> uploadFile({
    required final String path,
    final Map<String, dynamic>? queryParameters,
    final Map<String, String>? headers,
    final void Function(int count, int total)? progressCallback,
  }) async {
    try {
      final bool isConnected = await _isConnected();
      if (!isConnected) {
        return Result<Map<String, dynamic>>.error(
          ApiProviderException(
            statusCode: Constants.noInternetConnectionErrorCode,
            message: Constants.noInternetConnectionErrorMessage,
          ),
        );
      }
      final Response<dynamic> response = await _dioClient.uploadFile(
        path,
        queryParameters,
        headers,
        progressCallback,
      );
      if (response.statusCode == Constants.requestSuccessCode) {
        final Map<String, dynamic> responseMap =
            response.data as Map<String, dynamic>;
        return Result<Map<String, dynamic>>.success(responseMap);
      } else {
        return _getErrorResult(response);
      }
    }
    /// The error is handled at one place with method name "_handleError"
    // ignore: avoid_catches_without_on_clauses
    catch (error) {
      final ApiProviderException errorObject = _handleError(error);
      return Result<Map<String, dynamic>>.error(errorObject);
    }
  }

  /// This method is used to download a file
  Future<Result<Map<String, dynamic>>> downloadFile({
    required final String fileUrl,
    required final String savePath,
    final Map<String, dynamic>? queryParameters,
    final Map<String, String>? headers,
    final void Function(int count, int total)? progressCallback,
  }) async {
    try {
      final bool isConnected = await _isConnected();
      if (!isConnected) {
        return Result<Map<String, dynamic>>.error(
          ApiProviderException(
            statusCode: Constants.noInternetConnectionErrorCode,
            message: Constants.noInternetConnectionErrorMessage,
          ),
        );
      }
      final Response<dynamic> response = await _dioClient.downloadFile(
        fileUrl,
        savePath,
        queryParameters,
        headers,
        progressCallback,
      );
      if (response.statusCode == Constants.requestSuccessCode) {
        final Map<String, dynamic> responseMap =
            response.data as Map<String, dynamic>;
        return Result<Map<String, dynamic>>.success(responseMap);
      } else {
        return _getErrorResult(response);
      }
    }
    /// The error is handled at one place with method name "_handleError"
    // ignore: avoid_catches_without_on_clauses
    catch (error) {
      final ApiProviderException errorObject = _handleError(error);
      return Result<Map<String, dynamic>>.error(errorObject);
    }
  }

  Result<Map<String, dynamic>> _getErrorResult(
    final Response<dynamic> response,
  ) => Result<Map<String, dynamic>>.error(
    ApiProviderException(
      statusCode: response.statusCode ?? Constants.responseFailedErrorCode,
      message: Constants.responseFailedErrorMessage,
      response: response.data,
    ),
  );

  ApiProviderException _handleError(final Object error) {
    if (error is DioException) {
      String? message = error.message;
      String errorType = error.type.toString();
      String? type;
      String? title;
      String? detail;
      String? instance;
      String? status;
      String? timetamp;

      if ((message == null || message.isEmpty) && error.error != null) {
        if (error.error is String) {
          message = error.error as String?;
          if (message == "Error response from server") {
            final dynamic decoded = json.decode(error.response?.data);
            if (decoded is Map) {
              final Map<String, String?> serverErrorMap = <String, String?>{};
              for (final MapEntry<dynamic, dynamic> entry in decoded.entries) {
                serverErrorMap[entry.key.toString()] = entry.value?.toString();
              }
              type = serverErrorMap["type"];
              title = serverErrorMap["title"];
              detail = serverErrorMap["detail"];
              instance = serverErrorMap["instance"];
              status = serverErrorMap["status"];
              timetamp = serverErrorMap["timetamp"];
            }
          }
        } else if (error.error is HandshakeException) {
          message = (error.error! as HandshakeException).message;
          errorType = (error.error! as HandshakeException).type;
        }
      }
      return ApiProviderException(
        statusCode:
            error.response?.statusCode ?? Constants.requestCommonErrorCode,
        message: message ?? Constants.requestCommonErrorMessage,
        errorType: errorType,
        response: error.response?.data,
        type: type,
        title: title,
        detail: detail,
        instance: instance,
        status: status,
        timetamp: timetamp,
      );
    } else {
      return ApiProviderException(
        statusCode: Constants.requestCommonErrorCode,
        message: error.toString(),
      );
    }
  }

  Future<bool> _isConnected() async {
    final List<ConnectivityResult> connectivityResult = await _connectivity
        .checkConnectivity();

    bool isConnected = true;
    if (connectivityResult.isEmpty ||
        (connectivityResult.length == 1 &&
            connectivityResult.first == ConnectivityResult.none)) {
      isConnected = false;
    }
    return isConnected;
  }

  /// This method is used to set the dio client instance for testing purposes
  @visibleForTesting
  set dioClient(final DioClient dioClient) {
    _dioClient = dioClient;
  }

  /// This method is used to set the connectivity instance for testing purposes
  @visibleForTesting
  set connectivityInstance(final Connectivity connectivityInstance) {
    _connectivity = connectivityInstance;
  }

  /// This method is used to get the dio client instance for testing purposes
  @visibleForTesting
  DioClient get dioClient => _dioClient;

  /// This method is used to get the connectivity instance for testing purposes
  @visibleForTesting
  Connectivity get connectivityInstance => _connectivity;
}
