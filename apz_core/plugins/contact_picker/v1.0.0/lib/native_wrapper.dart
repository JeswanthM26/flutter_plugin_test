import "package:apz_contact_picker/picked_contact_model.dart";
import "package:flutter/services.dart";

/// This class is responsible for invoking the native contact picker 
/// and handling permissions.
class NativeWrapper {
  static const MethodChannel _channel = MethodChannel("contact_picker_plugin");

/// This method is responsible for picking a contact from the device.
  Future<PickedContact?> pickContact() async {
    try{
       final Map<dynamic, dynamic>? result = 
        await _channel.invokeMethod("pickContact");
        if (result != null) {
          return PickedContact.fromMap(result);
        }
        return null; // User cancelled the picker from the native UI
  }on Exception catch (error) {
      return  PickedContact(error:error.toString());
    }
  }
}
