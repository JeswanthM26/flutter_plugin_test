/// A class representing the data extracted from a universal link.
/// It contains the host, path, scheme, and full URL of the link.
class LinkData {
  /// Constructor to create a LinkData instance.
  LinkData({
    required this.host,
    required this.path,
    required this.scheme,
    required this.fullUrl,
    required this.queryParams,
  });

  /// Factory constructor to create a LinkData instance from a map.
  factory LinkData.fromMap(final Map<dynamic, dynamic> map) => LinkData(
    host: map["host"] ?? "",
    path: map["path"] ?? "",
    scheme: map["scheme"] ?? "",
    fullUrl: map["fullUrl"] ?? "",
    queryParams: Map<String, String>.from(
      map["queryParams"] ?? <String, String>{},
    ),
  );

  /// The host of the link, e.g., "example.com".
  final String host;

  /// The path of the link, e.g., "/path/to/resource".
  final String path;

  /// The scheme of the link, e.g., "https".
  final String scheme;

  /// The full URL of the link, e.g., "https://example.com/path/to/resource".
  final String fullUrl;

  /// The query parameters of the link, e.g., {"token": "abc123"}.
  final Map<String, String> queryParams;
}
