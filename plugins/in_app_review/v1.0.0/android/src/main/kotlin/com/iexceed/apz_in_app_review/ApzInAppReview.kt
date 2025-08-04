package com.iexceed.apz_in_app_review

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

/** ApzInAppReview */
class ApzInAppReview : FlutterPlugin, MethodCallHandler, ActivityAware {
  private lateinit var channel: MethodChannel
  private lateinit var context: Context
  private var activity: Activity? = null

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.iexceed/in_app_review")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onAttachedToActivity(flutterPluginBinding: ActivityPluginBinding) {
    activity = flutterPluginBinding.activity
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    val manager = ReviewManagerFactory.create(context)
    when (call.method) {
      "requestReview" -> {
        val currentActivity = activity
        if (currentActivity == null) {
          result.error("ACTIVITY_UNAVAILABLE", "Activity is not attached to the plugin.", null)
          return
        }
        val request = manager.requestReviewFlow()
        request.addOnCompleteListener { task ->
          if (task.isSuccessful) {
            val reviewInfo = task.result
            manager.launchReviewFlow(currentActivity, reviewInfo).addOnCompleteListener { launchTask
              ->
              if (launchTask.isSuccessful) {
                result.success(null)
              } else {
                result.error("LAUNCH_FAILED", "Failed to launch review flow UI.", null)
              }
            }
          } else {
            result.error("UNAVAILABLE", "Review not available", null)
          }
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
}
