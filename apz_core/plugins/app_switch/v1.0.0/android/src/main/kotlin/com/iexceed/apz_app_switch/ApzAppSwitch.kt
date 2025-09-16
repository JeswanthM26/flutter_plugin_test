package com.iexceed.apz_app_switch
import android.app.Application
import android.os.Handler
import android.os.Looper
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import android.util.Log

/** ApzAppSwitch */
class ApzAppSwitch: FlutterPlugin, ActivityAware {

  /// The MethodChannel for direct calls from Flutter (e.g., initialization).
  private lateinit var methodChannel: MethodChannel

  /// The EventChannel for streaming lifecycle events to Flutter.
  private lateinit var eventChannel: EventChannel

  /// The Android Application instance, crucial for registering lifecycle callbacks.
  private var application: Application? = null

  /// The native lifecycle detector instance. This instance will be managed by the plugin.
  private var lifecycleDetector: ApzAppSwitchStateDetector? = null

  /// The EventSink to send events to Flutter. This is set when Flutter starts listening.
  private var eventSink: EventChannel.EventSink? = null

  /// A Handler to ensure events are sent on the main thread (Flutter requires this for EventChannel).
  private val handler = Handler(Looper.getMainLooper())

  /*
   * Defines the callback that `ApzAppSwitchStateDetector` will use to notify the plugin
   * about state changes. This callback then sends the event to Flutter.
   */
  private val appLifecycleStateCallback = object : AppLifecycleStateCallback {
      override fun onStateChanged(state: AppLifecycleState) {
          handler.post {
              eventSink?.success(state.name) 
          }
      }
  }

  /*
   * Called when the plugin is first attached to a FlutterEngine.
   * This is where MethodChannel and EventChannel are set up.
   */
  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    methodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "apz_app_switch_method")
    methodChannel.setMethodCallHandler { call, result ->
        if (call.method == "initialize") {
            result.success(null)
        } else {
            result.notImplemented()
        }
    }

    eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "apz_app_switch_events")
    eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
      
       // Called when a Flutter client starts listening to the event stream.
      
      override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events 

        // If the application context is already available and the detector hasn't been registered yet,
        // register it now. This handles cases where onListen occurs after onAttachedToActivity.
        application?.let { app ->
            if (lifecycleDetector == null) {
                lifecycleDetector = ApzAppSwitchStateDetector().apply {
                    register(app, appLifecycleStateCallback) // Use the defined callback
                }
            }
        } ?: run {
            // If app context is not ready, we cannot register the detector yet.
            // onAttachedToActivity will handle the registration later.
        }
      }

      /*
       * Called when a Flutter client stops listening to the event stream.
       */
      override fun onCancel(arguments: Any?) {
        eventSink = null 
        // It will just stop sending events to this specific Flutter stream.
      }
    })
  }

  /*
   * Called when the plugin is detached from a FlutterEngine.
   * Perform all necessary cleanup here.
   */
  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    methodChannel.setMethodCallHandler(null)
    eventChannel.setStreamHandler(null)

    // Unregister the native detector from the Application when the engine detaches.
    application?.let { app ->
        lifecycleDetector?.unregister(app)
    }
    // Clear all references to prevent memory leaks.
    application = null
    lifecycleDetector = null
    eventSink = null
  }

  /*
   * Called when the plugin is attached to an Activity.
   * This provides the `Application` instance needed for `ActivityLifecycleCallbacks`.
   */
  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    application = binding.activity.application

    // THIS IS THE CRITICAL SPOT: Register the native detector as soon as the application context is available.
    // Ensure it's only registered once.
    if (lifecycleDetector == null) {
        application?.let { app ->
            lifecycleDetector = ApzAppSwitchStateDetector().apply {
                register(app, appLifecycleStateCallback) // Use the defined callback
            }
        }
    }
  }

  /*
   * Called when the plugin is detached from an Activity due to configuration changes.
   * Perform cleanup similar to `onDetachedFromActivity`.
   */
  override fun onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity()
  }

  /*
   * Called when the plugin is re-attached to an Activity after a configuration change.
   */
  override fun onReattachedToActivityForConfigChanges(@NonNull binding: ActivityPluginBinding) {
    onAttachedToActivity(binding)
  }

  /*
   * Called when the plugin is detached from an Activity.
   * Important for cleanup to prevent memory leaks across activity lifecycles.
   */
  override fun onDetachedFromActivity() {
    application?.let { app ->
      lifecycleDetector?.unregister(app)
      Log.d("ApzAppSwitch", "onDetachedFromActivity")
    }
    // Clear the application reference
    application = null
  }
}
