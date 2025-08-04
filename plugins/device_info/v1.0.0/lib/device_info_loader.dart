import 'package:apz_device_info/device_info_model.dart';

abstract class DeviceInfoLoader {
  Future<DeviceInfoModel?> loadDeviceInfo();
}
