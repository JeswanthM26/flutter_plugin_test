package com.iexceed.apz_send_sms

import android.content.Context
import android.content.Intent
import android.net.Uri
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

class ApzSendSMS : FlutterPlugin, MethodCallHandler {

  private lateinit var channel: MethodChannel
  private lateinit var context: Context

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.iexceed/apz_send_sms")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      "sendSMS" -> {
        val number = call.argument<String>("number") ?: ""
        val message = call.argument<String>("message") ?: ""

        if (number.isEmpty()) {
          result.error("INVALID_ARGUMENTS", "Phone number is required", null)
          return
        }

        try {
          val intent = Intent(Intent.ACTION_SENDTO)
          intent.data = Uri.parse("smsto:$number")
          intent.putExtra("sms_body", message)

          if (intent.resolveActivity(context.packageManager) != null) {
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            context.startActivity(intent)
            result.success("launched")
          } else {
            result.error("NO_SMS_APP", "No SMS app found", null)
          }
        } catch (e: Exception) {
          result.error("SEND_SMS_ERROR", e.localizedMessage, null)
        }
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}