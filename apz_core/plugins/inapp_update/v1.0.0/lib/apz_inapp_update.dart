import "dart:async";
import "dart:io";

import "package:apz_inapp_update/apz_inapp_update_enums.dart";
import "package:apz_utils/apz_utils.dart";
import "package:flutter/foundation.dart";
import "package:flutter/services.dart";

/// ApzInAppUpdate class
class ApzInAppUpdate {
  /// singleton factoy instance
  factory ApzInAppUpdate() => _instance;

  ApzInAppUpdate._internal();

  /// Singleton instance
  static final ApzInAppUpdate _instance = ApzInAppUpdate._internal();
  static const MethodChannel _channel = MethodChannel(
    "apz_inapp_update/methods",
  );
  static const EventChannel _installListener = EventChannel(
    "apz_inapp_update/stateEvents",
  );

  /// for Testing purpose
  @visibleForTesting
  static bool? isAndroidForTest;

  /// Has to be called before being able to start any update.
  Future<AppUpdateInfo> checkForUpdate() async {
    if (kIsWeb || !(isAndroidForTest ?? Platform.isAndroid)) {
      throw UnsupportedPlatformException(
        "checkForUpdate is only supported on Android (non-web platforms).",
      );
    }

    final Map<dynamic, dynamic>? result = await _channel.invokeMethod(
      "checkForUpdate",
    );

    if (result == null) {
      throw PlatformException(
        code: "NULL_RESULT",
        message: "checkForUpdate returned null result.",
      );
    }

    return AppUpdateInfo.fromMap(result);
  }

  /// Getter installerListner
  Stream<InstallStatus> get installUpdateListener {
    if (kIsWeb || !(isAndroidForTest ?? Platform.isAndroid)) {
      throw UnsupportedPlatformException(
        "Install listener is only supported on Android (non-web platforms).",
      );
    }
    return _installListener.receiveBroadcastStream().cast<int>().map((
      final int value,
    ) {
      switch (value) {
        case 0:
          return InstallStatus.unknown;
        case 1:
          return InstallStatus.pending;
        case 2:
          return InstallStatus.downloading;
        case 3:
          return InstallStatus.installing;
        case 4:
          return InstallStatus.installed;
        case 5:
          return InstallStatus.failed;
        case 6:
          return InstallStatus.canceled;
        case 11:
          return InstallStatus.downloaded;
        default:
          return InstallStatus.unknown;
      }
    });
  }

  /// Performs an immediate update that is entirely handled by the Play API.
  /// [checkForUpdate] has to be called first to be able to run this.
  Future<AppUpdateResult> performImmediateUpdate() async {
    if (kIsWeb || !(isAndroidForTest ?? Platform.isAndroid)) {
      throw UnsupportedPlatformException(
        "Immediate update is only supported on Android (non-web platforms).",
      );
    }
    try {
      await _channel.invokeMethod("performImmediateUpdate");
      return AppUpdateResult.success;
    } on PlatformException catch (e) {
      if (e.code == "USER_DENIED_UPDATE") {
        return AppUpdateResult.userDeniedUpdate;
      } else if (e.code == "IN_APP_UPDATE_FAILED") {
        return AppUpdateResult.inAppUpdateFailed;
      }

      rethrow;
    }
  }

  /// Starts the download of the app update.
  Future<AppUpdateResult> startFlexibleUpdate() async {
    if (kIsWeb || !(isAndroidForTest ?? Platform.isAndroid)) {
      throw UnsupportedPlatformException(
        "Flexible update is only supported on Android (non-web platforms).",
      );
    }
    try {
      await _channel.invokeMethod("startFlexibleUpdate");
      return AppUpdateResult.success;
    } on PlatformException catch (e) {
      if (e.code == "USER_DENIED_UPDATE") {
        return AppUpdateResult.userDeniedUpdate;
      } else if (e.code == "IN_APP_UPDATE_FAILED") {
        return AppUpdateResult.inAppUpdateFailed;
      }

      rethrow;
    }
  }

  /// Installs the update downloaded via [startFlexibleUpdate].
  Future<void> completeFlexibleUpdate() async {
    if (kIsWeb || !(isAndroidForTest ?? Platform.isAndroid)) {
      throw UnsupportedPlatformException(
        "Completing flexible update is only supported on Android (non-web).",
      );
    }
    return _channel.invokeMethod("completeFlexibleUpdate");
  }
}

