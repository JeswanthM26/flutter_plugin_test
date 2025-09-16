/// FileData Model class
class FileData {
  /// fileData constructor
  FileData({
    required this.name,
    required this.path,
    required this.mimeType,
    required this.size,
    required this.base64String,
  });

  /// file name
  final String name;

  /// file path
  final String path;

  /// file type
  final String mimeType;

  /// file size
  final int size;

  /// file bytes
  final String base64String;
}
