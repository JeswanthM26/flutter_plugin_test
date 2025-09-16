import "dart:convert";
import "dart:math";
import "package:apz_gps/apz_gps.dart";
import "package:apz_gps/location_model.dart";
import "package:flutter/foundation.dart";
import "package:pointycastle/digests/sha256.dart";

/// This class is to handle fingerprint utilities such as generating random
/// strings and generating SHA256 digests. It also provides methods to
/// fetch the current location using the ApzGPS package.
class FingerprintUtils {
  ApzGPS _apzGPS = ApzGPS();

  @visibleForTesting
  /// Sets whether the device is web or not.
  /// This is used for testing purposes to simulate web behavior.
  // ignore: use_setters_to_change_properties
  void setApzGPS({required final ApzGPS apzGPS}) {
    _apzGPS = apzGPS;
  }

  /// Fetches the current latitude and longitude of the device.
  /// Returns a string in the format "latitude,longitude" or null if the
  /// location cannot be fetched.
  /// Throws an exception if there is an error while fetching the location.
  Future<String?> getLatLong() async {
    try {
      final LocationModel location = await _apzGPS.getCurrentLocation();
      return "${location.latitude},${location.longitude}";
    } on Exception catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  /// Generates a random string of 20 characters using a predefined set of
  /// alphanumeric characters. The generated string is appended with the
  /// current timestamp to ensure uniqueness.
  String generateRandomString() {
    final Random random = Random();
    const String chars =
        "AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890";
    final String randomNumber = List<String>.generate(
      20,
      (final int index) => chars[random.nextInt(chars.length)],
    ).join();
    final String timeStamp = DateTime.now().toString();
    return randomNumber + timeStamp;
  }

  /// Generates a SHA256 digest of the input list by joining with [||] and
  /// returns it as a base64 encoded string.
  /// This is used to hash the fingerprint data for security.
  String generateDigest(final List<String> inputList) {
    final String stringData = inputList.join("||");
    final SHA256Digest sha256digest = SHA256Digest();
    final Uint8List dataBytes = utf8.encode(stringData);
    final Uint8List digestBytes = sha256digest.process(dataBytes);
    final String base64EncodedText = base64.encode(digestBytes);

    return base64EncodedText;
  }
}
