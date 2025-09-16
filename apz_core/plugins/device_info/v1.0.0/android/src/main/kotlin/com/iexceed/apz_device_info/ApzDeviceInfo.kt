package com.iexceed.apz_device_info

import android.os.Build
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import android.content.Context


/** ApzDeviceInfo */
class ApzDeviceInfo: FlutterPlugin, MethodCallHandler {

  private lateinit var channel : MethodChannel
  private lateinit var context: Context


  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.iexceed/device_info")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    if (call.method == "getDeviceInfo") {
      result.success(getDeviceInfo())
    } else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  private fun getDeviceInfo(): Map<String, Any> {
        val info = mutableMapOf<String, Any>()
        val contentResolver = context.contentResolver

        info["board"] = Build.BOARD
        info["bootloader"] = Build.BOOTLOADER
        info["brand"] = Build.BRAND
        info["deviceName"] = Build.DEVICE
        info["display"] = Build.DISPLAY
        info["fingerprint"] = Build.FINGERPRINT
        info["hardware"] = Build.HARDWARE
        info["host"] = Build.HOST
        info["id"] = Build.ID
        info["manufacturer"] = Build.MANUFACTURER
        info["model"] = Build.MODEL
        info["product"] = Build.PRODUCT
        info["name"] = Build.DEVICE
        info["tags"] = Build.TAGS
        info["type"] = Build.TYPE

        val version: MutableMap<String, Any> = HashMap()
        version["codename"] = Build.VERSION.CODENAME
        version["incremental"] = Build.VERSION.INCREMENTAL
        version["release"] = Build.VERSION.RELEASE
        version["sdkInt"] = Build.VERSION.SDK_INT

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            version["baseOS"] = Build.VERSION.BASE_OS
            version["previewSdkInt"] = Build.VERSION.PREVIEW_SDK_INT
            version["securityPatch"] = Build.VERSION.SECURITY_PATCH
        }

        info["version"] = version
        return info
    }
}
