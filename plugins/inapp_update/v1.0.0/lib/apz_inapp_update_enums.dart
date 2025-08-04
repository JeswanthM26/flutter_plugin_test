/// Status of a download/install.
///
/// For more information, see its corresponding page on
enum InstallStatus {
  /// unknown status
  unknown(0),

  /// pending status
  pending(1),

  /// download status
  downloading(2),

  /// installing status
  installing(3),

  /// installed status
  installed(4),

  /// failed status
  failed(5),

  /// cancelled status
  canceled(6),

  /// downloaded status
  downloaded(11);

  const InstallStatus(this.value);

  /// value int
  final int value;
}

/// Availability of an update for the requested package.
///
/// For more information, see its corresponding page on
enum UpdateAvailability {
  /// unknown
  unknown(0),

  /// updateNotAvailable
  updateNotAvailable(1),

  /// updateAvailable
  updateAvailable(2),

  /// developerTriggeredUpdateInProgress
  developerTriggeredUpdateInProgress(3);

  const UpdateAvailability(this.value);

  /// The integer value associated with the enum.
  final int value;
}

/// AppUpdateResult
enum AppUpdateResult {
  /// The user has accepted the update. For immediate updates, you might not
  /// receive this callback because the update should already be completed by
  /// Google Play by the time the control is given back to your app.
  success,

  /// The user has denied or cancelled the update.
  userDeniedUpdate,

  /// Some other error prevented either the user from providing consent or the
  /// update to proceed.
  inAppUpdateFailed,

  /// No update was available for the requested type,
  ///  or the type was not allowed.
  notAvailable, // Added to align with native plugin's return values
}
