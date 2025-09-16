import "dart:convert";

/// This file contains the ApiProviderException class, which is used to handle
class ApiProviderException implements Exception {
  /// Constructor for ApiProviderException.
  ApiProviderException({
    required this.statusCode,
    required this.message,
    this.errorType,
    this.response,
    this.type,
    this.title,
    this.detail,
    this.instance,
    this.status,
    this.timetamp,
  });

  /// The status code of the API response.
  int statusCode;

  /// The error message returned by the API.
  String message;

  /// The type of error, if available.
  String? errorType;

  /// The response data, if available.
  dynamic response;

  /// The type of the error, if available.
  String? type;

  /// The title of the error, if available.
  String? title;

  /// The detail of the error, if available.
  String? detail;

  /// The instance of the error, if available.
  String? instance;

  /// The status of the error, if available.
  String? status;

  /// The timestamp of the error, if available.
  String? timetamp;

  @override
  String toString() {
    final Map<String, dynamic> errorData = <String, dynamic>{
      "statusCode": statusCode,
      "message": message,
      "errorType": errorType,
      "response": response,
      "type": type,
      "title": title,
      "detail": detail,
      "instance": instance,
      "status": status,
      "timetamp": timetamp,
    };
    return json.encode(errorData);
  }
}
