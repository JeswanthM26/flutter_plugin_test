package com.iexceed.apz_screen_security

import android.app.Activity
import android.view.WindowManager
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** ApzScreenSecurity */
class ApzScreenSecurity: FlutterPlugin, MethodCallHandler, ActivityAware {
  private lateinit var methodChannel : MethodChannel
  private var activity: Activity? = null 

  // --- FlutterPlugin methods ---
  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    methodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "apz_screen_security")
    methodChannel.setMethodCallHandler(this)
  }
  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    methodChannel.setMethodCallHandler(null)
  }
  // --- End FlutterPlugin methods ---

  // --- ActivityAware methods ---
  override fun onAttachedToActivity(@NonNull binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivity() {
    activity = null
  }

  // --- REQUIRED: Implementations for ActivityAware for configuration changes ---
  // These two methods are mandatory when implementing ActivityAware,
  override fun onDetachedFromActivityForConfigChanges() {
    activity = null
  }

  override fun onReattachedToActivityForConfigChanges(@NonNull binding: ActivityPluginBinding) {
    activity = binding.activity
   
  }
  // --- End ActivityAware implementations ---

  // --- MethodCallHandler methods ---
  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    val currentActivity = activity // Use a local variable to ensure null-safety within this block

    if (currentActivity == null) {
      // If no activity is attached, return an error.
      result.error("NO_ACTIVITY", "No activity attached to the plugin.", null)
      return
    }

    when (call.method) {
      "enableSecure" -> {
        // Set the FLAG_SECURE window flag to prevent screenshots and screen recording.
        currentActivity.window?.setFlags(WindowManager.LayoutParams.FLAG_SECURE, WindowManager.LayoutParams.FLAG_SECURE)
        result.success(true)
      }
      "disableSecure" -> {
        // Clear the FLAG_SECURE window flag.
        currentActivity.window?.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
        result.success(true)
      }
      "isScreenCaptured" -> {
        // This method checks if the FLAG_SECURE is currently active on the window.
        // It does NOT detect if a screenshot has just been taken.
        val isSecureFlagSet = (currentActivity.window?.attributes?.flags ?: 0) and WindowManager.LayoutParams.FLAG_SECURE != 0
        result.success(isSecureFlagSet)
      }
      else -> {
        // If the method is not recognized, indicate it's not implemented.
        result.notImplemented()
      }
    }
  }
  // --- End MethodCallHandler methods ---
}
