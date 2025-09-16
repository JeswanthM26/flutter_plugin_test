import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';

// Import your actual files
import 'package:apz_contact_picker/picked_contact_model.dart';
import 'package:apz_contact_picker/native_wrapper.dart';

void main() {

  group('PickedContact Model Tests', () {
    test('should create PickedContact with all parameters', () {
      // Arrange
      const String fullName = 'John Doe';
      const String phoneNumber = '+1234567890';
      const String email = 'john.doe@example.com';
      final Uint8List thumbnail = Uint8List.fromList([1, 2, 3, 4, 5]);

      // Act
      final contact = PickedContact(
        fullName: fullName,
        phoneNumber: phoneNumber,
        email: email,
        thumbnail: thumbnail,
      );

      // Assert
      expect(contact.fullName, equals(fullName));
      expect(contact.phoneNumber, equals(phoneNumber));
      expect(contact.email, equals(email));
      expect(contact.thumbnail, equals(thumbnail));
    });

    test('should create PickedContact with null parameters', () {
      // Act
      final contact = PickedContact();

      // Assert
      expect(contact.fullName, isNull);
      expect(contact.phoneNumber, isNull);
      expect(contact.email, isNull);
      expect(contact.thumbnail, isNull);
    });

    test('should create PickedContact from map with all fields', () {
      // Arrange
      final Uint8List thumbnail = Uint8List.fromList([1, 2, 3, 4, 5]);
      final Map<dynamic, dynamic> map = {
        'fullName': 'Jane Smith',
        'phoneNumber': '+0987654321',
        'email': 'jane.smith@example.com',
        'thumbnail': thumbnail,
      };

      // Act
      final contact = PickedContact.fromMap(map);

      // Assert
      expect(contact.fullName, equals('Jane Smith'));
      expect(contact.phoneNumber, equals('+0987654321'));
      expect(contact.email, equals('jane.smith@example.com'));
      expect(contact.thumbnail, equals(thumbnail));
    });

    test('should create PickedContact from map with missing fields', () {
      // Arrange
      final Map<dynamic, dynamic> map = {
        'fullName': 'Partial Contact',
        // phoneNumber, email, and thumbnail are missing
      };

      // Act
      final contact = PickedContact.fromMap(map);

      // Assert
      expect(contact.fullName, equals('Partial Contact'));
      expect(contact.phoneNumber, isNull);
      expect(contact.email, isNull);
      expect(contact.thumbnail, isNull);
    });

    test('should create PickedContact from empty map', () {
      // Arrange
      final Map<dynamic, dynamic> emptyMap = <dynamic, dynamic>{};

      // Act
      final contact = PickedContact.fromMap(emptyMap);

      // Assert
      expect(contact.fullName, isNull);
      expect(contact.phoneNumber, isNull);
      expect(contact.email, isNull);
      expect(contact.thumbnail, isNull);
    });

    test('should handle null values in map correctly', () {
      // Arrange
      final Map<dynamic, dynamic> map = {
        'fullName': null,
        'phoneNumber': null,
        'email': null,
        'thumbnail': null,
      };

      // Act
      final contact = PickedContact.fromMap(map);

      // Assert
      expect(contact.fullName, isNull);
      expect(contact.phoneNumber, isNull);
      expect(contact.email, isNull);
      expect(contact.thumbnail, isNull);
    });
  });

  group('NativeWrapper Tests', () {
    late NativeWrapper nativeWrapper;

    setUp(() {
      nativeWrapper = NativeWrapper();
      
      // Setup method channel mock
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('contact_picker_plugin'),
        null, // We'll set this per test
      );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('contact_picker_plugin'),
        null,
      );
    });

    testWidgets('should return null when permission is denied', 
        (WidgetTester tester) async {
      // Arrange - Mock permission as denied
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('flutter.baseflow.com/permissions/methods'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'requestPermissions') {
            return {0: 0}; // PermissionStatus.denied
          }
          return null;
        },
      );

      // Act
      final result = await nativeWrapper.pickContact();

      // Assert
      expect(result, isNull);
    });

    testWidgets('should return null when user cancels contact picker', 
        (WidgetTester tester) async {
      // Arrange
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('contact_picker_plugin'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'pickContact') {
            return null; // User cancelled
          }
          return null;
        },
      );

      // Mock permission as granted
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('flutter.baseflow.com/permissions/methods'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'requestPermissions') {
            return {0: 1}; // PermissionStatus.granted
          }
          return null;
        },
      );

      // Act
      final result = await nativeWrapper.pickContact();

      // Assert
      expect(result, isNull);
    });


    testWidgets('should handle restricted permission status', 
        (WidgetTester tester) async {
      // Arrange - Mock permission as restricted
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('flutter.baseflow.com/permissions/methods'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'requestPermissions') {
            return {0: 2}; // PermissionStatus.restricted
          }
          return null;
        },
      );

      // Act
      final result = await nativeWrapper.pickContact();

      // Assert
      expect(result, isNull);
    });

    testWidgets('should handle limited permission status', 
        (WidgetTester tester) async {
      // Arrange - Mock permission as limited
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('flutter.baseflow.com/permissions/methods'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'requestPermissions') {
            return {0: 5}; // PermissionStatus.limited
          }
          return null;
        },
      );

      // Act
      final result = await nativeWrapper.pickContact();

      // Assert
      expect(result, isNull);
    });
  });
}
