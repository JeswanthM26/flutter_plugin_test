/// A Dart class to represent deep link data extracted from a URI.
class DeeplinkData {
  /// Represents the data extracted from a deep link URI.
  /// This class encapsulates the host, path, scheme, and query parameters
  DeeplinkData({
    required this.host,
    required this.path,
    required this.scheme,
    required this.queryParameters,
  });

  /// Factory constructor to create an instance from a URI.
  factory DeeplinkData.fromUri(final Uri uri) => DeeplinkData(
    host: uri.host,
    path: uri.path,
    scheme: uri.scheme,
    queryParameters: uri.queryParameters,
  );

  /// The host of the URI, e.g., "example.com"
  final String host;

  /// The path of the URI, e.g., "/path/to/resource"
  final String path;

  /// The scheme of the URI, e.g., "https"
  /// or "myapp"
  final String scheme;

  /// The query parameters of the URI as a map, e.g., {"key": "value"}
  /// If there are no query parameters, this will be an empty map.
  final Map<String, dynamic> queryParameters;

  @override
  String toString() =>
      "DeeplinkData("
      "host: $host, "
      "path: $path, "
      "scheme: $scheme, "
      "queryParameters: $queryParameters"
      ")";
}
