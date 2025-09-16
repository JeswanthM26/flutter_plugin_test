package com.iexceed.apz_peripherals

import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothAdapter
import android.nfc.NfcManager
import android.nfc.NfcAdapter

/** ApzPeripheralsPlugin */
class ApzPeripheralsPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private val CHANNEL = "apz_peripherals"
  private lateinit var context: Context

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL)
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    if (call.method == "getBatteryLevel") {
      val batteryLevel = getBatteryLevel()
      if (batteryLevel != -1) {
        result.success(batteryLevel)
      } else {
        result.error("UNAVAILABLE", "Battery level not available.", null)
      }
    } else if (call.method == "isBluetoothSupported") {
      val isBluetoothSupported = isBluetoothSupported();
      if(isBluetoothSupported) {
        result.success(isBluetoothSupported);
      } else {
        result.error("UNAVAILABLE", "Bluetooth not supported.", null)
      }
    } else if (call.method == "isNFCSupported") {
      val isNFCSupported = isNFCSupported();
      if(isNFCSupported) {
        result.success(isNFCSupported);
      } else {
        result.error("UNAVAILABLE", "NFC not supported.", null)
      }
    } else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  private fun getBatteryLevel(): Int {
    val batteryLevel: Int
    if (VERSION.SDK_INT >= VERSION_CODES.LOLLIPOP) {
      val batteryManager = context.getSystemService(Context.BATTERY_SERVICE) as BatteryManager
      batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
    } else {
      val intent = ContextWrapper(context).registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
      batteryLevel = intent!!.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) * 100 / intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
    }
    return batteryLevel
  }

  private fun isBluetoothSupported(): Boolean {
    val bluetoothManager: BluetoothManager = context.getSystemService(BluetoothManager::class.java)
    val bluetoothAdapter: BluetoothAdapter? = bluetoothManager.getAdapter()
    if (bluetoothAdapter == null) {
      // Device doesn't support Bluetooth
      return false;
    }
    return true;
  }

  private fun isNFCSupported(): Boolean {
    val nfcManager = context.getSystemService(Context.NFC_SERVICE) as NfcManager?
    val nfcAdapter: NfcAdapter? = nfcManager?.defaultAdapter
    if (nfcAdapter == null) {
      // Device doesn't support NFC
      return false;
    }
    return true;
  }
}

