package com.iexceed.apz_call_state
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel

class CallState : FlutterPlugin, EventChannel.StreamHandler {
    private lateinit var channel: EventChannel
    private var handler: CallStateHandler? = null
    private var applicationContext: android.content.Context? = null

    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = binding.applicationContext
        channel = EventChannel(binding.binaryMessenger, "call_state_events")
        channel.setStreamHandler(this)
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        if (events != null && applicationContext != null) {
            handler = CallStateHandler(applicationContext!!, events)
            handler?.startListening()
        }
    }

    override fun onCancel(arguments: Any?) {
        handler?.stopListening()
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        handler?.stopListening()
    }
}

