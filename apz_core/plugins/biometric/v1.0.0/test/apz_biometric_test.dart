import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mockito/mockito.dart';
import 'package:apz_biometric/apz_biometric.dart';

import 'mocks.mocks.dart';

void main() {
  late ApzBiometric apzBiometric;
  late MockLocalAuthentication mockAuth;

  setUp(() {
    mockAuth = MockLocalAuthentication();
    apzBiometric = ApzBiometric(auth: mockAuth);
  });

  group('ApzBiometric', () {
    test('should return true when biometric is supported', () async {
      when(mockAuth.isDeviceSupported()).thenAnswer((_) async => true);

      final result = await apzBiometric.isBiometricSupported();

      expect(result, true);
      verify(mockAuth.isDeviceSupported()).called(1);
    });

    test('should return list of biometrics', () async {
      when(
        mockAuth.getAvailableBiometrics(),
      ).thenAnswer((_) async => [BiometricType.fingerprint]);

      final biometrics = await apzBiometric.fetchAvailableBiometrics();

      expect(biometrics, contains(BiometricType.fingerprint));
      verify(mockAuth.getAvailableBiometrics()).called(1);
    });

    test('should return success AuthResult when authenticated', () async {
      when(
        mockAuth.authenticate(
          localizedReason: anyNamed('localizedReason'),
          authMessages: anyNamed('authMessages'),
          options: anyNamed('options'),
        ),
      ).thenAnswer((_) async => true);

      final result = await apzBiometric.authenticate(
        reason: 'Login',
        stickyAuth: true,
        biometricOnly: true,
      );

      expect(result.status, true);
      expect(result.message, 'Authentication successful');
    });

    test('should return failed AuthResult when canceled', () async {
      when(
        mockAuth.authenticate(
          localizedReason: anyNamed('localizedReason'),
          authMessages: anyNamed('authMessages'),
          options: anyNamed('options'),
        ),
      ).thenAnswer((_) async => false);

      final result = await apzBiometric.authenticate(
        reason: 'Login',
        stickyAuth: true,
        biometricOnly: true,
      );

      expect(result.status, false);
      expect(result.message, 'Authentication canceled by user');
    });

    test('should return error AuthResult on exception', () async {
      when(
        mockAuth.authenticate(
          localizedReason: anyNamed('localizedReason'),
          authMessages: anyNamed('authMessages'),
          options: anyNamed('options'),
        ),
      ).thenThrow(PlatformException(code: 'AUTH_ERROR', message: 'Failed'));

      final result = await apzBiometric.authenticate(
        reason: 'Login',
        stickyAuth: true,
        biometricOnly: true,
      );

      expect(result.status, false);
      expect(result.message, contains('Error'));
    });
  });
}
