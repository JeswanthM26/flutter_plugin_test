package com.iexceed.apz_app_shortcuts

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.ShortcutInfo
import android.content.pm.ShortcutManager
import android.graphics.drawable.Icon
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

class ApzAppShortcuts: FlutterPlugin, MethodCallHandler, ActivityAware {
  private lateinit var channel: MethodChannel
  private var context: Context? = null
  private var activity: Activity? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.iexceed/apz_app_shortcuts")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    if (call.method == "setShortcutItems") {
      val shortcuts = (call.arguments as List<Map<String, String>>).map {
        val launchIntent = context!!.packageManager.getLaunchIntentForPackage(context!!.packageName)?.apply {
          action = Intent.ACTION_VIEW
          putExtra("shortcut_id", it["id"])
        }

        ShortcutInfo.Builder(context!!, it["id"]!!)
          .setShortLabel(it["title"]!!)
          .setIcon(Icon.createWithResource(context!!, getIconId(it["icon"])))
          .setIntent(launchIntent!!)
          .build()
      }

      val shortcutManager = context!!.getSystemService(ShortcutManager::class.java)
      shortcutManager.dynamicShortcuts = shortcuts

      result.success(null)
    } else if (call.method == "clearShortcutItems") {
        val shortcutManager = context!!.getSystemService(ShortcutManager::class.java)
        shortcutManager.removeAllDynamicShortcuts()
        result.success(null)
    } else {
      result.notImplemented()
    }
  }

  private fun getIconId(name: String?): Int {
    return context!!.resources.getIdentifier(name ?: "ic_launcher", "drawable", context!!.packageName)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivity() {
    // Do Nothing
  }
  override fun onDetachedFromActivityForConfigChanges() {
    // Do Nothing
  }
  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}