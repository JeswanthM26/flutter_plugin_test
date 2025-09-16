import "package:apz_device_info/device_info_model.dart";
import "package:apz_device_info/native_wrapper.dart";

/// Singleton class to manage device information retrieval
class APZDeviceInfoManager {
  /// Factory constructor to return the singleton instance
  factory APZDeviceInfoManager() => _instance;

  APZDeviceInfoManager._internal();

  static final APZDeviceInfoManager _instance =
      APZDeviceInfoManager._internal();

  /// Loads device information asynchronously
  Future<DeviceInfoModel?> loadDeviceInfo() async {
    final NativeWrapper nativeWrapper = NativeWrapper();
    final Map<String, dynamic> infoMap = await nativeWrapper.getDeviceInfo();
    return DeviceInfoModel.fromMap(infoMap);
  }
}
