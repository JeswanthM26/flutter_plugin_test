import "package:apz_api_service/model/api_provider_exception.dart";

/// A class to represent the result of an API call.
sealed class Result<T> {
  const Result();
  factory Result.success(final T value) => Success<T>(value);
  factory Result.error(final ApiProviderException errorValue) =>
      Error<T>(errorValue);
}

/// Subclass of Result for values
final class Success<T> extends Result<T> {
  /// Constructor for Success.
  const Success(this.value);

  /// The value returned from the API call.
  final T value;
}

/// Subclass of Result for errors
final class Error<T> extends Result<T> {
  /// Constructor for Error.
  const Error(this.errorValue);

  /// The error returned from the API call.
  final ApiProviderException errorValue;
}
