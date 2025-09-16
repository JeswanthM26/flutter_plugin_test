import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:apz_device_info/device_info_model.dart';
import 'package:apz_device_info/device_info_loader.dart';
import 'apz_device_info_test.mocks.dart';

@GenerateMocks([DeviceInfoLoader])
void main() {
  test('DeviceInfoLoader returns expected DeviceInfoModel', () async {
    final mockLoader = MockDeviceInfoLoader();

    final mockMap = {
      'id': '12345',
      'manufacturer': 'Google',
      'model': 'Pixel 5',
    };

    final expectedModel = DeviceInfoModel.fromMap(mockMap);

    when(mockLoader.loadDeviceInfo()).thenAnswer((_) async => expectedModel);

    final result = await mockLoader.loadDeviceInfo();

    expect(result, isA<DeviceInfoModel>());
    expect(result?.id, '12345');
    expect(result?.manufacturer, 'Google');
    expect(result?.model, 'Pixel 5');
  });
}
