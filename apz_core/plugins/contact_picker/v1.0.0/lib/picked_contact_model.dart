import "package:flutter/foundation.dart";

/// This class represents a contact picked from the device.
class PickedContact { // Thumbnail as Uint8List

  /// Constructor for PickedContact
  PickedContact({
    this.fullName,
    this.phoneNumber,
    this.email,
    this.thumbnail,
    this.error
  });

/// This method converts a Map to a PickedContact object
  factory PickedContact.fromMap(
    final Map<dynamic, dynamic> map) => PickedContact(
      fullName: map["fullName"] as String?,
      phoneNumber: map["phoneNumber"] as String?,
      email: map["email"] as String?,
      thumbnail: map["thumbnail"] as Uint8List?, // Directly cast as Uint8List
     
    );

  /// full name of the contact
  final String? fullName;
  /// Phone number of the contact
  final String? phoneNumber;
  /// Email address of the contact
  final String? email;
  /// Thumbnail as Uint8List
  final Uint8List? thumbnail;
  /// error
  final String? error;
}
