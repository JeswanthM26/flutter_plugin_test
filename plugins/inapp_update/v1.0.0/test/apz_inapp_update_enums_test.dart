import "package:apz_inapp_update/apz_inapp_update_enums.dart";
import "package:flutter_test/flutter_test.dart";
void main() {
  TestWidgetsFlutterBinding.ensureInitialized(); // Required for platform channels

  // NEW GROUP FOR ENUM TESTS
  group('Enum Definitions', () {
    group('InstallStatus', () {
      test('all members have correct integer values', () {
        expect(InstallStatus.unknown.value, 0);
        expect(InstallStatus.pending.value, 1);
        expect(InstallStatus.downloading.value, 2);
        expect(InstallStatus.installing.value, 3);
        expect(InstallStatus.installed.value, 4);
        expect(InstallStatus.failed.value, 5);
        expect(InstallStatus.canceled.value, 6);
        expect(InstallStatus.downloaded.value, 11);
      });

      test('can be created from integer value', () {
        expect(InstallStatus.values.firstWhere((e) => e.value == 0), InstallStatus.unknown);
        expect(InstallStatus.values.firstWhere((e) => e.value == 1), InstallStatus.pending);
        expect(InstallStatus.values.firstWhere((e) => e.value == 2), InstallStatus.downloading);
        expect(InstallStatus.values.firstWhere((e) => e.value == 3), InstallStatus.installing);
        expect(InstallStatus.values.firstWhere((e) => e.value == 4), InstallStatus.installed);
        expect(InstallStatus.values.firstWhere((e) => e.value == 5), InstallStatus.failed);
        expect(InstallStatus.values.firstWhere((e) => e.value == 6), InstallStatus.canceled);
        expect(InstallStatus.values.firstWhere((e) => e.value == 11), InstallStatus.downloaded);
      });

      test('returns unknown for unmapped integer value', () {
        // This simulates how AppUpdateInfo.fromMap handles unmapped values
        expect(InstallStatus.values.firstWhere((e) => e.value == 99, orElse: () => InstallStatus.unknown), InstallStatus.unknown);
      });
    });

    group('UpdateAvailability', () {
      test('all members have correct integer values', () {
        expect(UpdateAvailability.unknown.value, 0);
        expect(UpdateAvailability.updateNotAvailable.value, 1);
        expect(UpdateAvailability.updateAvailable.value, 2);
        expect(UpdateAvailability.developerTriggeredUpdateInProgress.value, 3);
      });

      test('can be created from integer value', () {
        expect(UpdateAvailability.values.firstWhere((e) => e.value == 0), UpdateAvailability.unknown);
        expect(UpdateAvailability.values.firstWhere((e) => e.value == 1), UpdateAvailability.updateNotAvailable);
        expect(UpdateAvailability.values.firstWhere((e) => e.value == 2), UpdateAvailability.updateAvailable);
        expect(UpdateAvailability.values.firstWhere((e) => e.value == 3), UpdateAvailability.developerTriggeredUpdateInProgress);
      });

      test('returns unknown for unmapped integer value', () {
        // This simulates how AppUpdateInfo.fromMap handles unmapped values
        expect(UpdateAvailability.values.firstWhere((e) => e.value == 99, orElse: () => UpdateAvailability.unknown), UpdateAvailability.unknown);
      });
    });

    group('AppUpdateResult', () {
      test('all members are defined', () {
        expect(AppUpdateResult.success, isA<AppUpdateResult>());
        expect(AppUpdateResult.userDeniedUpdate, isA<AppUpdateResult>());
        expect(AppUpdateResult.inAppUpdateFailed, isA<AppUpdateResult>());
        expect(AppUpdateResult.notAvailable, isA<AppUpdateResult>());
      });

      test('equality works correctly', () {
        expect(AppUpdateResult.success, AppUpdateResult.success);
        expect(AppUpdateResult.success, isNot(AppUpdateResult.userDeniedUpdate));
      });
    });
  });
}