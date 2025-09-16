package com.iexceed.apz_play_integrity

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class ApzPlayIntegrity : FlutterPlugin, MethodChannel.MethodCallHandler {

    private lateinit var channel: MethodChannel
    private lateinit var classicHandler: ClassicIntegrityHandler
    private lateinit var standardHandler: StandardIntegrityHandler

    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        val context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "play_integrity_plugin")
        channel.setMethodCallHandler(this)
        classicHandler = ClassicIntegrityHandler(context)
        standardHandler = StandardIntegrityHandler(context)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "requestClassicIntegrityToken" -> classicHandler.requestClassicIntegrityToken(call, result)
            "prepareStandardIntegrityToken" -> standardHandler.prepareStandardIntegrityToken(call, result)
            "requestStandardIntegrityToken" -> standardHandler.requestStandardIntegrityToken(call, result)
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}