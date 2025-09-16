/// Represents an error with a description, code, and type.
/// This class is used to encapsulate error details that can be passed
/// to webview callbacks or other error handling mechanisms.
class ErrorData {
  /// Constructs an [ErrorData] with the required [description],
  /// [code], and [type].
  ErrorData({
    required this.description,
    required this.code,
    required this.type,
  });

  /// The description of the error.
  final String description;

  /// The error code associated with the error.
  final String code;

  /// The type of the error
  final String type;
}
