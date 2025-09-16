import "dart:io";

import "package:flutter/material.dart";
import "package:flutter/services.dart";

/// A class that provides methods to detect if a device is jailbroken or rooted.
enum JailbreakIssue {
  /// Indicates that the device is jailbroken.
  jailbreak,

  /// Indicates that the device is not a real device (e.g., an emulator).
  notRealDevice,

  /// Indicates that the device is running in a proxied environment.
  proxied,

  /// Indicates that the device is debugged.
  debugged,

  /// Indicates that the device is in developer mode.
  devMode,

  /// Indicates that the device has been reverse engineered.
  reverseEngineered,

  /// Indicates that the device has Frida installed.
  fridaFound,

  /// Indicates that the device has Cydia installed.
  cydiaFound,

  /// Indicates that the device has been tampered with.
  tampered,

  /// Indicates that the device is running on external storage.
  onExternalStorage,

  /// Indicates that the device is in an unknown state.
  unknown;

  /// Converts a string value to a [JailbreakIssue] enum.
  static JailbreakIssue fromString(final String value) {
    if (value == "jailbreak") {
      return JailbreakIssue.jailbreak;
    }
    if (value == "notRealDevice") {
      return JailbreakIssue.notRealDevice;
    }
    if (value == "proxied") {
      return JailbreakIssue.proxied;
    }
    if (value == "debugged") {
      return JailbreakIssue.debugged;
    }
    if (value == "devMode") {
      return JailbreakIssue.devMode;
    }
    if (value == "reverseEngineered") {
      return JailbreakIssue.reverseEngineered;
    }
    if (value == "fridaFound") {
      return JailbreakIssue.fridaFound;
    }
    if (value == "cydiaFound") {
      return JailbreakIssue.cydiaFound;
    }
    if (value == "tampered") {
      return JailbreakIssue.tampered;
    }
    if (value == "onExternalStorage") {
      return JailbreakIssue.onExternalStorage;
    }

    return JailbreakIssue.unknown;
  }
}

/// A class that provides methods to detect if a device is jailbroken or rooted.
class JailbreakRootDetection {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final MethodChannel methodChannel =
      const MethodChannel("jailbreak_root_detection");

  static final JailbreakRootDetection _instance = JailbreakRootDetection();

  /// Creates a new instance of [JailbreakRootDetection].
  static JailbreakRootDetection get instance => _instance;

  /// Creates a new instance of [JailbreakRootDetection].
  Future<List<JailbreakIssue>> get checkForIssues async {
    final List<String>? issues =
        await methodChannel.invokeMethod<List<String>>("checkForIssues");

    return issues?.map(JailbreakIssue.fromString).toList() ??
        <JailbreakIssue>[];
  }

  /// Support iOS and Android
  Future<bool> get isJailBroken async =>
      await methodChannel.invokeMethod<bool>("isJailBroken") ?? false;

  /// Support iOS and Android
  Future<bool> get isRealDevice async =>
      await methodChannel.invokeMethod<bool>("isRealDevice") ?? false;

  /// Support Android
  Future<bool> get isDevMode async =>
      await methodChannel.invokeMethod<bool>("isDevMode") ?? false;

  /// Support iOS and Android
  Future<bool> get isDebugged async =>
      await methodChannel.invokeMethod<bool>("isDebugged") ?? false;

  /// Support iOS only
  Future<bool> isTampered(final String bundleId) async =>
      await methodChannel.invokeMethod<bool>(
        "isTampered",
        <String, String>{"bundleId": bundleId},
      ) ??
      false;

  /// Support Android only
  Future<bool> get isOnExternalStorage async =>
      await methodChannel.invokeMethod<bool>("isOnExternalStorage") ?? false;

  /// Support iOS and Android
  Future<bool> get isNotTrust async {
    try {
      final bool jailBroken = await isJailBroken;
      final bool realDevice = await isRealDevice;
      if (Platform.isAndroid) {
        final bool onExternalStorage = await isOnExternalStorage;
        return jailBroken || !realDevice || onExternalStorage;
      }
      return jailBroken || !realDevice;
    } on PlatformException {
      return true;
    }
  }
}
