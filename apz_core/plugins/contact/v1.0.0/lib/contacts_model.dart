
import "package:flutter/foundation.dart";

/// This class represents a model for contacts, containing a list of contacts.
class ContactsModel {
/// Constructor for ContactsModel
  ContactsModel({required this.contacts});

/// Factory constructor that creates a ContactsModel from a list ofJSON objects.
  factory ContactsModel.fromJson(final List<Map<String, dynamic>> jsonList) =>
      ContactsModel(
      contacts: jsonList.map(Contact.fromJson).toList(),
    );
  /// List of contacts
  final List<Contact> contacts;
}

/// This class represents a contact, containing a name, numbers, emails,
/// and an optional photo.
class Contact {
/// Constructor for Contact
  Contact({
    required this.name,
    required this.numbers,
    required this.emails,
    this.firstName,
    this.lastName,
    this.photoBytes,
  });

  /// Factory constructor that creates a Contact from a JSON object.
  factory Contact.fromJson(final Map<String, dynamic> json) => Contact(
      name: json["name"] ?? "",
      numbers: List<String>.from(json["numbers"] ?? <String>[]),
      emails: List<String>.from(json["emails"] ?? <String>[]),
      firstName: json["firstName"] ?? "",
      lastName: json["lastName"] ?? "",
        photoBytes: (json["photoBytes"] != null)
          ? Uint8List.fromList(List<int>.from(json["photoBytes"]))
          : null,
    );

  /// name of the contact
  final String name;
  /// list of phone numbers
  final List<String> numbers;
  /// list of email addresses
  final List<String> emails;
  /// first name of the contact
  final String? firstName;
  /// last name of the contact
  final String? lastName;
  /// optional photo bytes
  final Uint8List? photoBytes;
}
