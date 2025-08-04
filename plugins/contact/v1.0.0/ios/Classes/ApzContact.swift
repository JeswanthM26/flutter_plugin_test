import Flutter
import UIKit
import Contacts

public class ApzContact: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "com.iexceed/contacts_plugin", binaryMessenger: registrar.messenger())
    let instance = ApzContact()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getContacts":
      guard let args = call.arguments as? [String: Any] else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
        return
      }

      let fetchEmail = args["fetchEmail"] as? Bool ?? false
      let fetchPhoto = args["fetchPhoto"] as? Bool ?? false
      let searchQuery = args["searchQuery"] as? String ?? ""

      getContacts(fetchEmail: fetchEmail, fetchPhoto: fetchPhoto, searchQuery: searchQuery, result: result)



    default:
      result(FlutterMethodNotImplemented)
    }
  }

 private func getContacts(fetchEmail: Bool, fetchPhoto: Bool, searchQuery: String, result: @escaping FlutterResult) {
     let store = CNContactStore()

     var keys: [CNKeyDescriptor] = [
         CNContactGivenNameKey as CNKeyDescriptor,
         CNContactFamilyNameKey as CNKeyDescriptor,
         CNContactPhoneNumbersKey as CNKeyDescriptor
     ]

     if fetchEmail {
         keys.append(CNContactEmailAddressesKey as CNKeyDescriptor)
     }

     if fetchPhoto {
         keys.append(CNContactThumbnailImageDataKey as CNKeyDescriptor)
     }

     let request = CNContactFetchRequest(keysToFetch: keys)

     // Predicate to filter by name OR phone number using CNContact.predicateForContacts(matchingName:) is only for names
     // So we will fetch all and filter manually for numbers because CNContactStore does not provide phone number predicate
     // But if searchQuery is empty, fetch all contacts

     let trimmedQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
     let hasQuery = !trimmedQuery.isEmpty

     do {
         var contactMap: [String: [String: Any]] = [:]

         try store.enumerateContacts(with: request) { (contact, stop) in
             // Compose full name and normalize to lowercase for grouping
             let fullName = "\(contact.givenName) \(contact.familyName)".trimmingCharacters(in: .whitespacesAndNewlines)
             guard !fullName.isEmpty else { return }

             let fullNameKey = fullName.lowercased()

             // Extract all phone numbers as strings
             let phoneNumbers = contact.phoneNumbers.compactMap { $0.value.stringValue }.filter { !$0.isEmpty }

             // Extract all emails if needed
             var emails: [String] = []
             if fetchEmail {
                 emails = contact.emailAddresses.compactMap { $0.value as String }.filter { !$0.isEmpty }
             }

             // Filter logic: if query exists, match name or any number (case insensitive)
             if hasQuery {
                 let queryLower = trimmedQuery.lowercased()
                 let nameMatches = fullName.lowercased().contains(queryLower)
                 let numberMatches = phoneNumbers.contains { $0.lowercased().contains(queryLower) }
                 let emailMatches = fetchEmail ? emails.contains { $0.lowercased().contains(queryLower) } : false

                 if !(nameMatches || numberMatches || emailMatches) {
                     return // skip contact if no match
                 }
             }

             // Fetch photo bytes if requested and if not already set for this contact
             var photoData = contactMap[fullNameKey]?["photoData"] as? Data

             if fetchPhoto && photoData == nil {
                 photoData = contact.thumbnailImageData
             }

             // Merge with existing or create new
             if var existingContact = contactMap[fullNameKey] {
                 // Merge phone numbers without duplicates
                 var existingNumbers = existingContact["numbers"] as? [String] ?? []
                 existingNumbers.append(contentsOf: phoneNumbers)
                 existingContact["numbers"] = Array(Set(existingNumbers))

                 // Merge emails
                 var existingEmails = existingContact["emails"] as? [String] ?? []
                 existingEmails.append(contentsOf: emails)
                 existingContact["emails"] = Array(Set(existingEmails))

                 // Set photo data if not set yet
                 if existingContact["photoData"] == nil {
                     existingContact["photoData"] = photoData
                 }

                 contactMap[fullNameKey] = existingContact
             } else {
                 // New contact entry
                 contactMap[fullNameKey] = [
                     "name": fullName,
                     "firstName": contact.givenName,
                     "lastName": contact.familyName,
                     "numbers": phoneNumbers,
                     "emails": emails,
                     "photoData": photoData as Any
                 ]
             }
         }

         // Convert contactMap to array, skipping contacts without any numbers or emails
         let contactsArray = contactMap.values.filter {
             let numbers = $0["numbers"] as? [String] ?? []
             let emails = $0["emails"] as? [String] ?? []
             return !numbers.isEmpty || !emails.isEmpty
         }

         result(contactsArray)

     } catch {
         result(FlutterError(code: "UNAVAILABLE", message: "Cannot fetch contacts", details: error.localizedDescription))
     }
 }
}
