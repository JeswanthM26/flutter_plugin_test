package com.iexceed.apz_call_state

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.telephony.PhoneStateListener
import android.telephony.TelephonyCallback
import android.telephony.TelephonyManager
import android.util.Log
import androidx.core.app.ActivityCompat
import io.flutter.plugin.common.EventChannel

class CallStateHandler(
    private val context: Context,
    private val events: EventChannel.EventSink
) {
    private var telephonyManager: TelephonyManager? = null
    private var phoneStateListener: PhoneStateListener? = null
    private var telephonyCallback: TelephonyCallback? = null

    // Track last known state in plugin
    private var lastState: Int = TelephonyManager.CALL_STATE_IDLE

    fun startListening() {
        telephonyManager =
            context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager

        if (ActivityCompat.checkSelfPermission(
                context,
                Manifest.permission.READ_PHONE_STATE
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            events.error("PERMISSION_DENIED", "READ_PHONE_STATE permission not granted", null)
            return
        }

        // 1️⃣ Emit initial state snapshot
        emitInitialState()

        // 2️⃣ Register listeners for live updates
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            telephonyCallback = object : TelephonyCallback(), TelephonyCallback.CallStateListener {
                override fun onCallStateChanged(state: Int) {
                    handleCallState(state)
                }
            }
            telephonyManager?.registerTelephonyCallback(
                context.mainExecutor,
                telephonyCallback as TelephonyCallback
            )
            Log.d("CallStateHandler", "Listening with TelephonyCallback")
        } else {
            phoneStateListener = object : PhoneStateListener() {
                override fun onCallStateChanged(state: Int, phoneNumber: String?) {
                    handleCallState(state)
                }
            }
            telephonyManager?.listen(phoneStateListener, PhoneStateListener.LISTEN_CALL_STATE)
            Log.d("CallStateHandler", "Listening with PhoneStateListener")
        }
    }

    fun stopListening() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            telephonyCallback?.let {
                telephonyManager?.unregisterTelephonyCallback(it)
            }
        } else {
            phoneStateListener?.let {
                telephonyManager?.listen(it, PhoneStateListener.LISTEN_NONE)
            }
        }
    }

    // -----------------------
    // Handle live updates
    // -----------------------
    private fun handleCallState(state: Int) {
        if (state == lastState) return
        events.success(mapState(state, lastState))
        lastState = state
    }

    // -----------------------
    // Emit initial snapshot state (No false outgoing)
    // -----------------------
    private fun emitInitialState() {
        val currentState = telephonyManager?.callState ?: TelephonyManager.CALL_STATE_IDLE

        when (currentState) {
            TelephonyManager.CALL_STATE_RINGING -> {
                events.success("incoming")
            }
            TelephonyManager.CALL_STATE_OFFHOOK -> {
                // ✅ Always treat OFFHOOK as "active" when initializing (no false outgoing)
                events.success("active")
            }
            TelephonyManager.CALL_STATE_IDLE -> {
                events.success("disconnected")
            }
        }

        lastState = currentState
    }

    // -----------------------
    // Map current + previous state to correct call state
    // -----------------------
    private fun mapState(current: Int, prev: Int): String {
        return when (current) {
            TelephonyManager.CALL_STATE_IDLE -> "disconnected"
            TelephonyManager.CALL_STATE_RINGING -> "incoming"
            TelephonyManager.CALL_STATE_OFFHOOK -> {
                when (prev) {
                    TelephonyManager.CALL_STATE_RINGING -> "active"  // answered incoming
                    TelephonyManager.CALL_STATE_IDLE -> "outgoing"   // new outgoing
                    else -> "active"                                 // already in call
                }
            }
            else -> "disconnected"
        }
    }
}
