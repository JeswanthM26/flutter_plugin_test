
import "package:apz_network_state_perm/apz_network_state_perm.dart";
import "package:apz_network_state_perm/native_wrapper.dart";
import "package:apz_network_state_perm/network_state_model.dart";
import 'package:apz_utils/apz_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:permission_handler/permission_handler.dart';

// Mock classes
class MockNativeWrapper extends Mock implements NativeWrapper {}

void main() {
   TestWidgetsFlutterBinding.ensureInitialized();
  late ApzNetworkStatePerm apzNetworkState;
  late MockNativeWrapper mockNativeWrapper;

  // Set up mock method channel for PermissionHandler
  const MethodChannel permissionChannel =
      MethodChannel('flutter.baseflow.com/permissions/methods');

  setUp(() {
    mockNativeWrapper = MockNativeWrapper();
    apzNetworkState = ApzNetworkStatePerm();

    // Set up a mock handler for the permission channel to control permission responses
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      permissionChannel,
      (MethodCall methodCall) async {
        if (methodCall.method == 'requestPermissions') {
          // Default to granted, specific tests will override this
          return {Permission.phone.value: PermissionStatus.granted.index,
          Permission.location.value: PermissionStatus.granted.index}; // 1 for granted
        }
        return null;
      },
    );
  });

  tearDown(() {
    // Reset mock handlers for permission channel
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      permissionChannel,
      null,
    );
  });


  group('ApzNetworkState', () {
    final tNetworkStateModel = NetworkStateModel(
      carrierName: "Test Carrier",
      mcc: "123",
      mnc: "456",
      networkType: "LTE",
      connectionType: "cellular",
      isVpn: false,
      ipAddress: "192.168.1.1",
      bandwidthMbps: 100,
      ssid: "TestWiFi",
      signalStrengthLevel: 3,
      latency: 10.1
    );

    test('getNetworkState returns NetworkStateModel on successful call', () async {
      // Arrange
      // Mock the MethodChannel for NativeWrapper.getNetworkDetails()
      const MethodChannel networkInfoChannel = MethodChannel("network_info_plugin");
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        networkInfoChannel,
        (MethodCall methodCall) async {
          if (methodCall.method == 'getNetworkDetails') {
            return tNetworkStateModel.toMap();
          }
          return null;
        },
      );

      // Act
      final result = await apzNetworkState.getNetworkState();

      // Assert
      expect(result, isA<NetworkStateModel>());
      expect(result!.carrierName, tNetworkStateModel.carrierName);
      expect(result.mcc, tNetworkStateModel.mcc);
      expect(result.mnc, tNetworkStateModel.mnc);
      expect(result.networkType, tNetworkStateModel.networkType);
      expect(result.connectionType, tNetworkStateModel.connectionType);
      expect(result.isVpn, tNetworkStateModel.isVpn);
      expect(result.ipAddress, tNetworkStateModel.ipAddress);
      expect(result.bandwidthMbps, tNetworkStateModel.bandwidthMbps);
      expect(result.ssid, tNetworkStateModel.ssid);
      expect(result.signalStrengthLevel, tNetworkStateModel.signalStrengthLevel);

      // Clean up the mock handler for NativeWrapper's channel
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        networkInfoChannel,
        null,
      );
    });

   test(
    'getNetworkState throws PermissionException when phone permission is denied',
    () async {
      // Arrange: simulate denied permission
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(permissionChannel,
              (MethodCall methodCall) async {
        if (methodCall.method == 'requestPermissions') {
          return {
            Permission.phone.value: PermissionStatus.denied.index,
            Permission.location.value: PermissionStatus.granted.index,
          };
        }
        return null;
      });

      // Act & Assert
      try {
        await apzNetworkState.getNetworkState();
        fail('Expected a PermissionException, but none was thrown.');
      } on PermissionException catch (e) {
        expect(e.status, PermissionsExceptionStatus.denied);
        expect(e.message, "Phone permission not granted.");
      } catch (e) {
        fail('Expected PermissionException, but got ${e.runtimeType}: $e');
      }
    },
  );

    test('getNetworkState throws PermissionException when phone permission is permanently denied', () async {
      // Arrange
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        permissionChannel,
        (MethodCall methodCall) async {
          if (methodCall.method == 'requestPermissions') {
            return {
              Permission.phone.value: PermissionStatus.permanentlyDenied.index,
               Permission.location.value: PermissionStatus.granted.index}; // 2 for permanentlyDenied
          }
          return null;
        },
      );

      // Act & Assert
      try {
        await apzNetworkState.getNetworkState();
        fail('Expected a PermissionException, but none was thrown.');
      } on PermissionException catch (e) {
        expect(e.status, PermissionsExceptionStatus.permanentlyDenied);
        expect(e.message, "Phone permission permanently denied. Please enable it from settings.");
      } catch (e) {
        fail('Expected PermissionException, but caught ${e.runtimeType}: $e');
      }
    });

    test('getNetworkState throws PermissionException when phone permission is restricted', () async {
      // Arrange
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        permissionChannel,
        (MethodCall methodCall) async {
          if (methodCall.method == 'requestPermissions') {
            return {
              Permission.phone.value: PermissionStatus.restricted.index,
               Permission.location.value: PermissionStatus.restricted.index}; // 3 for restricted
          }
          return null;
        },
      );

      // Act & Assert
      try {
        await apzNetworkState.getNetworkState();
        fail('Expected a PermissionException, but none was thrown.');
      } on PermissionException catch (e) {
        expect(e.status, PermissionsExceptionStatus.restricted);
        expect(e.message, "Phone access restricted or not fully granted. Please check your device settings.");
      } catch (e) {
        fail('Expected PermissionException, but caught ${e.runtimeType}: $e');
      }
    });

  
  });

  group('NetworkStateModel.fromMap', () {
    test('creates a NetworkStateModel from a valid map', () {
      final Map<String, dynamic> map = {
        "carrierName": "Test Carrier",
        "mcc": "123",
        "mnc": "456",
        "networkType": "LTE",
        "connectionType": "cellular",
        "isVpn": false,
        "ipAddress": "192.168.1.1",
        "bandwidthMbps": 100,
        "ssid": "TestWiFi",
        "signalStrengthLevel": 3,
      };

      final model = NetworkStateModel.fromMap(map);

      expect(model.carrierName, "Test Carrier");
      expect(model.mcc, "123");
      expect(model.mnc, "456");
      expect(model.networkType, "LTE");
      expect(model.connectionType, "cellular");
      expect(model.isVpn, false);
      expect(model.ipAddress, "192.168.1.1");
      expect(model.bandwidthMbps, 100);
      expect(model.ssid, "TestWiFi");
      expect(model.signalStrengthLevel, 3);
    });

    test('creates a NetworkStateModel with default values for missing keys', () {
      final Map<String, dynamic> map = {
        "networkType": "WiFi",
        "bandwidthMbps": 50.0,
        "ssid": "HomeWiFi",
      };

      final model = NetworkStateModel.fromMap(map);

      expect(model.carrierName, "");
      expect(model.mcc, "");
      expect(model.mnc, "");
      expect(model.networkType, "WiFi");
      expect(model.connectionType, "");
      expect(model.isVpn, false);
      expect(model.ipAddress, "");
      expect(model.bandwidthMbps, 50.0);
      expect(model.ssid, "HomeWiFi");
      //expect(model.signalStrengthLevel, -1);
    });
  });

  group('NetworkStateModel.toMap', () {
    test('converts NetworkStateModel to a map', () {
      final model = NetworkStateModel(
        carrierName: "Test Carrier",
        mcc: "123",
        mnc: "456",
        networkType: "LTE",
        connectionType: "cellular",
        isVpn: false,
        ipAddress: "192.168.1.1",
        bandwidthMbps: 100,
        ssid: "TestWiFi",
        signalStrengthLevel: 3,
        latency: 10.1
      );

      final map = model.toMap();

      expect(map["carrierName"], "Test Carrier");
      expect(map["mcc"], "123");
      expect(map["mnc"], "456");
      expect(map["networkType"], "LTE");
      expect(map["isVpn"], false);
      expect(map["ipAddress"], "192.168.1.1");
      expect(map["bandwidthMbps"], 100);
      expect(map["ssid"], "TestWiFi");
      expect(map["signalStrengthLevel"], 3);
    });
  });
}