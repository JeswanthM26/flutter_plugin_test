import "package:apz_api_service/src/encryption_decryption.dart";
import "package:apz_api_service/src/replay_prevention.dart";
import "package:apz_api_service/utils/print_utils.dart";
import "package:dio/dio.dart";

/// An interceptor for modifying request and response data
class CustomInterceptor extends Interceptor {
  /// Creates a new instance of [CustomInterceptor].
  CustomInterceptor({
    required final PrintUtils printUtils,
    required final bool payloadEncEnabled,
    required final EncryptionDecryption encryptionDecryption,
    required final bool dataIntegrityEnabled,
    required final ReplayPrevention replayPrevention,
  }) : _printUtils = printUtils,
       _payloadEncEnabled = payloadEncEnabled,
       _encryptionDecryption = encryptionDecryption,
       _dataIntegrityEnabled = dataIntegrityEnabled,
       _replayPrevention = replayPrevention;

  final PrintUtils _printUtils;
  final bool _payloadEncEnabled;
  final EncryptionDecryption _encryptionDecryption;
  final bool _dataIntegrityEnabled;
  final ReplayPrevention _replayPrevention;

  @override
  Future<void> onRequest(
    final RequestOptions options,
    final RequestInterceptorHandler handler,
  ) async {
    _printUtils.printCompleteStringUsingDebugPrint(
      "Request data: ${options.data}",
    );

    try {
      RequestOptions requestOptions = options;

      if (_payloadEncEnabled) {
        requestOptions = await _encryptionDecryption.encryptRequest(options);
      }

      if (_dataIntegrityEnabled) {
        requestOptions = _replayPrevention.addQOP(requestOptions);
      }

      super.onRequest(requestOptions, handler);
    } on DioException catch (error) {
      handler.reject(error);
    }
  }

  @override
  Future<void> onResponse(
    final Response<dynamic> response,
    final ResponseInterceptorHandler handler,
  ) async {
    _printUtils.printCompleteStringUsingDebugPrint(
      "Received response data: ${response.data}",
    );

    try {
      Response<dynamic> responseValue = response;

      if (_payloadEncEnabled) {
        responseValue = await _encryptionDecryption.decryptResponse(response);
      }

      if (_dataIntegrityEnabled) {
        _replayPrevention.verifyQOP(response);
      }

      super.onResponse(responseValue, handler);
    } on DioException catch (error) {
      handler.reject(error);
    }
  }
}
