package com.iexceed.apz_universal_linking
import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import android.util.Log

class UniversalLinking : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {
  
    var channel: MethodChannel? = null
    private var initialLink: String? = null
    private var activity: Activity? = null

    fun handleIntent(intent: Intent?) {
        val data: Uri? = intent?.data
        data?.let {
            initialLink = it.toString() 

             // Extract query parameters
            val queryParams = mutableMapOf<String, String>()
            for (key in it.queryParameterNames) {
                queryParams[key] = it.getQueryParameter(key) ?: ""
            }
            val linkMap = mapOf(
                "host" to (it.host ?: ""),
                "path" to (it.path ?: ""),
                "scheme" to (it.scheme ?: ""),
                "fullUrl" to it.toString(),
                "queryParams" to queryParams
            )
               
            Log.d("UNIVERSAL_LINK", "Link received: $linkMap")
                Handler(Looper.getMainLooper()).post {
                channel?.invokeMethod("onLinkReceived", linkMap)
            }
        }
    }



    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "apz_universal_linking")
        channel?.setMethodCallHandler(this)
    }

   override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method == "getInitialLink") {
            val uri = initialLink?.let { Uri.parse(it) }
            result.success(
                uri?.let {
                    val queryParams = mutableMapOf<String, String>()
                    for (key in it.queryParameterNames) {
                        queryParams[key] = it.getQueryParameter(key) ?: ""
                    }
                    mapOf(
                        "host" to (it.host ?: ""),
                        "path" to (it.path ?: ""),
                        "scheme" to (it.scheme ?: ""),
                        "fullUrl" to it.toString(),
                        "queryParams" to queryParams
                    )
                }
            )
        } else {
            result.notImplemented()
        }
    }


    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        handleIntent(activity?.intent)
        binding.addOnNewIntentListener {
            handleIntent(it)
            true
        }
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }
}