/// Contains information about the availability and progress of an app
@immutable
class AppUpdateInfo {
  /// constructor
  const AppUpdateInfo({
    required this.updateAvailability,
    required this.immediateUpdateAllowed,
    required this.immediateAllowedPreconditions,
    required this.flexibleUpdateAllowed,
    required this.flexibleAllowedPreconditions,
    required this.availableVersionCode,
    required this.installStatus,
    required this.packageName,
    required this.clientVersionStalenessDays,
    required this.updatePriority,
  });

  /// Factory constructor to create AppUpdateInfo from the native map result.
  factory AppUpdateInfo.fromMap(final Map<dynamic, dynamic> map) =>
      AppUpdateInfo(
        availableVersionCode: map["availableVersionCode"] as int?,
        immediateUpdateAllowed: map["isImmediateUpdateAllowed"] as bool,
        // CORRECTED: Safely cast and map list elements
        immediateAllowedPreconditions:
            (map["immediateAllowedPreconditions"] as List<Object?>)
                .map<int>((final Object? e) => e! as int)
                .toList(),
        flexibleUpdateAllowed:
            map["isFlexibleUpdateAllowed"]
                as bool, // Corrected key to match Kotlin
        // CORRECTED: Safely cast and map list elements
        flexibleAllowedPreconditions:
            (map["flexibleAllowedPreconditions"] as List<Object?>)
                .map<int>((final Object? e) => e! as int)
                .toList(),
        installStatus: InstallStatus.values.firstWhere(
          (final InstallStatus element) =>
              element.value == (map["installStatus"] ?? 0),
          orElse: () => InstallStatus.unknown,
        ),
        packageName: map["packageName"] as String,
        clientVersionStalenessDays: map["clientVersionStalenessDays"] as int?,
        updatePriority: map["updatePriority"] as int,
        updateAvailability: UpdateAvailability.values.firstWhere(
          (final UpdateAvailability element) =>
              element.value == (map["updateAvailability"] ?? 0),
          orElse: () => UpdateAvailability.unknown,
        ),
      );

  /// This is a value from [UpdateAvailability].
  final UpdateAvailability updateAvailability;

  /// Whether an immediate update is allowed.
  final bool immediateUpdateAllowed;

  /// determine the reason why an update cannot be started
  final List<int>? immediateAllowedPreconditions;

  /// Whether a flexible update is allowed.
  final bool flexibleUpdateAllowed;

  /// determine the reason why an update cannot be started
  final List<int>? flexibleAllowedPreconditions;

  /// If no updates are available, this is an arbitrary value.
  final int? availableVersionCode;

  /// This is a value from [InstallStatus].
  final InstallStatus installStatus;

  /// The package name for the app to be updated.
  final String packageName;

  /// The in-app update priority for this update, as defined by the developer
  final int updatePriority;

  /// The number of days since the Google Play Store app on the user"s device
  final int? clientVersionStalenessDays;

  @override
  bool operator ==(final Object other) =>
      identical(this, other) ||
      other is AppUpdateInfo &&
          runtimeType == other.runtimeType &&
          updateAvailability == other.updateAvailability &&
          immediateUpdateAllowed == other.immediateUpdateAllowed &&
          immediateAllowedPreconditions ==
              other.immediateAllowedPreconditions &&
          flexibleUpdateAllowed == other.flexibleUpdateAllowed &&
          flexibleAllowedPreconditions == other.flexibleAllowedPreconditions &&
          availableVersionCode == other.availableVersionCode &&
          installStatus == other.installStatus &&
          packageName == other.packageName &&
          clientVersionStalenessDays == other.clientVersionStalenessDays &&
          updatePriority == other.updatePriority;

  @override
  int get hashCode =>
      updateAvailability.hashCode ^
      immediateUpdateAllowed.hashCode ^
      immediateAllowedPreconditions.hashCode ^
      flexibleUpdateAllowed.hashCode ^
      flexibleAllowedPreconditions.hashCode ^
      availableVersionCode.hashCode ^
      installStatus.hashCode ^
      packageName.hashCode ^
      clientVersionStalenessDays.hashCode ^
      updatePriority.hashCode;

  @override
  String toString() =>
      "InAppUpdateState{updateAvailability: $updateAvailability, "
      "immediateUpdateAllowed: $immediateUpdateAllowed, "
      "immediateAllowedPreconditions: $immediateAllowedPreconditions, "
      "flexibleUpdateAllowed: $flexibleUpdateAllowed, "
      "flexibleAllowedPreconditions: $flexibleAllowedPreconditions, "
      "availableVersionCode: $availableVersionCode, "
      "installStatus: $installStatus, "
      "packageName: $packageName, "
      "clientVersionStalenessDays: $clientVersionStalenessDays, "
      "updatePriority: $updatePriority}";
}
