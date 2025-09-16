package com.iexceed.apz_datepicker

import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.fragment.app.FragmentActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.text.SimpleDateFormat
import java.util.*

class ApzDatepicker : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private var activity: FragmentActivity? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "com.iexceed/date_picker")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity as? FragmentActivity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity as? FragmentActivity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method == "showDatePicker") {
            val initialMillis = call.argument<Long>("initialDate") ?: System.currentTimeMillis()
            val minMillis = call.argument<Long>("minDate")
            val maxMillis = call.argument<Long>("maxDate")
            val cancelText = call.argument<String>("cancelText")?: "Cancel"
            val doneText = call.argument<String>("doneText") ?: "OK"
            val primaryColor = call.argument<Number>("primaryColor")?.toLong()
            val errorColor = call.argument<Number>("errorColor")?.toLong()
            val dateFormat = call.argument<String>("dateFormat")?: "dd-MM-yyyy"
            val languageCode = call.argument<String>("languageCode") ?: "en"


            // Ensure you have an activity reference and it's a FragmentActivity
            val currentActivity = activity // 'activity' is your FragmentActivity reference
            if (currentActivity is FragmentActivity) {
                val datePickerFragment = ComposeDatePickerDialogFragment.newInstance(
                    initialMillis,
                    minMillis,
                    maxMillis,
                    cancelText,
                    doneText,
                    primaryColor,
                    errorColor,
                    dateFormat,
                    languageCode
                )
                datePickerFragment.onDateSelected = { selectedDate ->
                val formattedDate = SimpleDateFormat(dateFormat, Locale.getDefault())
                    .format(Date(selectedDate))
                result.success(formattedDate)

                    result.success(selectedDate) // Send selected date back to Flutter
                }
                datePickerFragment.onDismiss = {
                    result.success(null) // Or result.error, or a specific value for dismissal
                }
                datePickerFragment.show(currentActivity.supportFragmentManager, "date_picker_dialog")
            } else {
                result.error("UNAVAILABLE", "Activity is not a FragmentActivity", null)
            }
        } else {
             // It's good practice to handle unknown methods
             result.notImplemented()
        }
    }
}