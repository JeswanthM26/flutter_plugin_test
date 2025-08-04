import 'native_wrapper.dart';
import 'package:apz_device_info/device_info_model.dart';

class APZDeviceInfoManager {
  static final APZDeviceInfoManager _instance =
      APZDeviceInfoManager._internal();

  factory APZDeviceInfoManager() {
    return _instance;
  }

  APZDeviceInfoManager._internal();

  Future<DeviceInfoModel?> loadDeviceInfo() async {
    final nativeWrapper = NativeWrapper();
    final infoMap = await nativeWrapper.getDeviceInfo();
    return DeviceInfoModel.fromMap(infoMap);
  }
}
