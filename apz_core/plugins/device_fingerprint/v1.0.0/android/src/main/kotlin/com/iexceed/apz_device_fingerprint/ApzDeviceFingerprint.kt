package com.iexceed.apz_device_fingerprint

import android.app.Activity
import android.content.Context
import com.google.android.play.core.review.ReviewManagerFactory
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import android.annotation.SuppressLint
import android.app.ActivityManager
import android.graphics.Point
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.os.Build
import android.os.Environment
import android.os.StatFs
import android.provider.Settings
import android.view.WindowManager
import java.nio.ByteOrder
import java.time.ZoneId

/** ApzDeviceFingerprint */
class ApzDeviceFingerprint : FlutterPlugin, MethodCallHandler, ActivityAware {
  private lateinit var channel: MethodChannel
  private lateinit var context: Context
  private var activity: Activity? = null

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.iexceed/apz_device_fingerprint")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onAttachedToActivity(flutterPluginBinding: ActivityPluginBinding) {
    activity = flutterPluginBinding.activity
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    val manager = ReviewManagerFactory.create(context)
    when (call.method) {
      "getDeviceFingerprint" -> {
        val currentActivity = activity
        if (currentActivity != null) {
          val data = getData(currentActivity)
          result.success(data)
        } else {
          result.error("ACTIVITY_UNAVAILABLE", "Activity is not attached to the plugin.", null)
        }
      }
      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromActivity() {
    activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
    activity = null
  }
  
  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  private fun getData(context: Context): Map<String, String> {
        val nullString = "null"
        var data: MutableMap<String, String> = mutableMapOf()

        data["source"] = "Android"

        val secureId = getAndroidId(context)
        if (!secureId.isNullOrEmpty()) {
          data["secureId"] = secureId
        } else {
          data["secureId"] = nullString
        }

        val deviceManufacturer = getDeviceManufacturer()
        data["deviceManufacturer"] = deviceManufacturer

        val deviceModel = getDeviceModel()
        data["deviceModel"] = deviceModel

        val screenResolution = getScreenResolution(context)
        data["screenResolution"] = "${screenResolution.first} x ${screenResolution.second} pixels"

        data["deviceType"] = "N/A"

        val totalDiskSpace = getTotalDiskSpace()
        data["totalDiskSpace"] = "$totalDiskSpace GB"

        val totalRAM = getTotalRAM(context)
        data["totalRAM"] = "$totalRAM GB"

        val cpuCount = getCPUCount()
        data["cpuCount"] = "$cpuCount"

        val cpuArchitecture = getCPUArchitecture()
        data["cpuArchitecture"] = cpuArchitecture

        val cpuEndianness = getCPUEndianness()
        data["cpuEndianness"] = cpuEndianness

        val deviceName = getDeviceName(context)
        data["deviceName"] = deviceName

        val glesVersion = getGLESVersion(context)
        if (glesVersion.isNotEmpty()) {
          data["glesVersion"] = glesVersion
        } else {
          data["glesVersion"] = nullString
        }

        val osVersion = getOSVersion()
        data["osVersion"] = osVersion

        val osBuildNumber = getOSBuildNumber()
        data["osBuildNumber"] = osBuildNumber

        val kernelVersion = getKernelVersion()
        if (!kernelVersion.isNullOrEmpty()) {
          data["kernelVersion"] = kernelVersion
        } else {
          data["kernelVersion"] = nullString
        }

        val enabledKeyboardLanguages = getEnabledKeyboardLanguages(context)
        if (enabledKeyboardLanguages.isNotEmpty()) {
          data["enabledKeyboardLanguages"] = enabledKeyboardLanguages.joinToString(",")
        } else {
          data["enabledKeyboardLanguages"] = nullString
        }

        data["installId"] = ""

        val timeZone = getTimeZone()
        data["timeZone"] = timeZone

        val connectionType = getCurrentNetworkConnectionType(context)
        data["connectionType"] = connectionType

        val freeDiskSpace = getFreeDiskSpace()
        data["freeDiskSpace"] = "$freeDiskSpace GB"

        return data
    }

    // Will not change
    @SuppressLint("HardwareIds")
    private fun getAndroidId(context: Context): String? {
        val androidId = Settings.Secure.getString(context.contentResolver, Settings.Secure.ANDROID_ID)
        return androidId
    }

    // Will not change
    private fun getDeviceManufacturer(): String {
        val manufacturer = Build.MANUFACTURER
        return manufacturer
    }

    // Will not change
    private fun getDeviceModel(): String {
        val deviceModel = Build.MODEL
        return deviceModel
    }

    // Will not change
    private fun getScreenResolution(context: Context): Pair<Int, Int> {

        val width: Int
        val height: Int

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val windowManager = context.getSystemService(Context.WINDOW_SERVICE) as? WindowManager
            val windowMetrics = windowManager?.currentWindowMetrics
            val bounds = windowMetrics?.bounds
            width = bounds?.width() ?: 0
            height = bounds?.height() ?: 0
        }else {
            val windowManager = context.getSystemService(Context.WINDOW_SERVICE) as? WindowManager
            val display = windowManager?.defaultDisplay
            val size = Point()
            display?.getRealSize(size)
            width = size.x
            height = size.y
        }

        return Pair(width, height)
    }

