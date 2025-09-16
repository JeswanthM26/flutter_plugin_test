import 'package:apz_contact/apz_contact.dart';
import 'package:apz_contact/contacts_model.dart';
import 'package:apz_contact/native_wrapper.dart';
import 'package:apz_utils/apz_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:permission_handler/permission_handler.dart';

class MockNativeWrapperContacts extends Mock implements NativeWrapperContacts {}
class MockPermissionService extends Mock implements PermissionService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockNativeWrapperContacts mockNativeWrapper;
  late MockPermissionService mockPermissionService;
  late ApzContact contactsFetcher;

  setUp(() {
    mockNativeWrapper = MockNativeWrapperContacts();
    mockPermissionService = MockPermissionService();

    contactsFetcher = ApzContact()
    ..setNativeWrapper(mockNativeWrapper)
    ..setPermissionService(mockPermissionService);
  });

  test('should return contacts on granted permission', () async {
    // Arrange
    when(() => mockPermissionService.requestContactsPermission())
        .thenAnswer((_) async => PermissionStatus.granted);

    when(() => mockNativeWrapper.getContacts(
      fetchEmail: any(named: 'fetchEmail'),
      fetchPhoto: any(named: 'fetchPhoto'),
      searchQuery: any(named: 'searchQuery'),
    )).thenAnswer((_) async => [
      {'name': 'John', 'phone': '12345'},
      {'name': 'Jane', 'phone': '67890'},
    ]);

    // Act
    final result = await contactsFetcher.loadContacts();

    // Assert
    expect(result, isA<ContactsModel>());
    expect(result.contacts.length, 2);
  });

  test('throws PermissionException if permission is denied', () async {
    // Arrange
    when(() =>mockPermissionService.requestContactsPermission())
        .thenAnswer((_) async => PermissionStatus.denied);

    // Act & Assert
    expect(
      () async => await contactsFetcher.loadContacts(),
      throwsA(isA<PermissionException>().having((e) => e.status,
          'status', PermissionsExceptionStatus.denied)),
    );

    verify(() =>mockPermissionService.requestContactsPermission()).called(1);
  });

  test('throws PermissionException if permission is permanently denied', () async {
    // Arrange
    when(() =>mockPermissionService.requestContactsPermission())
        .thenAnswer((_) async => PermissionStatus.permanentlyDenied);

    // Act & Assert
    expect(
      () async => await contactsFetcher.loadContacts(),
      throwsA(isA<PermissionException>().having(
          (e) => e.status, 'status', PermissionsExceptionStatus.permanentlyDenied)),
    );

    verify(() =>mockPermissionService.requestContactsPermission()).called(1);
  });

  test('throws PermissionException if permission is restricted', () async {
    // Arrange
    when(() =>mockPermissionService.requestContactsPermission())
        .thenAnswer((_) async => PermissionStatus.restricted);

    // Act & Assert
    expect(
      () async => await contactsFetcher.loadContacts(),
      throwsA(isA<PermissionException>().having(
          (e) => e.status, 'status', PermissionsExceptionStatus.restricted)),
    );

    verify(() =>mockPermissionService.requestContactsPermission()).called(1);
  });

  test('performance test with 1000 contacts', () async {
    // Arrange
    when(() =>mockPermissionService.requestContactsPermission())
        .thenAnswer((_) async => PermissionStatus.granted);

    final List<Map<String, dynamic>> testContacts = List.generate(1000, (index) {
      return {
        'name': 'Contact $index',
        'phone': '900000${index.toString().padLeft(4, '0')}',
      };
    });

    when(() => mockNativeWrapper.getContacts(
      fetchEmail: any(named: 'fetchEmail'),
      fetchPhoto: any(named: 'fetchPhoto'),
      searchQuery: any(named: 'searchQuery'),
    )).thenAnswer((_) async => testContacts);

    // Act
    final stopwatch = Stopwatch()..start();
    final result = await contactsFetcher.loadContacts();
    stopwatch.stop();

    final durationMs = stopwatch.elapsedMilliseconds;

    // Assert
    expect(result.contacts.length, 1000);
    expect(durationMs, lessThan(1000),
        reason: 'Should load under 1 second');
    print('⏱️ Loaded 1000 contacts in $durationMs ms');
  });

  group('Edge cases', () {
    test('should handle empty contacts list', () async {
      // Arrange
      when(() =>mockPermissionService.requestContactsPermission())
          .thenAnswer((_) async => PermissionStatus.granted);

      when(() => mockNativeWrapper.getContacts(
        fetchEmail: any(named: 'fetchEmail'),
        fetchPhoto: any(named: 'fetchPhoto'),
        searchQuery: any(named: 'searchQuery'),
      )).thenAnswer((_) async => []);

      // Act
      final result = await contactsFetcher.loadContacts();

      // Assert
      expect(result, isA<ContactsModel>());
      expect(result.contacts.length, 0);
    });

    test('should handle native wrapper throwing exception', () async {
      // Arrange
      when(() =>mockPermissionService.requestContactsPermission())
          .thenAnswer((_) async => PermissionStatus.granted);

      when(() => mockNativeWrapper.getContacts(
        fetchEmail: any(named: 'fetchEmail'),
        fetchPhoto: any(named: 'fetchPhoto'),
        searchQuery: any(named: 'searchQuery'),
      )).thenThrow(Exception('Native error'));

      // Act & Assert
      expect(
        () async => await contactsFetcher.loadContacts(),
        throwsA(isA<Exception>()),
      );
    });
  });
}
