import 'package:flutter_test/flutter_test.dart';
import 'package:apz_peripherals/apz_peripherals.dart';
import 'package:apz_peripherals/apz_peripherals_platform_interface.dart';
import 'package:apz_peripherals/apz_peripherals_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockApzPeripheralsPlatform
    with MockPlatformInterfaceMixin
    implements ApzPeripheralsPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
  
  @override
  Future<int?> getBatteryLevel() => Future.value(100);
  
  @override
  Future<bool?> isBluetoothSupported() => Future.value(true);

  @override
  Future<bool?> isNFCSupported() => Future.value(true);
}

void main() {
  final ApzPeripheralsPlatform initialPlatform = ApzPeripheralsPlatform.instance;

  test('$MethodChannelApzPeripherals is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelApzPeripherals>());
  });

  test('getPlatformVersion', () async {
    APZPeripherals apzPeripheralsPlugin = APZPeripherals();
    MockApzPeripheralsPlatform fakePlatform = MockApzPeripheralsPlatform();
    ApzPeripheralsPlatform.instance = fakePlatform;

    expect(await apzPeripheralsPlugin.getPlatformVersion(), '42');
  });

  test('getBatteryLevel', () async {
    APZPeripherals apzPeripheralsPlugin = APZPeripherals();
    MockApzPeripheralsPlatform fakePlatform = MockApzPeripheralsPlatform();
    ApzPeripheralsPlatform.instance = fakePlatform;

    expect(await apzPeripheralsPlugin.getBatteryLevel(), 100);
  });
  
  test('isBluetoothSupported', () async {
    APZPeripherals apzPeripheralsPlugin = APZPeripherals();
    MockApzPeripheralsPlatform fakePlatform = MockApzPeripheralsPlatform();
    ApzPeripheralsPlatform.instance = fakePlatform;

    expect(await apzPeripheralsPlugin.isBluetoothSupported(), true);
  });

  test('isNFCSupported', () async {
    APZPeripherals apzPeripheralsPlugin = APZPeripherals();
    MockApzPeripheralsPlatform fakePlatform = MockApzPeripheralsPlatform();
    ApzPeripheralsPlatform.instance = fakePlatform;

    expect(await apzPeripheralsPlugin.isNFCSupported(), true);
  });
}