    // Will not change
    private fun getTotalDiskSpace(): Long {
        val stat = StatFs(Environment.getDataDirectory().path)
        val totalBytes = stat.totalBytes
        return totalBytes / (1024 * 1024 * 1024)
    }

    // Will not change
    private fun getTotalRAM(context: Context): Long {
        val activityManager = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val memoryInfo = ActivityManager.MemoryInfo()
        activityManager.getMemoryInfo(memoryInfo)
        val totalRamBytes = memoryInfo.totalMem
        return totalRamBytes / (1024 * 1024 * 1024)
    }

    // Will not change
    private fun getCPUCount(): Int {
        val cpuCount = Runtime.getRuntime().availableProcessors()
        return cpuCount
    }

    // Will not change
    private fun getCPUArchitecture(): String {
        val architecture = Build.SUPPORTED_ABIS[0]
        return architecture
    }

    // Will not change
    private fun getCPUEndianness(): String {
        return if (ByteOrder.nativeOrder() == ByteOrder.BIG_ENDIAN) {
            "Big-Endian"
        } else {
            "Little-Endian"
        }
    }

    // Can change by user
    private fun getDeviceName(context: Context): String {
        val deviceName = Settings.Global.getString(context.contentResolver, Settings.Global.DEVICE_NAME)
        return deviceName
    }

    // Will change on OS update
    private fun getGLESVersion(context: Context): String {
        val activityManager = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val configInfo = activityManager.deviceConfigurationInfo
        return if (configInfo.reqGlEsVersion != 0) {
            val majorVersion = configInfo.reqGlEsVersion shr 16
            val minorVersion = configInfo.reqGlEsVersion and 0xFFFF
            "$majorVersion.$minorVersion"
        } else {
            ""
        }
    }

    // Will change on OS update
    private fun getOSVersion(): String {
        val osVersion = Build.VERSION.RELEASE
        return osVersion
    }

    // Will change on OS update
    private fun getOSBuildNumber(): String {
        val buildNumber = Build.ID
        return buildNumber
    }

    // Will change on OS update
    private fun getKernelVersion(): String? {
        val kernelVersion = System.getProperty("os.version")
        return kernelVersion
    }

    // This will change rarely
    private fun getEnabledKeyboardLanguages(context: Context): List<String> {
//        LocalList locals = context.getResources().getConfiguration().getLocales()
        val locals = context.resources.configuration.locales
        val localeStrings = mutableListOf<String>()
        for (i in 0 until locals.size()) {
            localeStrings.add(locals[i].toString())
        }

        return localeStrings
    }

    private fun getTimeZone(): String {
      val zoneId = ZoneId.systemDefault()
      val timeZoneId = zoneId.id
      return timeZoneId
    }

    // Will change
    private fun getCurrentNetworkConnectionType(context: Context): String {
        val connectivityManager = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager

        val network = connectivityManager.activeNetwork // Get the currently active default network
        val capabilities = connectivityManager.getNetworkCapabilities(network) // Get capabilities for that network

        return when {
            capabilities == null -> "NONE" // No active network or capabilities
            capabilities.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) -> "WIFI"
            capabilities.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR) -> "CELLULAR"
            capabilities.hasTransport(NetworkCapabilities.TRANSPORT_ETHERNET) -> "ETHERNET"
            else -> "UNKNOWN" // Connected, but type not recognized
        }
    }

    // Will change
    private fun getFreeDiskSpace(): Long {
        val stat = StatFs(Environment.getDataDirectory().path)
        val freeSpaceBytes = stat.availableBytes
        return freeSpaceBytes / (1024 * 1024 * 1024)
    }
}
