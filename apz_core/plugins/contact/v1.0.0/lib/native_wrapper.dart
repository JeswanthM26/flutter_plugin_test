import "package:flutter/services.dart";

/// This class is a wrapper around the native code for fetching contacts
/// and their photos.
class NativeWrapperContacts {
  static const MethodChannel _channel = MethodChannel(
    "com.iexceed/contacts_plugin",
  );

  /// Fetch list of name and email
  Future<List<Map<String, dynamic>>> getContacts({
    final bool? fetchEmail,
    final bool? fetchPhoto,
    final String? searchQuery,
  }) async {
    try {
      final List<dynamic> contacts = await _channel.invokeMethod(
        "getContacts",
        <String, Object?>{
          "fetchEmail": fetchEmail,
          "fetchPhoto": fetchPhoto,
          "searchQuery": searchQuery,
        },
      );

      return contacts
          /// Convert dynamic to Map<String, dynamic>
          // ignore: always_specify_types
          .map((final contact) => Map<String, dynamic>.from(contact))
          .toList();
    } on Exception catch (error) {
      return <Map<String, dynamic>>[
        <String, dynamic>{"error": error.toString()},
      ];
    }
  }
}
