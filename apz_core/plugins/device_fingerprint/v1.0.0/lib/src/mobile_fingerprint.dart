import "dart:io";
import "package:apz_device_fingerprint/utils/fingerprint_utils.dart";
import "package:apz_preference/apz_preference.dart";
import "package:flutter/services.dart";

/// This class is to handle the mobile device fingerprinting.
/// It fetches various device-related metadata and generates a
/// unique fingerprint for the device.
/// The fingerprint is hashed to ensure privacy.
class FingerprintData {
  final String _channelName = "com.iexceed/apz_device_fingerprint";
  final String _methodName = "getDeviceFingerprint";

  /// Fetches the device fingerprint by invoking a method on the
  /// native platform. Returns a hashed fingerprint as a string.
  /// Throws an exception if the operation fails.
  Future<String> getFingerprint(final FingerprintUtils fingerprintUtils) async {
    final MethodChannel channel = MethodChannel(_channelName);
    try {
      const String nullString = "null";
      const String naString = "N/A";
      final ApzPreference apzPreference = ApzPreference();
      final Map<Object?, Object?> rawData = await channel.invokeMethod(
        _methodName,
      );
      final Map<String, String> data = rawData.cast<String, String>();
      final String source = data["source"] ?? nullString;
      String secureId = data["secureId"] ?? nullString;
      final String deviceManufacturer =
          data["deviceManufacturer"] ?? nullString;
      final String deviceModel = data["deviceModel"] ?? nullString;
      final String screenResolution = data["screenResolution"] ?? nullString;
      final String deviceType = data["deviceType"] ?? nullString;
      final String totalDiskSpace = data["totalDiskSpace"] ?? nullString;
      final String totalRAM = data["totalRAM"] ?? nullString;
      final String cpuCount = data["cpuCount"] ?? nullString;
      final String cpuArchitecture = data["cpuArchitecture"] ?? nullString;
      final String cpuEndianness = data["cpuEndianness"] ?? nullString;
      final String deviceName = data["deviceName"] ?? nullString;
      final String glesVersion = data["glesVersion"] ?? nullString;
      final String osVersion = data["osVersion"] ?? nullString;
      final String osBuildNumber = data["osBuildNumber"] ?? nullString;
      final String kernelVersion = data["kernelVersion"] ?? nullString;
      final String enabledKeyboardLanguages =
          data["enabledKeyboardLanguages"] ?? nullString;
      String installId = data["installId"] ?? nullString;
      final String timeZone = data["timeZone"] ?? nullString;
      final String connectionType = data["connectionType"] ?? nullString;
      final String freeDiskSpace = data["freeDiskSpace"] ?? nullString;
      final String latLong =
          (await fingerprintUtils.getLatLong()) ?? nullString;
      const String colorDepth = naString;
      const String orientation = naString;
      const String userAgent = naString;
      const String deviceInfo = naString;
      const String browser = naString;
      const String browserVersion = naString;
      const String deviceMode = naString;
      const String webglData = naString;
      const String graphicCardDetails = naString;

      if (Platform.isIOS) {
        const String preferenceKey = "deviceFingerprintSecureId";
        final Object? secureIdObject = await apzPreference.getData(
          preferenceKey,
          String,
          isSecure: true,
        );
        if (secureIdObject != null) {
          secureId = secureIdObject.toString();
        } else {
          final String randomNumber = fingerprintUtils.generateRandomString();
          await apzPreference.saveData(
            preferenceKey,
            randomNumber,
            isSecure: true,
          );
          secureId = randomNumber;
        }
      } else if (Platform.isAndroid) {
        const String preferenceKey = "deviceFingerprintInstallId";
        final Object? installIdObject = await apzPreference.getData(
          preferenceKey,
          String,
        );
        if (installIdObject != null) {
          installId = installIdObject.toString();
        } else {
          final String randomNumber = fingerprintUtils.generateRandomString();
          await apzPreference.saveData(preferenceKey, randomNumber);
          installId = randomNumber;
        }
      }

      final List<String> deviceFingerprintList = <String>[
        source,
        secureId,
        deviceManufacturer,
        deviceModel,
        screenResolution,
        deviceType,
        totalDiskSpace,
        totalRAM,
        cpuCount,
        cpuArchitecture,
        cpuEndianness,
        colorDepth,
        browser,
        webglData,
        deviceName,
        glesVersion,
        osVersion,
        osBuildNumber,
        kernelVersion,
        enabledKeyboardLanguages,
        installId,
        timeZone,
        orientation,
        userAgent,
        deviceInfo,
        browserVersion,
        deviceMode,
        graphicCardDetails,
        connectionType,
        freeDiskSpace,
        latLong,
      ];

      final String digest = fingerprintUtils.generateDigest(
        deviceFingerprintList,
      );
      return digest;
    } on Exception catch (_) {
      rethrow;
    }
  }
}
