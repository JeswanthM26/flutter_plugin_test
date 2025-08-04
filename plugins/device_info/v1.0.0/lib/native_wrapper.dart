import 'package:flutter/services.dart';

class NativeWrapper {
  final MethodChannel _channel = MethodChannel('com.iexceed/device_info');

  Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      final result = await _channel.invokeMethod('getDeviceInfo');
      return (result as Map<Object?, Object?>).cast<String, dynamic>();
    } catch (e) {
      return {};
    }
  }
}
